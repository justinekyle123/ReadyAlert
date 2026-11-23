import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/firebase/cloud_alert_sync.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/role_permissions.dart';
import '../domain/models/alert_activity.dart';
import '../domain/models/alert_level.dart';

/// Stores and reads tri-alarm history.
///
/// Visibility follows the sender's role: hosts see every alert, while leaders
/// and members see school-wide broadcasts plus their own group's alerts. Live
/// alerts are scoped the same way, so a leader's alert only rings its group.
///
/// When Firebase is configured, broadcasts are also published to Firestore and
/// live updates from other devices are merged into the local database. Without
/// Firebase every method keeps working entirely offline.
class AlertRepository {
  AlertRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const String _scopedWhere =
      'group_id IS NULL OR group_id = ? OR created_by = ?';

  Future<List<AlertActivity>> historyFor(AppUser user) async {
    final permissions = RolePermissions.of(user);
    final db = await _database.database;

    final rows = permissions.canSeeAllGroups
        ? await db.query('alerts', orderBy: 'occurred_at DESC')
        : await db.query(
            'alerts',
            where: _scopedWhere,
            whereArgs: [user.groupId ?? -1, user.id],
            orderBy: 'occurred_at DESC',
          );

    return rows.map(AlertActivity.fromMap).toList();
  }

  /// The live alert [user] should be reacting to, or null when nothing is
  /// active for them.
  ///
  /// An alert is live until its sender ends it. Members of the sending
  /// leader's group receive it; hosts receive school-wide broadcasts. A member
  /// who has stopped an alert on their own account does not see it again.
  Future<AlertActivity?> liveAlertFor(AppUser user) async {
    final permissions = RolePermissions.of(user);
    final db = await _database.database;

    final rows = await db.rawQuery(
      '''
      SELECT a.* FROM alerts a
      WHERE a.ended_at IS NULL
        AND ${permissions.canSeeAllGroups ? 'a.group_id IS NULL' : '(a.group_id IS NULL OR a.group_id = ?)'}
        AND NOT EXISTS (
          SELECT 1 FROM alert_dismissals d
          WHERE d.alert_id = a.id AND d.user_id = ?
        )
      ORDER BY a.occurred_at DESC
      LIMIT 1
      ''',
      permissions.canSeeAllGroups
          ? [user.id]
          : [user.groupId ?? -1, user.id],
    );

    return rows.isEmpty ? null : AlertActivity.fromMap(rows.first);
  }

