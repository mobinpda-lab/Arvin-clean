import '../models/task.dart';
import '../models/goal_project.dart';

enum ReportTimePreset { all, today, tomorrow, thisWeek, future, past, undated }

enum ReportStatusFilter { all, open, completed, archived }

class TaskReportFilter {
  const TaskReportFilter({
    this.timePreset = ReportTimePreset.all,
    this.fromDate,
    this.toDate,
    this.fromTime,
    this.toTime,
    this.projectId,
    this.category,
    this.tag,
    this.projectIds = const <String>{},
    this.categories = const <String>{},
    this.tags = const <String>{},
    this.status = ReportStatusFilter.all,
    this.priority,
    this.hasRepeat,
    this.hasFollowUp,
    this.hasChecklist,
  });

  final ReportTimePreset timePreset;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Duration? fromTime;
  final Duration? toTime;
  final String? projectId;
  final String? category;
  final String? tag;
  final Set<String> projectIds;
  final Set<String> categories;
  final Set<String> tags;
  final ReportStatusFilter status;
  final TaskPriority? priority;
  final bool? hasRepeat;
  final bool? hasFollowUp;
  final bool? hasChecklist;

  bool get isActive =>
      timePreset != ReportTimePreset.all ||
      fromDate != null ||
      toDate != null ||
      fromTime != null ||
      toTime != null ||
      projectId != null ||
      category != null ||
      tag != null ||
      projectIds.isNotEmpty ||
      categories.isNotEmpty ||
      tags.isNotEmpty ||
      status != ReportStatusFilter.all ||
      priority != null ||
      hasRepeat != null ||
      hasFollowUp != null ||
      hasChecklist != null;

  List<Task> apply(
    Iterable<Task> tasks, {
    required DateTime now,
    Iterable<ProjectPlan> projects = const [],
  }) {
    final selectedProjectIds = <String>{
      ...projectIds,
      if (projectId != null) projectId!,
    };
    final selectedCategories = <String>{
      ...categories,
      if (category != null) category!,
    };
    final selectedTags = <String>{
      ...tags,
      if (tag != null) tag!,
    };
    final selectedProjects = projects
        .where((item) => selectedProjectIds.contains(item.id))
        .toList(growable: false);
    return tasks.where((task) {
      if (task.trashed) return false;
      if (!_matchesStatus(task)) return false;
      if (priority != null && task.priority != priority) return false;
      if (hasRepeat != null && (task.recurrence != null) != hasRepeat) {
        return false;
      }
      if (hasFollowUp != null && task.followUpEnabled != hasFollowUp) {
        return false;
      }
      if (hasChecklist != null &&
          (task.checklist.isNotEmpty) != hasChecklist) {
        return false;
      }
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(task.category?.trim())) {
        return false;
      }
      if (selectedTags.isNotEmpty &&
          !task.tags.any((value) => selectedTags.contains(value.trim()))) {
        return false;
      }
      if (selectedProjectIds.isNotEmpty &&
          !selectedProjects.any((project) => project.itemIds.contains(task.id))) {
        return false;
      }
      if (!_matchesTime(task.dueDate, now)) return false;
      return true;
    }).toList(growable: false);
  }

  bool _matchesStatus(Task task) {
    switch (status) {
      case ReportStatusFilter.all:
        return true;
      case ReportStatusFilter.open:
        return !task.completed && !task.archived;
      case ReportStatusFilter.completed:
        return task.completed;
      case ReportStatusFilter.archived:
        return task.archived;
    }
  }

  bool _matchesTime(DateTime? value, DateTime now) {
    if (value == null) {
      final noPreciseRange = fromDate == null &&
          toDate == null &&
          fromTime == null &&
          toTime == null;
      return timePreset == ReportTimePreset.undated ||
          (timePreset == ReportTimePreset.all && noPreciseRange);
    }

    final local = value.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);

    switch (timePreset) {
      case ReportTimePreset.all:
        break;
      case ReportTimePreset.today:
        if (day != today) return false;
      case ReportTimePreset.tomorrow:
        if (day != today.add(const Duration(days: 1))) return false;
      case ReportTimePreset.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 7));
        if (day.isBefore(start) || !day.isBefore(end)) return false;
      case ReportTimePreset.future:
        if (!day.isAfter(today)) return false;
      case ReportTimePreset.past:
        if (!day.isBefore(today)) return false;
      case ReportTimePreset.undated:
        return false;
    }

    if (fromDate != null && day.isBefore(_dateOnly(fromDate!))) return false;
    if (toDate != null && day.isAfter(_dateOnly(toDate!))) return false;

    final minute = local.hour * 60 + local.minute;
    if (fromTime != null && minute < fromTime!.inMinutes) return false;
    if (toTime != null && minute > toTime!.inMinutes) return false;
    return true;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
