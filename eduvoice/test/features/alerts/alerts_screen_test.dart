import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_harness.dart';

Future<void> pumpShell(WidgetTester tester) => pumpHostShell(tester);

Future<void> advance(WidgetTester tester, [int milliseconds = 600]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

double unreadDotScale(WidgetTester tester, int index) {
  return tester
      .widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(Key('alert-unread-$index')),
          matching: find.byType(AnimatedScale),
        ),
      )
      .scale;
}

void main() {
  setUp(() async {
    await setUpTestDatabase();
  });

  testWidgets('alerts tab lists the history grouped by day', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-alerts')));
    await advance(tester);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    // The dashboard's recent activity shows the same broadcast row.
    expect(find.text('Emergency alert broadcast'), findsWidgets);
    expect(find.text('Emergency alert cancelled'), findsOneWidget);
    expect(find.text('Monthly earthquake drill'), findsWidgets);
    expect(unreadDotScale(tester, 0), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row marks it read', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-alerts')));
    await advance(tester);

    expect(unreadDotScale(tester, 0), 1);
    await tester.tap(find.byKey(const Key('alert-row-0')));
    await advance(tester, 500);

    expect(unreadDotScale(tester, 0), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the menu marks every alert as read', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('nav-alerts')));
    await advance(tester);

    expect(unreadDotScale(tester, 2), 1);

    await tester.tap(find.byKey(const Key('alerts-menu')));
    await advance(tester, 500);
    await tester.tap(find.textContaining('Mark all as read'));
    await advance(tester, 500);

    expect(unreadDotScale(tester, 0), 0);
    expect(unreadDotScale(tester, 2), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alerts back button returns to Home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShell(tester);

    NavigationBar navBar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    await tester.tap(find.byKey(const Key('nav-alerts')));
    await advance(tester);
    expect(navBar().selectedIndex, 1);

    await tester.tap(find.byKey(const Key('alerts-back')));
    await advance(tester);
    expect(navBar().selectedIndex, 0);
    expect(tester.takeException(), isNull);
  });
}
