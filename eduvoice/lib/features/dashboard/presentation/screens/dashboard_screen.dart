import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../alerts/domain/models/alert_activity.dart';
import '../../../alerts/domain/models/alert_level.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../volunteers/domain/models/volunteer_group.dart';
import '../../data/dashboard_mock_data.dart';
import '../widgets/active_alert_view.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats_row.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/safety_reminder_card.dart';
import '../widgets/tri_alarm_status_card.dart';
import '../widgets/volunteer_groups_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppUser _user = DashboardMockData.currentUser;
  final List<VolunteerGroup> _groups = DashboardMockData.groups;

  AlertLevel _activeLevel = AlertLevel.green;
  DateTime _lastUpdated = DateTime.now().subtract(const Duration(minutes: 8));
  late final List<AlertActivity> _activities =
      DashboardMockData.initialActivities(DateTime.now());

  /// While true the dial is replaced by the live alert view.
  bool _alertSending = false;

  void _sendAlert(AlertLevel selectedLevel) {
    final now = DateTime.now();
    setState(() {
      _activeLevel = selectedLevel;
      _alertSending = true;
      _lastUpdated = now;
      _activities.insert(
        0,
        AlertActivity(
          level: selectedLevel,
          title: _broadcastTitle(selectedLevel),
          detail: '${_user.name} · all volunteer groups',
          occurredAt: now,
        ),
      );
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${selectedLevel.title} alert sent to '
            '${_groups.length} volunteer groups.',
          ),
        ),
      );
  }

  void _stopAlert() => setState(() => _alertSending = false);

  String _broadcastTitle(AlertLevel level) => switch (level) {
    AlertLevel.green => 'All clear broadcast',
    AlertLevel.yellow => 'Caution alert broadcast',
    AlertLevel.red => 'Emergency alert broadcast',
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.primarySoft, palette.background],
          stops: const [0, 0.24],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              // Bottom room for the floating add button in the shell.
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 84),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(child: DashboardHeader(user: _user)),
                  const SizedBox(height: 26),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: DashboardGreeting(user: _user),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _alertSending
                          ? ActiveAlertView(
                              key: const ValueKey('active-alert'),
                              level: _activeLevel,
                              onStop: _stopAlert,
                            )
                          : TriAlarmStatusCard(
                              key: const ValueKey('tri-alarm-dial'),
                              level: _activeLevel,
                              lastUpdated: _lastUpdated,
                              groupCount: _groups.length,
                              onSend: _sendAlert,
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 170),
                    child: DashboardStatsRow(groups: _groups),
                  ),
                  const SizedBox(height: 22),
                  const Divider(),
                  const SizedBox(height: 22),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 230),
                    child: SectionHeader(
                      title: 'Volunteer groups',
                      subtitle:
                          'Live check-in status from your assigned groups',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 280),
                    child: VolunteerGroupsCard(groups: _groups),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 22),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 340),
                    child: SectionHeader(
                      title: 'Recent activity',
                      subtitle: 'Latest tri-alarm broadcasts and check-ins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 390),
                    child: RecentActivityCard(activities: _activities),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 450),
                    child: SafetyReminderCard(),
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
