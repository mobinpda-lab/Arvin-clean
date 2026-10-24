import '../models/recurrence.dart';
import '../models/task.dart';

/// One scheduled occurrence projected from a canonical recurring Task.
///
/// [task] is the original canonical Task reference. This value object never
/// mutates it or any of its history. Consumers must not render a clock time
/// for [isAllDay] occurrences.
class RecurringTaskOccurrence {
  const RecurringTaskOccurrence({
    required this.task,
    required this.scheduledDate,
    required this.status,
  });

  final Task task;
  final DateTime scheduledDate;
  final RecurrenceOccurrenceStatus status;

  bool get isAllDay => task.allDay;
}

/// Immutable three-window projection of recurring Task occurrences.
class RecurringTripleWindowProjectionResult {
  RecurringTripleWindowProjectionResult({
    required Iterable<RecurringTaskOccurrence> past,
    required Iterable<RecurringTaskOccurrence> today,
    required Iterable<RecurringTaskOccurrence> upcoming,
  })  : past = List<RecurringTaskOccurrence>.unmodifiable(past),
        today = List<RecurringTaskOccurrence>.unmodifiable(today),
        upcoming = List<RecurringTaskOccurrence>.unmodifiable(upcoming);

  /// Past occurrences before local midnight today, excluding terminal states.
  final List<RecurringTaskOccurrence> past;

  /// Occurrences in [local midnight today, local midnight tomorrow).
  final List<RecurringTaskOccurrence> today;

  /// Occurrences in [local midnight tomorrow, horizon end).
  final List<RecurringTaskOccurrence> upcoming;

}

/// Pure, read-only projection for recurring occurrences across three windows.
///
/// The canonical recurrence anchor is [Task.reminderDate], matching
/// TaskRecurrenceRepository. The recurrence model remains responsible for
/// interval/count/endDate/inactive semantics; this class never generates
/// recurrence dates independently or persists occurrence state.
class RecurringTripleWindowProjection {
  const RecurringTripleWindowProjection();

  static const int defaultHorizonDays = 30;

  RecurringTripleWindowProjectionResult project(
    Iterable<Task> tasks, {
    required DateTime localAnchorDate,
    int horizonDays = defaultHorizonDays,
  }) {
    if (horizonDays < 1) {
      throw ArgumentError.value(horizonDays, 'horizonDays', 'Must be at least 1');
    }

    final localAnchor = localAnchorDate.toLocal();
    final todayStart = DateTime(localAnchor.year, localAnchor.month, localAnchor.day);
    final tomorrowStart = DateTime(todayStart.year, todayStart.month, todayStart.day + 1);
    final horizonEnd = DateTime(
      todayStart.year,
      todayStart.month,
      todayStart.day + horizonDays,
    );

    final past = <RecurringTaskOccurrence>[];
    final today = <RecurringTaskOccurrence>[];
    final upcoming = <RecurringTaskOccurrence>[];

    for (final task in tasks) {
      if (task.archived || task.trashed) continue;
      final rule = task.recurrence;
      final anchor = task.reminderDate;
      if (rule == null || anchor == null || !rule.active) continue;

      // RecurrenceRule owns the canonical cycle start and all rule constraints.
      final cycleStart = rule.startDate ?? anchor;
      if (cycleStart.isBefore(todayStart)) {
        for (final occurrence in rule.occurrencesBetween(
          anchor: anchor,
          from: cycleStart,
          to: todayStart,
        )) {
          final status = _statusFor(task, occurrence, todayStart);
          if (_isTerminal(status)) continue;
          past.add(RecurringTaskOccurrence(
            task: task,
            scheduledDate: occurrence,
            status: status,
          ));
        }
      }

      for (final occurrence in rule.occurrencesBetween(
        anchor: anchor,
        from: todayStart,
        to: tomorrowStart,
      )) {
        today.add(RecurringTaskOccurrence(
          task: task,
          scheduledDate: occurrence,
          status: _statusFor(task, occurrence, todayStart),
        ));
      }

      if (horizonEnd.isAfter(tomorrowStart)) {
        for (final occurrence in rule.occurrencesBetween(
          anchor: anchor,
          from: tomorrowStart,
          to: horizonEnd,
        )) {
          upcoming.add(RecurringTaskOccurrence(
            task: task,
            scheduledDate: occurrence,
            status: _statusFor(task, occurrence, todayStart),
          ));
        }
      }
    }

    int compare(RecurringTaskOccurrence left, RecurringTaskOccurrence right) {
      final byDate = left.scheduledDate.compareTo(right.scheduledDate);
      if (byDate != 0) return byDate;
      final byTaskId = left.task.id.compareTo(right.task.id);
      if (byTaskId != 0) return byTaskId;
      return left.status.index.compareTo(right.status.index);
    }

    past.sort(compare);
    today.sort(compare);
    upcoming.sort(compare);

    return RecurringTripleWindowProjectionResult(
      past: past,
      today: today,
      upcoming: upcoming,
    );
  }

  RecurrenceOccurrenceStatus _statusFor(
    Task task,
    DateTime occurrence,
    DateTime todayStart,
  ) {
    final stored = task.occurrenceHistory[occurrence.toIso8601String()];
    final storedName = stored?['status'];
    if (storedName is String) {
      for (final status in RecurrenceOccurrenceStatus.values) {
        if (status.name == storedName) return status;
      }
    }
    return occurrence.isBefore(todayStart)
        ? RecurrenceOccurrenceStatus.missed
        : RecurrenceOccurrenceStatus.pending;
  }

  bool _isTerminal(RecurrenceOccurrenceStatus status) =>
      status == RecurrenceOccurrenceStatus.completed ||
      status == RecurrenceOccurrenceStatus.skipped ||
      status == RecurrenceOccurrenceStatus.cancelled;
}
