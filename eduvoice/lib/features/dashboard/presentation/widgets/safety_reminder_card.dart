import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

class SafetyReminderCard extends StatelessWidget {
  const SafetyReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duck, cover, and hold',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: palette.primaryOnSoft,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'During shaking, drop to your knees, protect your head and '
                'neck, and hold on to something sturdy. Evacuate only '
                'after the shaking stops.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  height: 1.5,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
