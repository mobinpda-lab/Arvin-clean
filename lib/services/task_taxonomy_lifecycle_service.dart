import '../models/task.dart';

class TaxonomyDeleteBlocked implements Exception {
  const TaxonomyDeleteBlocked(this.kind, this.value, this.referenceCount);

  final String kind;
  final String value;
  final int referenceCount;

  @override
  String toString() =>
      'TaxonomyDeleteBlocked: $kind "$value" has $referenceCount canonical references';
}

/// Dependency-safe lifecycle operations over taxonomy already owned by Task.
///
/// This service intentionally owns no persistence and introduces no Category or
/// Tag store. Callers persist the same canonical Task objects through TaskStore.
class TaskTaxonomyLifecycleService {
  const TaskTaxonomyLifecycleService();

  List<String> categories(Iterable<Task> tasks) => _sortedUnique(
        tasks.map((task) => task.category),
      );

  List<String> tags(Iterable<Task> tasks) => _sortedUnique(
        tasks.expand((task) => task.tags),
      );

  int categoryReferenceCount(Iterable<Task> tasks, String category) {
    final target = category.trim();
    return tasks.where((task) => task.category?.trim() == target).length;
  }

  int tagReferenceCount(Iterable<Task> tasks, String tag) {
    final target = tag.trim();
    return tasks.where((task) => task.tags.any((value) => value.trim() == target)).length;
  }

  void assertCategoryCanDelete(Iterable<Task> tasks, String category) {
    final value = category.trim();
    final count = categoryReferenceCount(tasks, value);
    if (count > 0) throw TaxonomyDeleteBlocked('category', value, count);
  }

  void assertTagCanDelete(Iterable<Task> tasks, String tag) {
    final value = tag.trim();
    final count = tagReferenceCount(tasks, value);
    if (count > 0) throw TaxonomyDeleteBlocked('tag', value, count);
  }

  int renameCategory(
    Iterable<Task> tasks, {
    required String from,
    required String to,
  }) {
    final source = _requiredValue(from, 'from');
    final target = _requiredValue(to, 'to');
    var changed = 0;
    for (final task in tasks) {
      if (task.category?.trim() != source) continue;
      task.category = target;
      changed++;
    }
    return changed;
  }

  int renameTag(
    Iterable<Task> tasks, {
    required String from,
    required String to,
  }) {
    final source = _requiredValue(from, 'from');
    final target = _requiredValue(to, 'to');
    var changed = 0;
    for (final task in tasks) {
      if (!task.tags.any((value) => value.trim() == source)) continue;
      final next = <String>[];
      for (final value in task.tags) {
        final normalized = value.trim() == source ? target : value.trim();
        if (normalized.isNotEmpty && !next.contains(normalized)) next.add(normalized);
      }
      task.tags = next;
      changed++;
    }
    return changed;
  }

  List<String> _sortedUnique(Iterable<String?> values) {
    final result = values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return List<String>.unmodifiable(result);
  }

  String _requiredValue(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, name, 'Taxonomy value cannot be empty');
    }
    return normalized;
  }
}
