import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import 'account_defaults.dart';
import 'password_hash.dart';
import 'school_id.dart';

/// Demo school and shared seed password for every seeded account.
const String seedSchool = defaultSchoolName;
const String seedPassword = defaultAccountPassword;

const String _hostName = 'Juan Dela Cruz';

const String _hostAbout =
    'Host for the Polomolok National High School earthquake readiness '
    'program. I run the tri-alarm broadcasts, keep the volunteer rosters '
    'current, and make sure every group knows the assembly plan before the '
    'next shake. Outside of drills I help train new volunteers on first aid '
    'basics and radio handover.';

class _SeedGroup {
  const _SeedGroup({
    required this.name,
    required this.status,
    required this.leader,
    required this.members,
  });

  final String name;
  final String status;
  final String leader;
  final List<String> members;
}

const List<_SeedGroup> _seedGroups = [
  _SeedGroup(
    name: 'Red Cross Youth A',
    status: 'safe',
    leader: 'Maria Santos',
    members: [
      'Andrea Bautista',
      'Carlo Mendoza',
      'Divine Ramos',
      'Elijah Torres',
      'Faith Villanueva',
      'Gabriel Aquino',
      'Hannah Salazar',
      'Ian Navarro',
      'Jasmine Dizon',
      'Kevin Padilla',
      'Liza Fernandez',
    ],
  ),
  _SeedGroup(
    name: 'Red Cross Youth B',
    status: 'awaiting',
    leader: 'Jose Reyes',
    members: [
      'Miguel Castro',
      'Nicole Uy',
      'Oliver Garcia',
      'Patricia Lim',
      'Queenie Ramos',
      'Rafael Domingo',
      'Sofia Alonzo',
      'Tobias Rivera',
      'Ursula Bello',
    ],
  ),
  _SeedGroup(
    name: 'Boy Scouts Troop 1',
    status: 'safe',
    leader: 'Ana Cruz',
    members: [
      'Victor Pascual',
      'Wilma Espino',
      'Xavier Tan',
      'Yvonne Mercado',
      'Zander Ocampo',
      'Althea Rosales',
      'Benedict Silva',
    ],
  ),
  _SeedGroup(
    name: 'Boy Scouts Troop 2',
    status: 'safe',
    leader: 'Mark Lim',
    members: [
      'Carmela Reyes',
      'Dominic Chan',
      'Erika Lopez',
      'Francis Chua',
      'Grace Ong',
    ],
  ),
];

class _SeedSkill {
  const _SeedSkill(this.label, this.iconKey, this.tint);

  final String label;
  final String iconKey;
  final String tint;
}

const List<_SeedSkill> _seedSkills = [
  _SeedSkill('First aid', 'first_aid', 'coral'),
  _SeedSkill('Radio comms', 'radio', 'green'),
  _SeedSkill('Evacuation', 'evacuation', 'yellow'),
  _SeedSkill('Drills', 'drills', 'red'),
  _SeedSkill('Reporting', 'reporting', 'green'),
  _SeedSkill('Logistics', 'logistics', 'muted'),
];

class _SeedAlert {
  const _SeedAlert({
    required this.level,
    required this.title,
    required this.detail,
    required this.at,
    required this.by,
    this.groupName,
    this.unread = false,
  });

  final String level;
  final String title;
  final String detail;
  final DateTime at;
  final String by;
  final String? groupName;
  final bool unread;
}

