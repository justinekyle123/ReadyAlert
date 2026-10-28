import 'package:flutter/material.dart';

/// Central color palette for the Ready Alert application.
///
/// The brand colors are sampled from the coral emergency reference:
/// white cards and dark text on a warm red/coral base.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFE8534B);
  static const Color primaryDark = Color(0xFFB3312B);
  static const Color primarySoft = Color(0xFFFCEBE9);

  // Splash
  static const Color splashStart = Color(0xFFF27066);
  static const Color splashEnd = Color(0xFFD33D34);

  // Surfaces
  static const Color background = Color(0xFFFAF6F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5EDEC);
  static const Color border = Color(0xFFF0E1DF);

  // Text
  static const Color textPrimary = Color(0xFF1C1E26);
  static const Color textSecondary = Color(0xFF70737D);

  // Tri-alarm levels
  static const Color alertGreen = Color(0xFF1A9C54);
  static const Color alertGreenSoft = Color(0xFFE6F6ED);
  static const Color alertGreenDeep = Color(0xFF0B5A31);
  static const Color alertYellow = Color(0xFFEFB01B);
  static const Color alertYellowSoft = Color(0xFFFDF4DF);
  static const Color alertYellowDeep = Color(0xFF7A5207);
  static const Color alertRed = Color(0xFFD92D20);
  static const Color alertRedSoft = Color(0xFFFDECEA);
  static const Color alertRedDeep = Color(0xFF8F1D1D);

  // Misc
  static const Color shadow = Color(0x141C1E26);
}
