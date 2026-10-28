import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_palette.dart';

/// The docked `+` in the bottom bar. While [open] it fans out two actions —
/// add a user or add a group — that fade, lift and scale into place.
class AddMenu extends StatefulWidget {
  const AddMenu({
    super.key,
    required this.open,
    required this.onToggle,
    required this.onAddUser,
    required this.onAddGroup,
  });

  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onAddUser;
  final VoidCallback onAddGroup;

  @override
  State<AddMenu> createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _userStage = _stage(0, 0.85);
  late final Animation<double> _groupStage = _stage(0.15, 1);
  late final Animation<double> _rotateStage = _stage(0, 0.7);

  @override
  void initState() {
    super.initState();
    if (widget.open) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AddMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      widget.open ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _stage(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // The actions stay mounted only while opening, open or closing.
        final showActions = widget.open || _controller.value > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showActions) ...[
              _AddAction(
                key: const Key('add-user-button'),
                animation: _userStage,
                enabled: widget.open,
                icon: Icons.person_add_alt_1_rounded,
                label: 'Add user',
                tint: _AddTint.coral,
                onTap: widget.onAddUser,
              ),
              const SizedBox(height: 10),
              _AddAction(
                key: const Key('add-group-button'),
                animation: _groupStage,
                enabled: widget.open,
                icon: Icons.group_add_rounded,
                label: 'Add group',
                tint: _AddTint.green,
                onTap: widget.onAddGroup,
              ),
              const SizedBox(height: 14),
            ],
            Tooltip(
              message: widget.open ? 'Close' : 'Add user or group',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('add-menu-button'),
                  customBorder: const CircleBorder(),
                  onTap: widget.onToggle,
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      border: Border.all(
                        color: context.palette.surface,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: _rotateStage.value * 0.7853981634,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _AddTint { coral, green }

class _AddAction extends StatelessWidget {
  const _AddAction({
    super.key,
    required this.animation,
    required this.enabled,
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final Animation<double> animation;
  final bool enabled;
  final IconData icon;
  final String label;
  final _AddTint tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    final (iconColor, iconBackground) = switch (tint) {
      _AddTint.coral => (palette.primaryOnSoft, palette.primarySoft),
      _AddTint.green => (palette.alertGreenOn, palette.alertGreenSoft),
    };

    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - t)),
              child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
            ),
          );
        },
        child: Material(
          color: palette.surface,
          elevation: 6,
          shadowColor: palette.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: palette.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
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
