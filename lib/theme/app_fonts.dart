abstract final class AppFonts {
  /// The single and only text family permitted in the Arvin UI.
  static const String vazirmatnFamily = 'Vazirmatn';

  /// Compatibility helper for existing call sites. Sacred phrases are being
  /// migrated to dedicated SVG path assets; until then, text remains Vazirmatn.
  static String familyForText(String text) => vazirmatnFamily;
}
