import 'calendar_sync_plan_service.dart';
import 'external_calendar_link_store.dart';
import 'system_calendar_bridge.dart';

class CalendarProviderSyncResult {
  const CalendarProviderSyncResult({
    required this.created,
    required this.updated,
    required this.deleted,
    required this.noOp,
  });

  final int created;
  final int updated;
  final int deleted;
  final int noOp;
}

/// Executes one already-planned idempotent sync batch against Android Calendar
/// Provider and mutates link metadata only after each provider operation
/// succeeds. Canonical Arvin Task/FollowUp data is never modified here.
class CalendarProviderSyncExecutor {
  CalendarProviderSyncExecutor({
    SystemCalendarBridge? bridge,
    ExternalCalendarLinkStore? linkStore,
  })  : bridge = bridge ?? SystemCalendarBridge(),
        linkStore = linkStore ?? ExternalCalendarLinkStore();

  final SystemCalendarBridge bridge;
  final ExternalCalendarLinkStore linkStore;

  Future<CalendarProviderSyncResult> execute({
    required CalendarSyncPlan plan,
    required String targetCalendarId,
  }) async {
    final calendarId = targetCalendarId.trim();
    if (calendarId.isEmpty) {
      throw ArgumentError.value(
        targetCalendarId,
        'targetCalendarId',
        'A target device calendar is required.',
      );
    }

    final granted =
        await bridge.hasWritePermission() || await bridge.requestWritePermission();
    if (!granted) {
      throw StateError('Calendar write permission was not granted.');
    }

    final links = <String, ExternalCalendarEventLink>{
      for (final link in await linkStore.load()) link.reminderId: link,
    };

    var created = 0;
    var updated = 0;
    var deleted = 0;
    var noOp = 0;

    for (final item in plan.items) {
      switch (item.action) {
        case CalendarSyncAction.noOp:
          noOp++;
          break;
        case CalendarSyncAction.create:
          final revision = item.revision;
          if (revision == null) {
            throw StateError('Create plan item is missing its revision.');
          }
          final eventId = await bridge.createProviderEvent(
            calendarId: calendarId,
            title: revision.title,
            start: revision.start,
            end: revision.end,
            allDay: revision.allDay,
          );
          if (eventId == null) {
            throw StateError('Calendar Provider did not create an event.');
          }
          links[item.reminderId] = ExternalCalendarEventLink(
            reminderId: item.reminderId,
            calendarId: calendarId,
            eventId: eventId,
            lastSyncedFingerprint: revision.fingerprint,
          );
          await linkStore.save(links.values);
          created++;
          break;
        case CalendarSyncAction.update:
          final revision = item.revision;
          final link = item.link ?? links[item.reminderId];
          if (revision == null || link == null) {
            throw StateError('Update plan item is missing revision/link data.');
          }
          final ok = await bridge.updateProviderEvent(
            calendarId: link.calendarId,
            eventId: link.eventId,
            title: revision.title,
            start: revision.start,
            end: revision.end,
            allDay: revision.allDay,
          );
          if (!ok) {
            throw StateError('Calendar Provider did not update linked event.');
          }
          links[item.reminderId] = ExternalCalendarEventLink(
            reminderId: item.reminderId,
            calendarId: link.calendarId,
            eventId: link.eventId,
            lastSyncedFingerprint: revision.fingerprint,
          );
          await linkStore.save(links.values);
          updated++;
          break;
        case CalendarSyncAction.delete:
          final link = item.link ?? links[item.reminderId];
          if (link == null) {
            throw StateError('Delete plan item is missing linked event data.');
          }
          final ok = await bridge.deleteProviderEvent(
            calendarId: link.calendarId,
            eventId: link.eventId,
          );
          if (!ok) {
            throw StateError('Calendar Provider did not delete linked event.');
          }
          links.remove(item.reminderId);
          await linkStore.save(links.values);
          deleted++;
          break;
      }
    }

    return CalendarProviderSyncResult(
      created: created,
      updated: updated,
      deleted: deleted,
      noOp: noOp,
    );
  }
}
