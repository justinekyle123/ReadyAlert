import '../domain/models/volunteer_group.dart';

/// In-memory demo groups until the backend is connected.
abstract final class VolunteerGroupsMockData {
  static const List<VolunteerGroup> groups = [
    VolunteerGroup(
      name: 'Red Cross Youth A',
      leader: 'Maria Santos',
      memberCount: 12,
      status: GroupReportStatus.safe,
    ),
    VolunteerGroup(
      name: 'Red Cross Youth B',
      leader: 'Jose Reyes',
      memberCount: 10,
      status: GroupReportStatus.awaiting,
    ),
    VolunteerGroup(
      name: 'Boy Scouts Troop 1',
      leader: 'Ana Cruz',
      memberCount: 8,
      status: GroupReportStatus.safe,
    ),
    VolunteerGroup(
      name: 'Boy Scouts Troop 2',
      leader: 'Mark Lim',
      memberCount: 6,
      status: GroupReportStatus.safe,
    ),
  ];
}
