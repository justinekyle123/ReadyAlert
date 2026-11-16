import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_harness.dart';

Future<void> pumpShell(WidgetTester tester) => pumpHostShell(tester);

Future<void> advance(WidgetTester tester, [int milliseconds = 700]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

void main() {
  setUp(() async {
    await setUpTestDatabase();
  });

  testWidgets('the plus button reveals both add actions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);

    expect(find.text('Add user'), findsNothing);
    expect(find.text('Add group'), findsNothing);

    await tester.tap(find.byKey(const Key('add-menu-button')));
    await advance(tester);

    expect(find.text('Add user'), findsOneWidget);
    expect(find.text('Add group'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the add user action opens the volunteer form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('add-menu-button')));
    await advance(tester);

    await tester.tap(find.byKey(const Key('add-user-button')));
    await advance(tester);

    expect(find.byKey(const Key('add-user-name')), findsOneWidget);
    expect(find.byKey(const Key('default-password-note')), findsOneWidget);
    expect(find.text('Add user'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the add group action opens the group form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('add-menu-button')));
    await advance(tester);

    await tester.tap(find.byKey(const Key('add-group-button')));
    await advance(tester);

    expect(find.text('New volunteer group'), findsOneWidget);
    expect(find.byKey(const Key('create-group-name')), findsOneWidget);
    expect(find.text('Add group'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the page or switching tabs closes the menu', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);

    await tester.tap(find.byKey(const Key('add-menu-button')));
    await advance(tester);
    expect(find.text('Add user'), findsOneWidget);

    await tester.tapAt(const Offset(195, 300));
    await advance(tester);
    expect(find.text('Add user'), findsNothing);

    await tester.tap(find.byKey(const Key('add-menu-button')));
    await advance(tester);
    expect(find.text('Add user'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-alerts')));
    await advance(tester);
    expect(find.text('Add user'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
