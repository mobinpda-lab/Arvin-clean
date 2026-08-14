import '../models/task.dart';
import 'task_store.dart';

/// Application service for FollowUp operations.
///
/// Keeps UI code independent from persistence details while preserving the
/// existing TaskStore and `arvin.tasks` storage contract.
class FollowUpService {
  const FollowUpService({TaskStore? store}) : _store = store ?? const TaskStore();

  final TaskStore _store;

  Future<List<FollowUp>> loadForTask(String taskId) =>
      _store.loadFollowUps(taskId);

  Future<void> addToTask(String taskId, FollowUp followUp) =>
      _store.addFollowUp(taskId, followUp);

  Future<FollowUp?> latestForTask(String taskId) async {
    final items = await loadForTask(taskId);
    if (items.isEmpty) return null;
    return items.reduce(
      (current, candidate) =>
          candidate.dateTime.isAfter(current.dateTime) ? candidate : current,
    );
  }

  Future<FollowUp?> nextForTask(String taskId, {DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final items = await loadForTask(taskId);
    final upcoming = items
        .where((item) => item.nextFollowUp != null &&
            item.nextFollowUp!.isAfter(reference))
        .toList()
      ..sort((a, b) => a.nextFollowUp!.compareTo(b.nextFollowUp!));
    return upcoming.isEmpty ? null : upcoming.first;
  }
}
