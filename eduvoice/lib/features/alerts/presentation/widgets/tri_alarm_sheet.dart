import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/models/alert_level.dart';
import '../theme/alert_level_style.dart';

class TriAlarmSheet extends StatelessWidget {
  const TriAlarmSheet({super.key, required this.activeLevel});

  final AlertLevel activeLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Broadcast tri-alarm',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose the level to send to every volunteer group. '
                'The Host and all leaders will be notified.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.5,
                  height: 1.4,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              for (final level in AlertLevel.values) ...[
                _AlertLevelOption(level: level, isActive: level == activeLevel),
                if (level != AlertLevel.values.last) const SizedBox(height: 12),
              ],
              const SizedBox(height: 14),
              Text(
                'Use the level that matches what volunteers are '
                'experiencing on the ground.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertLevelOption extends StatelessWidget {
  const _AlertLevelOption({required this.level, required this.isActive});

  final AlertLevel level;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final foreground = level.foregroundFor(palette);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('alert-option-${level.name}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pop(level),
        child: Ink(
          decoration: BoxDecoration(
            color: level.softFor(palette),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: level.color.withValues(alpha: 0.32)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(level.icon, color: foreground, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          level.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'CURRENT',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: foreground,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      level.headline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      level.guidance,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        height: 1.4,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: foreground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
