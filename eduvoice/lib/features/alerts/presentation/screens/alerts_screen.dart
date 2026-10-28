import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../data/alerts_mock_data.dart';
import '../../domain/models/alert_activity.dart';
import '../theme/alert_level_style.dart';

/// Alert history: every broadcast and check-in, grouped by day.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.onBack});

  /// Returns to the Home tab; alerts live inside the shell.
  final VoidCallback? onBack;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final List<AlertActivity> _alerts = AlertsMockData.initial(
    DateTime.now(),
  );

  int get _unreadCount => _alerts.where((alert) => alert.isUnread).length;

  void _markAllRead() {
    if (_unreadCount == 0) {
      return;
    }
    setState(() {
      for (var index = 0; index < _alerts.length; index++) {
        _alerts[index] = _alerts[index].copyWith(isUnread: false);
      }
    });
  }

  void _markRead(int index) {
    if (!_alerts[index].isUnread) {
      return;
    }
    setState(() {
      _alerts[index] = _alerts[index].copyWith(isUnread: false);
    });
  }

  List<Widget> _buildFeed(BuildContext context) {
    final children = <Widget>[];
    String? heading;

    for (var index = 0; index < _alerts.length; index++) {
      final alert = _alerts[index];
      final dayHeading = formatDayHeading(alert.occurredAt);

      if (dayHeading != heading) {
        heading = dayHeading;
        children.add(
          _DayHeading(heading: dayHeading, isFirst: children.isEmpty),
        );
      }

      children.add(
        FadeSlideIn(
          delay: Duration(milliseconds: 35 * (index + 1).clamp(0, 8)),
          child: _AlertRow(
            index: index,
            activity: alert,
            onTap: () => _markRead(index),
          ),
        ),
      );
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.primarySoft, palette.background],
          stops: const [0, 0.22],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: FadeSlideIn(
                    child: _AlertsTopBar(
                      unreadCount: _unreadCount,
                      onBack: widget.onBack,
                      onMarkAllRead: _markAllRead,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    // Bottom room for the floating add button in the shell.
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 84),
                    children: _buildFeed(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertsTopBar extends StatelessWidget {
  const _AlertsTopBar({
    required this.unreadCount,
    required this.onMarkAllRead,
    this.onBack,
  });

  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            key: const Key('alerts-back'),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            tooltip: 'Back to Home',
            icon: const Icon(Icons.chevron_left_rounded, size: 26),
          ),
        ),
        Expanded(
          child: Text(
            'Alerts',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: PopupMenuButton<_AlertsMenuAction>(
            key: const Key('alerts-menu'),
            tooltip: 'Alert history options',
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            onSelected: (action) {
              switch (action) {
                case _AlertsMenuAction.markAllRead:
                  onMarkAllRead();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _AlertsMenuAction.markAllRead,
                enabled: unreadCount > 0,
                child: Text(
                  unreadCount > 0
                      ? 'Mark all as read ($unreadCount)'
                      : 'All alerts read',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _AlertsMenuAction { markAllRead }

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.heading, required this.isFirst});

  final String heading;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 4 : 20, bottom: 8),
      child: Text(
        heading,
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: palette.textSecondary,
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.index,
    required this.activity,
    required this.onTap,
  });

  final int index;
  final AlertActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return InkWell(
      key: Key('alert-row-$index'),
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: activity.level.softFor(palette),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                activity.level.icon,
                size: 20,
                color: activity.level.foregroundFor(palette),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activity.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  TimeOfDay.fromDateTime(activity.occurredAt).format(context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                _UnreadDot(
                  key: Key('alert-unread-$index'),
                  visible: activity.isUnread,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
