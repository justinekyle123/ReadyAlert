import 'package:flutter/material.dart';

import '../../auth/domain/models/app_user.dart';
import '../../dashboard/data/dashboard_mock_data.dart';

/// Accent used by a readiness skill chip, resolved against the active palette.
enum SkillTint { coral, green, yellow, red, muted }

class ProfileStat {
  const ProfileStat({required this.value, required this.label});

  final String value;
  final String label;
}

class ReadinessSkill {
  const ReadinessSkill({
    required this.label,
    required this.icon,
    required this.tint,
  });

  final String label;
  final IconData icon;
  final SkillTint tint;
}

/// In-memory demo profile until the backend is connected.
abstract final class ProfileMockData {
  static const AppUser user = DashboardMockData.currentUser;

  static const String about =
      'Host for the Polomolok National High School earthquake readiness '
      'program. I run the tri-alarm broadcasts, keep the volunteer rosters '
      'current, and make sure every group knows the assembly plan before the '
      'next shake. Outside of drills I help train new volunteers on first aid '
      'basics and radio handover.';

  static const List<ProfileStat> stats = [
    ProfileStat(value: '4', label: 'Groups'),
    ProfileStat(value: '36', label: 'Volunteers'),
    ProfileStat(value: '12', label: 'Broadcasts'),
  ];

  static const List<ReadinessSkill> skills = [
    ReadinessSkill(
      label: 'First aid',
      icon: Icons.medical_services_outlined,
      tint: SkillTint.coral,
    ),
    ReadinessSkill(
      label: 'Radio comms',
      icon: Icons.settings_input_antenna_rounded,
      tint: SkillTint.green,
    ),
    ReadinessSkill(
      label: 'Evacuation',
      icon: Icons.directions_walk_rounded,
      tint: SkillTint.yellow,
    ),
    ReadinessSkill(
      label: 'Drills',
      icon: Icons.timer_outlined,
      tint: SkillTint.red,
    ),
    ReadinessSkill(
      label: 'Reporting',
      icon: Icons.assignment_turned_in_outlined,
      tint: SkillTint.green,
    ),
    ReadinessSkill(
      label: 'Logistics',
      icon: Icons.inventory_2_outlined,
      tint: SkillTint.muted,
    ),
  ];
}
