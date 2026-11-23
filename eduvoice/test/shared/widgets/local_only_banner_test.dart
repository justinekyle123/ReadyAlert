import 'package:eduvoice/core/theme/app_theme.dart';
import 'package:eduvoice/shared/widgets/local_only_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpBanner(WidgetTester tester, {required bool syncEnabled}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: LocalOnlyBanner(syncEnabled: syncEnabled)),
    ),
  );
}

void main() {
  testWidgets('warns that alerts are local-only when sync is off', (
    tester,
  ) async {
    await pumpBanner(tester, syncEnabled: false);

    expect(find.byKey(const Key('local-only-banner')), findsOneWidget);
    expect(find.text('Online alerts are off'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders nothing when sync is on', (tester) async {
    await pumpBanner(tester, syncEnabled: true);

    expect(find.byKey(const Key('local-only-banner')), findsNothing);
    expect(find.text('Online alerts are off'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
