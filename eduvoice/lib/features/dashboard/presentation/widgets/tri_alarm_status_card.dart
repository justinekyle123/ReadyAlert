import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../alerts/domain/models/alert_level.dart';
import '../../../alerts/presentation/theme/alert_level_style.dart';

/// Tri-alarm dial: dial a level on the round colour buttons, read the level's
/// built-in message, then send the alert.
class TriAlarmStatusCard extends StatefulWidget {
  const TriAlarmStatusCard({
    super.key,
    required this.level,
    required this.lastUpdated,
    required this.groupCount,
    required this.onSend,
  });

  /// The alert level that was last sent.
  final AlertLevel level;
  final DateTime lastUpdated;
  final int groupCount;

  /// Called with the level currently dialled in.
  final ValueChanged<AlertLevel> onSend;

  @override
  State<TriAlarmStatusCard> createState() => _TriAlarmStatusCardState();
}

class _TriAlarmStatusCardState extends State<TriAlarmStatusCard> {
  late AlertLevel _selected = widget.level;

  @override
  void didUpdateWidget(TriAlarmStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _selected = widget.level;
    }
  }

  void _select(AlertLevel level) {
    if (level == _selected) {
      return;
    }
    setState(() => _selected = level);
  }

  @override
  Widget build(BuildContext context) {
    final level = _selected;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final option in AlertLevel.values)
              _AlarmLevelButton(
                level: option,
                isSelected: option == level,
                onTap: () => _select(option),
              ),
          ],
        ),
        const SizedBox(height: 22),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: _LevelMessage(key: ValueKey(level), level: level),
          ),
        ),
        const SizedBox(height: 20),
        _SendButton(level: level, onPressed: () => widget.onSend(level)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Last updated ${formatRelativeTime(widget.lastUpdated)} · '
            '${widget.groupCount} groups reached',
            style: TextStyle(fontSize: 10.5, color: palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// The message that is built into every alert level.
class _LevelMessage extends StatelessWidget {
  const _LevelMessage({super.key, required this.level});

  final AlertLevel level;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          level.title,
          style: TextStyle(
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          level.headline,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: level.foregroundFor(palette),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          level.guidance,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.5,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// A round colour button on the tri-alarm dial.
///
/// The selected button pops in, glows and keeps a slow pulse ring running so
/// the armed level is obvious at a glance.
class _AlarmLevelButton extends StatefulWidget {
  const _AlarmLevelButton({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final AlertLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AlarmLevelButton> createState() => _AlarmLevelButtonState();
}

class _AlarmLevelButtonState extends State<_AlarmLevelButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: widget.level.pulsePeriod,
    );
    if (widget.isSelected) {
      _pulse.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AlarmLevelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected == oldWidget.isSelected) {
      return;
    }
    if (widget.isSelected) {
      _pulse.repeat();
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final isSelected = widget.isSelected;
    final palette = context.palette;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${level.label} alert level',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('alert-level-${level.name}'),
            borderRadius: BorderRadius.circular(20),
            splashColor: level.color.withValues(alpha: 0.12),
            highlightColor: level.color.withValues(alpha: 0.06),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (isSelected)
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (context, _) {
                              final t = Curves.easeOut.transform(_pulse.value);
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Faint outer spark that trails the beat.
                                  Transform.scale(
                                    scale: 1 + 0.34 * t,
                                    child: Container(
                                      width: 78,
                                      height: 78,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: level.color.withValues(
                                            alpha: 0.22 * (1 - t),
                                          ),
                                          width: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bright neon ring riding the beat.
                                  Transform.scale(
                                    scale: 1 + 0.2 * t,
                                    child: Container(
                                      width: 78,
                                      height: 78,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: level.color.withValues(
                                            alpha: 0.6 * (1 - t),
                                          ),
                                          width: 2.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: level.color.withValues(
                                              alpha: 0.35 * (1 - t),
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        AnimatedScale(
                          scale: isSelected ? 1 : 0.88,
                          duration: const Duration(milliseconds: 340),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? level.color : palette.surface,
                              border: Border.all(
                                color: isSelected
                                    ? level.color.withValues(alpha: 0.6)
                                    : palette.border,
                                width: isSelected ? 2 : 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: level.color.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 24,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: palette.shadow,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: AnimatedScale(
                              scale: isSelected ? 1 : 0.92,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              child: Icon(
                                level.icon,
                                size: 32,
                                color: isSelected
                                    ? Colors.white
                                    : palette.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: isSelected
                          ? level.foregroundFor(palette)
                          : palette.textSecondary,
                    ),
                    child: Text(level.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.level, required this.onPressed});

  final AlertLevel level;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: level.deepColor),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        return FilledButton.icon(
          key: const Key('send-alert-button'),
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color ?? level.deepColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text(
            'Send alert',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }
}
