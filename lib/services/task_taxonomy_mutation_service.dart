import '../models/task.dart';

class TaskTaxonomyDeleteBlocked implements Exception {
  const TaskTaxonomyDeleteBlocked({
    required this.kind,
    required this.value,
    required this.referenceCount,
  });

  final String kind;
  final String value;
  final int referenceCount;

  @override
  String toString() =>
      'TaskTaxonomyDeleteBlocked: $kind "$value" is referenced by $referenceCount canonical items';
}

/// Canonical in-memory taxonomy mutations for Task/Note items.
///
/// Persistence remains owned by TaskStore/Home. This service only applies
/// deterministic category/tag changes to existing Task instances so item
/// identity, FollowUp history, reminders, due dates and unrelated metadata are
/// never replaced by a parallel taxonomy store.
///
/// Owner recovery rule: a Category or Tag that is referenced by a canonical
/// item cannot be destructively deleted. Callers must first rename/reassign the
/// references (or use a future explicit archive/disable path). The delete
/// methods therefore fail closed instead of silently orphaning user data.
class TaskTaxonomyMutationService {
  TaskTaxonomyMutationService({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  int categoryUsageCount(Iterable<Task> tasks, String category) {
    final target = category.trim();
    if (target.isEmpty) return 0;
    return tasks.where((task) => task.category?.trim() == target).length;
  }

  int tagUsageCount(Iterable<Task> tasks, String tag) {
    final target = tag.trim();
    if (target.isEmpty) return 0;
    return tasks
        .where((task) => task.tags.any((raw) => raw.trim() == target))
        .length;
  }

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

    final referenceCount = categoryUsageCount(tasks, target);
    if (referenceCount > 0) {
      throw TaskTaxonomyDeleteBlocked(
        kind: 'category',
        value: target,
        referenceCount: referenceCount,
      );
    }
    return 0;
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

    final referenceCount = tagUsageCount(tasks, target);
    if (referenceCount > 0) {
      throw TaskTaxonomyDeleteBlocked(
        kind: 'tag',
        value: target,
        referenceCount: referenceCount,
      );
    }
    return 0;
  }

  bool _sameStrings(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
