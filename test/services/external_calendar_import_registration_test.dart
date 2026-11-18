import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('restore preserves current-device links, fills missing links and filters absent Tasks', () async {
    final store = ExternalCalendarLinkStore(
      preferencesKey: 'test.externalCalendarLinks.restore',
    );
    final currentTaskLink = ExternalCalendarEventLink(
      reminderId: 'task-due:task-1',
      calendarId: '42',
      eventId: 'event-current',
      lastSyncedFingerprint: 'current-fingerprint',
    );
    final removedTaskLink = ExternalCalendarEventLink(
      reminderId: 'task-due:task-2',
      calendarId: '42',
      eventId: 'event-task-2',
      lastSyncedFingerprint: 'fingerprint-task-2',
    );
    final importedLink = ExternalCalendarEventLink(
      reminderId: 'external-calendar:42:instance-1',
      calendarId: '42',
      eventId: 'instance-1',
      lastSyncedFingerprint: 'imported-task:task-1',
    );
    await store.save([currentTaskLink, removedTaskLink, importedLink]);

    final backupReplacement = ExternalCalendarEventLink(
      reminderId: 'task-due:task-1',
      calendarId: '42',
      eventId: 'event-from-backup',
      lastSyncedFingerprint: 'backup-fingerprint',
    );
    final backupMissingLink = ExternalCalendarEventLink(
      reminderId: 'task-reminder:task-1',
      calendarId: '42',
      eventId: 'event-reminder',
      lastSyncedFingerprint: 'reminder-fingerprint',
    );
    final backupAbsentTaskLink = ExternalCalendarEventLink(
      reminderId: 'task-due:task-3',
      calendarId: '42',
      eventId: 'event-task-3',
      lastSyncedFingerprint: 'fingerprint-task-3',
    );

    await store.restoreForTasks(
      restoredTaskIds: const ['task-1'],
      backupLinks: [backupReplacement, backupMissingLink, backupAbsentTaskLink],
    );

    final links = await store.load();
    expect(links.map((link) => link.reminderId).toSet(), {
      'task-due:task-1',
      'task-reminder:task-1',
      'external-calendar:42:instance-1',
    });
    expect(
      links.singleWhere((link) => link.reminderId == 'task-due:task-1').eventId,
      'event-current',
    );
    expect(
      links.singleWhere((link) => link.reminderId == 'task-reminder:task-1').eventId,
      'event-reminder',
    );
    expect(
      links.singleWhere((link) => link.reminderId == 'external-calendar:42:instance-1')
          .lastSyncedFingerprint,
      'imported-task:task-1',
    );
  });

  test('legacy restore preserves current links for remaining Tasks without backup link metadata', () async {
    final store = ExternalCalendarLinkStore(
      preferencesKey: 'test.externalCalendarLinks.legacyRestore',
    );
    await store.save([
      ExternalCalendarEventLink(
        reminderId: 'task-due:task-1',
        calendarId: '42',
        eventId: 'event-1',
        lastSyncedFingerprint: 'fingerprint-1',
      ),
      ExternalCalendarEventLink(
        reminderId: 'task-due:task-2',
        calendarId: '42',
        eventId: 'event-2',
        lastSyncedFingerprint: 'fingerprint-2',
      ),
    ]);

    await store.restoreForTasks(restoredTaskIds: const ['task-1']);

    final links = await store.load();
    expect(links, hasLength(1));
    expect(links.single.reminderId, 'task-due:task-1');
    expect(links.single.eventId, 'event-1');
  });

  test('the same provider event instance can only be registered once', () async {
    final store = ExternalCalendarLinkStore(
      preferencesKey: 'test.externalCalendarLinks',
    );

    final first = await store.registerImportedEvent(
      reminderId: 'external-calendar:calendar-7:instance-1',
      calendarId: 'calendar-7',
      instanceId: 'instance-1',
      taskId: 'task-1',
    );
    final second = await store.registerImportedEvent(
      reminderId: 'external-calendar:calendar-7:instance-1',
      calendarId: 'calendar-7',
      instanceId: 'instance-1',
      taskId: 'task-2',
    );

    expect(first, isTrue);
    expect(second, isFalse);
    expect(
      await store.hasImportedEvent('external-calendar:calendar-7:instance-1'),
      isTrue,
    );
    final links = await store.load();
    expect(links, hasLength(1));
    expect(links.single.lastSyncedFingerprint, 'imported-task:task-1');
  });
}
