import 'models/task.dart';
import 'services/task_store.dart';

/// Canonical persistence boundary for FollowUp data.
///
/// FollowUps remain embedded in the canonical Task document. All mutations are
/// routed through [TaskStore.mutate] so FollowUp writes cannot race with Home,
/// Notebook, recurrence, People, or Sync writes to `arvin.tasks`.
class FollowUpRepository {
  const FollowUpRepository({TaskStore? store}) : _injectedStore = store;

  final TaskStore? _injectedStore;

  TaskStore get _store => _injectedStore ?? TaskStore();

  Future<List<FollowUp>> loadForTask(String taskId) async {
    final tasks = await _store.load();
    for (final task in tasks) {
      if (task.id == taskId) return _decodeFollowUps(task);
    }
    return const [];
  }

  Future<void> add(String taskId, FollowUp followUp) async {
    await _store.mutate<void>((tasks) {
      final task = _requiredTask(tasks, taskId);
      task.followUps = [..._decodeFollowUps(task), followUp];
      task.updatedAt = DateTime.now();
    });
  }

  Future<void> update(String taskId, FollowUp followUp) async {
    await _store.mutate<void>((tasks) {
      final task = _requiredTask(tasks, taskId);
      final existing = _decodeFollowUps(task);
      final index = existing.indexWhere((item) => item.id == followUp.id);
      if (index < 0) {
        throw StateError('FollowUp not found: ${followUp.id}');
      }

      final updated = List<FollowUp>.of(existing)..[index] = followUp;
      task.followUps = updated;
      task.updatedAt = DateTime.now();
    });
  }

  Future<FollowUp> setCompleted(
    String taskId,
    String followUpId,
    bool completed,
  ) {
    return _store.mutate<FollowUp>((tasks) {
      final task = _requiredTask(tasks, taskId);
      final existing = _decodeFollowUps(task);
      final index = existing.indexWhere((item) => item.id == followUpId);
      if (index < 0) {
        throw StateError('FollowUp not found: $followUpId');
      }

      final current = existing[index];
      final updatedFollowUp = FollowUp(
        id: current.id,
        dateTime: current.dateTime,
        title: current.title,
        note: current.note,
        result: current.result,
        reminderDate: current.reminderDate,
        nextFollowUp: current.nextFollowUp,
        completed: completed,
        waitingForResponse: current.waitingForResponse,
        personIds: current.personIds,
      );
      final updated = List<FollowUp>.of(existing)..[index] = updatedFollowUp;
      task.followUps = updated;
      task.updatedAt = DateTime.now();
      return updatedFollowUp;
    });
  }

  Task _requiredTask(List<Task> tasks, String taskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) throw StateError('Task not found: $taskId');
    return tasks[index];
  }

  List<FollowUp> _decodeFollowUps(Task task) =>
      List<FollowUp>.of(task.followUps);
}
