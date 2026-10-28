import 'package:eduvoice/app/app.dart';
import 'package:eduvoice/features/groups/presentation/screens/groups_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(
    const ReadyAlertApp(showSplash: false, showLogin: false),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1200));
}

Future<void> advance(WidgetTester tester, [int milliseconds = 600]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

void main() {
  testWidgets('groups tab shows the group rosters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-groups')));
    await advance(tester);

    expect(find.text('Rosters & check-in'), findsOneWidget);
    expect(find.text('Boy Scouts Troop 1'), findsWidgets);
    expect(find.text('Boy Scouts Troop 2'), findsWidgets);
    expect(find.byKey(const Key('groups-back')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups summary totals the rosters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-groups')));
    await advance(tester);

    expect(
      find.byKey(const Key('group-tile-Red Cross Youth A')),
      findsOneWidget,
    );

    Finder inGroups(String text) => find.descendant(
      of: find.byType(GroupsScreen),
      matching: find.text(text),
    );

    // 12 + 10 + 8 + 6 members across the four demo groups.
    expect(inGroups('4'), findsOneWidget);
    expect(inGroups('36'), findsOneWidget);
    expect(inGroups('3/4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups page fits a compact phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-groups')));
    await advance(tester);

    expect(find.text('Rosters & check-in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups back button returns to Home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);

    NavigationBar navBar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    await tester.tap(find.byKey(const Key('nav-groups')));
    await advance(tester);
    expect(navBar().selectedIndex, 2);

    await tester.tap(find.byKey(const Key('groups-back')));
    await advance(tester);
    expect(navBar().selectedIndex, 0);
    expect(tester.takeException(), isNull);
  });
}
