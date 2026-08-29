import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskSwipeAction { archive, trash, none }

class CalendarIntegrationSettings {
  const CalendarIntegrationSettings({
    this.enabled = false,
    this.showExternalEvents = false,
    this.syncArvinToDevice = false,
    this.visibleCalendarIds = const <String>{},
    this.targetCalendarId,
    this.syncDueDates = true,
    this.syncTaskReminders = true,
    this.syncFollowUps = true,
    this.syncFollowUpReminders = true,
    this.syncRecurrence = false,
    this.autoSync = false,
    this.deleteLinkedEventWithTask = false,
  });

  final bool enabled;
  final bool showExternalEvents;
  final bool syncArvinToDevice;
  final Set<String> visibleCalendarIds;
  final String? targetCalendarId;
  final bool syncDueDates;
  final bool syncTaskReminders;
  final bool syncFollowUps;
  final bool syncFollowUpReminders;
  final bool syncRecurrence;
  final bool autoSync;
  final bool deleteLinkedEventWithTask;

  CalendarIntegrationSettings copyWith({
    bool? enabled,
    bool? showExternalEvents,
    bool? syncArvinToDevice,
    Set<String>? visibleCalendarIds,
    String? targetCalendarId,
    bool clearTargetCalendarId = false,
    bool? syncDueDates,
    bool? syncTaskReminders,
    bool? syncFollowUps,
    bool? syncFollowUpReminders,
    bool? syncRecurrence,
    bool? autoSync,
    bool? deleteLinkedEventWithTask,
  }) {
    return CalendarIntegrationSettings(
      enabled: enabled ?? this.enabled,
      showExternalEvents: showExternalEvents ?? this.showExternalEvents,
      syncArvinToDevice: syncArvinToDevice ?? this.syncArvinToDevice,
      visibleCalendarIds: Set<String>.unmodifiable(
        visibleCalendarIds ?? this.visibleCalendarIds,
      ),
      targetCalendarId: clearTargetCalendarId
          ? null
          : _normalizeOptionalId(targetCalendarId) ?? this.targetCalendarId,
      syncDueDates: syncDueDates ?? this.syncDueDates,
      syncTaskReminders: syncTaskReminders ?? this.syncTaskReminders,
      syncFollowUps: syncFollowUps ?? this.syncFollowUps,
      syncFollowUpReminders:
          syncFollowUpReminders ?? this.syncFollowUpReminders,
      syncRecurrence: syncRecurrence ?? this.syncRecurrence,
      autoSync: autoSync ?? this.autoSync,
      deleteLinkedEventWithTask:
          deleteLinkedEventWithTask ?? this.deleteLinkedEventWithTask,
    );
  }

  static String? _normalizeOptionalId(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.usePersianDate,
    required this.fontFamily,
    this.swipeRightAction = TaskSwipeAction.trash,
    this.swipeLeftAction = TaskSwipeAction.archive,
    this.calendarIntegration = const CalendarIntegrationSettings(),
  });

  final ThemeMode themeMode;
  final bool usePersianDate;
  final String? fontFamily;
  final TaskSwipeAction swipeRightAction;
  final TaskSwipeAction swipeLeftAction;
  final CalendarIntegrationSettings calendarIntegration;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? usePersianDate,
    String? fontFamily,
    bool clearFontFamily = false,
    TaskSwipeAction? swipeRightAction,
    TaskSwipeAction? swipeLeftAction,
    CalendarIntegrationSettings? calendarIntegration,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      usePersianDate: usePersianDate ?? this.usePersianDate,
      fontFamily: clearFontFamily ? null : (fontFamily ?? this.fontFamily),
      swipeRightAction: swipeRightAction ?? this.swipeRightAction,
      swipeLeftAction: swipeLeftAction ?? this.swipeLeftAction,
      calendarIntegration: calendarIntegration ?? this.calendarIntegration,
    );
  }
}

class AppSettingsService {
  static const _themeModeKey = 'arvin.settings.themeMode';
  static const _persianDateKey = 'arvin.settings.usePersianDate';
  static const _fontFamilyKey = 'arvin.settings.fontFamily';
  static const _swipeRightKey = 'arvin.settings.swipeRightAction';
  static const _swipeLeftKey = 'arvin.settings.swipeLeftAction';

