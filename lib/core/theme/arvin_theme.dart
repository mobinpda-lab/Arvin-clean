import 'package:flutter/material.dart';

import '../../theme/arvin_design_tokens.dart';

/// Canonical Arvin teal brand tokens. User-selectable palette colors remain
/// secondary accents and never replace these fixed product identity colors.
abstract final class ArvinTheme {
  static const Color primaryTeal = Color(0xFF078B91);
  static const Color headerTeal = Color(0xFF066F75);
  static const Color primarySoft = Color(0xFFDDF7F5);
  static const Color backgroundLight = Color(0xFFF0FAF9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFD9ECEA);

  // Compatibility names retained while call sites migrate to semantic tokens.
  static const Color primaryBlue = primaryTeal;
  static const Color headerBlue = headerTeal;
  static const Color iceBlue = primarySoft;
  static const Color lightNeutral = backgroundLight;
  static const Color primaryTurquoise = primaryTeal;
  static const Color headerTurquoise = headerTeal;
  static const Color primaryPurple = primaryTeal;
  static const Color headerPurple = headerTeal;

  // Brand-colored shadow tokens remain subtle against the approved surfaces.
  static const Color primaryGlow = Color(0x40078B91);
  static const Color brandGlow = Color(0x40078B91);
  static Color shadowFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryGlow : brandGlow;

  static const BorderRadius cardBorderRadius =
      BorderRadius.all(Radius.circular(ArvinCardTokens.radius));
  static const String fontFamily = 'Vazirmatn';
  static const BoxShadow shadowStyle = BoxShadow(
    color: primaryGlow,
    blurRadius: ArvinShadows.cardBlur,
    spreadRadius: ArvinShadows.cardSpread,
    offset: ArvinShadows.cardOffset,
  );
}
