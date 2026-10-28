import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/domain/models/app_user.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user, this.onThemeToggle});

  final AppUser user;

  /// Defaults to the app-wide theme controller when one is in scope.
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final toggle = onThemeToggle ?? AppThemeScope.maybeOf(context)?.toggle;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: palette.surface, width: 2),
          ),
          child: Text(
            user.initials,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (toggle != null) ...[
          const SizedBox(width: 8),
          IconButton(
            key: const Key('theme-toggle'),
            onPressed: toggle,
            tooltip: isDarkMode
                ? 'Switch to light theme'
                : 'Switch to dark theme',
            style: IconButton.styleFrom(
              backgroundColor: palette.primarySoft,
              foregroundColor: palette.primaryOnSoft,
            ),
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }
}
