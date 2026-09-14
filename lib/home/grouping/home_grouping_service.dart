import '../../models/task.dart';
import 'home_group.dart';
import 'home_group_mode.dart';

class HomeGroupingService {
  const HomeGroupingService();

  List<HomeGroup<Task>> group(List<Task> tasks, HomeGroupMode mode) {
    switch (mode) {
      case HomeGroupMode.time:
        return _timeGroups(tasks);
      case HomeGroupMode.projects:
        return [
          HomeGroup<Task>(
            id: 'all',
            title: 'همه پروژه‌ها',
            items: tasks,
          ),
        ];
      case HomeGroupMode.categories:
        return _categoryGroups(tasks);
      case HomeGroupMode.labels:
        return _labelGroups(tasks);
    }
  }

  List<HomeGroup<Task>> _timeGroups(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overdue = <Task>[];
    final todayTasks = <Task>[];
    final future = <Task>[];
    final noDate = <Task>[];

    for (final task in tasks.where((task) => !task.completed)) {
      final due = task.dueDate;
      if (due == null) {
        noDate.add(task);
        continue;
      }

      final date = DateTime(due.year, due.month, due.day);
      if (date.isBefore(today)) {
        overdue.add(task);
      } else if (date == today) {
        todayTasks.add(task);
      } else {
        future.add(task);
      }
    }

    return [
      HomeGroup(id: 'overdue', title: 'عقب‌افتاده', items: overdue),
      HomeGroup(id: 'today', title: 'امروز', items: todayTasks),
      HomeGroup(id: 'future', title: 'آینده', items: future),
      HomeGroup(id: 'no-date', title: 'بدون موعد', items: noDate),
    ];
  }

  List<HomeGroup<Task>> _categoryGroups(List<Task> tasks) {
    final groups = <String, List<Task>>{};
    for (final task in tasks) {
      final key = task.category ?? 'بدون دسته';
      groups.putIfAbsent(key, () => []).add(task);
    }
    return groups.entries
        .map((entry) => HomeGroup<Task>(
              id: entry.key,
              title: entry.key,
              items: entry.value,
            ))
        .toList();
  }

  List<HomeGroup<Task>> _labelGroups(List<Task> tasks) {
    final groups = <String, List<Task>>{};
    for (final task in tasks) {
      if (task.tags.isEmpty) {
        groups.putIfAbsent('بدون برچسب', () => []).add(task);
        continue;
      }
      for (final tag in task.tags) {
        groups.putIfAbsent(tag, () => []).add(task);
      }
    }
    return groups.entries
        .map((entry) => HomeGroup<Task>(
              id: entry.key,
              title: entry.key,
              items: entry.value,
            ))
        .toList();
  }
}
