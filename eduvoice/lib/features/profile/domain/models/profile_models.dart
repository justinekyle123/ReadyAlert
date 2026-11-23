import 'package:flutter/material.dart';

/// A self-service profile change that cannot be saved, worded for the user.
class ProfileUpdateException implements Exception {
  const ProfileUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

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

  factory ReadinessSkill.fromRow(Map<String, Object?> row) {
    return ReadinessSkill(
      label: row['label'] as String,
      icon: _icons[row['icon_key']] ?? Icons.verified_outlined,
      tint: SkillTint.values.byName(row['tint'] as String),
    );
  }

  final String label;
  final IconData icon;
  final SkillTint tint;

  static const Map<String, IconData> _icons = {
    'first_aid': Icons.medical_services_outlined,
    'radio': Icons.settings_input_antenna_rounded,
    'evacuation': Icons.directions_walk_rounded,
    'drills': Icons.timer_outlined,
    'reporting': Icons.assignment_turned_in_outlined,
    'logistics': Icons.inventory_2_outlined,
  };
}
