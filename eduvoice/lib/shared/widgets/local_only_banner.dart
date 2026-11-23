import 'package:flutter/material.dart';

import '../../core/firebase/cloud_alert_sync.dart';
import '../../core/theme/app_palette.dart';

/// Warns that tri-alarm broadcasts stay on this device.
///
/// Shown whenever Firebase did not connect, so nobody assumes an alert sent
/// from here reaches the rest of the school.
class LocalOnlyBanner extends StatelessWidget {
  const LocalOnlyBanner({super.key, this.syncEnabled});

  /// Overrides the live Firebase state; defaults to [CloudAlertSync.enabled].
  final bool? syncEnabled;

  @override
  Widget build(BuildContext context) {
    if (syncEnabled ?? CloudAlertSync.instance.enabled) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      key: const Key('local-only-banner'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: palette.alertYellowSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.alertYellowOn.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: palette.alertYellowOn,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online alerts are off',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: palette.alertYellowOn,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Broadcasts stay on this device until Firebase reconnects.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 1.4,
                    color: palette.alertYellowOn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
