import 'person_reference.dart';
import 'recurrence.dart';

enum TaskPriority { none, low, medium, high }

enum NotebookItemKind { note, checklist }

class FollowUp {
  final String id;
  final DateTime dateTime;
  final String? title;
  final String note;
  final String? result;
  final DateTime? reminderDate;
  final DateTime? nextFollowUp;
  final bool completed;
  final bool waitingForResponse;
  final List<String> personIds;

  const FollowUp({
    required this.id,
    required this.dateTime,
    this.title,
    this.note = '',
    this.result,
    this.reminderDate,
    this.nextFollowUp,
    this.completed = false,
    this.waitingForResponse = false,
    this.personIds = const <String>[],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        if (title?.trim().isNotEmpty == true) 'title': title!.trim(),
        'note': note,
        'result': result,
        'reminderDate': reminderDate?.toIso8601String(),
        'nextFollowUp': nextFollowUp?.toIso8601String(),
        'completed': completed,
        'waitingForResponse': waitingForResponse,
        if (personIds.isNotEmpty) 'personIds': personIds,
      };

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      title: (json['title'] as String?)?.trim().isEmpty == true
          ? null
          : (json['title'] as String?)?.trim(),
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.tryParse(json['reminderDate'] as String),
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.tryParse(json['nextFollowUp'] as String),
      completed: json['completed'] as bool? ?? false,
      waitingForResponse: json['waitingForResponse'] as bool? ?? false,
      personIds: (json['personIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
  }
}

/// Temporary compatibility alias for the legacy Home load-only boundary.
/// Remove when HomePage stops using the legacy view model.
extension FollowUpLegacyDate on FollowUp {
  DateTime get date => dateTime;
}

/// Unified product model foundation:
/// an Item can behave as a simple note until follow-up is enabled.
/// These fields are additive and remain backward-compatible with legacy data.
class TaskReminder {
  const TaskReminder({
    required this.id,
    required this.title,
    required this.date,
    this.isAllDay = false,
    required this.sequence,
    this.isLegacyTaskReminder = false,
    this.followUpId,
  });

  final String id;
  final String title;
  final DateTime date;
  final bool isAllDay;
  final int sequence;

  /// True when this reminder represents the legacy singular Task.reminderDate.
  /// It retains the old Calendar identity during migration.
  final bool isLegacyTaskReminder;

  /// Stable link to the FollowUp record that owns this reminder, when the
  /// reminder is a follow-up reminder. Null keeps legacy/task reminders
  /// backward-compatible and distinguishable from follow-up reminders.
  final String? followUpId;

  TaskReminder copyWith({
    String? title,
    DateTime? date,
    bool? isAllDay,
  }) => TaskReminder(
        id: id,
        title: title ?? this.title,
        date: date ?? this.date,
        isAllDay: isAllDay ?? this.isAllDay,
        sequence: sequence,
        isLegacyTaskReminder: isLegacyTaskReminder,
        followUpId: followUpId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'isAllDay': isAllDay,
        'sequence': sequence,
        if (isLegacyTaskReminder) 'isLegacyTaskReminder': true,
        if (followUpId != null && followUpId!.trim().isNotEmpty)
          'followUpId': followUpId!.trim(),
      };

  factory TaskReminder.fromJson(Map<String, dynamic> json) => TaskReminder(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        isAllDay: json['isAllDay'] as bool? ?? false,
        sequence: (json['sequence'] as num?)?.toInt() ?? 1,
        isLegacyTaskReminder: json['isLegacyTaskReminder'] as bool? ?? false,
        followUpId: (json['followUpId'] as String?)?.trim().isEmpty == true
            ? null
            : (json['followUpId'] as String?)?.trim(),
      );
}

class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.allDay = false,
    this.followUpEnabled = false,
    this.followUpDate,
    this.tags = const [],
    this.category,
    this.checklist = const [],
    bool? checklistEnabled,
    this.checklistOccurrences = const {},
    this.occurrenceHistory = const {},
    this.notebookKind,
    this.reminderDate,
    Iterable<TaskReminder> taskReminders = const [],
    this.nextReminderSequence = 1,
    this.legacyTaskReminderMigrationVersion = 0,
    this.priority = TaskPriority.none,
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.followUps = const [],
    this.recurrence,
    Iterable<PersonReference> people = const [],
  }) : checklistEnabled = checklistEnabled ??
            (checklist.isNotEmpty || notebookKind == NotebookItemKind.checklist),
        people = _normalizePeople(people),
        taskReminders = List<TaskReminder>.of(taskReminders);

  final String id;
  String title;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dueDate;
  /// True when the due date is intentionally date-only (All-Day).
  /// The timestamp remains for date identity; consumers must not present its time.
  bool allDay;
  bool followUpEnabled;
  DateTime? followUpDate;
  List<String> tags;
  String? category;
  List<String> checklist;
  /// Whether the Task editor checklist mode is enabled. Disabled checklists
  /// retain their rows so toggling the feature off never deletes user data.
  bool checklistEnabled;
  /// Per-occurrence checklist state for recurring Tasks. Keys are canonical
  /// scheduled occurrence ISO timestamps. Stored in the canonical Task model.
  Map<String, List<String>> checklistOccurrences;
  /// Per-occurrence execution history for recurring Tasks. Keys are canonical
  /// scheduled occurrence ISO timestamps. Stored in the canonical Task model.
  Map<String, Map<String, dynamic>> occurrenceHistory;
  NotebookItemKind? notebookKind;
  /// Legacy singular Task reminder retained for backward compatibility.
  DateTime? reminderDate;
  /// New independent reminders stored in the canonical Task JSON envelope.
  List<TaskReminder> taskReminders;
  /// Monotonic per-Task sequence; removed reminder numbers are never reused.
  int nextReminderSequence;
  /// Version 1 means legacy Task.reminderDate was considered for migration.
  /// Persisted even after deletion so a stale legacy field cannot resurrect it.
  int legacyTaskReminderMigrationVersion;
  TaskPriority priority;
  bool archived;
  bool trashed;
  bool completed;
  List<FollowUp> followUps;
  RecurrenceRule? recurrence;
  final List<PersonReference> people;

  /// True only for an item explicitly created as a Notebook simple note.
  /// Notebook membership is independent from follow-up state: adding a
  /// FollowUp must not remove an existing note from the Notebook.
  ///
  /// The id-based fallback keeps legacy Notebook notes (created before
  /// `notebookKind` was persisted) readable without classifying ordinary
  /// Task ids as notes.
  bool get isSimpleNote =>
      notebookKind == NotebookItemKind.note ||
      (notebookKind == null && id.startsWith('note-'));

  bool get isNotebookItem => isSimpleNote || isNotebookChecklist;

  bool get isNotebookChecklist =>
      notebookKind == NotebookItemKind.checklist;

  static List<PersonReference> _normalizePeople(
    Iterable<PersonReference> values,
  ) {
    final next = List<PersonReference>.of(values);
    final seen = <String>{};
    for (final person in next) {
      if (!seen.add(person.id)) {
        throw ArgumentError.value(
          person.id,
          'people',
          'Duplicate Person id on Task',
        );
      }
    }
    return List<PersonReference>.unmodifiable(next);
  }

  static Map<String, List<String>> _decodeChecklistOccurrences(Object? raw) {
    if (raw == null) return <String, List<String>>{};
    if (raw is! Map) {
      throw const FormatException('Task checklistOccurrences must be a map');
    }
    final result = <String, List<String>>{};
    for (final entry in raw.entries) {
      if (entry.key is! String || entry.value is! List) {
        throw const FormatException('Invalid recurring checklist occurrence');
      }
      result[entry.key as String] =
          (entry.value as List).whereType<String>().toList();
    }
    return result;
  }

  static Map<String, Map<String, dynamic>> _decodeOccurrenceHistory(Object? raw) {
    if (raw == null) return <String, Map<String, dynamic>>{};
    if (raw is! Map) {
      throw const FormatException('Task occurrenceHistory must be a map');
    }
    final result = <String, Map<String, dynamic>>{};
    for (final entry in raw.entries) {
      if (entry.key is! String || entry.value is! Map) {
        throw const FormatException('Invalid recurring occurrence history');
      }
      result[entry.key as String] =
          Map<String, dynamic>.from(entry.value as Map);
    }
    return result;
  }

  static List<PersonReference> _decodePeople(Object? raw) {
    if (raw == null) return const <PersonReference>[];
    if (raw is! List) {
      throw const FormatException('Task people must be a list');
    }

    final people = <PersonReference>[];
    final seen = <String>{};
    for (final rawPerson in raw) {
      if (rawPerson is! Map) {
        throw const FormatException('Invalid Task Person reference');
      }

      late final Map<String, dynamic> personJson;
      try {
        personJson = Map<String, dynamic>.from(rawPerson);
      } catch (_) {
        throw const FormatException('Invalid Task Person reference');
      }

      final person = PersonReference.fromJson(personJson);
      if (!seen.add(person.id)) {
        throw const FormatException('Duplicate Person id on Task');
      }
      people.add(person);
    }
    return people;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        if (allDay) 'allDay': true,
        'followUpEnabled': followUpEnabled || followUps.isNotEmpty || followUpDate != null,
        'followUpDate': followUpDate?.toIso8601String(),
        'tags': tags,
        'category': category,
        'checklist': checklist,
        'checklistEnabled': checklistEnabled,
        if (checklistOccurrences.isNotEmpty)
          'checklistOccurrences': checklistOccurrences.map(
            (key, value) => MapEntry(key, List<String>.of(value)),
          ),
        if (occurrenceHistory.isNotEmpty)
          'occurrenceHistory': occurrenceHistory.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          ),
        if (notebookKind != null) 'notebookKind': notebookKind!.name,
        'reminderDate': reminderDate?.toIso8601String(),
        if (taskReminders.isNotEmpty)
          'taskReminders': taskReminders.map((item) => item.toJson()).toList(),
        if (nextReminderSequence > 1)
          'nextReminderSequence': nextReminderSequence,
        if (legacyTaskReminderMigrationVersion > 0)
          'legacyTaskReminderMigrationVersion': legacyTaskReminderMigrationVersion,
        if (priority != TaskPriority.none) 'priority': priority.name,
        'archived': archived,
        'trashed': trashed,
        'completed': completed,
        'followUps': followUps.map((e) => e.toJson()).toList(),
        if (recurrence != null) 'recurrence': recurrence!.toJson(),
        if (people.isNotEmpty)
          'people': people.map((person) => person.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    var loadedFollowUps = <FollowUp>[];
    if (json['followUps'] is List) {
      loadedFollowUps = (json['followUps'] as List)
          .map((item) => FollowUp.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    final loadedPeople = _decodePeople(json['people']);
    final loadedTaskReminders = <TaskReminder>[];
    final rawTaskReminders = json['taskReminders'];
    if (rawTaskReminders is List) {
      for (final rawReminder in rawTaskReminders) {
        if (rawReminder is Map) {
          loadedTaskReminders.add(
            TaskReminder.fromJson(Map<String, dynamic>.from(rawReminder)),
          );
        }
      }
    }

    final rawLegacyReminderDate = json['reminderDate'];
    final legacyReminderDate = rawLegacyReminderDate == null
        ? null
        : DateTime.tryParse(rawLegacyReminderDate as String);
    final storedSequence = (json['nextReminderSequence'] as num?)?.toInt() ?? 1;
    final sequenceFromJson = storedSequence < 1 ? 1 : storedSequence;
    final storedMigrationVersion =
        (json['legacyTaskReminderMigrationVersion'] as num?)?.toInt() ?? 0;
    var migrationVersion = storedMigrationVersion < 0 ? 0 : storedMigrationVersion;
    if (migrationVersion < 1 && legacyReminderDate != null) {
      if (!loadedTaskReminders.any((item) => item.isLegacyTaskReminder)) {
        final highestSequence = loadedTaskReminders.isEmpty
            ? 0
            : loadedTaskReminders
                .map((item) => item.sequence)
                .reduce((a, b) => a > b ? a : b);
        final migrationSequence = highestSequence + 1 > sequenceFromJson
            ? highestSequence + 1
            : sequenceFromJson;
        final taskTitle = json['title'] as String? ?? '';
        loadedTaskReminders.add(
          TaskReminder(
            id: 'legacy-task-reminder',
            title: 'یادآوری: $taskTitle',
            date: legacyReminderDate,
            sequence: migrationSequence,
            isLegacyTaskReminder: true,
          ),
        );
      }
      migrationVersion = 1;
    }

    final nextReminderSequence = [
      sequenceFromJson,
      if (loadedTaskReminders.isNotEmpty)
        loadedTaskReminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b) + 1,
    ].reduce((a, b) => a > b ? a : b);
    final legacyFollowUpDate = json['followUpDate'] == null
        ? null
        : DateTime.tryParse(json['followUpDate'] as String);
    final priorityName = json['priority'] as String?;
    final loadedPriority = TaskPriority.values.firstWhere(
      (value) => value.name == priorityName,
      orElse: () => TaskPriority.none,
    );

    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
      allDay: json['allDay'] as bool? ?? false,
      followUpEnabled: json['followUpEnabled'] as bool? ??
          loadedFollowUps.isNotEmpty || legacyFollowUpDate != null,
      followUpDate: legacyFollowUpDate,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      category: json['category'] as String?,
      checklist: (json['checklist'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      checklistEnabled: json['checklistEnabled'] as bool?,
      checklistOccurrences: _decodeChecklistOccurrences(
        json['checklistOccurrences'],
      ),
      occurrenceHistory: _decodeOccurrenceHistory(
        json['occurrenceHistory'],
      ),
      notebookKind: NotebookItemKind.values.cast<NotebookItemKind?>().firstWhere(
            (value) => value?.name == json['notebookKind'],
            orElse: () => null,
          ),
      reminderDate: legacyReminderDate,
      taskReminders: loadedTaskReminders,
      nextReminderSequence: nextReminderSequence,
      legacyTaskReminderMigrationVersion: migrationVersion,
      priority: loadedPriority,
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      followUps: loadedFollowUps,
      recurrence: json['recurrence'] is Map
          ? RecurrenceRule.fromJson(
              Map<String, dynamic>.from(json['recurrence'] as Map),
            )
          : null,
      people: loadedPeople,
    );
  }

  FollowUp? get lastFollowUp {
    if (followUps.isEmpty) return null;
    return followUps.reduce(
      (latest, candidate) => candidate.dateTime.isAfter(latest.dateTime)
          ? candidate
          : latest,
    );
  }

  DateTime? get lastFollowUpDate => lastFollowUp?.dateTime;

  DateTime? get legacyHomeFollowUpDate =>
      followUps.isEmpty ? followUpDate : lastFollowUpDate;
}
