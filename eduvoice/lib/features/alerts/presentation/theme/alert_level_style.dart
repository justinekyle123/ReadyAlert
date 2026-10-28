import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/models/alert_level.dart';

extension AlertLevelStyle on AlertLevel {
  Color get color => switch (this) {
    AlertLevel.green => AppColors.alertGreen,
    AlertLevel.yellow => AppColors.alertYellow,
    AlertLevel.red => AppColors.alertRed,
  };

  Color get deepColor => switch (this) {
    AlertLevel.green => AppColors.alertGreenDeep,
    AlertLevel.yellow => AppColors.alertYellowDeep,
    AlertLevel.red => AppColors.alertRedDeep,
  };

  Color get gradientStart => switch (this) {
    AlertLevel.green => const Color(0xFF0A3B26),
    AlertLevel.yellow => const Color(0xFF3B2C08),
    AlertLevel.red => const Color(0xFF431111),
  };

  Color get gradientEnd => switch (this) {
    AlertLevel.green => const Color(0xFF156B43),
    AlertLevel.yellow => const Color(0xFF6E5311),
    AlertLevel.red => const Color(0xFF7C2323),
  };

  /// Beat period of the level's neon pulse: yellow beats faster than green
  /// and red beats fastest.
  Duration get pulsePeriod => switch (this) {
    AlertLevel.green => const Duration(milliseconds: 2400),
    AlertLevel.yellow => const Duration(milliseconds: 1700),
    AlertLevel.red => const Duration(milliseconds: 1100),
  };

  IconData get icon => switch (this) {
    AlertLevel.green => Icons.verified_user_outlined,
    AlertLevel.yellow => Icons.warning_amber_rounded,
    AlertLevel.red => Icons.crisis_alert_rounded,
  };

  /// Soft background tint that matches the active brightness.
  Color softFor(AppPalette palette) => switch (this) {
    AlertLevel.green => palette.alertGreenSoft,
    AlertLevel.yellow => palette.alertYellowSoft,
    AlertLevel.red => palette.alertRedSoft,
  };

  /// Text and icon colour that reads on [softFor].
  Color foregroundFor(AppPalette palette) => switch (this) {
    AlertLevel.green => palette.alertGreenOn,
    AlertLevel.yellow => palette.alertYellowOn,
    AlertLevel.red => palette.alertRedOn,
  };
}
