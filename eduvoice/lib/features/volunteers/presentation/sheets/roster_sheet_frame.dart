import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Opens a roster form as a rounded bottom sheet.
Future<T?> showRosterSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: builder,
  );
}

/// The shared chrome around a roster form: handle, title, subtitle, body.
class RosterSheetFrame extends StatelessWidget {
  const RosterSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
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
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    height: 1.4,
                    color: palette.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small uppercase label above a roster form field.
class RosterFieldLabel extends StatelessWidget {
  const RosterFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: context.palette.textSecondary,
      ),
    );
  }
}

/// The filled input decoration used by every roster form.
InputDecoration rosterFieldDecoration(
  BuildContext context, {
  required String hint,
  IconData? icon,
}) {
  final palette = context.palette;

  OutlineInputBorder border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(fontSize: 12.5, color: palette.textSecondary),
    prefixIcon: icon == null
        ? null
        : Icon(icon, size: 18, color: palette.textSecondary),
    filled: true,
    fillColor: palette.surfaceMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    enabledBorder: border(palette.border),
    focusedBorder: border(AppColors.primary, width: 1.4),
    errorBorder: border(palette.alertRedOn.withValues(alpha: 0.6)),
    focusedErrorBorder: border(palette.alertRedOn, width: 1.4),
    errorStyle: TextStyle(
      fontSize: 10.5,
      height: 1.2,
      color: palette.alertRedOn,
    ),
  );
}

/// A rounded selectable pill, used for roles and groups.
class RosterChoice extends StatelessWidget {
  const RosterChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = selected ? palette.primaryOnSoft : palette.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? palette.primarySoft : palette.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? palette.primaryOnSoft : palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable row that stands in for a picker, such as choosing a leader.
class RosterPickTile extends StatelessWidget {
  const RosterPickTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon = Icons.person_search_rounded,
    this.interactive = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData icon;

  /// Read-only tiles still show the value but do not invite a tap.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: interactive ? onTap : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: palette.primaryOnSoft),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (interactive)
                Icon(
                  Icons.unfold_more_rounded,
                  size: 18,
                  color: palette.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explains the password every new account starts with.
class DefaultPasswordNote extends StatelessWidget {
  const DefaultPasswordNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      key: const Key('default-password-note'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.key_rounded, size: 16, color: palette.primaryOnSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Every volunteer added here starts with the password ready123.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: palette.primaryOnSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
