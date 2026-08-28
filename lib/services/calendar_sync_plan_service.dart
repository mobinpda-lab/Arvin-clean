import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../calendar_page.dart';
import 'system_calendar_bridge.dart';

class CalendarSyncRevision {
  const CalendarSyncRevision({
    required this.reminderId,
    required this.fingerprint,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
  });

  final String reminderId;
  final String fingerprint;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;
}

/// Local metadata linking one canonical Arvin reminder to one external event.
///
/// This is not a second calendar source of truth. Provider adapters may persist
/// these identifiers later so repeated sync can update the same external event
/// instead of creating duplicates.
class ExternalCalendarEventLink {
  ExternalCalendarEventLink({
    required this.reminderId,
    required this.calendarId,
    required this.eventId,
    required this.lastSyncedFingerprint,
  }) {
    if (reminderId.trim().isEmpty ||
        calendarId.trim().isEmpty ||
        eventId.trim().isEmpty ||
        lastSyncedFingerprint.trim().isEmpty) {
      throw ArgumentError('External calendar link fields must not be empty.');
    }
  }

  final String reminderId;
  final String calendarId;
  final String eventId;
  final String lastSyncedFingerprint;
}

enum CalendarSyncAction { create, update, noOp, delete }

class CalendarSyncPlanItem {
  const CalendarSyncPlanItem({
    required this.reminderId,
    required this.action,
    this.revision,
    this.link,
  });

  final String reminderId;
  final CalendarSyncAction action;
  final CalendarSyncRevision? revision;
  final ExternalCalendarEventLink? link;
}

class CalendarSyncPlan {
  CalendarSyncPlan(Iterable<CalendarSyncPlanItem> items)
      : items = List<CalendarSyncPlanItem>.unmodifiable(items);

  final List<CalendarSyncPlanItem> items;

  int count(CalendarSyncAction action) =>
      items.where((item) => item.action == action).length;
}

/// Produces stable provider-neutral revision evidence from canonical FollowUps.
class CalendarSyncRevisionService {
  CalendarSyncRevisionService({HashAlgorithm? hashAlgorithm})
      : _hashAlgorithm = hashAlgorithm ?? Sha256();

  final HashAlgorithm _hashAlgorithm;

  Future<CalendarSyncRevision> fromReminder(CalendarReminder reminder) async {
    if (!SystemCalendarBridge.isEligible(reminder)) {
      throw ArgumentError.value(
        reminder.id,
        'reminder.id',
        'Only active canonical FollowUp reminders are sync eligible.',
      );
    }
    final title = reminder.title.trim();
    if (title.isEmpty) {
      throw ArgumentError.value(reminder.title, 'reminder.title', 'Title is empty.');
    }

    final start = reminder.date;
    final end = reminder.isAllDay
        ? DateTime(start.year, start.month, start.day + 1)
        : start.add(const Duration(minutes: 30));
    final canonical = jsonEncode(<String, Object>{
      'id': reminder.id,
      'title': title,
      'startMillis': start.millisecondsSinceEpoch,
      'endMillis': end.millisecondsSinceEpoch,
      'allDay': reminder.isAllDay,
    });
    final hash = await _hashAlgorithm.hash(utf8.encode(canonical));

    return CalendarSyncRevision(
      reminderId: reminder.id,
      fingerprint: _toHex(hash.bytes),
      title: title,
      start: start,
      end: end,
      allDay: reminder.isAllDay,
    );
  }

  String _toHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

/// Plans idempotent create/update/delete operations for an external calendar.
///
/// Provider writes and link persistence are intentionally outside this class.
class CalendarSyncPlanService {
  const CalendarSyncPlanService();

  CalendarSyncPlan plan({
    required Iterable<CalendarSyncRevision> revisions,
    required Iterable<ExternalCalendarEventLink> links,
  }) {
    final revisionById = _indexRevisions(revisions);
    final linkById = _indexLinks(links);
    final ids = <String>{...revisionById.keys, ...linkById.keys}.toList()..sort();
    final items = <CalendarSyncPlanItem>[];

    for (final id in ids) {
      final revision = revisionById[id];
      final link = linkById[id];
      late final CalendarSyncAction action;
      if (revision != null && link == null) {
        action = CalendarSyncAction.create;
      } else if (revision == null && link != null) {
        action = CalendarSyncAction.delete;
      } else if (revision!.fingerprint == link!.lastSyncedFingerprint) {
        action = CalendarSyncAction.noOp;
      } else {
        action = CalendarSyncAction.update;
      }

      items.add(
        CalendarSyncPlanItem(
          reminderId: id,
          action: action,
          revision: revision,
          link: link,
        ),
      );
    }

    return CalendarSyncPlan(items);
  }

  Map<String, CalendarSyncRevision> _indexRevisions(
    Iterable<CalendarSyncRevision> values,
  ) {
    final result = <String, CalendarSyncRevision>{};
    for (final value in values) {
      if (value.reminderId.isEmpty || result.containsKey(value.reminderId)) {
        throw ArgumentError('Duplicate or empty calendar sync revision id.');
      }
      result[value.reminderId] = value;
    }
    return result;
  }

  Map<String, ExternalCalendarEventLink> _indexLinks(
    Iterable<ExternalCalendarEventLink> values,
  ) {
    final result = <String, ExternalCalendarEventLink>{};
    for (final value in values) {
      if (result.containsKey(value.reminderId)) {
        throw ArgumentError('Duplicate external calendar link id.');
      }
      result[value.reminderId] = value;
    }
    return result;
  }
}
