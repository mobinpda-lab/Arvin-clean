import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
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
