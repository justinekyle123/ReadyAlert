import 'package:eduvoice/features/alerts/domain/models/alert_level.dart';
import 'package:eduvoice/features/alerts/presentation/theme/alert_level_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pulse beats faster as the level rises', () {
    expect(
      AlertLevel.yellow.pulsePeriod,
      lessThan(AlertLevel.green.pulsePeriod),
    );
    expect(AlertLevel.red.pulsePeriod, lessThan(AlertLevel.yellow.pulsePeriod));
    expect(AlertLevel.red.pulsePeriod.inMilliseconds, greaterThan(500));
  });
}
