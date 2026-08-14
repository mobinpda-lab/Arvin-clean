import 'package:shared_preferences/shared_preferences.dart';

/// Persistent typography preferences for Arvin.
///
/// IranSansX is the product default; a user-selected family can override it
/// without changing the rest of the UI code.
class FontPreferences {
  const FontPreferences._();

  static const defaultFamily = 'IranSansX';
  static const defaultSize = 16.0;
  static const _familyKey = 'ui.font.family';
  static const _sizeKey = 'ui.font.size';

  static Future<String> family() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_familyKey) ?? defaultFamily;
  }

  static Future<double> size() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sizeKey) ?? defaultSize;
  }

  static Future<void> save({String? family, double? size}) async {
    final prefs = await SharedPreferences.getInstance();
    if (family != null && family.trim().isNotEmpty) {
      await prefs.setString(_familyKey, family.trim());
    }
    if (size != null && size >= 10 && size <= 30) {
      await prefs.setDouble(_sizeKey, size);
    }
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_familyKey);
    await prefs.remove(_sizeKey);
  }
}
