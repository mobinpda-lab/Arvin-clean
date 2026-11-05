import 'package:flutter/material.dart';

/// Shared visual tokens for Arvin's Microsoft To Do-inspired card system.
/// Keep product semantics (priority, status and taxonomy colors) in ArvinColors.
abstract final class ArvinTheme {
  static const Color primaryPurple = Color(0xFF3F3D56);
  static const Color headerPurple = Color(0xFF2D2B42);
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE6E7EE);
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16.0));
  static const String fontFamily = 'Vazirmatn';
  static const BoxShadow shadowStyle = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}
