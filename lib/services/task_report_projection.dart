import '../models/task.dart';

class TaskReportEntry {
  const TaskReportEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.checklist,
    required this.followUps,
    required this.completed,
    this.reminderDate,
    this.priority = TaskPriority.medium,
  });

  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final List<FollowUp> followUps;
  final List<String> checklist;
  final bool completed;
  final DateTime? reminderDate;
  final TaskPriority priority;
}

class TaskReportPriorityGroup {
  const TaskReportPriorityGroup({required this.priority, required this.entries});
  final TaskPriority priority;
  final List<TaskReportEntry> entries;
}

class TaskReport {
  const TaskReport({
    required this.title,
    required this.generatedAt,
    required this.entries,
  });

  final String title;
  final DateTime generatedAt;
  final List<TaskReportEntry> entries;

  /// Stable P1-to-P4 grouping for every report output surface.
  List<TaskReportPriorityGroup> get priorityGroups => TaskPriority.values
      .map((priority) => TaskReportPriorityGroup(
            priority: priority,
            entries: entries
                .where((entry) => entry.priority == priority)
                .toList(growable: false),
          ))
      .where((group) => group.entries.isNotEmpty)
      .toList(growable: false);
}

/// Read-only reporting projection over canonical Tasks.
class TaskReportProjection {
  const TaskReportProjection();

  TaskReport project(
    Iterable<Task> tasks, {
    Set<String>? selectedIds,
    DateTime? generatedAt,
    String title = 'گزارش آروین',
  }) {
    final entries = tasks
        .where((task) => !task.trashed)
        .where((task) => selectedIds == null || selectedIds.contains(task.id))
        .map(
          (task) => TaskReportEntry(
            id: task.id,
            title: task.title.trim().isEmpty ? 'بدون عنوان' : task.title,
            description: task.description,
            tags: List<String>.unmodifiable(task.tags),
            checklist: List<String>.unmodifiable(
              task.checklistEnabled ? task.checklist : const <String>[],
            ),
            followUps: List<FollowUp>.unmodifiable(task.followUps),
            completed: task.completed,
            reminderDate: task.reminderDate,
            priority: task.priority,
          ),
        )
        .toList(growable: false);

    return TaskReport(
      title: title,
      generatedAt: generatedAt ?? DateTime.now(),
      entries: entries,
    );
  }
}
