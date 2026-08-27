import 'schedule_conflict_service.dart';

/// Deterministic suggestion-only planner built on [ScheduleConflictService].
///
/// It never mutates Tasks, Calendar entries, reminders, or storage. Product UI
/// must explicitly confirm a suggestion before any canonical write occurs.
class ReschedulingPlanner {
  const ReschedulingPlanner({
    ScheduleConflictService conflictService = const ScheduleConflictService(),
  }) : _conflictService = conflictService;

  final ScheduleConflictService _conflictService;

  List<ScheduleInterval> suggest({
    required Iterable<ScheduleInterval> busy,
    required DateTime windowStart,
    required DateTime windowEnd,
    required Duration duration,
    Duration step = const Duration(minutes: 15),
    int limit = 3,
  }) {
    if (!windowEnd.isAfter(windowStart)) {
      throw ArgumentError('Rescheduling window end must be after start.');
    }
    if (duration <= Duration.zero) {
      throw ArgumentError('Rescheduling duration must be positive.');
    }
    if (step <= Duration.zero) {
      throw ArgumentError('Rescheduling step must be positive.');
    }
    if (limit < 1) {
      throw ArgumentError('Rescheduling suggestion limit must be positive.');
    }

    final busyIntervals = busy.toList(growable: false);
    final suggestions = <ScheduleInterval>[];
    var candidateStart = windowStart;
    var candidateIndex = 1;

    while (suggestions.length < limit) {
      final candidateEnd = candidateStart.add(duration);
      if (candidateEnd.isAfter(windowEnd)) break;

      final candidate = ScheduleInterval(
        id: '__reschedule_candidate__$candidateIndex',
        start: candidateStart,
        end: candidateEnd,
      );

      final conflicts = _conflictService.findConflicts([
        ...busyIntervals,
        candidate,
      ]);
      final candidateIsFree = conflicts.every(
        (conflict) =>
            conflict.first.id != candidate.id &&
            conflict.second.id != candidate.id,
      );

      if (candidateIsFree) {
        suggestions.add(candidate);
      }

      candidateStart = candidateStart.add(step);
      candidateIndex += 1;
    }

    return suggestions;
  }
}
