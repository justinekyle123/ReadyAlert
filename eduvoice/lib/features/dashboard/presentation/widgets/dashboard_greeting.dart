import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key, required this.user});

  final AppUser user;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final today = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting, ${user.firstName}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 12,
              color: palette.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                today,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
