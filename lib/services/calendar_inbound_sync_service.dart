/// Retired inbound-reconciliation compatibility surface.
///
/// Device Calendar events are read-only mirrors, not authorities over native
/// Arvin Tasks or Reminders. Live provider changes are reflected by
/// [ExternalCalendarEventProjection] when the Calendar view reloads its
/// provider snapshot. This legacy service intentionally performs no provider
/// query, link mutation, Task write, reminder reschedule, or deletion.
class CalendarInboundSyncResult {
  const CalendarInboundSyncResult({
    this.updated = 0,
    this.deleted = 0,
    this.conflicts = 0,
  });

  final int updated;
  final int deleted;
  final int conflicts;

  bool get changed => false;
}

class CalendarInboundSyncService {
  const CalendarInboundSyncService();

  Future<CalendarInboundSyncResult> reconcile({
    required DateTime start,
    required DateTime end,
  }) async {
    // Deliberate no-op: provider state must never mutate Arvin-owned entities.
    return const CalendarInboundSyncResult();
  }
}
