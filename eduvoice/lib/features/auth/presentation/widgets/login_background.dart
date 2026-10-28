import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft emergency-themed vector shapes that drift behind the login form.
///
/// The shapes are painted directly on the canvas and animated on an
/// infinite loop, so no image or SVG assets are required.
class LoginBackground extends StatefulWidget {
  const LoginBackground({super.key});

  @override
  State<LoginBackground> createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<LoginBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox.expand(
            child: CustomPaint(
              painter: _EmergencyPatternPainter(_controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _EmergencyPatternPainter extends CustomPainter {
  const _EmergencyPatternPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress * 2 * math.pi;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);

    // Slow rotating dashed radar rings.
    _drawDashedCircle(
      canvas,
      Offset(size.width * 0.88, size.height * 0.17),
      84,
      time * 0.35,
      ringPaint,
    );
    ringPaint.color = Colors.white.withValues(alpha: 0.05);
    _drawDashedCircle(
      canvas,
      Offset(size.width * 0.88, size.height * 0.17),
      118,
      -time * 0.22,
      ringPaint,
    );

    // Pulsing rescue rings near the lower-left corner.
    final rescueCenter = Offset(size.width * 0.08, size.height * 0.82);
    for (var index = 0; index < 3; index++) {
      final pulse = (progress + index / 3) % 1;
      final pulsePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: (1 - pulse) * 0.07);
      canvas.drawCircle(rescueCenter, 26 + pulse * 104, pulsePaint);
    }

    // Drifting medical crosses.
    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.09);
    const crosses = <({double x, double y, double size, double phase})>[
      (x: 0.13, y: 0.27, size: 11, phase: 0),
      (x: 0.78, y: 0.42, size: 15, phase: 0.28),
      (x: 0.22, y: 0.66, size: 9, phase: 0.55),
      (x: 0.9, y: 0.78, size: 12, phase: 0.72),
      (x: 0.6, y: 0.94, size: 10, phase: 0.4),
    ];
    for (final cross in crosses) {
      final angle = (progress + cross.phase) * 2 * math.pi;
      _drawCross(
        canvas,
        Offset(
          size.width * cross.x + math.sin(angle) * 12,
          size.height * cross.y + math.cos(angle) * 16,
        ),
        cross.size,
        crossPaint,
      );
    }

    // Quiet alert triangles.
    final alertPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.06);
    _drawAlertTriangle(
      canvas,
      Offset(size.width * 0.12, size.height * 0.47),
      13,
      alertPaint,
    );
    _drawAlertTriangle(
      canvas,
      Offset(size.width * 0.86, size.height * 0.63),
      17,
      alertPaint,
    );

    _drawHeartbeat(canvas, size);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Paint paint,
  ) {
    const segments = 28;
    final sweep = (2 * math.pi) / segments;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var index = 0; index < segments; index++) {
      canvas.drawArc(
        rect,
        rotation + index * sweep,
        sweep * 0.58,
        false,
        paint,
      );
    }
  }

  void _drawCross(Canvas canvas, Offset center, double arm, Paint paint) {
    canvas.drawLine(center.translate(-arm, 0), center.translate(arm, 0), paint);
    canvas.drawLine(center.translate(0, -arm), center.translate(0, arm), paint);
  }

  void _drawAlertTriangle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.92, center.dy + radius * 0.72)
      ..lineTo(center.dx - radius * 0.92, center.dy + radius * 0.72)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(
      center.translate(0, -radius * 0.18),
      center.translate(0, radius * 0.28),
      paint,
    );
  }

  void _drawHeartbeat(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.055);
    final baseline = size.height * 0.87;
    final segment = size.width / 4;
    final shift = (progress * segment * 2) % segment;
    final path = Path()..moveTo(-segment, baseline);

    for (var index = 0; index < 6; index++) {
      final x = index * segment + shift;
      path
        ..lineTo(x, baseline)
        ..lineTo(x + segment * 0.12, baseline)
        ..lineTo(x + segment * 0.18, baseline - 18)
        ..lineTo(x + segment * 0.24, baseline + 12)
        ..lineTo(x + segment * 0.3, baseline)
        ..lineTo(x + segment * 0.5, baseline);
    }

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EmergencyPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
