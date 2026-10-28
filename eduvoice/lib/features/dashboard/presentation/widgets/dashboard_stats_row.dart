import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../volunteers/domain/models/volunteer_group.dart';

class DashboardStatsRow extends StatelessWidget {
  const DashboardStatsRow({super.key, required this.groups});

  final List<VolunteerGroup> groups;

  @override
  Widget build(BuildContext context) {
    final totalMembers = groups.fold<int>(
      0,
      (total, group) => total + group.memberCount,
    );
    final reportsIn = groups
        .where((group) => group.status == GroupReportStatus.safe)
        .length;

    return Row(
      children: [
        _Stat(value: '${groups.length}', label: 'Groups'),
        const _StatDivider(),
        _Stat(value: '$totalMembers', label: 'Volunteers'),
        const _StatDivider(),
        _Stat(value: '$reportsIn/${groups.length}', label: 'Reports in'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.5,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: context.palette.border);
  }
}
