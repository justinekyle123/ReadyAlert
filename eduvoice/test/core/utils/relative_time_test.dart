import 'package:eduvoice/core/utils/relative_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRelativeTime', () {
    final now = DateTime(2026, 10, 26, 12);

    test('treats the last minute as "Just now"', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(seconds: 20)), now: now),
        'Just now',
      );
      expect(
        formatRelativeTime(now.add(const Duration(minutes: 1)), now: now),
        'Just now',
      );
    });

    test('formats minutes and hours', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 3)), now: now),
        '3 hr ago',
      );
    });

    test('formats days and older dates', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 1)), now: now),
        'Yesterday',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 4)), now: now),
        '4 days ago',
      );
      expect(formatRelativeTime(DateTime(2026, 9, 18), now: now), '9/18/2026');
    });
  });
}
