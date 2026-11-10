import '../models/task.dart';

/// Pure projection for the Home "Today" view.
///
/// Legacy Home projection for Tasks whose latest recorded Follow-up is today.
/// This is not the calendar-due-today projection and owns no persistence.
class HomeLastFollowUpProjection {
  const HomeLastFollowUpProjection();

  List<Task> select(Iterable<Task> tasks, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return tasks.where((task) {
      if (task.archived || task.trashed || task.completed) return false;
      final followUpDate = task.legacyHomeFollowUpDate;
      if (followUpDate == null) return false;
      return _sameLocalDay(followUpDate, reference);
    }).toList(growable: false);
  }

  bool _sameLocalDay(DateTime left, DateTime right) {
    final localLeft = left.toLocal();
    final localRight = right.toLocal();
    return localLeft.year == localRight.year &&
        localLeft.month == localRight.month &&
        localLeft.day == localRight.day;
  }
}

/// Source-compatible alias; new callers should use the unambiguous name.
typedef HomeTodayProjection = HomeLastFollowUpProjection;
