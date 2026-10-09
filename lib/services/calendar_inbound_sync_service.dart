import '../android_follow_up_reminder_scheduler.dart';
import '../calendar_page.dart';
import '../models/task.dart';
import '../services/task_store.dart';
import 'calendar_sync_plan_service.dart';
import 'external_calendar_link_store.dart';
import 'system_calendar_bridge.dart';

class CalendarInboundSyncResult {
  const CalendarInboundSyncResult({
    required this.updated,
    required this.deleted,
    required this.conflicts,
  });

  final int updated;
  final int deleted;
  final int conflicts;

  bool get changed => updated > 0 || deleted > 0;
}

/// Reconciles changes made in the Android Calendar Provider back into
/// Arvin-owned canonical Task/FollowUp data.
///
/// External-owned events remain read-only projections. Only provider events
/// already linked to an Arvin reminder are eligible for inbound mutation.
class CalendarInboundSyncService {
  CalendarInboundSyncService({
    SystemCalendarBridge? bridge,
    ExternalCalendarLinkStore? linkStore,
    TaskStore? taskStore,
    CalendarSyncRevisionService? revisionService,
    Future<void> Function()? reminderReschedule,
  })  : bridge = bridge ?? SystemCalendarBridge(),
        linkStore = linkStore ?? ExternalCalendarLinkStore(),
        taskStore = taskStore ?? TaskStore(),
        revisionService = revisionService ?? CalendarSyncRevisionService(),
        reminderReschedule = reminderReschedule ?? AndroidFollowUpReminderScheduler().reschedule;

  final SystemCalendarBridge bridge;
  final ExternalCalendarLinkStore linkStore;
  final TaskStore taskStore;
  final CalendarSyncRevisionService revisionService;
  final Future<void> Function() reminderReschedule;

  Future<CalendarInboundSyncResult> reconcile({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!await bridge.hasReadPermission()) {
      return const CalendarInboundSyncResult(
        updated: 0,
        deleted: 0,
        conflicts: 0,
      );
    }

    final links = await linkStore.load();
    if (links.isEmpty) {
      return const CalendarInboundSyncResult(
        updated: 0,
        deleted: 0,
        conflicts: 0,
      );
    }

    // The provider bridge intentionally caps one query at 20 calendars.
    // Batch here so a user with more than 20 linked calendars is reconciled
    // completely instead of silently dropping links after the first 20.
    final calendarIds = links.map((link) => link.calendarId).toSet().toList();
    final events = <DeviceCalendarEvent>[];
    for (var offset = 0;
        offset < calendarIds.length;
        offset += SystemCalendarBridge.maxEventQueryCalendars) {
      final batch = calendarIds.skip(offset).take(
        SystemCalendarBridge.maxEventQueryCalendars,
      );
      events.addAll(
        await bridge.listDeviceCalendarEvents(
          calendarIds: batch,
          start: start,
          end: end,
        ),
      );
    }

    final eventByProviderKey = <String, DeviceCalendarEvent>{};
    for (final event in events) {
      final key = _providerKey(event.calendarId, event.eventId);
      eventByProviderKey.putIfAbsent(key, () => event);
    }

    var updated = 0;
    var deleted = 0;
    var conflicts = 0;
    final remainingLinks = <ExternalCalendarEventLink>[];

    final tasks = await taskStore.load();
    for (final link in links) {
      if (link.reminderId.startsWith('external-calendar:')) {
        remainingLinks.add(link);
        continue;
      }
      final event = eventByProviderKey[_providerKey(link.calendarId, link.eventId)];
      final current = _canonicalReminder(tasks, link.reminderId);

      if (event == null) {
        if (current == null) {
          remainingLinks.add(link);
          continue;
        }
        final currentRevision = await revisionService.fromReminder(current);
        if (currentRevision.fingerprint != link.lastSyncedFingerprint) {
          conflicts++;
          remainingLinks.add(link);
          continue;
        }

        final removed = await _clearCanonical(tasks, link.reminderId);
        if (removed) {
          deleted++;
          continue;
        }
        remainingLinks.add(link);
        continue;
      }

      final providerReminder = CalendarReminder(
        id: link.reminderId,
        title: event.title,
        date: _normalizedStart(event),
        isAllDay: event.allDay,
        description: event.description,
        end: _normalizedEnd(event),
      );
      final providerRevision = await revisionService.fromReminder(providerReminder);
      if (providerRevision.fingerprint == link.lastSyncedFingerprint) {
        remainingLinks.add(link);
        continue;
      }

      if (current == null) {
        conflicts++;
        remainingLinks.add(link);
        continue;
      }

      final currentRevision = await revisionService.fromReminder(current);
      if (currentRevision.fingerprint != link.lastSyncedFingerprint) {
        conflicts++;
        remainingLinks.add(link);
        continue;
      }

      final applied = await _applyCanonical(tasks, link.reminderId, providerRevision);
      if (!applied) {
        conflicts++;
        remainingLinks.add(link);
        continue;
      }

      updated++;
      remainingLinks.add(
        ExternalCalendarEventLink(
          reminderId: link.reminderId,
          calendarId: link.calendarId,
          eventId: link.eventId,
          lastSyncedFingerprint: providerRevision.fingerprint,
        ),
      );
    }

    if (updated > 0 || deleted > 0) {
      await taskStore.save(tasks);
      try {
        await reminderReschedule();
      } catch (_) {
        // Canonical calendar/task reconciliation succeeded; reminder scheduling
        // is best-effort and can retry through the existing scheduler lifecycle.
      }
    }
    await linkStore.save(remainingLinks);

    return CalendarInboundSyncResult(
      updated: updated,
      deleted: deleted,
      conflicts: conflicts,
    );
  }

