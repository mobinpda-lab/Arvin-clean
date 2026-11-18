import '../models/task.dart';

/// Selects only tasks with an actual completion timestamp inside one local
/// Jalali day. The supplied day comes from the Persian date picker and is
/// represented as its corresponding local Gregorian calendar date.
class CompletedTaskReportProjection {
  const CompletedTaskReportProjection();

  List<Task> forJalaliDay(Iterable<Task> tasks, DateTime jalaliDay) {
    final localDay = jalaliDay.toLocal();
    final startOfDay = DateTime(localDay.year, localDay.month, localDay.day);
    final startOfNextDay = DateTime(localDay.year, localDay.month, localDay.day + 1);

    return List<Task>.unmodifiable(tasks.where((task) {
      if (!task.completed) return false;
      final completedAt = task.completedAt;
      if (completedAt == null) return false;
      return !completedAt.isBefore(startOfDay) &&
          completedAt.isBefore(startOfNextDay);
    }));
  }
}
