import 'package:flutter/material.dart';

/// Shared non-color tokens for the Arvin Material 3 design system.
/// Brand and semantic colors remain owned by ArvinColors.
abstract final class ArvinSpacing {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
}

abstract final class ArvinRadii {
  static const double small = 8;
  static const double control = 14;
  static const double card = 16;
  static const double navigation = 18;
  static const double dialog = 24;
  static const double sheet = 28;
  static const double pill = 999;
}

abstract final class ArvinMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration reduced = Duration.zero;
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;
}

abstract final class ArvinTouchTargets {
  static const double minimum = 48;
}

abstract final class ArvinTypography {
  static const double caption = 10.5;
  static const double label = 14;
  static const double body = 16;
  static const double bodyLarge = 18;
  static const double title = 22;
  static const double display = 28;
}

abstract final class ArvinShadows {
  static const double cardBlur = 8;
  static const Offset cardOffset = Offset(0, 2);
  static const double dialogBlur = 24;
  static const Offset dialogOffset = Offset(0, 8);
}

abstract final class ArvinButtonTokens {
  static const double height = 48;
  static const double minimumWidth = 48;
  static const double horizontalPadding = 16;
  static const double radius = ArvinRadii.control;
}

abstract final class ArvinInputTokens {
  static const double minimumHeight = 52;
  static const double horizontalPadding = 14;
  static const double radius = ArvinRadii.control;
}

abstract final class ArvinCardTokens {
  static const double padding = 16;
  static const double radius = ArvinRadii.card;
  static const double compactRadius = ArvinRadii.control;
  static const double elevation = 1;
  static const double verticalMargin = 2;
}

abstract final class ArvinNavigationTokens {
  static const double height = 60;
  static const double iconSize = 22;
  static const double horizontalInset = 10;
  static const double verticalInset = 7;
  static const double radius = ArvinRadii.navigation;
}

abstract final class ArvinDialogTokens {
  static const double padding = 20;
  static const double radius = ArvinRadii.dialog;
  static const double titleSize = 18;
}