  /// Whether [user] has muted the siren on this account.
  Future<bool> isSirenMuted(AppUser user) async {
    final db = await _database.database;
    final rows = await db.query(
      'alert_preferences',
      columns: ['siren_muted'],
      where: 'user_id = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    return rows.isNotEmpty && (rows.first['siren_muted'] as int? ?? 0) == 1;
  }

  /// Remembers a member's mute choice across sign-ins.
  Future<void> setSirenMuted(AppUser user, bool muted) async {
    final db = await _database.database;
    await db.insert('alert_preferences', {
      'user_id': user.id,
      'siren_muted': muted ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Stops [alertId] for [user].
  ///
  /// The sender ends the alert for the whole group; anyone else in the group
  /// only dismisses it on their own account.
  Future<void> stopAlert({
    required AppUser user,
    required int alertId,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'alerts',
      columns: ['created_by', 'remote_id'],
      where: 'id = ?',
      whereArgs: [alertId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return;
    }

    if (rows.first['created_by'] == user.id) {
      await db.update(
        'alerts',
        {'ended_at': DateTime.now().toIso8601String()},
        where: 'id = ? AND ended_at IS NULL',
        whereArgs: [alertId],
      );
      final remoteId = rows.first['remote_id'] as String?;
      if (remoteId != null) {
        await _endRemoteSilently(remoteId);
      }
      return;
    }

    await db.insert('alert_dismissals', {
      'alert_id': alertId,
      'user_id': user.id,
      'dismissed_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Stores a broadcast from [sender] and returns the saved activity.
  ///
  /// Hosts reach every group, leaders reach only their own group, and members
  /// are rejected.
  Future<AlertActivity> broadcast({
    required AppUser sender,
    required AlertLevel level,
  }) async {
    final permissions = RolePermissions.of(sender);
    if (!permissions.canBroadcastAlerts) {
      throw StateError('${sender.role.label} accounts cannot send alerts.');
    }

    final db = await _database.database;
    final now = DateTime.now();
    final groupId = permissions.canBroadcastToAllGroups ? null : sender.groupId;
    if (groupId == null && !permissions.canBroadcastToAllGroups) {
      throw StateError(
        '${sender.role.label} accounts need a group before sending alerts.',
      );
    }
    final scope = permissions.canBroadcastToAllGroups
        ? 'all volunteer groups'
        : await _groupName(db, groupId);

    final activity = AlertActivity(
      level: level,
      title: broadcastTitle(level),
      detail: '${sender.name} · $scope',
      occurredAt: now,
    );

    // Stable across the sending device and Firestore, so the snapshot stream
    // recognises its own document instead of importing a duplicate.
    final remoteId = 'a${sender.id}_${now.microsecondsSinceEpoch}';

    final id = await db.insert('alerts', {
      'level': level.name,
      'title': activity.title,
      'detail': activity.detail,
      'occurred_at': now.toIso8601String(),
      'remote_id': remoteId,
      'is_unread': 0,
      'group_id': groupId,
      'created_by': sender.id,
    });

    if (CloudAlertSync.instance.enabled) {
      final groupName = groupId == null
          ? null
          : await _savedGroupName(db, groupId);
      unawaited(
        _publishSilently(
          remoteId: remoteId,
          activity: activity,
          groupName: groupName,
          sender: sender,
        ),
      );
    }

    return activity.copyWith(id: id);
  }

  Future<void> markRead(AppUser user, int alertId) async {
    final db = await _database.database;
    await db.update(
      'alerts',
      {'is_unread': 0},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  Future<void> markAllRead(AppUser user) async {
    final permissions = RolePermissions.of(user);
    final db = await _database.database;

    if (permissions.canSeeAllGroups) {
      await db.update('alerts', {'is_unread': 0}, where: 'is_unread = 1');
      return;
    }

    await db.update(
      'alerts',
      {'is_unread': 0},
      where: 'is_unread = 1 AND ($_scopedWhere)',
      whereArgs: [user.groupId ?? -1, user.id],
    );
  }

  Future<int> broadcastCount(AppUser user) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM alerts WHERE created_by = ?',
      [user.id],
    );
    return rows.first['total'] as int? ?? 0;
  }

  /// Emits whenever a remote device changes an alert this account can see.
  ///
  /// Each event has already been merged into SQLite by the time it is
  /// delivered, so screens only need to reload their queries. The stream is
  /// empty when Firebase is not configured.
  Stream<void> liveUpdates(AppUser user) async* {
    if (!CloudAlertSync.instance.enabled) {
      return;
    }

    final permissions = RolePermissions.of(user);
    final db = await _database.database;
    final groupName = permissions.canSeeAllGroups
        ? null
        : await _savedGroupName(db, user.groupId);

    await for (final remoteAlerts in CloudAlertSync.instance.watchRecent()) {
      var changed = false;
      for (final remote in remoteAlerts) {
        if (!permissions.canSeeAllGroups &&
            remote.groupName != null &&
            remote.groupName != groupName) {
          continue;
        }
        if (await _importRemote(remote)) {
          changed = true;
        }
      }
      if (changed) {
        yield null;
      }
    }
  }

  /// Merges one remote alert into the local history.
  ///
  /// Finished remote alerts only close an alert that is already known; they
  /// are not imported as new history on every device.
  Future<bool> _importRemote(RemoteAlert remote) async {
    final db = await _database.database;
    final existing = await db.query(
      'alerts',
      columns: ['id', 'ended_at'],
      where: 'remote_id = ?',
      whereArgs: [remote.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      if (remote.endedAt != null && existing.first['ended_at'] == null) {
        await db.update(
          'alerts',
          {'ended_at': remote.endedAt!.toIso8601String()},
          where: 'remote_id = ?',
          whereArgs: [remote.id],
        );
        return true;
      }
      return false;
    }

    if (remote.endedAt != null) {
      return false;
    }

    int? groupId;
    if (remote.groupName != null) {
      final groups = await db.query(
        'volunteer_groups',
        columns: ['id'],
        where: 'LOWER(name) = ?',
        whereArgs: [remote.groupName!.toLowerCase()],
        limit: 1,
      );
      if (groups.isEmpty) {
        // Another school's group, or one this device has not created yet.
        return false;
      }
      groupId = groups.first['id'] as int;
    }

    await db.insert('alerts', {
      'level': remote.level.name,
      'title': remote.title,
      'detail': remote.detail,
      'occurred_at': remote.occurredAt.toIso8601String(),
      'remote_id': remote.id,
      'is_unread': 1,
      'group_id': groupId,
      'created_by': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return true;
  }

  Future<void> _publishSilently({
    required String remoteId,
    required AlertActivity activity,
    required String? groupName,
    required AppUser sender,
  }) async {
    try {
      await CloudAlertSync.instance.publish(
        remoteId: remoteId,
        activity: activity,
        groupName: groupName,
        senderName: sender.name,
        senderSchoolId: sender.schoolId,
      );
    } on Object catch (error) {
      debugPrint('Alert $remoteId stayed local; Firebase publish failed: $error');
    }
  }

  Future<void> _endRemoteSilently(String remoteId) async {
    try {
      await CloudAlertSync.instance.end(remoteId);
    } on Object catch (error) {
      debugPrint('Alert $remoteId stayed local; Firebase end failed: $error');
    }
  }

  static String broadcastTitle(AlertLevel level) => switch (level) {
    AlertLevel.green => 'All clear broadcast',
    AlertLevel.yellow => 'Caution alert broadcast',
    AlertLevel.red => 'Emergency alert broadcast',
  };

  Future<String> _groupName(Database db, int? groupId) async {
    return await _savedGroupName(db, groupId) ?? 'your group';
  }

  Future<String?> _savedGroupName(Database db, int? groupId) async {
    if (groupId == null) {
      return null;
    }
    final rows = await db.query(
      'volunteer_groups',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['name'] as String;
  }
}
