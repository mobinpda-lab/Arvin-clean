import '../calendar_page.dart';
import 'schedule_conflict_service.dart';

/// Read-only bridge from Arvin's existing calendar presentation model into
/// transient conflict-analysis intervals.
///
/// Timed reminders use the same 30-minute convention already used when Arvin
/// exports a FollowUp reminder through SystemCalendarBridge. Completed and
/// all-day reminders do not block clock-time availability in this projection.
class CalendarScheduleProjection {
  const CalendarScheduleProjection({
    this.timedDuration = const Duration(minutes: 30),
  });

  final Duration timedDuration;

  List<ScheduleInterval> project(Iterable<CalendarReminder> reminders) {
    if (timedDuration <= Duration.zero) {
      throw ArgumentError('Timed reminder duration must be positive.');
    }

    final intervals = reminders
        .where((reminder) => !reminder.completed && !reminder.isAllDay)
        .map(
          (reminder) => ScheduleInterval(
            id: 'calendar:${reminder.id}',
            ownerId: reminder.id,
            start: reminder.date,
            end: reminder.date.add(timedDuration),
          ),
        )
        .toList();

    intervals.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      return a.id.compareTo(b.id);
    });

    return List<ScheduleInterval>.unmodifiable(intervals);
  }
}
