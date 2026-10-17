import '../models/task.dart';
import '../models/goal_project.dart';
import '../models/recurrence.dart';

enum ReportTimePreset { all, today, tomorrow, thisWeek, future, past, undated }

enum ReportStatusFilter { all, open, completed, archived }

enum ReportNoteDateField { created, updated }

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
    this.personIds = const <String>{},
    this.waitingForResponse,
    this.status = ReportStatusFilter.all,
    this.statuses = const <ReportStatusFilter>{},
    this.trackingLevels = const <RecurrenceTrackingLevel>{},
    this.noteKinds = const <NotebookItemKind>{},
    this.noteQuery = '',
    this.noteDateField,
    this.noteFromDate,
    this.noteToDate,
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
  final Set<String> personIds;
  /// Null means no waiting-state constraint; true/false filter active waiting follow-ups.
  final bool? waitingForResponse;
  final ReportStatusFilter status;
  final Set<ReportStatusFilter> statuses;
  final Set<RecurrenceTrackingLevel> trackingLevels;
  final Set<NotebookItemKind> noteKinds;
  final String noteQuery;
  final ReportNoteDateField? noteDateField;
  final DateTime? noteFromDate;
  final DateTime? noteToDate;
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
      personIds.isNotEmpty ||
      waitingForResponse != null ||
      status != ReportStatusFilter.all ||
      statuses.isNotEmpty ||
      trackingLevels.isNotEmpty ||
      noteKinds.isNotEmpty ||
      noteQuery.trim().isNotEmpty ||
      ((noteFromDate != null || noteToDate != null) && noteDateField != null) ||
      noteFromDate != null ||
      noteToDate != null ||
      priority != null ||
      hasRepeat != null ||
      hasFollowUp != null ||
      hasChecklist != null;


  TaskReportFilter copyWith({
    Set<String>? personIds,
    bool? waitingForResponse,
    bool clearWaitingForResponse = false,
  }) =>
      TaskReportFilter(
        timePreset: timePreset,
        fromDate: fromDate,
        toDate: toDate,
        fromTime: fromTime,
        toTime: toTime,
        projectId: projectId,
        category: category,
        tag: tag,
        projectIds: projectIds,
        categories: categories,
        tags: tags,
        personIds: personIds ?? this.personIds,
        waitingForResponse: clearWaitingForResponse
            ? null
            : waitingForResponse ?? this.waitingForResponse,
        status: status,
        statuses: statuses,
        trackingLevels: trackingLevels,
        noteKinds: noteKinds,
        noteQuery: noteQuery,
        noteDateField: noteDateField,
        noteFromDate: noteFromDate,
        noteToDate: noteToDate,
        priority: priority,
        hasRepeat: hasRepeat,
        hasFollowUp: hasFollowUp,
        hasChecklist: hasChecklist,
      );

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
      if (personIds.isNotEmpty &&
          !task.people.any((person) => personIds.contains(person.id)) &&
          !task.followUps.any((followUp) =>
              followUp.personIds.any(personIds.contains))) {
        return false;
      }
      if (waitingForResponse != null) {
        final hasWaitingFollowUp = task.followUps.any(
          (followUp) => followUp.waitingForResponse && !followUp.completed,
        );
        if (hasWaitingFollowUp != waitingForResponse) return false;
      }
      if (!_matchesStatus(task)) return false;
      if (trackingLevels.isNotEmpty &&
          (task.recurrence == null ||
              !trackingLevels.contains(task.recurrence!.trackingLevel))) {
        return false;
      }
      if (!_matchesNote(task)) return false;
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
    final selected = statuses.where((value) => value != ReportStatusFilter.all).toSet();
    if (selected.isNotEmpty) {
      return selected.any((value) => _statusMatches(task, value));
    }
    return _statusMatches(task, status);
  }

  bool _statusMatches(Task task, ReportStatusFilter status) {
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


  bool _matchesNote(Task task) {
    final query = noteQuery.trim().toLowerCase();
    final hasNoteFilter = noteKinds.isNotEmpty ||
        query.isNotEmpty ||
        noteDateField != null ||
        noteFromDate != null ||
        noteToDate != null;
    if (!hasNoteFilter) return true;
    if (!task.isNotebookItem) return false;

    final kind = task.isNotebookChecklist
        ? NotebookItemKind.checklist
        : NotebookItemKind.note;
    if (noteKinds.isNotEmpty && !noteKinds.contains(kind)) return false;
    if (query.isNotEmpty &&
        !task.title.toLowerCase().contains(query) &&
        !task.description.toLowerCase().contains(query)) {
      return false;
    }

    if (noteFromDate != null || noteToDate != null) {
      final value = noteDateField == ReportNoteDateField.updated
          ? task.updatedAt
          : task.createdAt;
      if (value == null) return false;
      final day = _dateOnly(value.toLocal());
      if (noteFromDate != null && day.isBefore(_dateOnly(noteFromDate!))) {
        return false;
      }
      if (noteToDate != null && day.isAfter(_dateOnly(noteToDate!))) {
        return false;
      }
    }
    return true;
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
