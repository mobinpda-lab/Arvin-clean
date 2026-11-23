import '../models/task.dart';

/// Pure selection rules for Task bulk actions.
///
/// UI surfaces keep owning their local selection state; this service makes
/// toggle/select-all/reconciliation behavior deterministic across Home and
/// Notebook without introducing another store or persistence path.
class TaskBulkSelectionService {
  const TaskBulkSelectionService();

  Set<String> toggle(Iterable<String> selectedIds, String taskId) {
    final next = Set<String>.of(selectedIds);
    if (!next.add(taskId)) next.remove(taskId);
    return next;
  }

  Set<String> selectAll(
    Iterable<String> selectedIds,
    Iterable<Task> visibleTasks,
  ) {
    final visibleIds = visibleTasks.map((task) => task.id).toSet();
    if (visibleIds.isEmpty) return Set<String>.of(selectedIds);

    final next = Set<String>.of(selectedIds);
    final allVisibleAlreadySelected = visibleIds.every(next.contains);
    if (allVisibleAlreadySelected) {
      next.removeAll(visibleIds);
    } else {
      next.addAll(visibleIds);
    }
    return next;
  }

  /// Drops IDs which are no longer present in the canonical Task collection.
  /// This prevents stale selection state after delete/restore/filter refreshes.
  Set<String> reconcile(
    Iterable<String> selectedIds,
    Iterable<Task> canonicalTasks,
  ) {
    final existing = canonicalTasks.map((task) => task.id).toSet();
    return selectedIds.where(existing.contains).toSet();
  }

  bool allVisibleSelected(
    Iterable<String> selectedIds,
    Iterable<Task> visibleTasks,
  ) {
    final visibleIds = visibleTasks.map((task) => task.id).toList();
    if (visibleIds.isEmpty) return false;
    final selected = selectedIds.toSet();
    return visibleIds.every(selected.contains);
  }

  List<Task> selectedTasks(
    Iterable<Task> canonicalTasks,
    Iterable<String> selectedIds,
  ) {
    final ids = selectedIds.toSet();
    return canonicalTasks.where((task) => ids.contains(task.id)).toList();
  }
}
