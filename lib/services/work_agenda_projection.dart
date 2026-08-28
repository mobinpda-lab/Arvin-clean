import '../models/task.dart';

enum WorkAgendaEventKind {
  taskDue,
  taskReminder,
  followUpSchedule,
  followUpReminder,
}

class WorkAgendaEvent {
  const WorkAgendaEvent({
    required this.kind,
    required this.at,
    this.followUpId,
  });

  final WorkAgendaEventKind kind;
  final DateTime at;
  final String? followUpId;

  String get stableKey =>
      '${kind.name}:${followUpId ?? ''}:${at.toIso8601String()}';
}

class WorkAgendaItem {
  const WorkAgendaItem({
    required this.taskId,
    required this.taskTitle,
    required this.completed,
    required this.events,
  });

  final String taskId;
  final String taskTitle;
  final bool completed;
  final List<WorkAgendaEvent> events;

  DateTime get firstEventAt => events.first.at;
}

class WorkAgendaDay {
  const WorkAgendaDay({
    required this.day,
    required this.items,
  });

  /// Local calendar day at midnight.
  final DateTime day;
  final List<WorkAgendaItem> items;
}

/// Read-only composition of canonical user work for one local day or an
/// inclusive local date range.
///
/// This service deliberately consumes only canonical [Task]/[FollowUp] data.
/// Official occasions, prayer times and Daily Content are not inputs and
/// therefore cannot leak into work reports.
///
/// A Task may match through several scheduling concepts on the same day but is
/// emitted once for that day with all matching [events] attached. FollowUp
/// identity is preserved on FollowUp-derived events.
class WorkAgendaProjection {
  const WorkAgendaProjection();

  List<WorkAgendaDay> forDay(
    Iterable<Task> tasks, {
    required DateTime day,
  }) {
    return forRange(tasks, startDay: day, endDay: day);
  }

  List<WorkAgendaDay> forRange(
    Iterable<Task> tasks, {
    required DateTime startDay,
    required DateTime endDay,
  }) {
    final start = _day(startDay);
    final end = _day(endDay);
    if (end.isBefore(start)) {
      throw ArgumentError.value(
        endDay,
        'endDay',
        'endDay must be on or after startDay',
      );
    }
    final endExclusive = end.add(const Duration(days: 1));

    final grouped = <DateTime, Map<String, _MutableAgendaItem>>{};

    for (final task in tasks) {
      // Active/report scopes intentionally exclude archived and trashed work.
      // Completed scheduled work remains reportable with its status intact.
      if (task.archived || task.trashed) continue;

      void addEvent(
        DateTime? value,
        WorkAgendaEventKind kind, {
        String? followUpId,
      }) {
        if (value == null) return;
        final local = value.toLocal();
        if (local.isBefore(start) || !local.isBefore(endExclusive)) return;

        final eventDay = _day(local);
        final dayItems = grouped.putIfAbsent(
          eventDay,
          () => <String, _MutableAgendaItem>{},
        );
        final item = dayItems.putIfAbsent(
          task.id,
          () => _MutableAgendaItem(
            taskId: task.id,
            taskTitle: task.title,
            completed: task.completed,
          ),
        );
        item.events.add(
          WorkAgendaEvent(
            kind: kind,
            at: value,
            followUpId: followUpId,
          ),
        );
      }

      addEvent(task.dueDate, WorkAgendaEventKind.taskDue);
      addEvent(task.reminderDate, WorkAgendaEventKind.taskReminder);

      // Match the canonical AutomaticFollowUpService rule: only the latest
      // real FollowUp can own the current nextFollowUp schedule. The legacy
      // Task.followUpDate is deliberately not treated as real history/work.
      final latestFollowUp = task.lastFollowUp;
      addEvent(
        latestFollowUp?.nextFollowUp,
        WorkAgendaEventKind.followUpSchedule,
        followUpId: latestFollowUp?.id,
      );

      // Independent reminders belong to their exact canonical FollowUp.
      for (final followUp in task.followUps) {
        addEvent(
          followUp.reminderDate,
          WorkAgendaEventKind.followUpReminder,
          followUpId: followUp.id,
        );
      }
    }

    final days = grouped.keys.toList()..sort();
    return List<WorkAgendaDay>.unmodifiable(
      days.map((day) {
        final items = grouped[day]!.values.map((value) {
          value.events.sort(_compareEvents);
          return WorkAgendaItem(
            taskId: value.taskId,
            taskTitle: value.taskTitle,
            completed: value.completed,
            events: List<WorkAgendaEvent>.unmodifiable(value.events),
          );
        }).toList()
          ..sort((a, b) {
            final byTime = a.firstEventAt
                .toLocal()
                .compareTo(b.firstEventAt.toLocal());
            if (byTime != 0) return byTime;
            return a.taskId.compareTo(b.taskId);
          });

        return WorkAgendaDay(
          day: day,
          items: List<WorkAgendaItem>.unmodifiable(items),
        );
      }),
    );
  }

  static int _compareEvents(WorkAgendaEvent a, WorkAgendaEvent b) {
    final byTime = a.at.toLocal().compareTo(b.at.toLocal());
    if (byTime != 0) return byTime;
    final byKind = a.kind.index.compareTo(b.kind.index);
    if (byKind != 0) return byKind;
    return a.stableKey.compareTo(b.stableKey);
  }

  static DateTime _day(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

class _MutableAgendaItem {
  _MutableAgendaItem({
    required this.taskId,
    required this.taskTitle,
    required this.completed,
  });

  final String taskId;
  final String taskTitle;
  final bool completed;
  final List<WorkAgendaEvent> events = <WorkAgendaEvent>[];
}
