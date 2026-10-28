import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme-aware neutrals, tints and status colours for Ready Alert.
///
/// Brand coral stays fixed, but surfaces, text and status tints flip with the
/// brightness so widgets never hardcode a light-only colour.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primarySoft,
    required this.primaryOnSoft,
    required this.shadow,
    required this.alertGreenSoft,
    required this.alertYellowSoft,
    required this.alertRedSoft,
    required this.alertGreenOn,
    required this.alertYellowOn,
    required this.alertRedOn,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  /// Tinted coral chip/icon background.
  final Color primarySoft;

  /// Coral-tinted text and icons drawn on [primarySoft].
  final Color primaryOnSoft;

  final Color shadow;

  final Color alertGreenSoft;
  final Color alertYellowSoft;
  final Color alertRedSoft;
  final Color alertGreenOn;
  final Color alertYellowOn;
  final Color alertRedOn;

  static const AppPalette light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceMuted: AppColors.surfaceMuted,
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    primarySoft: AppColors.primarySoft,
    primaryOnSoft: AppColors.primaryDark,
    shadow: AppColors.shadow,
    alertGreenSoft: AppColors.alertGreenSoft,
    alertYellowSoft: AppColors.alertYellowSoft,
    alertRedSoft: AppColors.alertRedSoft,
    alertGreenOn: AppColors.alertGreenDeep,
    alertYellowOn: AppColors.alertYellowDeep,
    alertRedOn: AppColors.alertRedDeep,
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF141011),
    surface: Color(0xFF1E191A),
    surfaceMuted: Color(0xFF282223),
    border: Color(0xFF352D2F),
    textPrimary: Color(0xFFF3EDEC),
    textSecondary: Color(0xFFA69D9F),
    primarySoft: Color(0xFF3A211F),
    primaryOnSoft: Color(0xFFFFB3AA),
    shadow: Color(0x66000000),
    alertGreenSoft: Color(0xFF12321F),
    alertYellowSoft: Color(0xFF382D0D),
    alertRedSoft: Color(0xFF3B1B18),
    alertGreenOn: Color(0xFF74E3A3),
    alertYellowOn: Color(0xFFF0CC70),
    alertRedOn: Color(0xFFF8A79E),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? primarySoft,
    Color? primaryOnSoft,
    Color? shadow,
    Color? alertGreenSoft,
    Color? alertYellowSoft,
    Color? alertRedSoft,
    Color? alertGreenOn,
    Color? alertYellowOn,
    Color? alertRedOn,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryOnSoft: primaryOnSoft ?? this.primaryOnSoft,
      shadow: shadow ?? this.shadow,
      alertGreenSoft: alertGreenSoft ?? this.alertGreenSoft,
      alertYellowSoft: alertYellowSoft ?? this.alertYellowSoft,
      alertRedSoft: alertRedSoft ?? this.alertRedSoft,
      alertGreenOn: alertGreenOn ?? this.alertGreenOn,
      alertYellowOn: alertYellowOn ?? this.alertYellowOn,
      alertRedOn: alertRedOn ?? this.alertRedOn,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) {
      return this;
    }

    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppPalette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      primarySoft: mix(primarySoft, other.primarySoft),
      primaryOnSoft: mix(primaryOnSoft, other.primaryOnSoft),
      shadow: mix(shadow, other.shadow),
      alertGreenSoft: mix(alertGreenSoft, other.alertGreenSoft),
      alertYellowSoft: mix(alertYellowSoft, other.alertYellowSoft),
      alertRedSoft: mix(alertRedSoft, other.alertRedSoft),
      alertGreenOn: mix(alertGreenOn, other.alertGreenOn),
      alertYellowOn: mix(alertYellowOn, other.alertYellowOn),
      alertRedOn: mix(alertRedOn, other.alertRedOn),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// The active palette, falling back to light when no theme is present.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