  CalendarReminder? _canonicalReminder(
    List<Task> tasks,
    String reminderId,
  ) {
    if (reminderId.startsWith('task-due:')) {
      final task = _taskForId(tasks, reminderId.substring('task-due:'.length));
      final date = task?.dueDate;
      if (task == null || date == null || task.trashed) return null;
      return CalendarReminder(
        id: reminderId,
        title: task.title,
        date: date,
        isAllDay: _isDateOnly(date),
        completed: task.completed,
      );
    }

    if (reminderId.startsWith('task-reminder:')) {
      final task = _taskForId(
        tasks,
        reminderId.substring('task-reminder:'.length),
      );
      final date = task?.reminderDate;
      if (task == null || date == null || task.trashed) return null;
      return CalendarReminder(
        id: reminderId,
        title: 'یادآوری: ${task.title}',
        date: date,
        completed: task.completed,
      );
    }

    if (reminderId.startsWith('followup:')) {
      final parsed = _parseFollowUpReminderId(reminderId);
      if (parsed == null) return null;
      final task = _taskForId(tasks, parsed.$1);
      if (task == null || task.trashed) return null;
      for (final followUp in task.followUps) {
        if (followUp.id != parsed.$2) continue;
        return CalendarReminder(
          id: reminderId,
          title: followUp.note.trim().isEmpty
              ? task.title
              : '${task.title} — ${followUp.note.trim()}',
          date: followUp.dateTime,
          completed: followUp.completed || task.completed,
        );
      }
    }

    if (reminderId.startsWith('task-followup:')) {
      final task = _taskForId(
        tasks,
        reminderId.substring('task-followup:'.length),
      );
      final date = task?.followUpDate;
      if (task == null || date == null || task.trashed) return null;
      return CalendarReminder(
        id: reminderId,
        title: task.title,
        date: date,
        completed: task.completed,
      );
    }

    // Recurrence occurrences are projections rather than one canonical
    // persisted timestamp; do not guess a mutation target from an occurrence.
    return null;
  }

