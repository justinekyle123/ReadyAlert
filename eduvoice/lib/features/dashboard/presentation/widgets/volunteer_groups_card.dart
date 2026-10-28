import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../volunteers/domain/models/volunteer_group.dart';

class VolunteerGroupsCard extends StatelessWidget {
  const VolunteerGroupsCard({super.key, required this.groups});

  final List<VolunteerGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          _GroupRow(group: groups[index]),
          if (index != groups.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final VolunteerGroup group;

  (Color, Color) _statusColors(AppPalette palette) => switch (group.status) {
    GroupReportStatus.safe => (palette.alertGreenOn, palette.alertGreenSoft),
    GroupReportStatus.awaiting => (
      palette.alertYellowOn,
      palette.alertYellowSoft,
    ),
    GroupReportStatus.needsAssistance => (
      palette.alertRedOn,
      palette.alertRedSoft,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final (foreground, background) = _statusColors(palette);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.groups_2_outlined,
              size: 20,
              color: palette.primaryOnSoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${group.leader} · ${group.memberCount} members',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(
            label: group.status.label,
            foreground: foreground,
            background: background,
          ),
        ],
      ),
    );
  }
}
