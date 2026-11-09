import 'package:flutter/material.dart';

/// Canonical Arvin Blue & White brand tokens.
/// User-selectable palette colors are secondary accents only and never brand tokens.
abstract final class ArvinTheme {
  static const Color primaryBlue = Color(0xFF4169A1);
  static const Color headerBlue = Color(0xFF355782);
  static const Color primarySoft = Color(0xFFE5EDF8);
  static const Color iceBlue = Color(0xFFF0F5FC);
  static const Color lightNeutral = Color(0xFFF4F6F9);

  // Compatibility aliases retained for existing semantic call sites.
  static const Color primaryTeal = primaryBlue;
  static const Color headerTeal = headerBlue;
  static const Color primaryTurquoise = primaryBlue;
  static const Color headerTurquoise = headerBlue;
  static const Color primaryPurple = primaryBlue;
  static const Color headerPurple = headerBlue;

  static const Color backgroundLight = lightNeutral;
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7F0);
  // Keep the legacy shadow token for Dark Mode; use brandGlow in Light Mode.
  static const Color primaryGlow = Color(0x40008080);
  static const Color brandGlow = Color(0x404169A1);
  static Color shadowFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryGlow : brandGlow;
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
