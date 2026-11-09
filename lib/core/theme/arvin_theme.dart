import 'package:flutter/material.dart';

/// Shared Persian Teal brand and calm surface tokens for Arvin.
/// Product semantics (priority, status and taxonomy colors) stay in ArvinColors.
abstract final class ArvinTheme {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color headerTeal = Color(0xFF115E59);
  static const Color primarySoft = Color(0xFFDDF3EF);

  // Compatibility aliases for older call sites; all resolve to Persian Teal.
  static const Color primaryBlue = primaryTeal;
  static const Color headerBlue = headerTeal;
  static const Color primaryTurquoise = primaryTeal;
  static const Color headerTurquoise = headerTeal;
  static const Color primaryPurple = primaryTeal;
  static const Color headerPurple = headerTeal;

  static const Color backgroundLight = Color(0xFFF8F8FB);
  static const Color cardBackground = Color(0xFFFDFDFE);
  static const Color cardBorder = Color(0xFFE5E7F0);
  static const Color primaryGlow = Color(0x400F766E);
  static const BorderRadius cardBorderRadius =
      BorderRadius.all(Radius.circular(16.0));
  static const String fontFamily = 'Vazirmatn';
  static const BoxShadow shadowStyle = BoxShadow(
    color: primaryGlow,
    blurRadius: 10,
    spreadRadius: 0.5,
    offset: Offset(0, 4),
  );
}