  Future<bool> _applyCanonical(
    List<Task> tasks,
    String reminderId,
    CalendarSyncRevision revision,
  ) async {
    if (reminderId.startsWith('task-due:')) {
      final task = _taskForId(tasks, reminderId.substring('task-due:'.length));
      if (task == null || task.trashed) return false;
      task.title = revision.title;
      task.dueDate = revision.start;
      task.updatedAt = DateTime.now();
      return true;
    }

    if (reminderId.startsWith('task-reminder:')) {
      final task = _taskForId(
        tasks,
        reminderId.substring('task-reminder:'.length),
      );
      if (task == null || task.trashed) return false;
      task.title = revision.title.replaceFirst('یادآوری: ', '');
      task.reminderDate = revision.start;
      task.updatedAt = DateTime.now();
      return true;
    }

    if (reminderId.startsWith('followup:')) {
      final parsed = _parseFollowUpReminderId(reminderId);
      if (parsed == null) return false;
      final task = _taskForId(tasks, parsed.$1);
      if (task == null || task.trashed) return false;
      final index = task.followUps.indexWhere((item) => item.id == parsed.$2);
      if (index < 0) return false;
      final current = task.followUps[index];
      final next = List<FollowUp>.of(task.followUps);
      next[index] = FollowUp(
        id: current.id,
        dateTime: revision.start,
        note: current.note,
        result: current.result,
        reminderDate: current.reminderDate,
        nextFollowUp: current.nextFollowUp,
        completed: current.completed,
      );
      task.followUps = next;
      task.followUpEnabled = true;
      task.updatedAt = DateTime.now();
      return true;
    }

    if (reminderId.startsWith('task-followup:')) {
      final task = _taskForId(
        tasks,
        reminderId.substring('task-followup:'.length),
      );
      if (task == null || task.trashed) return false;
      task.followUpDate = revision.start;
      task.updatedAt = DateTime.now();
      return true;
    }

    return false;
  }

  Future<bool> _clearCanonical(
    List<Task> tasks,
    String reminderId,
  ) async {
    if (reminderId.startsWith('task-due:')) {
      final task = _taskForId(tasks, reminderId.substring('task-due:'.length));
      if (task == null || task.trashed) return false;
      task.dueDate = null;
      task.updatedAt = DateTime.now();
      return true;
    }

    if (reminderId.startsWith('task-reminder:')) {
      final task = _taskForId(
        tasks,
        reminderId.substring('task-reminder:'.length),
      );
      if (task == null || task.trashed) return false;
      task.reminderDate = null;
      task.updatedAt = DateTime.now();
      return true;
    }

    if (reminderId.startsWith('followup:')) {
      final parsed = _parseFollowUpReminderId(reminderId);
      if (parsed == null) return false;
      final task = _taskForId(tasks, parsed.$1);
      if (task == null || task.trashed) return false;
      final index = task.followUps.indexWhere((item) => item.id == parsed.$2);
      if (index < 0) return false;
      final next = List<FollowUp>.of(task.followUps)..removeAt(index);
      task.followUps = next;
      task.followUpEnabled = next.isNotEmpty;
      task.updatedAt = DateTime.now();
      return true;
    }

    if (reminderId.startsWith('task-followup:')) {
      final task = _taskForId(
        tasks,
        reminderId.substring('task-followup:'.length),
      );
      if (task == null || task.trashed) return false;
      task.followUpDate = null;
      task.updatedAt = DateTime.now();
      return true;
    }

    return false;
  }

  Task? _taskForId(List<Task> tasks, String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    for (final task in tasks) {
      if (task.id == normalized) return task;
    }
    return null;
  }

  (String, String)? _parseFollowUpReminderId(String reminderId) {
    final value = reminderId.substring('followup:'.length);
    final separator = value.indexOf(':');
    if (separator <= 0 || separator == value.length - 1) return null;
    return (
      value.substring(0, separator),
      value.substring(separator + 1),
    );
  }

  String _providerKey(String calendarId, String eventId) =>
      '${calendarId.trim()}:${eventId.trim()}';

  DateTime _normalizedStart(DeviceCalendarEvent event) {
    if (!event.allDay) return event.start;
    return DateTime(event.start.year, event.start.month, event.start.day);
  }

  DateTime _normalizedEnd(DeviceCalendarEvent event) {
    if (!event.allDay) return event.end;
    final start = _normalizedStart(event);
    return start.add(const Duration(days: 1));
  }

  bool _isDateOnly(DateTime value) =>
      value.hour == 0 &&
      value.minute == 0 &&
      value.second == 0 &&
      value.millisecond == 0 &&
      value.microsecond == 0;
}
