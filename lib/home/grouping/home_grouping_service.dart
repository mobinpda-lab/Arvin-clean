import '../../models/task.dart';
import 'home_group.dart';
import 'home_group_mode.dart';

/// Creates Home projections from existing application data.
///
/// This layer intentionally does not persist anything and does not duplicate
/// Task data. The source of truth remains the existing stores/models.
class HomeGroupingService {
  const HomeGroupingService();

  List<HomeGroup<Task>> buildGroups(
    HomeGroupMode mode,
    List<Task> tasks,
  ) {
    final activeTasks = tasks.where((task) => !task.trashed).toList();

    switch (mode) {
      case HomeGroupMode.time:
        return _timeGroups(activeTasks);
      case HomeGroupMode.projects:
        return _projectGroups(activeTasks);
      case HomeGroupMode.categories:
        return _categoryGroups(activeTasks);
      case HomeGroupMode.labels:
        return _labelGroups(activeTasks);
    }
  }

  List<HomeGroup<Task>> _timeGroups(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      HomeGroup<Task>(
        id: 'overdue',
        title: 'Overdue',
        items: tasks.where((task) {
          final due = task.dueDate;
          return due != null && due.isBefore(today) && !task.completed;
        }).toList(),
      ),
      HomeGroup<Task>(
        id: 'today',
        title: 'Today',
        items: tasks.where((task) {
          final due = task.dueDate;
          return due != null &&
              due.year == today.year &&
              due.month == today.month &&
              due.day == today.day;
        }).toList(),
      ),
      HomeGroup<Task>(
        id: 'future',
        title: 'Future',
        items: tasks.where((task) {
          final due = task.dueDate;
          return due != null && due.isAfter(today);
        }).toList(),
      ),
      HomeGroup<Task>(
        id: 'no_date',
        title: 'No Date',
        items: tasks.where((task) => task.dueDate == null).toList(),
      ),
    ];
  }

  List<HomeGroup<Task>> _projectGroups(List<Task> tasks) => const [];

  List<HomeGroup<Task>> _categoryGroups(List<Task> tasks) {
    final groups = <String, List<Task>>{};

    for (final task in tasks) {
      final key = task.category ?? 'uncategorized';
      groups.putIfAbsent(key, () => []).add(task);
    }

    return groups.entries
        .map(
          (entry) => HomeGroup<Task>(
            id: entry.key,
            title: entry.key,
            items: entry.value,
          ),
        )
        .toList();
  }

  List<HomeGroup<Task>> _labelGroups(List<Task> tasks) {
    final groups = <String, List<Task>>{};

    for (final task in tasks) {
      for (final tag in task.tags) {
        groups.putIfAbsent(tag, () => []).add(task);
      }
    }

    return groups.entries
        .map(
          (entry) => HomeGroup<Task>(
            id: entry.key,
            title: entry.key,
            items: entry.value,
          ),
        )
        .toList();
  }
}
