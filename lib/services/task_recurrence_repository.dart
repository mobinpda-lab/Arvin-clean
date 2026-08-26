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

  Future<Task> setRule(String taskId, RecurrenceRule? rule) async {
    final tasks = await _store.load();
    final task = _find(tasks, taskId);
    task.recurrence = rule;
    task.updatedAt = _now();
    await _store.save(tasks);
    return task;
  }

  Future<Task> resumeFromToday(
    String taskId, {
    DateTime? target,
  }) async {
    final tasks = await _store.load();
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
    await _store.save(tasks);
    return task;
  }

  Task _find(List<Task> tasks, String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    throw StateError('Task not found: $taskId');
  }
}
