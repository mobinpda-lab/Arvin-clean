import 'package:flutter/services.dart';

abstract final class AppFonts {
  static const String vazirharfFamily = 'VazirHarf';
  static const String vazirmatnFamily = 'Vazirmatn';
  static const String vazirmatnRegularAsset =
      'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf';
  static const String vazirmatnMediumAsset =
      'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf';
  static const String vazirmatnBoldAsset =
      'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf';
  static const String vazirmatnFamily = 'Vazirmatn';

  static const String vazirmatnRegularAsset =
      'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf';
  static const String vazirmatnMediumAsset =
      'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf';
  static const String vazirmatnBoldAsset =
      'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf';
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
      // VazirHarf is bundled and is the public/default project font.
      // Licensed IRANSansX takes precedence only when private assets exist.
      return false;
    }
  }
}
