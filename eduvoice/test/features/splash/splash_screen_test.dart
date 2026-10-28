import 'package:eduvoice/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash screen transitions into the login screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ReadyAlertApp());

    expect(find.text('Prepare. Respond. Stay connected.'), findsOneWidget);
    expect(find.text('POLOMOLOK NATIONAL HIGH SCHOOL'), findsOneWidget);
    expect(find.byKey(const Key('login-email')), findsNothing);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
