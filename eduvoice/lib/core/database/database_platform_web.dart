import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Browsers have no native SQLite, so the WASM build served from `web/`
/// (`sqlite3.wasm` and `sqflite_sw.js`) backs the same database API.
Future<void> configureDatabasePlatform() async {
  databaseFactory = databaseFactoryFfiWeb;
}
