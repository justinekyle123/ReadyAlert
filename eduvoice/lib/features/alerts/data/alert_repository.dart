import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/role_permissions.dart';
import '../domain/models/alert_activity.dart';
import '../domain/models/alert_level.dart';

/// Stores and reads tri-alarm history.
///
/// Visibility follows the sender's role: hosts see every alert, while leaders
/// and members see school-wide broadcasts plus their own group's alerts. Live
/// alerts are scoped the same way, so a leader's alert only rings its group.
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
      columns: ['created_by'],
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

    final id = await db.insert('alerts', {
      'level': level.name,
      'title': activity.title,
      'detail': activity.detail,
      'occurred_at': now.toIso8601String(),
      'is_unread': 0,
      'group_id': groupId,
      'created_by': sender.id,
    });

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

  static String broadcastTitle(AlertLevel level) => switch (level) {
    AlertLevel.green => 'All clear broadcast',
    AlertLevel.yellow => 'Caution alert broadcast',
    AlertLevel.red => 'Emergency alert broadcast',
  };

  Future<String> _groupName(Database db, int? groupId) async {
    if (groupId == null) {
      return 'your group';
    }
    final rows = await db.query(
      'volunteer_groups',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    return rows.isEmpty ? 'your group' : rows.first['name'] as String;
  }
}
