import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../volunteers/data/volunteer_groups_mock_data.dart';
import '../../../volunteers/domain/models/volunteer_group.dart';

/// Volunteer groups: the rosters the host reaches when an alert goes out.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key, this.onBack});

  /// Returns to the Home tab; groups live inside the shell.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final groups = VolunteerGroupsMockData.groups;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.primarySoft, palette.background],
          stops: const [0, 0.22],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              // Bottom room for the docked add button in the shell.
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 84),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(child: _GroupsTopBar(onBack: onBack)),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: _GroupsSummary(groups: groups),
                  ),
                  const SizedBox(height: 24),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 120),
                    child: SectionHeader(
                      title: 'Rosters & check-in',
                      subtitle: 'Everyone you reach when an alert goes out',
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < groups.length; index++) ...[
                    FadeSlideIn(
                      key: Key('group-tile-${groups[index].name}'),
                      delay: Duration(milliseconds: 170 + 40 * index),
                      child: _GroupTile(group: groups[index]),
                    ),
                    if (index != groups.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupsTopBar extends StatelessWidget {
  const _GroupsTopBar({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            key: const Key('groups-back'),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            tooltip: 'Back to Home',
            icon: const Icon(Icons.chevron_left_rounded, size: 26),
          ),
        ),
        Expanded(
          child: Text(
            'Groups',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _GroupsSummary extends StatelessWidget {
  const _GroupsSummary({required this.groups});

  final List<VolunteerGroup> groups;

  @override
  Widget build(BuildContext context) {
    final totalMembers = groups.fold<int>(
      0,
      (total, group) => total + group.memberCount,
    );
    final reportedIn = groups
        .where((group) => group.status == GroupReportStatus.safe)
        .length;

    return Row(
      children: [
        _SummaryStat(value: '${groups.length}', label: 'Groups'),
        const _SummaryDivider(),
        _SummaryStat(value: '$totalMembers', label: 'Volunteers'),
        const _SummaryDivider(),
        _SummaryStat(value: '$reportedIn/${groups.length}', label: 'Safe'),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

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

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: context.palette.border);
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

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

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.groups_2_rounded, size: 22, color: foreground),
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
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${group.leader} · ${group.memberCount} members',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
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
