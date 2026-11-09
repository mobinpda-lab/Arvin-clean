import '../../models/goal_project.dart';
import '../../models/task.dart';
import 'home_group.dart';
import 'home_group_mode.dart';
import '../../services/iran_clock.dart';
import '../../services/task_due_status.dart';
import '../../services/task_list_sort_service.dart';

/// Creates Home projections from existing canonical application data.
///
/// This layer intentionally does not persist anything and does not duplicate
/// Task payloads. TaskStore remains the source of truth; Project membership is
/// supplied from the canonical ProjectStore/ProjectPlan collection.
class HomeGroupingService {
  const HomeGroupingService();

  List<HomeGroup<Task>> buildGroups(
    HomeGroupMode mode,
    List<Task> tasks, {
    Iterable<ProjectPlan> projects = const <ProjectPlan>[],
    DateTime? now,
  }) {
    final activeTasks = tasks.where((task) => !task.trashed).toList();

    switch (mode) {
      case HomeGroupMode.time:
        return _timeGroups(activeTasks, now: now ?? IranClock.now());
      case HomeGroupMode.projects:
        return _projectGroups(activeTasks, projects);
      case HomeGroupMode.categories:
        return _categoryGroups(activeTasks);
      case HomeGroupMode.labels:
        return _labelGroups(activeTasks);
    }
  }

  List<HomeGroup<Task>> _timeGroups(
    List<Task> tasks, {
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    DateTime dayOf(DateTime value) =>
        DateTime(value.year, value.month, value.day);

    final grouped = <String, List<Task>>{
      'overdue': <Task>[],
      'completed_past': <Task>[],
      'today': <Task>[],
      'tomorrow': <Task>[],
      'future': <Task>[],
      'no_date': <Task>[],
    };

    for (final task in tasks) {
      final due = task.dueDate;
      if (due == null) {
        grouped['no_date']!.add(task);
        continue;
      }

      final day = dayOf(due);
      if (task.completed && day.isBefore(today)) {
        grouped['completed_past']!.add(task);
      } else if (TaskDueStatus.isOverdue(task, now: now)) {
        grouped['overdue']!.add(task);
      } else if (day == today) {
        grouped['today']!.add(task);
      } else if (day == tomorrow) {
        grouped['tomorrow']!.add(task);
      } else {
        grouped['future']!.add(task);
      }
    }

    const sorter = TaskListSortService();
    List<Task> ordered(String key) =>
        key == 'overdue' || key == 'completed_past'
            ? sorter.sortPast(grouped[key]!)
            : sorter.sortByPriorityThenCreatedAt(grouped[key]!);

    return [
      HomeGroup<Task>(id: 'overdue', title: 'گذشته', items: ordered('overdue')),
      HomeGroup<Task>(
        id: 'completed_past',
        title: 'گذشته (انجام‌شده)',
        items: ordered('completed_past'),
      ),
      HomeGroup<Task>(id: 'today', title: 'امروز', items: ordered('today')),
      HomeGroup<Task>(id: 'tomorrow', title: 'فردا', items: ordered('tomorrow')),
      HomeGroup<Task>(id: 'future', title: 'آینده', items: ordered('future')),
      HomeGroup<Task>(id: 'no_date', title: 'فاقد زمان', items: ordered('no_date')),
    ];
  }

  List<HomeGroup<Task>> _projectGroups(
    List<Task> tasks,
    Iterable<ProjectPlan> projects,
  ) {
    final taskById = {for (final task in tasks) task.id: task};
    final assignedTaskIds = <String>{};
    final result = <HomeGroup<Task>>[];

    for (final project in projects) {
      final items = <Task>[];
      for (final taskId in project.itemIds) {
        // Canonical assignment permits at most one Project per Task. If
        // corrupted legacy data contains duplicate memberships, keep Home a
        // projection of one Task rather than multiplying it across Projects.
        if (!assignedTaskIds.add(taskId)) continue;
        final task = taskById[taskId];
        if (task != null) items.add(task);
      }

      result.add(
        HomeGroup<Task>(
          id: project.id,
          title: project.title,
          items: items,
        ),
      );
    }

    result.add(
      HomeGroup<Task>(
        id: 'no_project',
        title: 'بدون پروژه',
        items: tasks
            .where((task) => !assignedTaskIds.contains(task.id))
            .toList(),
      ),
    );

    return result;
  }

  List<HomeGroup<Task>> _categoryGroups(List<Task> tasks) {
    final groups = <String, List<Task>>{};

    for (final task in tasks) {
      final category = task.category?.trim();
      final key = category == null || category.isEmpty
          ? 'uncategorized'
          : category;
      groups.putIfAbsent(key, () => []).add(task);
    }

    return groups.entries
        .map(
          (entry) => HomeGroup<Task>(
            id: entry.key,
            title: entry.key == 'uncategorized' ? 'بدون دسته' : entry.key,
            items: entry.value,
          ),
        )
        .toList();
  }

  List<HomeGroup<Task>> _labelGroups(List<Task> tasks) {
    final groups = <String, List<Task>>{};
    final untagged = <Task>[];

    for (final task in tasks) {
      final normalizedTags = task.tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet();

      if (normalizedTags.isEmpty) {
        untagged.add(task);
        continue;
      }

      for (final tag in normalizedTags) {
        groups.putIfAbsent(tag, () => []).add(task);
      }
    }

    final result = groups.entries
        .map(
          (entry) => HomeGroup<Task>(
            id: entry.key,
            title: entry.key,
            items: entry.value,
          ),
        )
        .toList();

    result.add(
      HomeGroup<Task>(
        id: 'untagged',
        title: 'بدون برچسب',
        items: untagged,
      ),
    );

    return result;
  }
}
