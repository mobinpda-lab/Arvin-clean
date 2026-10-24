import 'package:flutter/services.dart';

abstract final class AppFonts {
  /// Canonical UI family. Keep role weights aligned with docs/TYPOGRAPHY_CANONICAL.md.
  static const String vazirmatnFamily = 'Vazirmatn';

  /// PDF/report-only family; it must not be used as a UI fallback.
  static const String vazirharfFamily = 'VazirHarf';
  static const String iranSansXFamily = 'IRANSansXFaNum';

  static const String iranSansXRegularAsset =
      'assets/fonts/IRANSansXFaNum-Regular.ttf';
  static const String iranSansXBoldAsset =
      'assets/fonts/IRANSansXFaNum-Bold.ttf';

  static Future<bool> loadLicensedIranSansX() async {
    final loader = FontLoader(iranSansXFamily);
    try {
      loader.addFont(rootBundle.load(iranSansXRegularAsset));
      loader.addFont(rootBundle.load(iranSansXBoldAsset));
      await loader.load();
      return true;
    } catch (_) {
      // This optional private font loader is not part of the canonical UI font.
      // The UI always uses the bundled Vazirmatn family.
      return false;
    }
  }
}
