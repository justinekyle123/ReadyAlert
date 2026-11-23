import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_platform_stub.dart'
    if (dart.library.js_interop) 'database_platform_web.dart'
    if (dart.library.io) 'database_platform_io.dart';
import 'seed_data.dart';

/// The app's local SQLite database.
///
/// One file holds accounts, volunteer groups, the alert history and each
/// account's readiness skills. Every screen reads its data back through the
/// repositories, which query this database.
class AppDatabase {
  AppDatabase({this.databasePath});

  static AppDatabase? _instance;

  /// App-wide database, opened lazily on first use.
  static AppDatabase get instance => _instance ??= AppDatabase();

  /// Replaces the app-wide database with a fresh one.
  ///
  /// Tests pass [inMemoryDatabasePath] so every test starts from the seed. The
  /// previous handle is not awaited: its open future belongs to the test that
  /// has just finished, so awaiting it here would stall the next test.
  static void reset({String path = inMemoryDatabasePath}) {
    _instance = AppDatabase(databasePath: path);
  }

  /// Selects the platform's SQLite backend: the plugin on mobile, FFI on
  /// desktop, and the WASM worker in browsers.
  ///
  /// The web backend needs `web/sqlite3.wasm` and `web/sqflite_sw.js`; generate
  /// them with `dart run sqflite_common_ffi_web:setup` from the project root.
  static Future<void> configurePlatform() => configureDatabasePlatform();

  /// Overrides the on-disk location; tests point this at memory.
  final String? databasePath;

  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final path =
        databasePath ?? p.join(await getDatabasesPath(), 'ready_alert.db');

    return openDatabase(
      path,
      version: 4,
      // Each test gets its own in-memory database instead of sqflite's cached
      // connection, which would otherwise stay locked by a finished test.
      singleInstance: path != inMemoryDatabasePath,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) => seedDatabase(db),
      onUpgrade: upgradeDatabase,
    );
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening == null) {
      return;
    }
    try {
      final db = await opening;
      await db.close();
    } on Object {
      // A database that never opened has nothing to release.
    }
  }
}
