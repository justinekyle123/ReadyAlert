import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A continuously animated emergency alert beacon: a floating alert badge
/// surrounded by pulsing rings and a slowly rotating dashed orbit.
class EmergencyHero extends StatefulWidget {
  const EmergencyHero({super.key, this.size = 156});

  final double size;

  @override
  State<EmergencyHero> createState() => _EmergencyHeroState();
}

class _EmergencyHeroState extends State<EmergencyHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = widget.size + 54;
    final pulseSize = widget.size * 0.72;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final float = math.sin(progress * 2 * math.pi) * 5;
          final breathe = 1 + math.sin(progress * 2 * math.pi) * 0.025;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < 3; index++)
                _PulseRing(
                  progress: (progress + index / 3) % 1,
                  baseSize: pulseSize,
                ),
              Transform.rotate(
                angle: progress * 2 * math.pi,
                child: CustomPaint(
                  size: Size.square(widget.size + 20),
                  painter: const _HeroOrbitPainter(),
                ),
              ),
              Transform.translate(
                offset: Offset(0, float),
                child: Transform.scale(scale: breathe, child: child),
              ),
            ],
          );
        },
        child: Container(
          width: widget.size * 0.69,
          height: widget.size * 0.69,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 34,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_active_rounded,
                size: widget.size * 0.32,
                color: AppColors.primary,
              ),
              Align(
                alignment: const Alignment(0.6, -0.6),
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.alertRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress, required this.baseSize});

  final double progress;
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + 0.82 * progress,
      child: Opacity(
        opacity: (1 - progress) * 0.3,
        child: Container(
          width: baseSize,
          height: baseSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _HeroOrbitPainter extends CustomPainter {
  const _HeroOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.46;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    const segments = 32;
    final sweep = (2 * math.pi) / segments;
    for (var index = 0; index < segments; index++) {
      canvas.drawArc(rect, index * sweep, sweep * 0.42, false, arcPaint);
    }

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final angle in [0.0, 2 * math.pi / 3, 4 * math.pi / 3]) {
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(point, 2.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroOrbitPainter oldDelegate) => false;
}
