import 'package:flutter/material.dart';

/// Shared default sky-blue brand and surface tokens for Arvin's light, calm UI.
/// Keep product semantics (priority, status and taxonomy colors) in ArvinColors.
abstract final class ArvinTheme {
  static const Color primaryTurquoise = Color(0xFF3A86EF);
  static const Color headerTurquoise = Color(0xFF276FC9);
  static const Color primarySoft = Color(0xFFEAF2FF);
  // Compatibility aliases for older call sites; both resolve to turquoise.
  static const Color primaryPurple = primaryTurquoise;
  static const Color headerPurple = headerTurquoise;
  static const Color backgroundLight = Color(0xFFF8F8FB);
  static const Color cardBackground = Color(0xFFFDFDFE);
  static const Color cardBorder = Color(0xFFE5E7F0);
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const String fontFamily = 'Vazirmatn';
  static const BoxShadow shadowStyle = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}
