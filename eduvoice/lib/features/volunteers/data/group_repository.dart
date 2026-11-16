import '../../../core/database/app_database.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/role_permissions.dart';
import '../domain/models/volunteer_group.dart';

/// Reads volunteer groups with their leader and live member count.
///
/// Hosts see every group; leaders and members only see their own.
class GroupRepository {
  GroupRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Groups joined with their leader and live member count.
  ///
  /// Public so roster writes can read a saved group back through it.
  static const String groupQuery = '''
    SELECT g.id, g.name, g.status, g.leader_id,
           COALESCE(u.name, 'Unassigned') AS leader_name,
           (
             SELECT COUNT(*) FROM users m WHERE m.group_id = g.id
           ) AS member_count
    FROM volunteer_groups g
    LEFT JOIN users u ON u.id = g.leader_id
  ''';

  Future<List<VolunteerGroup>> groupsFor(AppUser user) async {
    final permissions = RolePermissions.of(user);
    final db = await _database.database;

    final rows = permissions.canSeeAllGroups
        ? await db.rawQuery('$groupQuery ORDER BY g.id')
        : await db.rawQuery('$groupQuery WHERE g.id = ? ORDER BY g.id', [
            user.groupId ?? -1,
          ]);

    return rows.map(VolunteerGroup.fromRow).toList();
  }
}
