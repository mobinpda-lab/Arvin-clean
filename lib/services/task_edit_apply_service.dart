import '../models/task.dart';

/// Applies the editable Task payload returned by an editor onto the existing
/// canonical Task instance without replacing identity or FollowUp history.
///
/// Persistence remains owned by the existing TaskStore/Home write path.
class TaskEditApplyService {
  TaskEditApplyService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  void apply(Task target, Task edited) {
    final appliedAt = _now();
    final hasRepeatState = target.recurrence != null ||
        edited.recurrence != null ||
        target.checklistOccurrences.isNotEmpty ||
        target.occurrenceHistory.isNotEmpty;
    final templateChanged =
        !_sameChecklistTemplate(target.checklist, edited.checklist);

    if (hasRepeatState && templateChanged) {
      // A recurring Task's checklist is a template, not an execution record.
      // Past occurrence snapshots remain immutable; current and future stored
      // snapshots are rebuilt from the new unchecked template in this same
      // canonical Task mutation. The occurrence keys and lifecycle history
      // are deliberately preserved.
      final template = edited.checklist.map(_uncheckedChecklistItem).toList();
      final effectiveDay = _calendarDay(appliedAt);
      target.checklist = template;
      target.checklistOccurrences = <String, List<String>>{
        for (final entry in target.checklistOccurrences.entries)
          entry.key: _isPastOccurrence(entry.key, effectiveDay)
              ? List<String>.of(entry.value)
              : List<String>.of(template),
      };
    } else {
      target.checklist = List<String>.of(edited.checklist);
    }

    target.title = edited.title;
    target.description = edited.description;
    target.dueDate = edited.dueDate;
    target.allDay = edited.allDay;
    target.followUpEnabled = edited.followUpEnabled;
    target.followUpDate = edited.followUpDate;
    target.tags = List<String>.of(edited.tags);
    target.category = edited.category;
    target.checklistEnabled = edited.checklistEnabled;
    // occurrenceHistory contains independent completed/cancelled lifecycle
    // state and is intentionally not changed by checklist template edits.
    target.reminderDate = edited.reminderDate;
    target.taskReminders = List<TaskReminder>.of(edited.taskReminders);
    target.nextReminderSequence = edited.nextReminderSequence;
    target.legacyTaskReminderMigrationVersion =
        edited.legacyTaskReminderMigrationVersion;
    target.priority = edited.priority;
    target.completed = edited.completed;
    target.recurrence = edited.recurrence;
    target.updatedAt = appliedAt;
  }

  static bool _sameChecklistTemplate(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (_checklistLabel(left[index]) != _checklistLabel(right[index])) {
        return false;
      }
    }
    return true;
  }

  static String _checklistLabel(String item) {
    final trimmed = item.trim();
    if (trimmed.startsWith('[x]') || trimmed.startsWith('[ ]')) {
      return trimmed.substring(3).trim();
    }
    return trimmed;
  }

  static String _uncheckedChecklistItem(String item) =>
      '[ ] ${_checklistLabel(item)}';

  static DateTime _calendarDay(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static bool _isPastOccurrence(String key, DateTime effectiveDay) {
    // A malformed legacy key cannot be classified safely; preserve its data
    // rather than risk destructive cleanup outside the proven date boundary.
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return true;
    return _calendarDay(parsed).isBefore(effectiveDay);
  }
}