  static const _calendarEnabledKey = 'arvin.settings.calendar.enabled';
  static const _calendarShowExternalKey =
      'arvin.settings.calendar.showExternalEvents';
  static const _calendarSyncOutboundKey =
      'arvin.settings.calendar.syncArvinToDevice';
  static const _calendarVisibleIdsKey =
      'arvin.settings.calendar.visibleCalendarIds';
  static const _calendarTargetIdKey = 'arvin.settings.calendar.targetCalendarId';
  static const _calendarSyncDueKey = 'arvin.settings.calendar.syncDueDates';
  static const _calendarSyncTaskReminderKey =
      'arvin.settings.calendar.syncTaskReminders';
  static const _calendarSyncFollowUpKey =
      'arvin.settings.calendar.syncFollowUps';
  static const _calendarSyncFollowUpReminderKey =
      'arvin.settings.calendar.syncFollowUpReminders';
  static const _calendarSyncRecurrenceKey =
      'arvin.settings.calendar.syncRecurrence';
  static const _calendarAutoSyncKey = 'arvin.settings.calendar.autoSync';
  static const _calendarDeleteLinkedKey =
      'arvin.settings.calendar.deleteLinkedEventWithTask';

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
      calendarIntegration: _loadCalendarIntegration(preferences),
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

  Future<void> saveCalendarIntegrationSettings(
    CalendarIntegrationSettings settings,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_calendarEnabledKey, settings.enabled);
    await preferences.setBool(
      _calendarShowExternalKey,
      settings.showExternalEvents,
    );
    await preferences.setBool(
      _calendarSyncOutboundKey,
      settings.syncArvinToDevice,
    );
    final visibleIds = settings.visibleCalendarIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    await preferences.setStringList(_calendarVisibleIdsKey, visibleIds);

    final targetId = _normalizeCalendarId(settings.targetCalendarId);
    if (targetId == null) {
      await preferences.remove(_calendarTargetIdKey);
    } else {
      await preferences.setString(_calendarTargetIdKey, targetId);
    }

    await preferences.setBool(_calendarSyncDueKey, settings.syncDueDates);
    await preferences.setBool(
      _calendarSyncTaskReminderKey,
      settings.syncTaskReminders,
    );
    await preferences.setBool(
      _calendarSyncFollowUpKey,
      settings.syncFollowUps,
    );
    await preferences.setBool(
      _calendarSyncFollowUpReminderKey,
      settings.syncFollowUpReminders,
    );
    await preferences.setBool(
      _calendarSyncRecurrenceKey,
      settings.syncRecurrence,
    );
    await preferences.setBool(_calendarAutoSyncKey, settings.autoSync);
    await preferences.setBool(
      _calendarDeleteLinkedKey,
      settings.deleteLinkedEventWithTask,
    );
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
    final current = await load();
    final restored = decodePortableJson(json).copyWith(
      calendarIntegration: current.calendarIntegration,
    );
    await saveSettings(restored);
    return restored;
  }

  CalendarIntegrationSettings _loadCalendarIntegration(
    SharedPreferences preferences,
  ) {
    final rawVisibleIds =
        preferences.getStringList(_calendarVisibleIdsKey) ?? const <String>[];
    final visibleIds = rawVisibleIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    return CalendarIntegrationSettings(
      enabled: preferences.getBool(_calendarEnabledKey) ?? false,
      showExternalEvents:
          preferences.getBool(_calendarShowExternalKey) ?? false,
      syncArvinToDevice:
          preferences.getBool(_calendarSyncOutboundKey) ?? false,
      visibleCalendarIds: Set<String>.unmodifiable(visibleIds),
      targetCalendarId:
          _normalizeCalendarId(preferences.getString(_calendarTargetIdKey)),
      syncDueDates: preferences.getBool(_calendarSyncDueKey) ?? true,
      syncTaskReminders:
          preferences.getBool(_calendarSyncTaskReminderKey) ?? true,
      syncFollowUps: preferences.getBool(_calendarSyncFollowUpKey) ?? true,
      syncFollowUpReminders:
          preferences.getBool(_calendarSyncFollowUpReminderKey) ?? true,
      syncRecurrence: preferences.getBool(_calendarSyncRecurrenceKey) ?? false,
      autoSync: preferences.getBool(_calendarAutoSyncKey) ?? false,
      deleteLinkedEventWithTask:
          preferences.getBool(_calendarDeleteLinkedKey) ?? false,
    );
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

  String? _normalizeCalendarId(String? id) {
    final value = id?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
