import '../calendar_page.dart';
import '../models/task.dart';

/// Read-only, internal-only projection of planned follow-up actions.
///
/// This class is intentionally separate from FollowUpCalendarProjection:
/// its output is for the Arvin calendar UI only and must never be passed to
/// notification scheduling or CalendarOutboundSyncService.
class FollowUpInternalCalendarProjection {
  const FollowUpInternalCalendarProjection();

  List<CalendarReminder> project(
    Iterable<Task> tasks, {
    DateTime? visibleFrom,
    DateTime? visibleTo,
  }) {
    final actions = <CalendarReminder>[];
    for (final task in tasks) {
      if (task.trashed) continue;
      for (final followUp in task.followUps) {
        final at = followUp.nextFollowUp;
        if (at == null) continue;
        if (visibleFrom != null && at.isBefore(visibleFrom)) continue;
        if (visibleTo != null && !at.isBefore(visibleTo)) continue;
        final note = followUp.note.trim();
        actions.add(
          CalendarReminder(
            id: 'task-followup-action:${task.id}:${followUp.id}',
            title: note.isEmpty ? task.title : '${task.title} — $note',
            date: at,
            completed: followUp.completed || task.completed,
          ),
        );
      }
    }
    actions.sort((a, b) => a.date.compareTo(b.date));
    return List<CalendarReminder>.unmodifiable(actions);
  }
}
