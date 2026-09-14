import '../../models/goal_project.dart';
import '../../models/task.dart';
import 'home_group.dart';
import 'home_group_mode.dart';

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
  }) {
    final activeTasks = tasks.where((task) => !task.trashed).toList();

    switch (mode) {
      case HomeGroupMode.time:
        return _timeGroups(activeTasks);
      case HomeGroupMode.projects:
        return _projectGroups(activeTasks, projects);
      case HomeGroupMode.categories:
        return _categoryGroups(activeTasks);
      case HomeGroupMode.labels:
        return _labelGroups(activeTasks);
    }
  }

  List<HomeGroup<Task>> _timeGroups(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime dayOf(DateTime value) =>
        DateTime(value.year, value.month, value.day);

    return [
      HomeGroup<Task>(
        id: 'overdue',
        title: 'عقب‌افتاده',
        items: tasks.where((task) {
          final due = task.dueDate;
          return due != null &&
              dayOf(due).isBefore(today) &&
              !task.completed;
        }).toList(),
      ),
      HomeGroup<Task>(
        id: 'today',
        title: 'امروز',
        items: tasks.where((task) {
          final due = task.dueDate;
          return due != null && dayOf(due) == today;
        }).toList(),
      ),
      HomeGroup<Task>(
        id: 'future',
        title: 'آینده',
        items: tasks.where((task) {
          final due = task.dueDate;
          return due != null && dayOf(due).isAfter(today);
        }).toList(),
      ),
      HomeGroup<Task>(
        id: 'no_date',
        title: 'بدون موعد',
        items: tasks.where((task) => task.dueDate == null).toList(),
      ),
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
