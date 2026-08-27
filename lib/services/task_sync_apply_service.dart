import 'dart:convert';

import '../models/task.dart';
import 'sync_merge_service.dart';
import 'task_store.dart';
import 'task_sync_plan_service.dart';

enum TaskSyncConflictChoice { useLocal, useRemote }

class TaskSyncApplyResult {
  TaskSyncApplyResult({
    required Iterable<Task> tasks,
    required this.resolvedConflictCount,
  }) : tasks = List<Task>.unmodifiable(tasks);

  final List<Task> tasks;
  final int resolvedConflictCount;
}

/// Applies an already-reviewed [TaskSyncPlan] through the canonical TaskStore.
///
/// The service deliberately owns no transport and never invents conflict
/// winners. A plan is applied only when the current local store still matches
/// the exact local snapshot used to build that plan. This prevents a stale
/// sync decision from overwriting newer local edits.
class TaskSyncApplyService {
  TaskSyncApplyService({TaskStore? store}) : _store = store ?? TaskStore();

  final TaskStore _store;

  Future<TaskSyncApplyResult> apply({
    required TaskSyncPlan plan,
    Map<String, TaskSyncConflictChoice> conflictChoices = const {},
  }) async {
    _validatePlanAndChoices(plan, conflictChoices);

    final currentLocal = await _store.load();
    _assertCurrentLocalMatchesPlan(plan, currentLocal);

    final selectedById = <String, Task>{};
    var resolvedConflictCount = 0;

    for (final item in plan.items) {
      switch (item.result.decision) {
        case SyncMergeDecision.localOnly:
        case SyncMergeDecision.identical:
        case SyncMergeDecision.useLocal:
          selectedById[item.id] = _requireLocal(item);
        case SyncMergeDecision.remoteOnly:
        case SyncMergeDecision.useRemote:
          selectedById[item.id] = _requireRemote(item);
        case SyncMergeDecision.conflict:
          final choice = conflictChoices[item.id];
          if (choice == null) {
            throw StateError('Unresolved sync conflict: ${item.id}');
          }
          selectedById[item.id] = switch (choice) {
            TaskSyncConflictChoice.useLocal => _requireLocal(item),
            TaskSyncConflictChoice.useRemote => _requireRemote(item),
          };
          resolvedConflictCount++;
      }
    }

    // Preserve the user's current local ordering for existing records. New
    // remote-only records are appended in the deterministic plan order.
    final merged = <Task>[];
    for (final localTask in currentLocal) {
      final selected = selectedById.remove(localTask.id);
      if (selected != null) merged.add(selected);
    }
    for (final item in plan.items) {
      final selected = selectedById.remove(item.id);
      if (selected != null) merged.add(selected);
    }

    if (selectedById.isNotEmpty) {
      throw StateError('Sync plan produced unconsumed Task ids.');
    }

    // One canonical write only after all validation and conflict resolution.
    await _store.save(merged);
    return TaskSyncApplyResult(
      tasks: merged,
      resolvedConflictCount: resolvedConflictCount,
    );
  }

  void _validatePlanAndChoices(
    TaskSyncPlan plan,
    Map<String, TaskSyncConflictChoice> choices,
  ) {
    final ids = <String>{};
    final conflictIds = <String>{};
    for (final item in plan.items) {
      if (item.id.isEmpty || !ids.add(item.id)) {
        throw ArgumentError('Sync plan contains an empty or duplicate Task id.');
      }
      if (item.result.decision == SyncMergeDecision.conflict) {
        conflictIds.add(item.id);
      }
    }

    for (final id in choices.keys) {
      if (!conflictIds.contains(id)) {
        throw ArgumentError('Conflict choice does not target a conflict: $id');
      }
    }
  }

  void _assertCurrentLocalMatchesPlan(
    TaskSyncPlan plan,
    List<Task> currentLocal,
  ) {
    final expected = <String, Task>{};
    for (final item in plan.items) {
      final local = item.localTask;
      if (local != null) expected[item.id] = local;
    }

    final current = <String, Task>{};
    for (final task in currentLocal) {
      if (task.id.isEmpty || current.containsKey(task.id)) {
        throw StateError('Current TaskStore contains an invalid Task id.');
      }
      current[task.id] = task;
    }

    if (current.length != expected.length ||
        !current.keys.every(expected.containsKey)) {
      throw StateError('Sync plan is stale: local Task set changed.');
    }

    for (final entry in current.entries) {
      final expectedTask = expected[entry.key]!;
      if (jsonEncode(entry.value.toJson()) !=
          jsonEncode(expectedTask.toJson())) {
        throw StateError('Sync plan is stale: local Task changed: ${entry.key}');
      }
    }
  }

  Task _requireLocal(TaskSyncPlanItem item) {
    final task = item.localTask;
    if (task == null) {
      throw StateError('Sync decision requires missing local Task: ${item.id}');
    }
    return task;
  }

  Task _requireRemote(TaskSyncPlanItem item) {
    final task = item.remoteTask;
    if (task == null) {
      throw StateError('Sync decision requires missing remote Task: ${item.id}');
    }
    return task;
  }
}
