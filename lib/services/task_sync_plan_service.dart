import '../models/task.dart';
import 'sync_merge_service.dart';
import 'task_sync_revision_service.dart';

class TaskSyncPlanItem {
  const TaskSyncPlanItem({
    required this.id,
    required this.result,
    this.localTask,
    this.remoteTask,
  });

  final String id;
  final SyncMergeResult result;
  final Task? localTask;
  final Task? remoteTask;

  bool get requiresUserResolution => result.requiresUserResolution;
}

class TaskSyncPlan {
  TaskSyncPlan(Iterable<TaskSyncPlanItem> items)
      : items = List.unmodifiable(items);

  final List<TaskSyncPlanItem> items;

  int get conflictCount =>
      items.where((item) => item.requiresUserResolution).length;

  bool get hasConflicts => conflictCount > 0;
}

/// Builds a deterministic, read-only merge plan for two canonical Task sets.
///
/// This service owns no transport, persistence, provider, repository, or
/// background work. It composes [TaskSyncRevisionService] and
/// [SyncMergeService], so divergent records remain explicit conflicts unless
/// caller-provided common-ancestor fingerprint evidence proves only one side
/// changed.
class TaskSyncPlanService {
  TaskSyncPlanService({
    TaskSyncRevisionService? revisionService,
    SyncMergeService mergeService = const SyncMergeService(),
  })  : _revisionService = revisionService ?? TaskSyncRevisionService(),
        _mergeService = mergeService;

  final TaskSyncRevisionService _revisionService;
  final SyncMergeService _mergeService;

  Future<TaskSyncPlan> plan({
    required Iterable<Task> localTasks,
    required Iterable<Task> remoteTasks,
    Map<String, String> baseFingerprints = const {},
  }) async {
    final localById = _indexUnique(localTasks, side: 'local');
    final remoteById = _indexUnique(remoteTasks, side: 'remote');
    final ids = <String>{...localById.keys, ...remoteById.keys}.toList()..sort();

    final items = <TaskSyncPlanItem>[];
    for (final id in ids) {
      final localTask = localById[id];
      final remoteTask = remoteById[id];
      final localRevision = localTask == null
          ? null
          : await _revisionService.fromTask(localTask);
      final remoteRevision = remoteTask == null
          ? null
          : await _revisionService.fromTask(remoteTask);

      final result = _mergeService.decide(
        local: localRevision,
        remote: remoteRevision,
        baseFingerprint: baseFingerprints[id],
      );

      items.add(
        TaskSyncPlanItem(
          id: id,
          result: result,
          localTask: localTask,
          remoteTask: remoteTask,
        ),
      );
    }

    return TaskSyncPlan(items);
  }

  Map<String, Task> _indexUnique(
    Iterable<Task> tasks, {
    required String side,
  }) {
    final indexed = <String, Task>{};
    for (final task in tasks) {
      if (task.id.isEmpty) {
        throw ArgumentError('$side Task id must not be empty.');
      }
      if (indexed.containsKey(task.id)) {
        throw ArgumentError('Duplicate $side Task id: ${task.id}');
      }
      indexed[task.id] = task;
    }
    return indexed;
  }
}
