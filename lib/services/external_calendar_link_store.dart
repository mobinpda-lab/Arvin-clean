import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_sync_plan_service.dart';

/// Persists only provider-link metadata needed for idempotent external sync.
///
/// This store is intentionally separate from canonical Task data and is not
/// part of portable backup/export state.
class ExternalCalendarLinkStore {
  ExternalCalendarLinkStore({
    this.preferencesKey = 'arvin.calendar.externalLinks',
  });

  final String preferencesKey;

  Future<List<ExternalCalendarEventLink>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(preferencesKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <ExternalCalendarEventLink>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('External calendar link payload is invalid.');
    }

    final links = <ExternalCalendarEventLink>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final value = Map<String, Object?>.from(item);
      try {
        links.add(
          ExternalCalendarEventLink(
            reminderId: value['reminderId'] as String? ?? '',
            calendarId: value['calendarId'] as String? ?? '',
            eventId: value['eventId'] as String? ?? '',
            lastSyncedFingerprint:
                value['lastSyncedFingerprint'] as String? ?? '',
          ),
        );
      } on ArgumentError {
        continue;
      }
    }
    return List<ExternalCalendarEventLink>.unmodifiable(links);
  }

  Future<void> save(Iterable<ExternalCalendarEventLink> links) async {
    final values = links.toList(growable: false)
      ..sort((a, b) => a.reminderId.compareTo(b.reminderId));
    final payload = values
        .map(
          (link) => <String, Object>{
            'reminderId': link.reminderId,
            'calendarId': link.calendarId,
            'eventId': link.eventId,
            'lastSyncedFingerprint': link.lastSyncedFingerprint,
          },
        )
        .toList(growable: false);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferencesKey, jsonEncode(payload));
  }
}
