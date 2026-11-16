import '../../../core/database/app_database.dart';
import '../../../core/database/password_hash.dart';
import '../domain/models/app_user.dart';

/// Reads and verifies accounts in the local `users` table.
class AuthRepository {
  AuthRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Returns the matching account, or null when the credentials are wrong.
  Future<AppUser?> signIn({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty || password.isEmpty) {
      return null;
    }

    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'LOWER(school_id) = ? OR LOWER(email) = ?',
      whereArgs: [trimmed.toLowerCase(), trimmed.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    final salt = row['password_salt'] as String;
    if (hashPassword(password, salt) != row['password_hash']) {
      return null;
    }
    return AppUser.fromMap(row);
  }

  /// The primary host account, used when the login screen is skipped.
  Future<AppUser?> defaultHost() async {
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [UserRole.host.name],
      orderBy: 'id',
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }
}
