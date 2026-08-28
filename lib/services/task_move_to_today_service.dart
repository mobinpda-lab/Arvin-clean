import '../models/task.dart';
import 'task_store.dart';

/// Canonical write path for the owner-approved «انتقال به امروز» action.
///
/// Only [Task.dueDate] and [Task.updatedAt] are changed. The Task id, reminder,
/// FollowUp history, checklist, category and all other canonical fields are
/// preserved because the existing Task object is saved through [TaskStore].
class TaskMoveToTodayService {
  TaskMoveToTodayService({TaskStore? store}) : _store = store ?? TaskStore();

  final TaskStore _store;

  Future<Task> move(String taskId, {DateTime? now}) async {
    final effectiveNow = now ?? DateTime.now();
    final tasks = await _store.load();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      throw StateError('Task not found: $taskId');
    }

    final task = tasks[index];
    if (task.archived || task.trashed) {
      throw StateError('Inactive Task cannot move to today: $taskId');
    }

    final previousDue = task.dueDate;
    task.dueDate = DateTime(
      effectiveNow.year,
      effectiveNow.month,
      effectiveNow.day,
      previousDue?.hour ?? effectiveNow.hour,
      previousDue?.minute ?? effectiveNow.minute,
    );
    task.updatedAt = effectiveNow;

    await _store.save(tasks);
    return task;
  }
}
