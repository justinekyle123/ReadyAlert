import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

/// The standard card used across Ready Alert screens.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Overrides the card surface; defaults to the active theme's surface.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
