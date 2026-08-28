import '../models/task.dart';

enum HomeListScope {
  all,
  notes,
  followUpEnabled,
  today,
  future,
  overdue,
}

enum HomeListSort { date, latest, title }

/// Pure canonical projection for Home list scopes and ordering.
///
/// No persistence, selection state, routing or UI state is owned here. Date
/// scopes prefer the independent Task due date and fall back to the existing
/// legacy FollowUp projection only while Home migration remains incomplete.
class HomeListProjection {
  const HomeListProjection();

  List<Task> project(
    Iterable<Task> tasks, {
    required HomeListScope scope,
    required HomeListSort sort,
    bool ascending = true,
    DateTime? now,
  }) {
    final reference = (now ?? DateTime.now()).toLocal();
    final result = tasks.where((task) {
      if (task.archived || task.trashed) return false;

      switch (scope) {
        case HomeListScope.all:
          return true;
        case HomeListScope.notes:
          return task.isSimpleNote;
        case HomeListScope.followUpEnabled:
          return !task.isSimpleNote;
        case HomeListScope.today:
          final date = _effectiveDate(task);
          return !task.completed &&
              date != null &&
              _sameLocalDay(date, reference);
        case HomeListScope.future:
          final date = _effectiveDate(task);
          return !task.completed &&
              date != null &&
              _day(date).isAfter(_day(reference));
        case HomeListScope.overdue:
          final date = _effectiveDate(task);
          return !task.completed &&
              date != null &&
              _day(date).isBefore(_day(reference));
      }
    }).toList();

    result.sort((left, right) {
      final comparison = switch (sort) {
        HomeListSort.date => _compareNullableDates(
            _effectiveDate(left),
            _effectiveDate(right),
          ),
        HomeListSort.latest => _compareNullableDates(
            _latestMeaningfulDate(left),
            _latestMeaningfulDate(right),
          ),
        HomeListSort.title => left.title.trim().compareTo(right.title.trim()),
      };
      if (comparison != 0) return ascending ? comparison : -comparison;
      final byId = left.id.compareTo(right.id);
      return ascending ? byId : -byId;
    });

    return List<Task>.unmodifiable(result);
  }

  DateTime? _effectiveDate(Task task) =>
      task.dueDate ?? task.legacyHomeFollowUpDate;

  DateTime? _latestMeaningfulDate(Task task) {
    DateTime? latest;
    for (final candidate in <DateTime?>[
      task.createdAt,
      task.updatedAt,
      task.lastFollowUpDate,
    ]) {
      if (candidate == null) continue;
      if (latest == null || candidate.isAfter(latest)) latest = candidate;
    }
    return latest;
  }

  int _compareNullableDates(DateTime? left, DateTime? right) {
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return left.compareTo(right);
  }

  DateTime _day(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  bool _sameLocalDay(DateTime left, DateTime right) =>
      _day(left) == _day(right);
}
