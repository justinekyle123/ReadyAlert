import 'package:eduvoice/core/database/seed_data.dart';
import 'package:eduvoice/features/auth/data/auth_repository.dart';
import 'package:eduvoice/features/auth/domain/models/app_user.dart';
import 'package:eduvoice/features/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_harness.dart';

Future<void> pumpShell(WidgetTester tester) => pumpHostShell(tester);

Future<void> advance(WidgetTester tester, [int milliseconds = 600]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

void main() {
  setUp(() async {
    await setUpTestDatabase();
  });

  testWidgets('profile tab shows the profile page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-profile')));
    await advance(tester);

    expect(find.text('About me'), findsOneWidget);
    expect(find.text('Readiness skills'), findsOneWidget);
    expect(find.text('Broadcasts'), findsOneWidget);
    // "Volunteers" is also a stat label on the Home tab.
    expect(find.text('Volunteers'), findsWidgets);
    expect(find.text('First aid'), findsOneWidget);
    expect(find.text('Radio comms'), findsOneWidget);
    expect(find.text('Read more'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('read more expands and collapses the about text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-profile')));
    await advance(tester);

    final toggle = find.byKey(const Key('profile-read-more'));
    await tester.ensureVisible(toggle);
    await advance(tester);

    await tester.tap(toggle);
    await advance(tester, 700);
    expect(find.text('Read less'), findsOneWidget);

    await tester.tap(toggle);
    await advance(tester, 700);
    expect(find.text('Read more'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hamburger opens settings and logout returns to login', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-profile')));
    await advance(tester);

    await tester.tap(find.byKey(const Key('profile-settings-menu')));
    await advance(tester, 700);
    expect(find.text('Settings'), findsOneWidget);

    final logout = find.byKey(const Key('settings-logout'));
    await tester.ensureVisible(logout);
    await advance(tester);
    await tester.tap(logout);
    await advance(tester, 900);

    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings edits the signed-in account details only', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-profile')));
    await advance(tester);
    await tester.tap(find.byKey(const Key('profile-settings-menu')));
    await advance(tester, 700);

    final edit = find.byKey(const Key('settings-edit-details'));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await settle(tester, 800);

    expect(find.byKey(const Key('edit-profile-name')), findsOneWidget);
    // There is no role field on a self-service edit.
    expect(find.byKey(const Key('edit-user-role-leader')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('edit-profile-name')),
      'Juan D. Cruz',
    );
    await tester.enterText(
      find.byKey(const Key('edit-profile-email')),
      'juan.cruz@pnhs.edu.ph',
    );
    await tester.enterText(
      find.byKey(const Key('edit-profile-phone')),
      '0917 555 0100',
    );

    final save = find.byKey(const Key('edit-profile-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settle(tester, 1200);

    expect(find.text('Your details are updated.'), findsOneWidget);
    expect(find.text('juan.cruz@pnhs.edu.ph'), findsOneWidget);
    expect(find.text('0917 555 0100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('editing details never changes the role', () async {
    final before = await signInAs('andrea.bautista');
    final updated = await ProfileRepository().updateContactDetails(
      user: before,
      name: 'Andrea Bautista-Ramos',
      email: 'andrea.ramos@pnhs.edu.ph',
      phone: '0917 555 0101',
    );

    expect(updated.role, UserRole.member);
    expect(updated.email, 'andrea.ramos@pnhs.edu.ph');

    final signedIn = await AuthRepository().signIn(
      identifier: 'andrea.ramos@pnhs.edu.ph',
      password: seedPassword,
    );
    expect(signedIn, isNotNull);
    expect(signedIn!.name, 'Andrea Bautista-Ramos');
    expect(signedIn.role, UserRole.member);
    expect(signedIn.phone, '0917 555 0101');
  });

  testWidgets('profile back button returns to Home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);

    NavigationBar navBar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    await tester.tap(find.byKey(const Key('nav-profile')));
    await advance(tester);
    expect(navBar().selectedIndex, 3);

    await tester.tap(find.byKey(const Key('profile-back')));
    await advance(tester);
    expect(navBar().selectedIndex, 0);
    expect(tester.takeException(), isNull);
  });
}
