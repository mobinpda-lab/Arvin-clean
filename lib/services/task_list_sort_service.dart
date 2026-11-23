import '../models/task.dart';

enum TaskListSort { date, latest, lastFollowUp, title }

/// Stable, non-mutating sorting for canonical Task lists.
class TaskListSortService {
  const TaskListSortService();

  List<Task> sort(
    Iterable<Task> tasks, {
    required TaskListSort by,
    bool descending = false,
  }) {
    final indexed = tasks.toList(growable: false).asMap().entries.toList();
    indexed.sort((left, right) {
      final comparison = switch (by) {
        TaskListSort.date => _compareNullableDate(
            left.value.dueDate,
            right.value.dueDate,
            descending: descending,
          ),
        TaskListSort.latest => _compareNullableDate(
            _latestMeaningful(left.value),
            _latestMeaningful(right.value),
            descending: descending,
          ),
        TaskListSort.lastFollowUp => _compareNullableDate(
            left.value.lastFollowUpDate,
            right.value.lastFollowUpDate,
            descending: descending,
          ),
        TaskListSort.title => _directional(
            _normalizeTitle(left.value.title)
                .compareTo(_normalizeTitle(right.value.title)),
            descending,
          ),
      };
      if (comparison != 0) return comparison;

      final idComparison = left.value.id.compareTo(right.value.id);
      if (idComparison != 0) return idComparison;
      return left.key.compareTo(right.key);
    });
    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  int _directional(int value, bool descending) => descending ? -value : value;

  int _compareNullableDate(
    DateTime? left,
    DateTime? right, {
    required bool descending,
  }) {
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return _directional(left.compareTo(right), descending);
  }

  DateTime? _latestMeaningful(Task task) {
    DateTime? latest;
    for (final value in <DateTime?>[
      task.createdAt,
      task.updatedAt,
      task.lastFollowUpDate,
    ]) {
      if (value != null && (latest == null || value.isAfter(latest))) {
        latest = value;
      }
    }
    return latest;
  }

  String _normalizeTitle(String value) => value.trim().toLowerCase();
}
