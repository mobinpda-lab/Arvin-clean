import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_sync_plan_service.dart';

/// Persists only provider-link metadata needed for idempotent external sync.
///
/// This store remains separate from canonical Task data, but its link metadata
/// is serialized into the existing portable backup document. Provider identity
/// must still be verified before any restored link authorizes a write/delete.
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

  /// Returns whether this provider event instance was already imported.
  Future<bool> hasImportedEvent(String reminderId) async {
    final normalized = reminderId.trim();
    if (normalized.isEmpty) return false;
    return (await load()).any(
      (link) => link.reminderId == normalized &&
          link.lastSyncedFingerprint.startsWith('imported-task:'),
    );
  }

  /// Records the stable provider instance identity against its canonical Task.
  /// The existing link metadata is reused; no second Task or import store is added.
  Future<bool> registerImportedEvent({
    required String reminderId,
    required String calendarId,
    required String instanceId,
    required String taskId,
  }) async {
    final normalizedReminderId = reminderId.trim();
    final normalizedCalendarId = calendarId.trim();
    final normalizedInstanceId = instanceId.trim();
    final normalizedTaskId = taskId.trim();
    if (normalizedReminderId.isEmpty ||
        normalizedCalendarId.isEmpty ||
        normalizedInstanceId.isEmpty ||
        normalizedTaskId.isEmpty) {
      throw ArgumentError('Imported event identity and Task id must not be empty.');
    }

    final existing = await load();
    if (existing.any((link) => link.reminderId == normalizedReminderId)) {
      return false;
    }
    await save([
      ...existing,
      ExternalCalendarEventLink(
        reminderId: normalizedReminderId,
        calendarId: normalizedCalendarId,
        eventId: normalizedInstanceId,
        lastSyncedFingerprint: 'imported-task:$normalizedTaskId',
      ),
    ]);
    return true;
  }

  Future<void> removeByReminderIds(Iterable<String> reminderIds) async {
    final ids = reminderIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) return;
    final existing = await load();
    await save(existing.where((link) => !ids.contains(link.reminderId)));
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
