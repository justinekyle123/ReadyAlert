import '../../alerts/domain/models/alert_activity.dart';
import '../../alerts/domain/models/alert_level.dart';
import '../../auth/domain/models/app_user.dart';
import '../../volunteers/data/volunteer_groups_mock_data.dart';
import '../../volunteers/domain/models/volunteer_group.dart';

/// In-memory demo data for the dashboard until the backend is connected.
abstract final class DashboardMockData {
  static const AppUser currentUser = AppUser(
    name: 'Juan Dela Cruz',
    role: UserRole.host,
    school: 'Polomolok National High School',
  );

  static const List<VolunteerGroup> groups = VolunteerGroupsMockData.groups;

  static List<AlertActivity> initialActivities(DateTime now) {
    return [
      AlertActivity(
        level: AlertLevel.green,
        title: 'All clear confirmed',
        detail: 'Juan Dela Cruz · all volunteer groups',
        occurredAt: now.subtract(const Duration(minutes: 8)),
      ),
      AlertActivity(
        level: AlertLevel.yellow,
        title: 'Caution raised for Red Cross Youth B',
        detail: 'Jose Reyes · Red Cross Youth B',
        occurredAt: now.subtract(const Duration(minutes: 23)),
      ),
      AlertActivity(
        level: AlertLevel.green,
        title: 'Group check-in completed',
        detail: 'Maria Santos · 12 members accounted for',
        occurredAt: now.subtract(const Duration(minutes: 41)),
      ),
      AlertActivity(
        level: AlertLevel.green,
        title: 'Monthly earthquake drill',
        detail: 'Polomolok NHS · 36 volunteers',
        occurredAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
