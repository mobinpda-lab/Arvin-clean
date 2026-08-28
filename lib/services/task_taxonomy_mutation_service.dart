import '../models/task.dart';

/// Canonical in-memory taxonomy mutations for Task/Note items.
///
/// Persistence remains owned by TaskStore/Home. This service only applies
/// deterministic category/tag changes to existing Task instances so item
/// identity, FollowUp history, reminders, due dates and unrelated metadata are
/// never replaced by a parallel taxonomy store.
class TaskTaxonomyMutationService {
  TaskTaxonomyMutationService({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  int renameCategory(
    List<Task> tasks, {
    required String from,
    required String to,
  }) {
    final source = from.trim();
    final target = to.trim();
    if (source.isEmpty || target.isEmpty || source == target) return 0;

    var changed = 0;
    final changedAt = _now();
    for (final task in tasks) {
      if (task.category?.trim() != source) continue;
      task.category = target;
      task.updatedAt = changedAt;
      changed++;
    }
    return changed;
  }

  int deleteCategory(List<Task> tasks, String category) {
    final target = category.trim();
    if (target.isEmpty) return 0;

    var changed = 0;
    final changedAt = _now();
    for (final task in tasks) {
      if (task.category?.trim() != target) continue;
      task.category = null;
      task.updatedAt = changedAt;
      changed++;
    }
    return changed;
  }

  int renameTag(
    List<Task> tasks, {
    required String from,
    required String to,
  }) {
    final source = from.trim();
    final target = to.trim();
    if (source.isEmpty || target.isEmpty || source == target) return 0;

    var changed = 0;
    final changedAt = _now();
    for (final task in tasks) {
      final next = <String>[];
      final seen = <String>{};
      var touched = false;

      for (final raw in task.tags) {
        final value = raw.trim();
        if (value.isEmpty) continue;
        final replacement = value == source ? target : value;
        if (replacement != value) touched = true;
        if (seen.add(replacement)) next.add(replacement);
      }

      if (!touched || _sameStrings(task.tags, next)) continue;
      task.tags = next;
      task.updatedAt = changedAt;
      changed++;
    }
    return changed;
  }

  int deleteTag(List<Task> tasks, String tag) {
    final target = tag.trim();
    if (target.isEmpty) return 0;

    var changed = 0;
    final changedAt = _now();
    for (final task in tasks) {
      final next = task.tags.where((raw) => raw.trim() != target).toList();
      if (_sameStrings(task.tags, next)) continue;
      task.tags = next;
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
