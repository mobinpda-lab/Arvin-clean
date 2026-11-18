/// Shared non-color design tokens for the Arvin Material 3 interface.
/// Color values remain owned by [ArvinColors] in arvin_colors.dart.
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
  static const double pill = 999;
}

abstract final class ArvinMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
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
}
