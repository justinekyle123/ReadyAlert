import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../alerts/domain/models/alert_activity.dart';
import '../../../alerts/presentation/theme/alert_level_style.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, required this.activities});

  final List<AlertActivity> activities;

  @override
  Widget build(BuildContext context) {
    final visibleActivities = activities.take(4).toList();

    return Column(
      children: [
        for (var index = 0; index < visibleActivities.length; index++) ...[
          _ActivityRow(activity: visibleActivities[index]),
          if (index != visibleActivities.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final AlertActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.level.softFor(palette),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.level.icon,
              size: 17,
              color: activity.level.foregroundFor(palette),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatRelativeTime(activity.occurredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  activity.detail,
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
        ],
      ),
    );
  }
}
