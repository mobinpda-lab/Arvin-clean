import 'package:flutter/services.dart';

abstract final class AppFonts {
  static const String family = 'IRANSansXFaNum';
  static const String regularAsset =
      'assets/fonts/IRANSansXFaNum-Regular.ttf';
  static const String boldAsset = 'assets/fonts/IRANSansXFaNum-Bold.ttf';

  static Future<bool> loadLicensedIranSansX() async {
    final loader = FontLoader(family);
    try {
      loader.addFont(rootBundle.load(regularAsset));
      loader.addFont(rootBundle.load(boldAsset));
      await loader.load();
      return true;
    } catch (_) {
      // Public CI intentionally has no proprietary font binaries. In that
      // environment Flutter falls back to the platform font and still builds.
      return false;
    }
  }
}
