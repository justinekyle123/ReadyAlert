import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/firebase/cloud_alert_sync.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/local_only_banner.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../alerts/data/alert_repository.dart';
import '../../../alerts/domain/models/alert_activity.dart';
import '../../../alerts/domain/models/alert_level.dart';
import '../../../auth/application/session_controller.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/domain/role_permissions.dart';
import '../../../volunteers/application/roster_controller.dart';
import '../../../volunteers/data/group_repository.dart';
import '../../../volunteers/domain/models/volunteer_group.dart';
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
  final GroupRepository _groupRepository = GroupRepository();
  final AlertRepository _alertRepository = AlertRepository();

  AppUser? _user;
  List<VolunteerGroup> _groups = const [];
  List<AlertActivity> _activities = const [];
  AlertLevel _activeLevel = AlertLevel.green;
  DateTime _lastUpdated = DateTime.now();
  int _rosterRevision = -1;

  /// The alert this account is reacting to right now, if any. While it is set
  /// the dial is replaced by the live alert view.
  AlertActivity? _liveAlert;

  /// Persisted per-account siren choice.
  bool _sirenMuted = false;

  StreamSubscription<void>? _liveSubscription;

  @override
  void dispose() {
    _liveSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = SessionScope.of(context).user;
    final revision = RosterScope.of(context).revision;
    if (user == null || (user.id == _user?.id && revision == _rosterRevision)) {
      return;
    }
    _user = user;
    _rosterRevision = revision;
    _load(user);
    _subscribeToLiveUpdates(user);
  }

  /// Listens for alerts raised or ended on another device when Firebase is
  /// configured. The stream stays empty in local-only mode.
  void _subscribeToLiveUpdates(AppUser user) {
    _liveSubscription?.cancel();
    _liveSubscription = _alertRepository.liveUpdates(user).listen((_) {
      if (!mounted || user.id != _user?.id) {
        return;
      }
      unawaited(_load(user));
    });
  }

  Future<void> _load(AppUser user) async {
    final groups = await _groupRepository.groupsFor(user);
    final activities = await _alertRepository.historyFor(user);
    final live = await _alertRepository.liveAlertFor(user);
    final muted = await _alertRepository.isSirenMuted(user);
    if (!mounted || user.id != _user?.id) {
      return;
    }
    setState(() {
      _groups = groups;
      _activities = activities;
      _liveAlert = live;
      _sirenMuted = muted;
      if (live != null) {
        _activeLevel = live.level;
        _lastUpdated = live.occurredAt;
      } else if (activities.isNotEmpty) {
        _activeLevel = activities.first.level;
        _lastUpdated = activities.first.occurredAt;
      }
    });
  }

  Future<void> _sendAlert(AlertLevel selectedLevel) async {
    final user = _user;
    if (user == null) {
      return;
    }
    if (!RolePermissions.of(user).canBroadcastAlerts) {
      _showMessage('Only hosts and youth leaders can send alerts.');
      return;
    }

    final activity = await _alertRepository.broadcast(
      sender: user,
      level: selectedLevel,
    );
    if (!mounted || user.id != _user?.id) {
      return;
    }

    setState(() {
      _activeLevel = selectedLevel;
      _liveAlert = activity;
      _lastUpdated = activity.occurredAt;
      _activities = [activity, ..._activities];
    });

    final groupWord = _groups.length == 1 ? 'group' : 'groups';
    final groupScoped = !RolePermissions.of(user).canBroadcastToAllGroups;
    _showMessage(
      groupScoped && _groups.isNotEmpty
          ? '${selectedLevel.title} alert sent to ${_groups.first.name}.'
          : '${selectedLevel.title} alert sent to '
                '${_groups.length} volunteer $groupWord.',
    );
  }

  Future<void> _setSirenMuted(bool muted) async {
    setState(() => _sirenMuted = muted);
    final user = _user;
    if (user == null) {
      return;
    }
    try {
      await _alertRepository.setSirenMuted(user, muted);
    } on Object catch (error) {
      debugPrint('Could not save the siren preference: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Stops the live alert. A sender ends it for the group; a member only
  /// dismisses it on their own account.
  Future<void> _stopAlert() async {
    final alert = _liveAlert;
    if (alert == null) {
      return;
    }
    setState(() => _liveAlert = null);

    final user = _user;
    final alertId = alert.id;
    if (user == null || alertId == null) {
      return;
    }
    try {
      await _alertRepository.stopAlert(user: user, alertId: alertId);
    } on Object catch (error) {
      debugPrint('Could not stop alert $alertId: $error');
      if (mounted) {
        _showMessage('Could not stop this alert. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final palette = context.palette;
    final liveAlert = _liveAlert;
    final canBroadcast = RolePermissions.of(user).canBroadcastAlerts;

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
                  if (!CloudAlertSync.instance.enabled) ...[
                    const FadeSlideIn(child: LocalOnlyBanner()),
                    const SizedBox(height: 16),
                  ],
                  FadeSlideIn(child: DashboardHeader(user: user)),
                  const SizedBox(height: 26),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: DashboardGreeting(user: user),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: liveAlert != null
                          ? ActiveAlertView(
                              key: const ValueKey('active-alert'),
                              level: liveAlert.level,
                              initialMuted: _sirenMuted,
                              onMutedChanged: (muted) =>
                                  unawaited(_setSirenMuted(muted)),
                              onStop: () => unawaited(_stopAlert()),
                            )
                          : TriAlarmStatusCard(
                              key: const ValueKey('tri-alarm-dial'),
                              level: _activeLevel,
                              lastUpdated: _lastUpdated,
                              groupCount: _groups.length,
                              canSend: canBroadcast,
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