/// Creates the schema and fills it with the school's demo roster and history.
Future<void> seedDatabase(Database db) async {
  await _createSchema(db);

  final now = DateTime.now();
  final createdAt = now.toIso8601String();
  final random = Random.secure();

  final groupIds = <String, int>{};
  for (final group in _seedGroups) {
    groupIds[group.name] = await db.insert('volunteer_groups', {
      'name': group.name,
      'status': group.status,
      'created_at': createdAt,
    });
  }

  final userIds = <String, int>{};

  Future<int> insertUser({
    required String name,
    required String role,
    required String about,
    String? groupName,
    String? schoolId,
  }) async {
    final identifier = schoolId ?? schoolIdFor(name);
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    final userId = await db.insert('users', {
      'name': name,
      'school_id': identifier,
      'email': '$identifier@$defaultSchoolEmailDomain',
      'password_salt': salt,
      'password_hash': hashPassword(seedPassword, salt),
      'role': role,
      'school': seedSchool,
      'group_id': groupName == null ? null : groupIds[groupName],
      'about': about,
      'created_at': createdAt,
    });
    userIds[name] = userId;
    return userId;
  }

  await insertUser(
    name: _hostName,
    role: 'host',
    schoolId: 'juan.delacruz',
    about: _hostAbout,
  );

  for (final group in _seedGroups) {
    final leaderId = await insertUser(
      name: group.leader,
      role: 'leader',
      groupName: group.name,
      about:
          'Youth volunteer leader for ${group.name}. I keep the roster '
          'complete, run check-ins during drills, and report our status to '
          'the host.',
    );
    await db.update(
      'volunteer_groups',
      {'leader_id': leaderId},
      where: 'id = ?',
      whereArgs: [groupIds[group.name]],
    );

    for (final member in group.members) {
      await insertUser(
        name: member,
        role: 'member',
        groupName: group.name,
        about:
            'Volunteer with ${group.name}, trained in first aid and '
            'evacuation basics for earthquake emergencies.',
      );
    }
  }

  final skillBatch = db.batch();
  for (final userId in userIds.values) {
    for (var index = 0; index < _seedSkills.length; index++) {
      final skill = _seedSkills[index];
      skillBatch.insert('user_skills', {
        'user_id': userId,
        'label': skill.label,
        'icon_key': skill.iconKey,
        'tint': skill.tint,
        'sort_order': index,
      });
    }
  }
  await skillBatch.commit(noResult: true);

  final startOfToday = DateTime(now.year, now.month, now.day);
  final yesterday = startOfToday.subtract(const Duration(days: 1));

  final alertBatch = db.batch();
  for (final alert in _seedAlerts(now, yesterday, startOfToday)) {
    alertBatch.insert('alerts', {
      'level': alert.level,
      'title': alert.title,
      'detail': alert.detail,
      'occurred_at': alert.at.toIso8601String(),
      // Seeded history is finished; only new broadcasts start live.
      'ended_at': alert.at.toIso8601String(),
      'is_unread': alert.unread ? 1 : 0,
      'group_id': alert.groupName == null ? null : groupIds[alert.groupName],
      'created_by': userIds[alert.by],
    });
  }
  await alertBatch.commit(noResult: true);
}

List<_SeedAlert> _seedAlerts(
  DateTime now,
  DateTime yesterday,
  DateTime startOfToday,
) {
  return [
    _SeedAlert(
      level: 'green',
      title: 'All clear confirmed',
      detail: 'Juan Dela Cruz · all volunteer groups',
      at: now.subtract(const Duration(minutes: 8)),
      by: _hostName,
      unread: true,
    ),
    _SeedAlert(
      level: 'red',
      title: 'Emergency alert broadcast',
      detail: 'Juan Dela Cruz · all volunteer groups',
      at: now.subtract(const Duration(minutes: 12)),
      by: _hostName,
      unread: true,
    ),
    _SeedAlert(
      level: 'yellow',
      title: 'Caution raised for Red Cross Youth B',
      detail: 'Jose Reyes · Red Cross Youth B',
      at: now.subtract(const Duration(minutes: 23)),
      by: 'Jose Reyes',
      groupName: 'Red Cross Youth B',
      unread: true,
    ),
    _SeedAlert(
      level: 'green',
      title: 'Group check-in completed',
      detail: 'Maria Santos · 12 members accounted for',
      at: now.subtract(const Duration(minutes: 41)),
      by: 'Maria Santos',
      groupName: 'Red Cross Youth A',
    ),
    _SeedAlert(
      level: 'green',
      title: 'All clear confirmed',
      detail: 'Red Cross Youth A · 12 members accounted for',
      at: now.subtract(const Duration(hours: 2, minutes: 5)),
      by: 'Maria Santos',
      groupName: 'Red Cross Youth A',
    ),
    _SeedAlert(
      level: 'yellow',
      title: 'Caution raised for Red Cross Youth B',
      detail: 'Jose Reyes · Red Cross Youth B',
      at: yesterday.add(const Duration(hours: 8, minutes: 20)),
      by: 'Jose Reyes',
      groupName: 'Red Cross Youth B',
      unread: true,
    ),
    _SeedAlert(
      level: 'green',
      title: 'Group check-in completed',
      detail: 'Maria Santos · 12 members accounted for',
      at: yesterday.add(const Duration(hours: 7, minutes: 5)),
      by: 'Maria Santos',
      groupName: 'Red Cross Youth A',
    ),
    _SeedAlert(
      level: 'yellow',
      title: 'Caution alert broadcast',
      detail: 'Juan Dela Cruz · 2 volunteer groups',
      at: startOfToday.subtract(const Duration(days: 2, hours: 4)),
      by: _hostName,
    ),
    _SeedAlert(
      level: 'red',
      title: 'Emergency alert cancelled',
      detail: 'Ana Cruz · all volunteer groups',
      at: startOfToday.subtract(const Duration(days: 2, hours: 5)),
      by: 'Ana Cruz',
      unread: true,
    ),
    _SeedAlert(
      level: 'green',
      title: 'Monthly earthquake drill',
      detail: 'Polomolok NHS · 36 volunteers',
      at: startOfToday.subtract(const Duration(days: 4, hours: 3)),
      by: _hostName,
    ),
    _SeedAlert(
      level: 'green',
      title: 'All clear confirmed',
      detail: 'Juan Dela Cruz · all volunteer groups',
      at: startOfToday.subtract(const Duration(days: 6, hours: 6)),
      by: _hostName,
    ),
  ];
}

