import '../calendar_page.dart';
import 'calendar_schedule_projection.dart';
import 'rescheduling_planner.dart';
import 'schedule_conflict_service.dart';

enum CalendarReschedulingAdviceState {
  targetUnavailable,
  noConflict,
  conflict,
}

class CalendarReschedulingAdvice {
  CalendarReschedulingAdvice({
    required this.state,
    this.target,
    Iterable<ScheduleConflict> conflicts = const [],
    Iterable<ScheduleInterval> suggestions = const [],
  })  : conflicts = List.unmodifiable(conflicts),
        suggestions = List.unmodifiable(suggestions);

  final CalendarReschedulingAdviceState state;
  final ScheduleInterval? target;
  final List<ScheduleConflict> conflicts;
  final List<ScheduleInterval> suggestions;

  bool get hasConflict => state == CalendarReschedulingAdviceState.conflict;
}

/// Read-only composition of Arvin's merged calendar conflict and rescheduling
/// foundations.
///
/// This service never writes Calendar, Task, FollowUp, notification, scheduler,
/// repository, or storage state. It only projects existing reminders, confirms
/// whether one selected reminder conflicts, and returns deterministic candidate
/// times for a later user-confirmed canonical write.
class CalendarReschedulingAdvisor {
  const CalendarReschedulingAdvisor({
    CalendarScheduleProjection projection = const CalendarScheduleProjection(),
    ScheduleConflictService conflictService = const ScheduleConflictService(),
    ReschedulingPlanner planner = const ReschedulingPlanner(),
  })  : _projection = projection,
        _conflictService = conflictService,
        _planner = planner;

  final CalendarScheduleProjection _projection;
  final ScheduleConflictService _conflictService;
  final ReschedulingPlanner _planner;

  CalendarReschedulingAdvice advise({
    required Iterable<CalendarReminder> reminders,
    required String reminderId,
    required DateTime windowStart,
    required DateTime windowEnd,
    Duration step = const Duration(minutes: 15),
    int limit = 3,
  }) {
    if (reminderId.isEmpty) {
      throw ArgumentError.value(
        reminderId,
        'reminderId',
        'Reminder id must not be empty.',
      );
    }

    final projected = _projection.project(reminders);
    ScheduleInterval? target;
    for (final interval in projected) {
      if (interval.ownerId == reminderId) {
        target = interval;
        break;
      }
    }

    final selectedTarget = target;
    if (selectedTarget == null) {
      return CalendarReschedulingAdvice(
        state: CalendarReschedulingAdviceState.targetUnavailable,
      );
    }

    final targetConflicts = _conflictService
        .findConflicts(projected)
        .where(
          (conflict) =>
              conflict.first.id == selectedTarget.id ||
              conflict.second.id == selectedTarget.id,
        )
        .toList(growable: false);

    if (targetConflicts.isEmpty) {
      return CalendarReschedulingAdvice(
        state: CalendarReschedulingAdviceState.noConflict,
        target: selectedTarget,
      );
    }

    final suggestions = _planner.suggest(
      busy: projected.where((interval) => interval.id != selectedTarget.id),
      windowStart: windowStart,
      windowEnd: windowEnd,
      duration: selectedTarget.end.difference(selectedTarget.start),
      step: step,
      limit: limit,
    );

    return CalendarReschedulingAdvice(
      state: CalendarReschedulingAdviceState.conflict,
      target: selectedTarget,
      conflicts: targetConflicts,
      suggestions: suggestions,
    );
  }
}
