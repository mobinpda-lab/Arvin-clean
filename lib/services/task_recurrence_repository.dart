import '../models/recurrence.dart';
import '../models/task.dart';
import 'task_store.dart';

/// Canonical write boundary for recurrence on existing Unified Tasks.
///
/// This repository owns no storage. It updates only [TaskStore.key] through the
/// existing [TaskStore] and never rewrites FollowUp history.
class TaskRecurrenceRepository {
  TaskRecurrenceRepository({TaskStore? store, DateTime Function()? now})
      : _store = store ?? TaskStore(),
        _now = now ?? DateTime.now;

  final TaskStore _store;
  final DateTime Function() _now;

  Future<List<Task>> loadTasks() => _store.load();

  Future<Task> setRule(String taskId, RecurrenceRule? rule) {
    return _store.mutate<Task>((tasks) {
      final task = _find(tasks, taskId);
      task.recurrence = rule;
      task.updatedAt = _now();
      return task;
    });
  }

  /// Returns the checklist state for one scheduled occurrence.
  /// A new occurrence starts from the unchecked canonical checklist template;
  /// it never inherits the previous occurrence's tick state.
  Future<List<String>> checklistForOccurrence(
    String taskId,
    DateTime occurrence,
  ) async {
    final task = _findTask(await _store.load(), taskId);
    final key = _occurrenceKey(occurrence);
    final stored = task.checklistOccurrences[key];
    if (stored != null) return List<String>.of(stored);
    return task.checklist.map(_uncheckedItem).toList(growable: false);
  }

  /// Persists checklist state for exactly one recurring occurrence through the
  /// canonical TaskStore. Other occurrences remain untouched.
  Future<Task> setChecklistForOccurrence(
    String taskId,
    DateTime occurrence,
    List<String> checklist,
  ) {
    return _store.mutate<Task>((tasks) {
      final task = _findTask(tasks, taskId);
      final next = <String, List<String>>{
        for (final entry in task.checklistOccurrences.entries)
          entry.key: List<String>.of(entry.value),
      };
      next[_occurrenceKey(occurrence)] = checklist.map(_normalizeItem).toList();
      task.checklistOccurrences = next;
      task.updatedAt = _now();
      return task;
    });
  }

  static String _occurrenceKey(DateTime occurrence) =>
      occurrence.toIso8601String();

  static String _normalizeItem(String item) {
    final trimmed = item.trim();
    if (trimmed.startsWith('[x] ')) return trimmed;
    if (trimmed.startsWith('[ ] ')) return trimmed;
    if (trimmed.startsWith('[x]')) return '[x] ${trimmed.substring(3).trim()}';
    if (trimmed.startsWith('[ ]')) return '[ ] ${trimmed.substring(3).trim()}';
    return '[ ] $trimmed';
  }

  static String _uncheckedItem(String item) {
    final normalized = _normalizeItem(item);
    return '[ ] ${normalized.substring(3).trim()}';
  }

  Task _findTask(List<Task> tasks, String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    throw StateError('Task not found: $taskId');
  }

  Future<Task> resumeFromToday(
    String taskId, {
    DateTime? target,
  }) {
    return _store.mutate<Task>((tasks) {
      final task = _find(tasks, taskId);
      final rule = task.recurrence;
      final scheduledFrom = task.reminderDate;

      if (rule == null) {
        throw StateError('Task has no recurrence: $taskId');
      }
      if (scheduledFrom == null) {
        throw StateError('Task has no reminder schedule: $taskId');
      }

      final next = rule.resumeFromToday(
        scheduledFrom: scheduledFrom,
        target: target ?? _now(),
      );
      task.reminderDate = next;
      task.updatedAt = _now();
      return task;
    });
  }

  Task _find(List<Task> tasks, String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    throw StateError('Task not found: $taskId');
  }
}
