import 'package:flutter/material.dart';

/// Shared default sky-blue brand and surface tokens for Arvin's light, calm UI.
/// Keep product semantics (priority, status and taxonomy colors) in ArvinColors.
abstract final class ArvinTheme {
  static const Color primaryBlue = Color(0xFF3A86EF);
  static const Color headerBlue = Color(0xFF276FC9);
  static const Color primarySoft = Color(0xFFEAF2FF);
  // Legacy names remain as compatibility aliases; their values are blue.
  static const Color primaryTurquoise = primaryBlue;
  static const Color headerTurquoise = headerBlue;
  static const Color primaryPurple = primaryBlue;
  static const Color headerPurple = headerBlue;
  static const Color backgroundLight = Color(0xFFF8F8FB);
  static const Color cardBackground = Color(0xFFFDFDFE);
  static const Color cardBorder = Color(0xFFE5E7F0);
  static const Color primaryGlow = Color(0x403A86EF);
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const String fontFamily = 'Vazirmatn';
  static const BoxShadow shadowStyle = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}