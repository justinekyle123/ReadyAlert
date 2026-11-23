import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_harness.dart';

void main() {
  setUp(() async {
    await setUpTestDatabase();
  });

  Future<void> pumpAs(WidgetTester tester, String schoolId) async {
    final user = await tester.runAsync(() => signInAs(schoolId));
    await pumpShell(tester, user!);
  }

  testWidgets('members get a read-only dashboard and no add menu', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAs(tester, 'andrea.bautista');

    expect(find.byKey(const Key('send-alert-button')), findsNothing);
    expect(
      find.text('Only hosts and youth leaders can send alerts.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('add-menu-button')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('members only see their own group', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAs(tester, 'andrea.bautista');
    await tester.tap(find.byKey(const Key('nav-groups')));
    await settle(tester);

    expect(find.text('Red Cross Youth A'), findsWidgets);
    expect(find.text('Red Cross Youth B'), findsNothing);
    expect(find.text('Boy Scouts Troop 1'), findsNothing);

    // Members can open their own group's roster, but only to read it.
    await tester.tap(find.byKey(const Key('group-open-Red Cross Youth A')));
    await settle(tester, 900);
    expect(find.byKey(const Key('group-details-title')), findsOneWidget);
    expect(find.text('Maria Santos'), findsWidgets);
    expect(find.text('Andrea Bautista'), findsOneWidget);
    expect(find.byKey(const Key('group-details-edit')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaders send alerts but cannot manage the roster', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAs(tester, 'maria.santos');

    expect(find.byKey(const Key('send-alert-button')), findsOneWidget);
    // Creating and editing users or groups is a host responsibility.
    expect(find.byKey(const Key('add-menu-button')), findsNothing);

    await tester.tap(find.byKey(const Key('nav-groups')));
    await settle(tester);

    // Leaders can view their own roster, but cannot edit it.
    await tester.tap(find.byKey(const Key('group-open-Red Cross Youth A')));
    await settle(tester, 900);
    expect(find.byKey(const Key('group-details-title')), findsOneWidget);
    expect(find.byKey(const Key('group-details-edit')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaders broadcast to their own group only', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAs(tester, 'maria.santos');

    final sendButton = find.byKey(const Key('send-alert-button'));
    await tester.ensureVisible(sendButton);
    await settle(tester);
    await tester.tap(sendButton);
    await settle(tester, 800);

    expect(
      find.text('All Clear alert sent to Red Cross Youth A.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
