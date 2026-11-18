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
    reminderId: 'command-20e:reminder-a',
    calendarId: 'android-calendar-account-a',
    eventId: 'android-provider-event-1001',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-a',
  ),
  ExternalCalendarEventLink(
    reminderId: 'command-20e:reminder-b',
    calendarId: 'android-calendar-account-b',
    eventId: 'android-provider-event-2002',
    lastSyncedFingerprint: 'sha256:command-20e-fingerprint-b',
  ),
];

Map<String, Object?> _values(ExternalCalendarEventLink link) => <String, Object?>{
      'reminderId': link.reminderId,
      'calendarId': link.calendarId,
      'eventId': link.eventId,
      'lastSyncedFingerprint': link.lastSyncedFingerprint,
    };

void _verify(List<ExternalCalendarEventLink> actual) {
  if (actual.length != _expected.length) {
    throw StateError('Expected two Calendar links; found ${actual.length}.');
  }
  for (var index = 0; index < _expected.length; index++) {
    if (jsonEncode(_values(actual[index])) != jsonEncode(_values(_expected[index]))) {
      throw StateError('Calendar link mismatch at index $index.');
    }
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
    _verify(saved);
    for (var index = 0; index < saved.length; index++) {
      debugPrintSynchronously(
        'CALENDAR_LINK_STAGE_A_VALUE=${jsonEncode(<String, Object?>{
          'index': index,
          'actual': _values(saved[index]),
        })}',
      );
    }
    debugPrintSynchronously('CALENDAR_LINK_STAGE_A_WRITE=PASS');
    visiblePhase = 'WRITE COMPLETE — stop and relaunch this process';
  } else if (phase == 'written') {
    await preferences.reload();
    final restored = await store.load();
    _verify(restored);
    for (var index = 0; index < restored.length; index++) {
      debugPrintSynchronously(
        'CALENDAR_LINK_STAGE_B_VALUE=${jsonEncode(<String, Object?>{
          'index': index,
          'actual': _values(restored[index]),
        })}',
      );
    }
    debugPrintSynchronously('CALENDAR_LINK_STAGE_B_READ=PASS');
    debugPrintSynchronously('CALENDAR_LINK_ALL_EIGHT_VALUES_MATCH=PASS');
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
