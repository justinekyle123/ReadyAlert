import '../domain/models/alert_activity.dart';
import '../domain/models/alert_level.dart';

/// In-memory alert history until the backend is connected.
abstract final class AlertsMockData {
  static List<AlertActivity> initial(DateTime now) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    final yesterday = startOfToday.subtract(const Duration(days: 1));

    return [
      AlertActivity(
        level: AlertLevel.red,
        title: 'Emergency alert broadcast',
        detail: 'Juan Dela Cruz · all volunteer groups',
        occurredAt: now.subtract(const Duration(minutes: 12)),
        isUnread: true,
      ),
      AlertActivity(
        level: AlertLevel.green,
        title: 'All clear confirmed',
        detail: 'Red Cross Youth A · 12 members accounted for',
        occurredAt: now.subtract(const Duration(hours: 2, minutes: 5)),
      ),
      AlertActivity(
        level: AlertLevel.yellow,
        title: 'Caution raised for Red Cross Youth B',
        detail: 'Jose Reyes · Red Cross Youth B',
        occurredAt: yesterday.add(const Duration(hours: 8, minutes: 20)),
        isUnread: true,
      ),
      AlertActivity(
        level: AlertLevel.green,
        title: 'Group check-in completed',
        detail: 'Maria Santos · 12 members accounted for',
        occurredAt: yesterday.add(const Duration(hours: 7, minutes: 5)),
      ),
      AlertActivity(
        level: AlertLevel.yellow,
        title: 'Caution alert broadcast',
        detail: 'Juan Dela Cruz · 2 volunteer groups',
        occurredAt: startOfToday.subtract(const Duration(days: 2, hours: 4)),
      ),
      AlertActivity(
        level: AlertLevel.red,
        title: 'Emergency alert cancelled',
        detail: 'Ana Cruz · all volunteer groups',
        occurredAt: startOfToday.subtract(const Duration(days: 2, hours: 5)),
        isUnread: true,
      ),
      AlertActivity(
        level: AlertLevel.green,
        title: 'Monthly earthquake drill',
        detail: 'Polomolok NHS · 36 volunteers',
        occurredAt: startOfToday.subtract(const Duration(days: 4, hours: 3)),
      ),
      AlertActivity(
        level: AlertLevel.green,
        title: 'All clear confirmed',
        detail: 'Juan Dela Cruz · all volunteer groups',
        occurredAt: startOfToday.subtract(const Duration(days: 6, hours: 6)),
      ),
    ];
  }
}
