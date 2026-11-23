import '../../../core/database/app_database.dart';
import '../../alerts/data/alert_repository.dart';
import '../../auth/domain/models/app_user.dart';
import '../../volunteers/data/group_repository.dart';
import '../domain/models/profile_models.dart';

/// The numbers and skills shown on a profile, read from SQLite.
class ProfileSnapshot {
  const ProfileSnapshot({
    required this.groupCount,
    required this.volunteerCount,
    required this.broadcastCount,
    required this.skills,
  });

  final int groupCount;
  final int volunteerCount;
  final int broadcastCount;
  final List<ReadinessSkill> skills;
}

class ProfileRepository {
  ProfileRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<ProfileSnapshot> load(AppUser user) async {
    // Start every read before awaiting so the screen resolves in one pass.
    final groupsFuture = GroupRepository(database: _database).groupsFor(user);
    final broadcastsFuture = AlertRepository(
      database: _database,
    ).broadcastCount(user);
    final skillsFuture = _skillsFor(user.id);

    final groups = await groupsFuture;
    final broadcasts = await broadcastsFuture;
    final skills = await skillsFuture;

    return ProfileSnapshot(
      groupCount: groups.length,
      volunteerCount: groups.fold(
        0,
        (total, group) => total + group.memberCount,
      ),
      broadcastCount: broadcasts,
      skills: skills,
    );
  }

  /// Updates the signed-in account's own name, email and contact number.
  ///
  /// Role, group, school and school ID are deliberately not parameters: only
  /// the host changes those from the roster editor.
  Future<AppUser> updateContactDetails({
    required AppUser user,
    required String name,
    required String email,
    required String phone,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPhone = phone.trim();

    if (trimmedName.isEmpty) {
      throw const ProfileUpdateException('Enter your full name.');
    }
    if (trimmedEmail.isEmpty ||
        !trimmedEmail.contains('@') ||
        !trimmedEmail.contains('.')) {
      throw const ProfileUpdateException('Enter a valid email address.');
    }

    final db = await _database.database;
    final duplicate = await db.query(
      'users',
      columns: ['id'],
      where: 'LOWER(email) = ? AND id <> ?',
      whereArgs: [trimmedEmail, user.id],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw const ProfileUpdateException(
        'That email is already used by another account.',
      );
    }

    await db.update(
      'users',
      {
        'name': trimmedName,
        'email': trimmedEmail,
        'phone': trimmedPhone.isEmpty ? null : trimmedPhone,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return AppUser(
      id: user.id,
      name: trimmedName,
      role: user.role,
      school: user.school,
      schoolId: user.schoolId,
      email: trimmedEmail,
      phone: trimmedPhone.isEmpty ? null : trimmedPhone,
      groupId: user.groupId,
      about: user.about,
    );
  }

  Future<List<ReadinessSkill>> _skillsFor(int userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'user_skills',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'sort_order',
    );
    return rows.map(ReadinessSkill.fromRow).toList();
  }
}
