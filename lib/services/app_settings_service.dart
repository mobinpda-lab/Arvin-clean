import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskSwipeAction { archive, trash, none }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.usePersianDate,
    required this.fontFamily,
    this.swipeRightAction = TaskSwipeAction.trash,
    this.swipeLeftAction = TaskSwipeAction.archive,
  });

  final ThemeMode themeMode;
  final bool usePersianDate;
  final String? fontFamily;
  final TaskSwipeAction swipeRightAction;
  final TaskSwipeAction swipeLeftAction;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? usePersianDate,
    String? fontFamily,
    bool clearFontFamily = false,
    TaskSwipeAction? swipeRightAction,
    TaskSwipeAction? swipeLeftAction,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      usePersianDate: usePersianDate ?? this.usePersianDate,
      fontFamily: clearFontFamily ? null : (fontFamily ?? this.fontFamily),
      swipeRightAction: swipeRightAction ?? this.swipeRightAction,
      swipeLeftAction: swipeLeftAction ?? this.swipeLeftAction,
    );
  }
}

class AppSettingsService {
  static const _themeModeKey = 'arvin.settings.themeMode';
  static const _persianDateKey = 'arvin.settings.usePersianDate';
  static const _fontFamilyKey = 'arvin.settings.fontFamily';
  static const _swipeRightKey = 'arvin.settings.swipeRightAction';
  static const _swipeLeftKey = 'arvin.settings.swipeLeftAction';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings(
      themeMode: _decodeThemeMode(preferences.getString(_themeModeKey)),
      usePersianDate: preferences.getBool(_persianDateKey) ?? true,
      fontFamily: _normalizeFontFamily(preferences.getString(_fontFamilyKey)),
      swipeRightAction: _decodeSwipeAction(
        preferences.getString(_swipeRightKey),
        fallback: TaskSwipeAction.trash,
      ),
      swipeLeftAction: _decodeSwipeAction(
        preferences.getString(_swipeLeftKey),
        fallback: TaskSwipeAction.archive,
      ),
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

  Future<void> saveSwipeActions({
    required TaskSwipeAction right,
    required TaskSwipeAction left,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_swipeRightKey, right.name);
    await preferences.setString(_swipeLeftKey, left.name);
  }

  Map<String, dynamic> toPortableJson(AppSettings settings) {
    final family = _normalizeFontFamily(settings.fontFamily);
    return <String, dynamic>{
      'themeMode': settings.themeMode.name,
      'usePersianDate': settings.usePersianDate,
      'swipeRightAction': settings.swipeRightAction.name,
      'swipeLeftAction': settings.swipeLeftAction.name,
      if (family != null) 'fontFamily': family,
    };
  }

  AppSettings decodePortableJson(Map<String, dynamic> json) {
    final rawThemeMode = json['themeMode'];
    final rawPersianDate = json['usePersianDate'];
    final rawFontFamily = json['fontFamily'];
    final rawSwipeRight = json['swipeRightAction'];
    final rawSwipeLeft = json['swipeLeftAction'];

    if (rawThemeMode != null && rawThemeMode is! String) {
      throw const FormatException('Arvin backup theme setting is invalid');
    }
    if (rawPersianDate != null && rawPersianDate is! bool) {
      throw const FormatException('Arvin backup Persian-date setting is invalid');
    }
    if (rawFontFamily != null && rawFontFamily is! String) {
      throw const FormatException('Arvin backup font setting is invalid');
    }
    if (rawSwipeRight != null && rawSwipeRight is! String) {
      throw const FormatException('Arvin backup right-swipe setting is invalid');
    }
    if (rawSwipeLeft != null && rawSwipeLeft is! String) {
      throw const FormatException('Arvin backup left-swipe setting is invalid');
    }

    ThemeMode themeMode = ThemeMode.system;
    if (rawThemeMode is String) {
      final matching = ThemeMode.values.where((mode) => mode.name == rawThemeMode);
      if (matching.isEmpty) {
        throw const FormatException('Arvin backup theme setting is unsupported');
      }
      themeMode = matching.first;
    }

    return AppSettings(
      themeMode: themeMode,
      usePersianDate: rawPersianDate is bool ? rawPersianDate : true,
      fontFamily: _normalizeFontFamily(rawFontFamily as String?),
      swipeRightAction: _decodePortableSwipeAction(
        rawSwipeRight as String?,
        fallback: TaskSwipeAction.trash,
        side: 'right',
      ),
      swipeLeftAction: _decodePortableSwipeAction(
        rawSwipeLeft as String?,
        fallback: TaskSwipeAction.archive,
        side: 'left',
      ),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, settings.themeMode.name);
    await preferences.setBool(_persianDateKey, settings.usePersianDate);
    await preferences.setString(_swipeRightKey, settings.swipeRightAction.name);
    await preferences.setString(_swipeLeftKey, settings.swipeLeftAction.name);

    final family = _normalizeFontFamily(settings.fontFamily);
    if (family == null) {
      await preferences.remove(_fontFamilyKey);
    } else {
      await preferences.setString(_fontFamilyKey, family);
    }
  }

  Future<AppSettings> restorePortableJson(Map<String, dynamic> json) async {
    final settings = decodePortableJson(json);
    await saveSettings(settings);
    return settings;
  }

  ThemeMode _decodeThemeMode(String? raw) {
    return ThemeMode.values.where((mode) => mode.name == raw).firstOrNull ??
        ThemeMode.system;
  }

  TaskSwipeAction _decodeSwipeAction(
    String? raw, {
    required TaskSwipeAction fallback,
  }) {
    return TaskSwipeAction.values
            .where((action) => action.name == raw)
            .firstOrNull ??
        fallback;
  }

  TaskSwipeAction _decodePortableSwipeAction(
    String? raw, {
    required TaskSwipeAction fallback,
    required String side,
  }) {
    if (raw == null) return fallback;
    final matching = TaskSwipeAction.values.where((action) => action.name == raw);
    if (matching.isEmpty) {
      throw FormatException('Arvin backup $side-swipe setting is unsupported');
    }
    return matching.first;
  }

  String? _normalizeFontFamily(String? family) {
    final value = family?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
