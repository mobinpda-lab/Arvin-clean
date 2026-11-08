import '../models/task.dart';

/// Selects only explicitly chosen Home focus Tasks.
/// Due dates never add a Task to this projection.
class TodayFocusProjection {
  const TodayFocusProjection();

  List<Task> select(Iterable<Task> tasks) => tasks
      .where((task) =>
          task.isSelectedForToday && !task.archived && !task.trashed)
      .toList(growable: false);
}
