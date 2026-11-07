import 'package:flutter/material.dart';

/// Shared turquoise brand and surface tokens for Arvin's light, calm UI.
/// Keep product semantics (priority, status and taxonomy colors) in ArvinColors.
abstract final class ArvinTheme {
  static const Color primaryTurquoise = Color(0xFF078B91);
  static const Color headerTurquoise = Color(0xFF066F75);
  // Compatibility aliases for older call sites; both resolve to turquoise.
  static const Color primaryPurple = primaryTurquoise;
  static const Color headerPurple = headerTurquoise;
  static const Color backgroundLight = Color(0xFFF0FAF9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFD9ECEA);
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const String fontFamily = 'Vazirmatn';
  static const BoxShadow shadowStyle = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}
