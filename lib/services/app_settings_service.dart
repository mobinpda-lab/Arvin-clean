import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.usePersianDate,
    required this.fontFamily,
  });

  final ThemeMode themeMode;
  final bool usePersianDate;
  final String? fontFamily;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? usePersianDate,
    String? fontFamily,
    bool clearFontFamily = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      usePersianDate: usePersianDate ?? this.usePersianDate,
      fontFamily: clearFontFamily ? null : (fontFamily ?? this.fontFamily),
    );
  }
}

class AppSettingsService {
  static const _themeModeKey = 'arvin.settings.themeMode';
  static const _persianDateKey = 'arvin.settings.usePersianDate';
  static const _fontFamilyKey = 'arvin.settings.fontFamily';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings(
      themeMode: _decodeThemeMode(preferences.getString(_themeModeKey)),
      usePersianDate: preferences.getBool(_persianDateKey) ?? false,
      fontFamily: _normalizeFontFamily(preferences.getString(_fontFamilyKey)),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, mode.name);
  }

  Future<void> saveUsePersianDate(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_persianDateKey, enabled);
  }

  Future<void> saveFontFamily(String? family) async {
    final preferences = await SharedPreferences.getInstance();
    final normalized = _normalizeFontFamily(family);
    if (normalized == null) {
      await preferences.remove(_fontFamilyKey);
      return;
    }
    await preferences.setString(_fontFamilyKey, normalized);
  }

  ThemeMode _decodeThemeMode(String? raw) {
    return ThemeMode.values.where((mode) => mode.name == raw).firstOrNull ??
        ThemeMode.system;
  }

  String? _normalizeFontFamily(String? family) {
    final value = family?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