Future<void> _createSchema(Database db) async {
  await db.execute('''
    CREATE TABLE volunteer_groups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      leader_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
      status TEXT NOT NULL
        CHECK (status IN ('safe', 'awaiting', 'needsAssistance')),
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      school_id TEXT NOT NULL UNIQUE,
      email TEXT NOT NULL UNIQUE,
      password_salt TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      role TEXT NOT NULL CHECK (role IN ('host', 'leader', 'member')),
      school TEXT NOT NULL,
      group_id INTEGER REFERENCES volunteer_groups(id) ON DELETE SET NULL,
      about TEXT,
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE alerts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      level TEXT NOT NULL CHECK (level IN ('green', 'yellow', 'red')),
      title TEXT NOT NULL,
      detail TEXT NOT NULL,
      occurred_at TEXT NOT NULL,
      ended_at TEXT,
      is_unread INTEGER NOT NULL DEFAULT 0,
      group_id INTEGER REFERENCES volunteer_groups(id) ON DELETE CASCADE,
      created_by INTEGER REFERENCES users(id) ON DELETE SET NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE user_skills (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      label TEXT NOT NULL,
      icon_key TEXT NOT NULL,
      tint TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.execute('CREATE INDEX users_group_id ON users (group_id)');
  await db.execute('CREATE INDEX alerts_occurred_at ON alerts (occurred_at)');
  await db.execute('CREATE INDEX alerts_created_by ON alerts (created_by)');
  await db.execute('CREATE INDEX user_skills_user_id ON user_skills (user_id)');

  await _createAlertDismissals(db);
  await _createOneLeaderIndex(db);
}

/// Upgrades a database opened at an earlier schema version.
///
/// History that already existed was finished, not live, so it is closed off
/// instead of ringing every group's siren after an app update.
Future<void> upgradeDatabase(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE alerts ADD COLUMN ended_at TEXT');
    await db.execute('UPDATE alerts SET ended_at = occurred_at');
    await _createAlertDismissals(db);
    await _createOneLeaderIndex(db);
  }
}

/// Per-account stops: a group member who stops an alert dismisses it on their
/// own account without ending it for the rest of the group.
Future<void> _createAlertDismissals(Database db) async {
  await db.execute('''
    CREATE TABLE alert_dismissals (
      alert_id INTEGER NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      dismissed_at TEXT NOT NULL,
      PRIMARY KEY (alert_id, user_id)
    )
  ''');
}

/// One leader handles one group, so a leader can only be attached once.
Future<void> _createOneLeaderIndex(Database db) async {
  await db.execute('''
    CREATE UNIQUE INDEX volunteer_groups_leader_id
    ON volunteer_groups (leader_id)
    WHERE leader_id IS NOT NULL
  ''');
}
