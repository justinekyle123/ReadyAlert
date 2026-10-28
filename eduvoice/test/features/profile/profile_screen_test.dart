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

Future<void> advance(WidgetTester tester, [int milliseconds = 600]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

void main() {
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
