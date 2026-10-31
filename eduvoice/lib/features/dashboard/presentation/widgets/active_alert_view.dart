import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/audio/alert_siren.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../alerts/domain/models/alert_level.dart';
import '../../../alerts/presentation/theme/alert_level_style.dart';

/// Stands in for the tri-alarm dial while an alert is live: the armed level as
/// one large neon circle that beats faster as the level rises, its message
/// underneath, and a button to stop it. The siren loops until it is stopped.
class ActiveAlertView extends StatefulWidget {
  const ActiveAlertView({super.key, required this.level, required this.onStop});

  final AlertLevel level;
  final VoidCallback onStop;

  @override
  State<ActiveAlertView> createState() => _ActiveAlertViewState();
}

class _ActiveAlertViewState extends State<ActiveAlertView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final AlertSiren _siren = AlertSiren();

  /// Muted hides the siren only; the alert itself stays live.
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.level.pulsePeriod,
    )..repeat();
    unawaited(_siren.start());
  }

  @override
  void didUpdateWidget(covariant ActiveAlertView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _controller
        ..duration = widget.level.pulsePeriod
        ..repeat();
    }
  }

  @override
  void dispose() {
    unawaited(_siren.dispose());
    _controller.dispose();
    super.dispose();
  }

  void _stop() {
    unawaited(_siren.stop());
    widget.onStop();
  }

  void _toggleMuted() {
    setState(() => _muted = !_muted);
    unawaited(_siren.setMuted(_muted));
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final palette = context.palette;

    return Column(
      children: [
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            // One breath in and out per beat.
            final breath = 0.5 - 0.5 * math.cos(2 * math.pi * t);
            return SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _SparkRing(
                    level: level,
                    scale: 1 + 0.3 * t,
                    opacity: 0.45 * (1 - t),
                  ),
                  _SparkRing(
                    level: level,
                    scale: 1 + 0.3 * ((t + 0.5) % 1),
                    opacity: 0.32 * (1 - ((t + 0.5) % 1)),
                  ),
                  Transform.scale(
                    key: const Key('active-alert-circle'),
                    scale: 1 + 0.04 * breath,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [level.gradientStart, level.gradientEnd],
                        ),
                        border: Border.all(
                          color: level.color.withValues(
                            alpha: 0.55 + 0.35 * breath,
                          ),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: level.color.withValues(
                              alpha: 0.28 + 0.3 * breath,
                            ),
                            blurRadius: 26 + 26 * breath,
                            spreadRadius: 3 + 7 * breath,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: level.color.withValues(
                              alpha: 0.18 + 0.22 * breath,
                            ),
                            blurRadius: 8 + 10 * breath,
                          ),
                        ],
                      ),
                      child: Icon(level.icon, size: 84, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          level.title,
          key: const Key('active-alert-title'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 27,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          level.headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: level.foregroundFor(palette),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 188,
              child: OutlinedButton.icon(
                key: const Key('stop-alert-button'),
                onPressed: _stop,
                style: OutlinedButton.styleFrom(
                  backgroundColor: palette.surface,
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.stop_rounded, size: 20),
                label: const Text('Stop'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              key: const Key('mute-siren-button'),
              onPressed: _toggleMuted,
              tooltip: _muted ? 'Unmute siren' : 'Mute siren',
              style: IconButton.styleFrom(
                backgroundColor: palette.surface,
                foregroundColor: _muted
                    ? palette.textSecondary
                    : palette.textPrimary,
                side: BorderSide(color: palette.border),
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A neon ring that sparks outwards from the live circle and fades as it goes.
class _SparkRing extends StatelessWidget {
  const _SparkRing({
    required this.level,
    required this.scale,
    required this.opacity,
  });

  final AlertLevel level;
  final double scale;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: level.color.withValues(alpha: opacity.clamp(0, 1)),
            width: 2.4,
          ),
          boxShadow: [
            BoxShadow(
              color: level.color.withValues(alpha: (opacity * 0.5).clamp(0, 1)),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
