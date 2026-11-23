import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/account_defaults.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/password_hash.dart';
import '../../../core/database/school_id.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/role_permissions.dart';
import '../domain/models/roster_exception.dart';
import '../domain/models/roster_models.dart';
import '../domain/models/volunteer_group.dart';
import 'group_repository.dart';

/// Writes to the local roster: new accounts, new groups and their leaders.
///
/// Every change is checked against the actor's role first, so the rules hold
/// even if a screen forgets to hide an action. Hosts create, assign and edit
/// every account and group; leaders and members cannot change the roster.
class RosterRepository {
  RosterRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  final Random _random = Random.secure();

  /// Creates a member or leader account with the default password.
  ///
  /// Only the host provisions accounts. Every account except a host belongs
  /// to exactly one group.
  Future<NewAccount> createUser({
    required AppUser actor,
    required String name,
    UserRole role = UserRole.member,
    int? groupId,
  }) async {
    if (!RolePermissions.of(actor).canAddUsers) {
      throw const RosterException('Only the host can add accounts.');
    }
    if (role == UserRole.host) {
      throw const RosterException(
        'A school has one host account; add this person as a member or leader.',
      );
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const RosterException("Enter the volunteer's full name.");
    }
    if (groupId == null) {
      throw RosterException(
        role == UserRole.leader
            ? 'Choose the group this youth leader will lead.'
            : 'Choose the group this volunteer belongs to.',
      );
    }

    final db = await _database.database;
    final groupName = await _groupName(db, groupId);
    if (groupName == null) {
      throw const RosterException('That group no longer exists.');
    }
    if (role == UserRole.leader) {
      final rows = await db.query(
        'volunteer_groups',
        columns: ['leader_id'],
        where: 'id = ?',
        whereArgs: [groupId],
        limit: 1,
      );
      if (rows.first['leader_id'] != null) {
        throw RosterException(
          '$groupName already has a leader. Change it from the Groups tab.',
        );
      }
    }

    final identifier = await _uniqueSchoolId(db, schoolIdFor(trimmed));
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => _random.nextInt(256)),
    );
    final about = switch (role) {
      UserRole.leader => 'Youth volunteer leader for $groupName.',
      _ => 'Volunteer with $groupName, added to the roster by ${actor.name}.',
    };

    final id = await db.insert('users', {
      'name': trimmed,
      'school_id': identifier,
      'email': '$identifier@$defaultSchoolEmailDomain',
      'password_salt': salt,
      'password_hash': hashPassword(defaultAccountPassword, salt),
      'role': role.name,
      'school': actor.school,
      'group_id': groupId,
      'about': about,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (role == UserRole.leader) {
      await _applyLeader(db, groupId: groupId, userId: id);
    }

    return NewAccount(
      user: AppUser(
        id: id,
        name: trimmed,
        role: role,
        school: actor.school,
        schoolId: identifier,
        groupId: groupId,
        about: about,
      ),
      schoolId: identifier,
    );
  }

  /// Renames an account, changes its role, or moves it to another group.
  ///
  /// Only the host edits accounts. A person's school ID never changes, so
  /// their sign-in details stay the same after an edit.
  Future<NewAccount> updateUser({
    required AppUser actor,
    required int userId,
    required String name,
    required UserRole role,
    int? groupId,
  }) async {
    if (!RolePermissions.of(actor).canEditUsers) {
      throw const RosterException('Only the host can edit accounts.');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const RosterException("Enter the volunteer's full name.");
    }

    final db = await _database.database;
    final targetRows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (targetRows.isEmpty) {
      throw const RosterException('That account no longer exists.');
    }

    final target = targetRows.first;
    final currentRole = UserRole.values.byName(target['role'] as String);
    final identifier = target['school_id'] as String;
    final about = target['about'] as String?;

    if (currentRole == UserRole.host) {
      if (role != UserRole.host) {
        throw const RosterException(
          'The host account cannot be changed to another role.',
        );
      }
      await db.update(
        'users',
        {'name': trimmed},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return NewAccount(
        user: AppUser(
          id: userId,
          name: trimmed,
          role: UserRole.host,
          school: actor.school,
          schoolId: identifier,
          about: about,
        ),
        schoolId: identifier,
      );
    }

    if (role == UserRole.host) {
      throw const RosterException(
        'A school has one host account; keep this person as a member or leader.',
      );
    }
    if (groupId == null) {
      throw const RosterException('Choose the group this volunteer belongs to.');
    }

    final groupRows = await db.query(
      'volunteer_groups',
      columns: ['id', 'name', 'leader_id'],
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    if (groupRows.isEmpty) {
      throw const RosterException('That group no longer exists.');
    }
    final groupName = groupRows.first['name'] as String;
    final previousLeaderId = groupRows.first['leader_id'] as int?;
    if (role == UserRole.leader &&
        previousLeaderId != null &&
        previousLeaderId != userId) {
      throw RosterException(
        '$groupName already has a leader. Change it from the Groups tab.',
      );
    }

    await db.transaction((txn) async {
      // Moving or demoting a leader releases the group they led.
      await txn.update(
        'volunteer_groups',
        {'leader_id': null},
        where: 'leader_id = ?',
        whereArgs: [userId],
      );

      if (role == UserRole.leader) {
        if (previousLeaderId != null && previousLeaderId != userId) {
          await txn.update(
            'users',
            {'role': UserRole.member.name},
            where: 'id = ? AND role = ?',
            whereArgs: [previousLeaderId, UserRole.leader.name],
          );
        }
        await txn.update(
          'volunteer_groups',
          {'leader_id': null},
          where: 'leader_id = ? AND id <> ?',
          whereArgs: [userId, groupId],
        );
        await txn.update(
          'volunteer_groups',
          {'leader_id': userId},
          where: 'id = ?',
          whereArgs: [groupId],
        );
      }

      await txn.update(
        'users',
        {'name': trimmed, 'role': role.name, 'group_id': groupId},
        where: 'id = ?',
        whereArgs: [userId],
      );
    });

    return NewAccount(
      user: AppUser(
        id: userId,
        name: trimmed,
        role: role,
        school: actor.school,
        schoolId: identifier,
        groupId: groupId,
        about: about,
      ),
      schoolId: identifier,
    );
  }

  /// Renames a group, updates its check-in status, and optionally assigns a
  /// new leader.
  Future<VolunteerGroup> updateGroup({
    required AppUser actor,
    required int groupId,
    required String name,
    required GroupReportStatus status,
    int? leaderId,
  }) async {
    if (!RolePermissions.of(actor).canEditGroups) {
      throw const RosterException('Only the host can edit groups.');
    }

    final trimmed = name.trim();
    if (trimmed.length < 3) {
      throw const RosterException(
        'Give the group a name of at least 3 characters.',
      );
    }

    final db = await _database.database;
    final groupRows = await db.query(
      'volunteer_groups',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    if (groupRows.isEmpty) {
      throw const RosterException('That group no longer exists.');
    }

    final duplicate = await db.query(
      'volunteer_groups',
      columns: ['id'],
      where: 'LOWER(name) = ? AND id <> ?',
      whereArgs: [trimmed.toLowerCase(), groupId],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw RosterException('A group named "$trimmed" already exists.');
    }

    late Map<String, Object?> savedRow;
    await db.transaction((txn) async {
      await txn.update(
        'volunteer_groups',
        {'name': trimmed, 'status': status.name},
        where: 'id = ?',
        whereArgs: [groupId],
      );

      if (leaderId != null) {
        final leaderRows = await txn.query(
          'users',
          columns: ['id', 'role'],
          where: 'id = ?',
          whereArgs: [leaderId],
          limit: 1,
        );
        if (leaderRows.isEmpty) {
          throw const RosterException('That account no longer exists.');
        }
        if (leaderRows.first['role'] == UserRole.host.name) {
          throw const RosterException('Hosts cannot lead a group.');
        }

        final current = await txn.query(
          'volunteer_groups',
          columns: ['leader_id'],
          where: 'id = ?',
          whereArgs: [groupId],
          limit: 1,
        );
        final previousLeaderId = current.first['leader_id'] as int?;
        if (previousLeaderId != null && previousLeaderId != leaderId) {
          await txn.update(
            'users',
            {'role': UserRole.member.name},
            where: 'id = ? AND role = ?',
            whereArgs: [previousLeaderId, UserRole.leader.name],
          );
        }
        await txn.update(
          'volunteer_groups',
          {'leader_id': null},
          where: 'leader_id = ? AND id <> ?',
          whereArgs: [leaderId, groupId],
        );
        await txn.update(
          'users',
          {'role': UserRole.leader.name, 'group_id': groupId},
          where: 'id = ?',
          whereArgs: [leaderId],
        );
        await txn.update(
          'volunteer_groups',
          {'leader_id': leaderId},
          where: 'id = ?',
          whereArgs: [groupId],
        );
      }

      // Read the saved group through the same transaction so the screen gets
      // a consistent row without a second database round trip.
      final saved = await txn.rawQuery(
        '${GroupRepository.groupQuery} WHERE g.id = ?',
        [groupId],
      );
      savedRow = saved.first;
    });

    return VolunteerGroup.fromRow(savedRow);
  }

  /// The volunteers inside [groupId], ordered by name.
  ///
  /// Hosts may read any group; leaders and members only their own.
  Future<List<AppUser>> membersForGroup({
    required AppUser actor,
    required int groupId,
  }) async {
    final permissions = RolePermissions.of(actor);
    if (!permissions.canSeeAllGroups && actor.groupId != groupId) {
      throw const RosterException('You can only see your own group.');
    }

    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'group_id = ? AND role <> ?',
      whereArgs: [groupId, UserRole.host.name],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(AppUser.fromMap).toList();
  }

  /// Creates a volunteer group, optionally with its first leader.
  Future<VolunteerGroup> createGroup({
    required AppUser actor,
    required String name,
    int? leaderId,
  }) async {
    if (!RolePermissions.of(actor).canAddGroups) {
      throw const RosterException('Only the host can create volunteer groups.');
    }

    final trimmed = name.trim();
    if (trimmed.length < 3) {
      throw const RosterException(
        'Give the group a name of at least 3 characters.',
      );
    }

    final db = await _database.database;
    final existing = await db.query(
      'volunteer_groups',
      columns: ['id'],
      where: 'LOWER(name) = ?',
      whereArgs: [trimmed.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw RosterException('A group named "$trimmed" already exists.');
    }

    final id = await db.insert('volunteer_groups', {
      'name': trimmed,
      'status': GroupReportStatus.awaiting.name,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (leaderId != null) {
      await _applyLeader(db, groupId: id, userId: leaderId);
    }

    final rows = await db.rawQuery(
      '${GroupRepository.groupQuery} WHERE g.id = ?',
      [id],
    );
    return VolunteerGroup.fromRow(rows.first);
  }

  /// Makes [userId] the leader of [groupId], moving them into the group.
  Future<void> assignLeader({
    required AppUser actor,
    required int groupId,
    required int userId,
  }) async {
    if (!RolePermissions.of(actor).canAssignLeaders) {
      throw const RosterException('Only the host can assign group leaders.');
    }
    final db = await _database.database;
    await _applyLeader(db, groupId: groupId, userId: userId);
  }

  /// Accounts that can lead a group: everyone except hosts.
  ///
  /// Members of [preferGroupId] come first so a group's own volunteers are the
  /// easiest ones to promote.
  Future<List<RosterContact>> leaderCandidates({
    required AppUser actor,
    int? preferGroupId,
  }) async {
    if (!RolePermissions.of(actor).canAssignLeaders) {
      throw const RosterException('Only the host can assign group leaders.');
    }

    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT u.*, g.name AS group_name
      FROM users u
      LEFT JOIN volunteer_groups g ON g.id = u.group_id
      WHERE u.role <> ?
      ORDER BY CASE WHEN u.group_id = ? THEN 0 ELSE 1 END,
               u.name COLLATE NOCASE
      ''',
      [UserRole.host.name, preferGroupId ?? -1],
    );

    return rows
        .map(
          (row) => RosterContact(
            user: AppUser.fromMap(row),
            groupName: row['group_name'] as String?,
          ),
        )
        .toList();
  }

  Future<void> _applyLeader(
    Database db, {
    required int groupId,
    required int userId,
  }) async {
    final groupRows = await db.query(
      'volunteer_groups',
      columns: ['id', 'leader_id'],
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    if (groupRows.isEmpty) {
      throw const RosterException('That group no longer exists.');
    }

    final userRows = await db.query(
      'users',
      columns: ['id', 'role'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) {
      throw const RosterException('That account no longer exists.');
    }
    if (userRows.first['role'] == UserRole.host.name) {
      throw const RosterException(
        'Hosts oversee every group and cannot lead one.',
      );
    }

    final previousLeaderId = groupRows.first['leader_id'] as int?;

    await db.transaction((txn) async {
      if (previousLeaderId != null && previousLeaderId != userId) {
        await txn.update(
          'users',
          {'role': UserRole.member.name},
          where: 'id = ? AND role = ?',
          whereArgs: [previousLeaderId, UserRole.leader.name],
        );
      }
      // A person leads one group at a time.
      await txn.update(
        'volunteer_groups',
        {'leader_id': null},
        where: 'leader_id = ? AND id <> ?',
        whereArgs: [userId, groupId],
      );
      await txn.update(
        'users',
        {'role': UserRole.leader.name, 'group_id': groupId},
        where: 'id = ?',
        whereArgs: [userId],
      );
      await txn.update(
        'volunteer_groups',
        {'leader_id': userId},
        where: 'id = ?',
        whereArgs: [groupId],
      );
    });
  }

  Future<String?> _groupName(Database db, int? groupId) async {
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

  Future<String> _uniqueSchoolId(Database db, String base) async {
    var candidate = base;
    var suffix = 2;
    while (await _schoolIdTaken(db, candidate)) {
      candidate = '$base$suffix';
      suffix++;
    }
    return candidate;
  }

  Future<bool> _schoolIdTaken(Database db, String schoolId) async {
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'LOWER(school_id) = ?',
      whereArgs: [schoolId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
