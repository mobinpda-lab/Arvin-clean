import 'package:shared_preferences/shared_preferences.dart';

import '../daily_content.dart';

class DailyContentPreferences {
  const DailyContentPreferences({
    required this.enabled,
    required this.notificationEnabled,
    required this.notificationHour,
    required this.notificationMinute,
    required this.enabledKinds,
  });

  final bool enabled;
  final bool notificationEnabled;
  final int notificationHour;
  final int notificationMinute;
  final Set<DailyContentKind> enabledKinds;

  bool isKindEnabled(DailyContentKind kind) => enabled && enabledKinds.contains(kind);

  DailyContentPreferences copyWith({
    bool? enabled,
    bool? notificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    Set<DailyContentKind>? enabledKinds,
  }) {
    return DailyContentPreferences(
      enabled: enabled ?? this.enabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      enabledKinds: Set.unmodifiable(enabledKinds ?? this.enabledKinds),
    );
  }
}

class DailyContentPreferencesService {
  static const _enabledKey = 'arvin.dailyContent.enabled';
  static const _notificationEnabledKey = 'arvin.dailyContent.notificationEnabled';
  static const _notificationHourKey = 'arvin.dailyContent.notificationHour';
  static const _notificationMinuteKey = 'arvin.dailyContent.notificationMinute';
  static const _enabledKindsKey = 'arvin.dailyContent.enabledKinds';

  static const defaultNotificationHour = 8;
  static const defaultNotificationMinute = 0;

  Future<DailyContentPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawKinds = preferences.getStringList(_enabledKindsKey);
    final kinds = rawKinds == null
        ? DailyContentKind.values.toSet()
        : rawKinds
            .map(_decodeKind)
            .whereType<DailyContentKind>()
            .toSet();

    return DailyContentPreferences(
      enabled: preferences.getBool(_enabledKey) ?? true,
      notificationEnabled:
          preferences.getBool(_notificationEnabledKey) ?? false,
      notificationHour: _validHour(preferences.getInt(_notificationHourKey)),
      notificationMinute:
          _validMinute(preferences.getInt(_notificationMinuteKey)),
      enabledKinds: Set.unmodifiable(kinds),
    );
  }

  Future<void> saveEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, value);
  }

  Future<void> saveNotificationEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notificationEnabledKey, value);
  }

  Future<void> saveNotificationTime({required int hour, required int minute}) async {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Daily Content notification time is invalid');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_notificationHourKey, hour);
    await preferences.setInt(_notificationMinuteKey, minute);
  }

  Future<void> saveKindEnabled(DailyContentKind kind, bool enabled) async {
    final current = await load();
    final kinds = current.enabledKinds.toSet();
    if (enabled) {
      kinds.add(kind);
    } else {
      kinds.remove(kind);
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _enabledKindsKey,
      kinds.map((item) => item.name).toList(growable: false)..sort(),
    );
  }

  int _validHour(int? value) =>
      value != null && value >= 0 && value <= 23 ? value : defaultNotificationHour;

  int _validMinute(int? value) => value != null && value >= 0 && value <= 59
      ? value
      : defaultNotificationMinute;

  DailyContentKind? _decodeKind(String raw) {
    for (final kind in DailyContentKind.values) {
      if (kind.name == raw) return kind;
    }
    return null;
  }
}
