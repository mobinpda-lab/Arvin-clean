import '../models/task.dart';

/// Pure projection for the Home "Today" view.
///
/// This reuses the canonical Task list and the same current Home follow-up
/// date projection. It never owns persistence, routing, or a second task list.
class HomeTodayProjection {
  const HomeTodayProjection();

  List<Task> select(Iterable<Task> tasks, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return tasks.where((task) {
      if (task.archived || task.trashed || task.completed) return false;
      final followUpDate = task.legacyHomeFollowUpDate;
      if (followUpDate == null) return false;
      return _sameLocalDay(followUpDate, reference);
    }).toList(growable: false);
  }

  bool _sameLocalDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
