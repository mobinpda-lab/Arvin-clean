abstract final class AppFonts {
  /// Canonical Persian UI font: VazirHarf v34.003.
  static const String vazirHarfFamily = 'VazirHarf';

  /// Compatibility helper for existing call sites.
  static String familyForText(String text) => vazirHarfFamily;
}
