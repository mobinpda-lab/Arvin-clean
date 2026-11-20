import 'dart:convert';

import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _linksKey = 'arvin.calendar.externalLinks.command20e';
const String _phaseKey = 'arvin.calendar.externalLinks.command20e.phase';

final List<ExternalCalendarEventLink> _expected = <ExternalCalendarEventLink>[
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-01',
    calendarId: 'android-calendar-account-01',
    eventId: 'android-provider-event-1000',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-01',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-02',
    calendarId: 'android-calendar-account-02',
    eventId: 'android-provider-event-1001',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-02',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-03',
    calendarId: 'android-calendar-account-03',
    eventId: 'android-provider-event-1002',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-03',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-04',
    calendarId: 'android-calendar-account-04',
    eventId: 'android-provider-event-1003',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-04',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-05',
    calendarId: 'android-calendar-account-05',
    eventId: 'android-provider-event-1004',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-05',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-06',
    calendarId: 'android-calendar-account-06',
    eventId: 'android-provider-event-1005',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-06',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-07',
    calendarId: 'android-calendar-account-07',
    eventId: 'android-provider-event-1006',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-07',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-08',
    calendarId: 'android-calendar-account-08',
    eventId: 'android-provider-event-1007',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-08',
  ),
];

Map<String, Object?> _values(ExternalCalendarEventLink link) => <String, Object?>{
      'reminderId': link.reminderId,
      'calendarId': link.calendarId,
      'eventId': link.eventId,
      'lastSyncedFingerprint': link.lastSyncedFingerprint,
    };

String _linkId(ExternalCalendarEventLink link) => link.reminderId;

Map<String, ExternalCalendarEventLink> _indexById(
  List<ExternalCalendarEventLink> links,
) {
  final indexed = <String, ExternalCalendarEventLink>{};
  for (final link in links) {
    final id = _linkId(link);
    if (indexed.containsKey(id)) {
      throw StateError('Duplicate Calendar Link identity: $id');
    }
    indexed[id] = link;
  }
  return indexed;
}

void _verify(List<ExternalCalendarEventLink> actual, String stage) {
  final expectedById = _indexById(_expected);
  final actualById = _indexById(actual);
  if (actualById.length != 8) {
    throw StateError('$stage: expected 8 independent Links; found ${actualById.length}.');
  }
  for (final entry in expectedById.entries) {
    final id = entry.key;
    final restored = actualById[id];
    if (restored == null) {
      throw StateError('$stage: missing Calendar Link $id.');
    }
    final expectedValues = _values(entry.value);
    final actualValues = _values(restored);
    for (final field in expectedValues.keys) {
      if (actualValues[field] != expectedValues[field]) {
        throw StateError('$stage: Link $id field $field mismatch: '
            'expected=${expectedValues[field]} actual=${actualValues[field]}');
      }
      debugPrintSynchronously(
        'CALENDAR_LINK_ASSERTION=PASS id=$id field=$field value=${actualValues[field]}',
      );
    }
  }
}

void _emitValues(List<ExternalCalendarEventLink> links, String marker) {
  final indexed = _indexById(links);
  for (final expected in _expected) {
    final id = _linkId(expected);
    final actual = indexed[id]!;
    debugPrintSynchronously(
      '$marker=${jsonEncode(<String, Object?>{
        'linkId': id,
        'actual': _values(actual),
      })}',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final store = ExternalCalendarLinkStore(preferencesKey: _linksKey);
  final phase = preferences.getString(_phaseKey);
  late final String visiblePhase;

  if (phase == null) {
    await preferences.remove(_linksKey);
    await store.save(_expected);
    await preferences.setString(_phaseKey, 'written');
    await preferences.reload();
    final saved = await store.load();
    _verify(saved, 'STAGE_A');
    _emitValues(saved, 'CALENDAR_LINK_STAGE_A_VALUE');
    debugPrintSynchronously('CALENDAR_LINK_COUNT=8');
    debugPrintSynchronously('CALENDAR_LINK_FIELDS_PER_LINK=4');
    debugPrintSynchronously('CALENDAR_LINK_TOTAL_ASSERTIONS=32');
    debugPrintSynchronously('CALENDAR_LINK_STAGE_A_WRITE=PASS');
    visiblePhase = 'WRITE COMPLETE — stop and relaunch this process';
  } else if (phase == 'written') {
    await preferences.reload();
    final restored = await store.load();
    _verify(restored, 'STAGE_B');
    _emitValues(restored, 'CALENDAR_LINK_STAGE_B_VALUE');
    debugPrintSynchronously('CALENDAR_LINK_STAGE_B_READ=PASS');
    debugPrintSynchronously('CALENDAR_LINK_ALL_EIGHT_LINKS_MATCH=PASS');
    debugPrintSynchronously('CALENDAR_LINK_ALL_THIRTY_TWO_ASSERTIONS=PASS');
    await preferences.remove(_linksKey);
    await preferences.remove(_phaseKey);
    await preferences.reload();
    if (preferences.getString(_linksKey) != null ||
        preferences.getString(_phaseKey) != null) {
      throw StateError('Calendar test fixture cleanup did not persist.');
    }
    debugPrintSynchronously('CALENDAR_LINK_TEST_KEY_CLEANUP=PASS');
    visiblePhase = 'READ COMPLETE — fixture keys cleaned';
  } else {
    throw StateError('Unexpected COMMAND 20-E fixture phase: $phase');
  }

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Arvin COMMAND 20-E\n$visiblePhase',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
