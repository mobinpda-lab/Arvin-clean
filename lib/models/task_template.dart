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
    Iterable<String> tags = const [],
    Iterable<String> checklist = const [],
    Iterable<PersonReference> people = const [],
    Iterable<TaskTemplateReminder> reminders = const [],
    this.recurrence,
    this.centerNameSnapshot,
    this.projectNameSnapshot,
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
  final List<String> tags;
  final List<String> checklist;
  final List<PersonReference> people;
  final List<TaskTemplateReminder> reminders;
  final RecurrenceRule? recurrence;
  final String? centerNameSnapshot;
  final String? projectNameSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  factory TaskTemplate.fromTask({
    required String id,
    required String name,
    required Task task,
    String? centerNameSnapshot,
    String? projectNameSnapshot,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final recurrence = task.recurrence;
    return TaskTemplate(
      id: id,
      name: name.trim(),
      title: task.title.trim(),
      description: task.description,
      category: task.category,
      priority: task.priority,
      tags: task.tags,
      checklist: task.checklist.map(_withoutExecutionMarker),
      people: task.people,
      reminders: task.taskReminders.map((reminder) => TaskTemplateReminder(
        title: reminder.title,
        isAllDay: reminder.isAllDay,
        sequence: reminder.sequence,
      )),
      recurrence: recurrence == null ? null : RecurrenceRule(
        frequency: recurrence.frequency,
        interval: recurrence.interval,
        count: recurrence.count,
        active: recurrence.active,
        trackingLevel: recurrence.trackingLevel,
      ),
      centerNameSnapshot: _clean(centerNameSnapshot),
      projectNameSnapshot: _clean(projectNameSnapshot),
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
    'tags_json': jsonEncode(tags),
    'checklist_json': jsonEncode(checklist),
    'people_json': jsonEncode(people.map((person) => person.toJson()).toList()),
    'reminders_json': jsonEncode(reminders.map((reminder) => reminder.toJson()).toList()),
    'recurrence_json': recurrence == null ? null : jsonEncode(recurrence!.toJson()),
    'center_name_snapshot': centerNameSnapshot,
    'project_name_snapshot': projectNameSnapshot,
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
    required this.sequence,
  });
  final String title;
  final bool isAllDay;
  final int sequence;

  Map<String, Object?> toJson() => {
    'title': title,
    'isAllDay': isAllDay,
    'sequence': sequence,
  };

  factory TaskTemplateReminder.fromJson(Map<String, dynamic> json) =>
      TaskTemplateReminder(
        title: json['title'] as String? ?? '',
        isAllDay: json['isAllDay'] as bool? ?? false,
        sequence: (json['sequence'] as num?)?.toInt() ?? 1,
      );
}
