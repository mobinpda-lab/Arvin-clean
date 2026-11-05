import 'dart:convert';

import '../models/person_reference.dart';
import '../models/recurrence.dart';
import '../models/task.dart';

/// Immutable reusable definition copied from an executable Task.
///
/// Execution state is deliberately absent: no due date, completion timestamp,
/// Follow-up history, recurrence occurrence history, or reminder fire date.
class TaskTemplate {
  TaskTemplate({
    required this.id,
    required this.name,
    required this.title,
    this.description = '',
    this.category,
    this.priority = TaskPriority.medium,
    this.checklistEnabled = false,
    Iterable<String> tags = const [],
    Iterable<String> checklist = const [],
    Iterable<PersonReference> people = const [],
    Iterable<TaskTemplateReminder> reminders = const [],
    this.recurrence,
    this.centerNameSnapshot,
    this.projectNameSnapshot,
    this.centerIdSnapshot,
    this.projectIdSnapshot,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  })  : tags = List.unmodifiable(tags),
        checklist = List.unmodifiable(checklist),
        people = List.unmodifiable(people),
        reminders = List.unmodifiable(reminders);

  final String id;
  final String name;
  final String title;
  final String description;
  final String? category;
  final TaskPriority priority;
  final bool checklistEnabled;
  final List<String> tags;
  final List<String> checklist;
  final List<PersonReference> people;
  final List<TaskTemplateReminder> reminders;
  final RecurrenceRule? recurrence;
  final String? centerNameSnapshot;
  final String? projectNameSnapshot;
  final String? centerIdSnapshot;
  final String? projectIdSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  factory TaskTemplate.fromTask({
    required String id,
    required String name,
    required Task task,
    String? centerNameSnapshot,
    String? projectNameSnapshot,
    String? centerIdSnapshot,
    String? projectIdSnapshot,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final recurrence = task.recurrence;
    final reminderDefinitions = task.taskReminders.map((reminder) => TaskTemplateReminder(
      title: reminder.title,
      isAllDay: reminder.isAllDay,
      hour: reminder.date.hour,
      minute: reminder.date.minute,
      isEnabled: reminder.isEnabled,
      sequence: reminder.sequence,
    )).toList(growable: true);
    // Legacy Task.reminderDate is still canonical input for older Tasks. Copy
    // its time-of-day only; the calendar date is execution history, not a
    // reusable template default. Do not duplicate a reminder already migrated
    // into the independent reminder collection.
    if (task.reminderDate != null &&
        !task.taskReminders.any((reminder) => reminder.isLegacyTaskReminder ||
            reminder.date.isAtSameMomentAs(task.reminderDate!))) {
      final sequence = reminderDefinitions.isEmpty
          ? 1
          : reminderDefinitions.map((item) => item.sequence).reduce((a, b) => a > b ? a : b) + 1;
      reminderDefinitions.add(TaskTemplateReminder(
        title: 'یادآور اصلی',
        isAllDay: false,
        hour: task.reminderDate!.hour,
        minute: task.reminderDate!.minute,
        isEnabled: true,
        sequence: sequence,
      ));
    }
    return TaskTemplate(
      id: id,
      name: name.trim(),
      title: task.title.trim(),
      description: task.description,
      category: task.category,
      priority: task.priority,
      checklistEnabled: task.checklistEnabled,
      tags: task.tags,
      checklist: task.checklist.map(_withoutExecutionMarker),
      people: task.people,
      reminders: reminderDefinitions,
      recurrence: recurrence == null ? null : RecurrenceRule(
        frequency: recurrence.frequency,
        interval: recurrence.interval,
        count: recurrence.count,
        active: recurrence.active,
        trackingLevel: recurrence.trackingLevel,
      ),
      centerNameSnapshot: _clean(centerNameSnapshot),
      projectNameSnapshot: _clean(projectNameSnapshot),
      centerIdSnapshot: _clean(centerIdSnapshot),
      projectIdSnapshot: _clean(projectIdSnapshot),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  static String _withoutExecutionMarker(String value) =>
      value.replaceFirst(RegExp(r'^\s*\[(?:x|X|✓| )\]\s*'), '').trim();

  static String? _clean(String? value) {
    final result = value?.trim();
    return result == null || result.isEmpty ? null : result;
  }

  Map<String, Object?> toColumns() => {
    'id': id,
    'name': name,
    'title': title,
    'description': description,
    'category': category,
    'priority': priority.name,
    'checklist_enabled': checklistEnabled ? 1 : 0,
    'tags_json': jsonEncode(tags),
    'checklist_json': jsonEncode(checklist),
    'people_json': jsonEncode(people.map((person) => person.toJson()).toList()),
    'reminders_json': jsonEncode(reminders.map((reminder) => reminder.toJson()).toList()),
    'recurrence_json': recurrence == null ? null : jsonEncode(recurrence!.toJson()),
    'center_name_snapshot': centerNameSnapshot,
    'project_name_snapshot': projectNameSnapshot,
    'center_id_snapshot': centerIdSnapshot,
    'project_id_snapshot': projectIdSnapshot,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_archived': isArchived ? 1 : 0,
  };

  factory TaskTemplate.fromColumns(Map<String, Object?> row) {
    List<dynamic> decodeList(String key) {
      final raw = row[key];
      if (raw is! String) return const [];
      final value = jsonDecode(raw);
      if (value is! List) throw FormatException('Invalid Task Template $key');
      return value;
    }
    final priorityName = row['priority'] as String?;
    return TaskTemplate(
      id: row['id'] as String,
      name: row['name'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      category: row['category'] as String?,
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == priorityName,
        orElse: () => TaskPriority.medium,
      ),
      checklistEnabled: (row['checklist_enabled'] as num?)?.toInt() == 1,
      tags: decodeList('tags_json').whereType<String>(),
      checklist: decodeList('checklist_json').whereType<String>(),
      people: decodeList('people_json')
          .whereType<Map>()
          .map((value) => PersonReference.fromJson(Map<String, dynamic>.from(value))),
      reminders: decodeList('reminders_json')
          .whereType<Map>()
          .map((value) => TaskTemplateReminder.fromJson(Map<String, dynamic>.from(value))),
      recurrence: row['recurrence_json'] is String
          ? RecurrenceRule.fromJson(Map<String, dynamic>.from(jsonDecode(row['recurrence_json'] as String) as Map))
          : null,
      centerNameSnapshot: row['center_name_snapshot'] as String?,
      projectNameSnapshot: row['project_name_snapshot'] as String?,
      centerIdSnapshot: row['center_id_snapshot'] as String?,
      projectIdSnapshot: row['project_id_snapshot'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      isArchived: (row['is_archived'] as num).toInt() == 1,
    );
  }
}

class TaskTemplateReminder {
  const TaskTemplateReminder({
    required this.title,
    required this.isAllDay,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    required this.sequence,
  });
  final String title;
  final bool isAllDay;
  final int hour;
  final int minute;
  final bool isEnabled;
  final int sequence;

  Map<String, Object?> toJson() => {
    'title': title,
    'isAllDay': isAllDay,
    'hour': hour,
    'minute': minute,
    'isEnabled': isEnabled,
    'sequence': sequence,
  };

  factory TaskTemplateReminder.fromJson(Map<String, dynamic> json) =>
      TaskTemplateReminder(
        title: json['title'] as String? ?? '',
        isAllDay: json['isAllDay'] as bool? ?? false,
        hour: (json['hour'] as num?)?.toInt() ?? 0,
        minute: (json['minute'] as num?)?.toInt() ?? 0,
        isEnabled: json['isEnabled'] as bool? ?? true,
        sequence: (json['sequence'] as num?)?.toInt() ?? 1,
      );
}
