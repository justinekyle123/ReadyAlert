import 'package:eduvoice/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(
    const ReadyAlertApp(showSplash: false, showLogin: false),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1200));
}

Future<void> advance(WidgetTester tester, [int milliseconds = 700]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

void main() {
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

  testWidgets('choosing an add action reports that it is not wired up', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('add-menu-button')));
    await advance(tester);

    await tester.tap(find.byKey(const Key('add-group-button')));
    await advance(tester);

    expect(
      find.text('Creating groups will be available soon.'),
      findsOneWidget,
    );
    expect(find.text('Add user'), findsNothing);
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
