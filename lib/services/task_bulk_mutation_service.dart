import '../models/task.dart';

/// Applies batch mutations directly to the existing canonical [Task] objects.
///
/// The service deliberately has no persistence of its own. Callers keep using
/// TaskStore / the canonical Home write path after a successful mutation.
class TaskBulkMutationService {
  TaskBulkMutationService({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Moves selected tasks to trash without changing IDs, history, category,
  /// tags, due dates, reminders or follow-up state.
  int moveToTrash(List<Task> tasks, Iterable<String> selectedIds) {
    final ids = selectedIds.toSet();
    if (ids.isEmpty) return 0;

    var changed = 0;
    final changedAt = _now();
    for (final task in tasks) {
      if (!ids.contains(task.id) || task.trashed) continue;
      task.trashed = true;
      task.updatedAt = changedAt;
      changed++;
    }
    return changed;
  }

  /// Reassigns selected tasks to one category. A blank category clears the
  /// assignment. Existing task identity and all unrelated fields are kept.
  int moveToCategory(
    List<Task> tasks,
    Iterable<String> selectedIds,
    String? category,
  ) {
    final ids = selectedIds.toSet();
    if (ids.isEmpty) return 0;

    final normalized = category?.trim();
    final nextCategory = normalized == null || normalized.isEmpty
        ? null
        : normalized;
    var changed = 0;
    final changedAt = _now();

    for (final task in tasks) {
      if (!ids.contains(task.id) || task.category == nextCategory) continue;
      task.category = nextCategory;
      task.updatedAt = changedAt;
      changed++;
    }
    return changed;
  }

  /// Adds one or more tags to selected tasks while preserving unrelated tags.
  /// Empty values are ignored and tags are de-duplicated deterministically.
  int addTags(
    List<Task> tasks,
    Iterable<String> selectedIds,
    Iterable<String> tags,
  ) {
    final ids = selectedIds.toSet();
    if (ids.isEmpty) return 0;

    final additions = <String>[];
    final seenAdditions = <String>{};
    for (final raw in tags) {
      final value = raw.trim();
      if (value.isEmpty || !seenAdditions.add(value)) continue;
      additions.add(value);
    }
    if (additions.isEmpty) return 0;

    var changed = 0;
    final changedAt = _now();
    for (final task in tasks) {
      if (!ids.contains(task.id)) continue;

      final merged = <String>[];
      final seen = <String>{};
      for (final raw in [...task.tags, ...additions]) {
        final value = raw.trim();
        if (value.isEmpty || !seen.add(value)) continue;
        merged.add(value);
      }

      if (_sameStrings(task.tags, merged)) continue;
      task.tags = merged;
      task.updatedAt = changedAt;
      changed++;
    }
    return changed;
  }

  bool _sameStrings(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
