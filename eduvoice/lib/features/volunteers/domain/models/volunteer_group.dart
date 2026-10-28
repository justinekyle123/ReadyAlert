enum GroupReportStatus {
  safe('Safe'),
  awaiting('Awaiting'),
  needsAssistance('Needs help');

  const GroupReportStatus(this.label);

  final String label;
}

class VolunteerGroup {
  const VolunteerGroup({
    required this.name,
    required this.leader,
    required this.memberCount,
    required this.status,
  });

  final String name;
  final String leader;
  final int memberCount;
  final GroupReportStatus status;
}
