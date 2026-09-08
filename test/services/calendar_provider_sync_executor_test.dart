import 'package:arvin/services/calendar_provider_sync_executor.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBridge extends SystemCalendarBridge {
  bool writeGranted = true;
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;
  final List<String> calls = <String>[];

  @override
  Future<bool> hasWritePermission() async => writeGranted;

  @override
  Future<bool> requestWritePermission() async => writeGranted;

  @override
  Future<String?> createProviderEvent({
    required String calendarId,
    required String title,
    required DateTime start,
    required DateTime end,
    required bool allDay,
  }) async {
    calls.add('create:$calendarId:$title');
    return failCreate ? null : 'event-1';
  }

  @override
  Future<bool> updateProviderEvent({
    required String calendarId,
    required String eventId,
    required String title,
    required DateTime start,
    required DateTime end,
    required bool allDay,
  }) async {
    calls.add('update:$calendarId:$eventId:$title');
    return !failUpdate;
  }

  @override
  Future<bool> deleteProviderEvent({
    required String calendarId,
    required String eventId,
  }) async {
    calls.add('delete:$calendarId:$eventId');
    return !failDelete;
  }
}

class _MemoryLinkStore extends ExternalCalendarLinkStore {
  _MemoryLinkStore([Iterable<ExternalCalendarEventLink> seed = const []])
      : links = List<ExternalCalendarEventLink>.of(seed);

  List<ExternalCalendarEventLink> links;
  int saveCount = 0;

  @override
  Future<List<ExternalCalendarEventLink>> load() async =>
      List<ExternalCalendarEventLink>.of(links);

  @override
  Future<void> save(Iterable<ExternalCalendarEventLink> next) async {
    saveCount++;
    links = List<ExternalCalendarEventLink>.of(next);
  }
}

CalendarSyncRevision _revision(String id, String fingerprint, String title) {
  final start = DateTime(2026, 9, 8, 12);
  return CalendarSyncRevision(
    reminderId: id,
    fingerprint: fingerprint,
    title: title,
    start: start,
    end: start.add(const Duration(minutes: 30)),
    allDay: false,
  );
}

void main() {
  test('create persists link only after provider success', () async {
    final bridge = _FakeBridge();
    final store = _MemoryLinkStore();
    final executor =
        CalendarProviderSyncExecutor(bridge: bridge, linkStore: store);

    final result = await executor.execute(
      plan: CalendarSyncPlan([
        CalendarSyncPlanItem(
          reminderId: 'followup:1',
          action: CalendarSyncAction.create,
          revision: _revision('followup:1', 'fp1', 'پیگیری'),
        ),
      ]),
      targetCalendarId: '42',
    );

    expect(result.created, 1);
    expect(store.saveCount, 1);
    expect(store.links.single.eventId, 'event-1');
    expect(store.links.single.lastSyncedFingerprint, 'fp1');
  });

  test('provider create failure leaves link metadata untouched', () async {
    final bridge = _FakeBridge()..failCreate = true;
    final store = _MemoryLinkStore();
    final executor =
        CalendarProviderSyncExecutor(bridge: bridge, linkStore: store);

    await expectLater(
      executor.execute(
        plan: CalendarSyncPlan([
          CalendarSyncPlanItem(
            reminderId: 'followup:1',
            action: CalendarSyncAction.create,
            revision: _revision('followup:1', 'fp1', 'پیگیری'),
          ),
        ]),
        targetCalendarId: '42',
      ),
      throwsStateError,
    );

    expect(store.saveCount, 0);
    expect(store.links, isEmpty);
  });

  test('update preserves exact linked event id and advances fingerprint', () async {
    final old = ExternalCalendarEventLink(
      reminderId: 'followup:1',
      calendarId: '42',
      eventId: '7',
      lastSyncedFingerprint: 'old',
    );
    final bridge = _FakeBridge();
    final store = _MemoryLinkStore([old]);
    final executor =
        CalendarProviderSyncExecutor(bridge: bridge, linkStore: store);

    final result = await executor.execute(
      plan: CalendarSyncPlan([
        CalendarSyncPlanItem(
          reminderId: 'followup:1',
          action: CalendarSyncAction.update,
          revision: _revision('followup:1', 'new', 'پیگیری جدید'),
          link: old,
        ),
      ]),
      targetCalendarId: '42',
    );

    expect(result.updated, 1);
    expect(bridge.calls.single, contains('update:42:7'));
    expect(store.links.single.eventId, '7');
    expect(store.links.single.lastSyncedFingerprint, 'new');
  });

  test('delete removes link only after exact provider delete succeeds', () async {
    final old = ExternalCalendarEventLink(
      reminderId: 'followup:1',
      calendarId: '42',
      eventId: '7',
      lastSyncedFingerprint: 'old',
    );
    final bridge = _FakeBridge();
    final store = _MemoryLinkStore([old]);
    final executor =
        CalendarProviderSyncExecutor(bridge: bridge, linkStore: store);

    final result = await executor.execute(
      plan: CalendarSyncPlan([
        CalendarSyncPlanItem(
          reminderId: 'followup:1',
          action: CalendarSyncAction.delete,
          link: old,
        ),
      ]),
      targetCalendarId: '42',
    );

    expect(result.deleted, 1);
    expect(bridge.calls.single, 'delete:42:7');
    expect(store.links, isEmpty);
  });
}
