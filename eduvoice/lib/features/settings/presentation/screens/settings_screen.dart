import 'package:flutter/material.dart';

import '../../../../core/firebase/cloud_alert_sync.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/application/session_controller.dart';
import '../../../auth/domain/models/app_user.dart';
import '../widgets/edit_profile_sheet.dart';

/// Account settings, reached from the hamburger menu on the profile screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _signOut(BuildContext context) {
    final session = SessionScope.of(context);
    // Leave this route first so the signed-out app lands on the login screen.
    Navigator.of(context).popUntil((route) => route.isFirst);
    session.signOut();
  }

  Future<void> _editDetails(BuildContext context, AppUser user) async {
    final updated = await showEditProfileSheet(context, user: user);
    if (updated == null || !context.mounted) {
      return;
    }
    SessionScope.of(context).signIn(updated);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Your details are updated.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final user = SessionScope.of(context).user;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          key: const Key('settings-back'),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          tooltip: 'Back to Profile',
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: 26,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (user != null) ...[
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: palette.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: palette.primaryOnSoft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  user.role.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SettingsDetailRow(
                            label: 'School ID',
                            value: user.schoolId ?? '—',
                          ),
                          const SizedBox(height: 7),
                          _SettingsDetailRow(
                            label: 'Email',
                            value: user.email ?? 'Not set',
                          ),
                          const SizedBox(height: 7),
                          _SettingsDetailRow(
                            label: 'Contact number',
                            value: (user.phone?.isNotEmpty ?? false)
                                ? user.phone!
                                : 'Not set',
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              key: const Key('settings-edit-details'),
                              onPressed: () => _editDetails(context, user),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.primaryOnSoft,
                                side: BorderSide(color: palette.border),
                                minimumSize: const Size(0, 42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text(
                                'Edit my details',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your role, group and school ID can only be '
                            'changed by the host.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10.5,
                              height: 1.4,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CloudAlertSync.instance.enabled
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_off_rounded,
                            size: 20,
                            color: CloudAlertSync.instance.enabled
                                ? palette.alertGreenOn
                                : palette.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Online alerts',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CloudAlertSync.instance.enabled
                                      ? 'Firebase sync is on. Broadcasts reach '
                                            'every signed-in device.'
                                      : 'Local only. Broadcasts stay on '
                                            'this device until Firebase '
                                            'reconnects.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5,
                                    height: 1.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('settings-logout'),
                    onPressed: () => _signOut(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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

class _SettingsDetailRow extends StatelessWidget {
  const _SettingsDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: palette.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
