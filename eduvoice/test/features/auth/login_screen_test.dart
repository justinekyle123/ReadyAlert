import 'package:eduvoice/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login validates the form and opens the dashboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ReadyAlertApp(showSplash: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    final submit = find.byKey(const Key('login-submit'));
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Enter your school ID or email'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await tester.tap(find.byKey(const Key('login-password-toggle')));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'juan.delacruz',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'ready123');
    await tester.pump();

    await tester.tap(submit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('All Clear'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login survives an extremely short viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 40));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ReadyAlertApp(showSplash: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(tester.takeException(), isNull);
  });

  testWidgets('login fits a compact phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ReadyAlertApp(showSplash: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
