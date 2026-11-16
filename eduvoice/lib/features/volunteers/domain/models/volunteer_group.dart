enum GroupReportStatus {
  safe('Safe'),
  awaiting('Awaiting'),
  needsAssistance('Needs help');

  const GroupReportStatus(this.label);

  final String label;
}

class VolunteerGroup {
  const VolunteerGroup({
    required this.id,
    required this.name,
    required this.leader,
    required this.memberCount,
    required this.status,
    this.leaderId,
  });

  /// Decodes a joined row from [GroupRepository].
  factory VolunteerGroup.fromRow(Map<String, Object?> row) {
    return VolunteerGroup(
      id: row['id'] as int,
      name: row['name'] as String,
      leader: row['leader_name'] as String,
      leaderId: row['leader_id'] as int?,
      memberCount: row['member_count'] as int? ?? 0,
      status: GroupReportStatus.values.byName(row['status'] as String),
    );
  }

  final int id;
  final String name;
  final String leader;

  /// The account leading the group, or null while it is unassigned.
  final int? leaderId;

  final int memberCount;
  final GroupReportStatus status;
}
