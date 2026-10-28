import 'package:eduvoice/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dashboard keeps a looping pulse animation alive on the selected alert
/// button, so tests step time forward explicitly instead of waiting for the
/// whole tree to settle.
Future<void> pumpDashboard(WidgetTester tester) async {
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
  testWidgets('dashboard shows the tri-alarm dial and groups', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    // The profile tab is mounted alongside Home, so the name shows twice.
    expect(find.text('Juan Dela Cruz'), findsWidgets);
    expect(find.text('All Clear'), findsOneWidget);
    expect(find.byKey(const Key('alert-level-green')), findsOneWidget);
    expect(find.byKey(const Key('alert-level-yellow')), findsOneWidget);
    expect(find.byKey(const Key('alert-level-red')), findsOneWidget);
    expect(find.byKey(const Key('send-alert-button')), findsOneWidget);
    expect(find.text('Volunteer groups'), findsOneWidget);
    // The groups tab is mounted alongside Home, so the group shows twice.
    expect(find.text('Red Cross Youth A'), findsWidgets);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Duck, cover, and hold'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('greeting shows today\'s date', (tester) async {
    await pumpDashboard(tester);

    final today = MaterialLocalizations.of(
      tester.element(find.text('Welcome back')),
    ).formatFullDate(DateTime.now());

    expect(find.text(today), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a colour shows that level message', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);

    expect(find.text('All Clear'), findsOneWidget);
    expect(find.text('No earthquake reported'), findsOneWidget);

    final redButton = find.byKey(const Key('alert-level-red'));
    await tester.ensureVisible(redButton);
    await advance(tester);
    await tester.tap(redButton);
    await advance(tester, 800);

    expect(find.text('Emergency'), findsOneWidget);
    expect(find.text('Strong shaking reported'), findsOneWidget);
    expect(find.text('All Clear'), findsNothing);

    final yellowButton = find.byKey(const Key('alert-level-yellow'));
    await tester.ensureVisible(yellowButton);
    await advance(tester);
    await tester.tap(yellowButton);
    await advance(tester, 800);

    expect(find.text('Caution'), findsOneWidget);
    expect(find.text('Mild shaking reported'), findsOneWidget);
    expect(find.text('Emergency'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sending the dialled level updates status and activity', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);

    final redButton = find.byKey(const Key('alert-level-red'));
    await tester.ensureVisible(redButton);
    await advance(tester);
    await tester.tap(redButton);
    await advance(tester, 800);

    final sendButton = find.byKey(const Key('send-alert-button'));
    await tester.ensureVisible(sendButton);
    await advance(tester);
    await tester.tap(sendButton);
    await advance(tester, 800);

    expect(find.text('Emergency'), findsOneWidget);
    expect(
      find.text('Emergency alert sent to 4 volunteer groups.'),
      findsOneWidget,
    );
    // The alerts tab is mounted too and holds the same broadcast title.
    expect(find.text('Emergency alert broadcast'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sending swaps the dial for the live alert, stop restores it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);

    final redButton = find.byKey(const Key('alert-level-red'));
    await tester.ensureVisible(redButton);
    await advance(tester);
    await tester.tap(redButton);
    await advance(tester, 800);

    final sendButton = find.byKey(const Key('send-alert-button'));
    await tester.ensureVisible(sendButton);
    await advance(tester);
    await tester.tap(sendButton);
    await advance(tester, 800);

    expect(find.byKey(const Key('send-alert-button')), findsNothing);
    expect(find.byKey(const Key('alert-level-red')), findsNothing);
    expect(find.byKey(const Key('active-alert-title')), findsOneWidget);
    expect(find.text('Emergency'), findsOneWidget);

    final stopButton = find.byKey(const Key('stop-alert-button'));
    expect(stopButton, findsOneWidget);
    await tester.tap(stopButton);
    await advance(tester, 800);

    expect(find.byKey(const Key('stop-alert-button')), findsNothing);
    expect(find.byKey(const Key('send-alert-button')), findsOneWidget);
    expect(find.byKey(const Key('alert-level-red')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('live alert circle keeps pulsing until stopped', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);

    final redButton = find.byKey(const Key('alert-level-red'));
    await tester.ensureVisible(redButton);
    await advance(tester);
    await tester.tap(redButton);
    await advance(tester, 800);

    final sendButton = find.byKey(const Key('send-alert-button'));
    await tester.ensureVisible(sendButton);
    await advance(tester);
    await tester.tap(sendButton);
    await advance(tester, 800);

    double circleScale() => tester
        .widget<Transform>(find.byKey(const Key('active-alert-circle')))
        .transform
        .getMaxScaleOnAxis();

    final first = circleScale();
    await tester.pump(const Duration(milliseconds: 700));
    final second = circleScale();
    expect(second, isNot(closeTo(first, 0.001)));

    await tester.tap(find.byKey(const Key('stop-alert-button')));
    await advance(tester, 800);
    expect(find.byKey(const Key('active-alert-circle')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header theme toggle switches between light and dark', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app().themeMode, ThemeMode.light);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await advance(tester, 800);

    expect(app().themeMode, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Welcome back'))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await advance(tester, 800);

    expect(app().themeMode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('Welcome back'))).brightness,
      Brightness.light,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard fits a compact phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation switches between tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpDashboard(tester);
    expect(find.text('All Clear'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-groups')));
    await advance(tester);
    expect(find.text('Rosters & check-in'), findsOneWidget);
    expect(find.text('Red Cross Youth B'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('nav-home')));
    await advance(tester);
    expect(find.text('All Clear'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
