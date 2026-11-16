import 'package:eduvoice/app/app.dart';
import 'package:eduvoice/core/audio/alert_siren.dart';
import 'package:eduvoice/core/database/app_database.dart';
import 'package:eduvoice/core/database/seed_data.dart';
import 'package:eduvoice/features/auth/data/auth_repository.dart';
import 'package:eduvoice/features/auth/domain/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Points the app at a fresh, seeded in-memory database.
///
/// The no-isolate factory keeps the SQLite calls on the test isolate so a
/// normal `pump()` resolves the screen's queries.
Future<void> setUpTestDatabase() async {
  AlertSiren.enabled = false;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
  AppDatabase.reset();
  await AppDatabase.instance.database;
}

/// Signs in a seeded account by school ID and returns it.
Future<AppUser> signInAs(String schoolId) async {
  final user = await AuthRepository().signIn(
    identifier: schoolId,
    password: seedPassword,
  );
  expect(user, isNotNull, reason: 'Seeded account $schoolId must exist.');
  return user!;
}

/// Pumps the UI while giving the real SQLite work a chance to finish.
///
/// Widget tests run in a fake-async zone, so a database future started during
/// a build only completes inside [WidgetTester.runAsync]. Two rounds let the
/// query resolve and the screen rebuild with the rows.
Future<void> settle(WidgetTester tester, [int milliseconds = 600]) async {
  await tester.pump();
  for (var round = 0; round < 2; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(Duration(milliseconds: milliseconds ~/ 2));
  }
}

/// Opens the app shell already signed in as [user].
Future<void> pumpShell(WidgetTester tester, AppUser user) async {
  await tester.pumpWidget(
    ReadyAlertApp(showSplash: false, showLogin: false, initialUser: user),
  );
  await settle(tester, 1200);
}

/// Opens the app shell already signed in as the host.
Future<void> pumpHostShell(WidgetTester tester) async {
  final user = await tester.runAsync(() => signInAs('juan.delacruz'));
  await pumpShell(tester, user!);
}
