import 'dart:convert';

import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _phase =
    String.fromEnvironment('ARVIN_CALENDAR_LINK_PHASE', defaultValue: 'unset');
const String _key = 'arvin.calendar.externalLinks.command20e';

final List<ExternalCalendarEventLink> _expectedLinks =
    <ExternalCalendarEventLink>[
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

Map<String, Object?> _linkValues(ExternalCalendarEventLink link) => <String, Object?>{'reminderId':link.reminderId,'calendarId':link.calendarId,'eventId':link.eventId,'lastSyncedFingerprint':link.lastSyncedFingerprint};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Calendar Link uses real Android SharedPreferences across process restart',
    (_) async {
      final preferences = await SharedPreferences.getInstance();
      final store = ExternalCalendarLinkStore(preferencesKey: _key);

      if (_phase == 'write') {
        await preferences.remove(_key);
        await store.save(_expectedLinks);
        await preferences.reload();

        final raw = preferences.getString(_key);
        expect(raw, isNotNull);
        expect(raw, isNotEmpty);
        final decoded = jsonDecode(raw!);
        expect(decoded, hasLength(2));

        final immediateRead = await store.load();
        expect(immediateRead, hasLength(2));
        for (var index = 0; index < _expectedLinks.length; index++) {
          final expected = _expectedLinks[index];
          final actual = immediateRead[index];
          expect(actual.reminderId, expected.reminderId);
          expect(actual.calendarId, expected.calendarId);
          expect(actual.eventId, expected.eventId);
          expect(actual.lastSyncedFingerprint, expected.lastSyncedFingerprint);
          debugPrintSynchronously(
            'CALENDAR_LINK_STAGE_A_VALUE=${jsonEncode(<String, Object?>{'index':index,'actual':_linkValues(actual)})}',
          );
        }
        debugPrintSynchronously('CALENDAR_LINK_REAL_BACKEND_WRITE=PASS');
        debugPrintSynchronously('CALENDAR_LINK_WRITE_PHASE_COMPLETE=PASS');
        return;
      }

      if (_phase == 'read') {
        await preferences.reload();
        final restored = await store.load();
        expect(restored, hasLength(_expectedLinks.length));

        for (var index = 0; index < _expectedLinks.length; index++) {
          final expected = _expectedLinks[index];
          final actual = restored[index];
          expect(actual.reminderId, expected.reminderId);
          expect(actual.calendarId, expected.calendarId);
          expect(actual.eventId, expected.eventId);
          expect(actual.lastSyncedFingerprint,
              expected.lastSyncedFingerprint);
          debugPrintSynchronously('CALENDAR_LINK_VALUE_COMPARISON=${jsonEncode(<String, Object?>{'index':index,'expected':_linkValues(expected),'actual':_linkValues(actual)})}');
        }

        debugPrintSynchronously('CALENDAR_LINK_FRESH_PROCESS_READ=PASS');
        debugPrintSynchronously('CALENDAR_LINK_ALL_EIGHT_VALUES_MATCH=PASS');
        debugPrintSynchronously('CALENDAR_LINK_ALL_IDENTITIES_AND_FINGERPRINTS=PASS');
        debugPrintSynchronously('CALENDAR_LINK_REAL_PERSISTENCE=PASS');

        return;
      }

      if (_phase == 'cleanup') {
        await preferences.remove(_key);
        await preferences.reload();
        expect(preferences.getString(_key), isNull);
        debugPrintSynchronously('CALENDAR_LINK_TEST_KEY_CLEANUP=PASS');
        return;
      }

      throw StateError(
        'Set ARVIN_CALENDAR_LINK_PHASE to write, read, or cleanup; received: $_phase',
      );
    },
  );
}
