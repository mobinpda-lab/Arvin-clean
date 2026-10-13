import 'person_reference.dart';
import 'recurrence.dart';

enum TaskPriority { none, low, medium, high }

enum NotebookItemKind { note, checklist }

class FollowUp {
  final String id;
  final DateTime dateTime;
  final String note;
  final String? result;
  final DateTime? reminderDate;
  final DateTime? nextFollowUp;
  final bool completed;

  const FollowUp({
    required this.id,
    required this.dateTime,
    this.note = '',
    this.result,
    this.reminderDate,
    this.nextFollowUp,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
        'result': result,
        'reminderDate': reminderDate?.toIso8601String(),
        'nextFollowUp': nextFollowUp?.toIso8601String(),
        'completed': completed,
      };

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.tryParse(json['reminderDate'] as String),
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.tryParse(json['nextFollowUp'] as String),
      completed: json['completed'] as bool? ?? false,
    );
  }
}

/// Temporary compatibility alias for the legacy Home load-only boundary.
/// Remove when HomePage stops using the legacy view model.
extension FollowUpLegacyDate on FollowUp {
  DateTime get date => dateTime;
}

/// A reminder owned by a canonical Task. The legacy Task.reminderDate and
/// FollowUp.reminderDate fields remain independently readable during migration.
class TaskReminder {
  const TaskReminder({
    required this.id,
    required this.taskId,
    required this.title,
    required this.date,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.isAllDay = false,
    required this.sequence,
  });

  final String id;
  final String taskId;
  final String title;
  final DateTime date;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAllDay;
  final int sequence;

  TaskReminder copyWith({
    String? taskId,
    String? title,
    DateTime? date,
    String? status,
    DateTime? updatedAt,
    bool? isAllDay,
  }) =>
      TaskReminder(
        id: id,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        date: date ?? this.date,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isAllDay: isAllDay ?? this.isAllDay,
        sequence: sequence,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'title': title,
        'date': date.toIso8601String(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isAllDay': isAllDay,
        'sequence': sequence,
      };

  factory TaskReminder.fromJson(
    Map<String, dynamic> json, {
    required String fallbackTaskId,
    required DateTime fallbackCreatedAt,
  }) {
    DateTime parseDate(Object? raw, DateTime fallback) {
      if (raw is! String) return fallback;
      return DateTime.tryParse(raw) ?? fallback;
    }

    return TaskReminder(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? fallbackTaskId,
      title: json['title'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'active',
      createdAt: parseDate(json['createdAt'], fallbackCreatedAt),
      updatedAt: parseDate(json['updatedAt'], fallbackCreatedAt),
      isAllDay: json['isAllDay'] as bool? ?? false,
      sequence: (json['sequence'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Canonical Task model. Every Task can have zero or more real FollowUp records.
/// `followUpEnabled` remains only as a deprecated compatibility mirror for old
/// readers; current behavior must derive from `followUps`/`followUpDate` data.
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
    this.legacyReminderMigrationCompleted = false,
    Iterable<TaskReminder> taskReminders = const [],
    this.nextReminderSequence = 1,
    this.priority = TaskPriority.none,
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.followUps = const [],
    this.recurrence,
    Iterable<PersonReference> people = const [],
  }) : checklistEnabled = checklistEnabled ??
            (checklist.isNotEmpty || notebookKind == NotebookItemKind.checklist),
        taskReminders = List<TaskReminder>.of(taskReminders),
        people = _normalizePeople(people);

  final String id;
  String title;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dueDate;
  /// True when the due date is intentionally date-only (All-Day).
  /// The timestamp remains for date identity; consumers must not present its time.
  bool allDay;
  bool followUpEnabled; // Deprecated compatibility mirror; never a decision source.
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
  DateTime? reminderDate;
  /// True once the legacy Task reminder has been represented in the canonical
  /// collection. The legacy value is retained for rollback, but must no longer
  /// be projected separately after the migrated record is durable.
  bool legacyReminderMigrationCompleted;
  /// Independent reminders stored in the canonical Task JSON envelope.
  List<TaskReminder> taskReminders;
  /// Next per-Task reminder number; deleted numbers are never reused.
  int nextReminderSequence;
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
        'followUpEnabled': followUps.isNotEmpty || followUpDate != null,
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
        'legacyReminderMigrationCompleted': legacyReminderMigrationCompleted,
        'taskReminders': taskReminders.map((reminder) => reminder.toJson()).toList(),
        'nextReminderSequence': nextReminderSequence,
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
    final taskId = json['id'] as String? ?? '';
    final taskTitle = json['title'] as String? ?? '';
    final taskCreatedAt = json['createdAt'] == null
        ? null
        : DateTime.tryParse(json['createdAt'] as String);
    final taskUpdatedAt = json['updatedAt'] == null
        ? null
        : DateTime.tryParse(json['updatedAt'] as String);
    final legacyReminderDate = json['reminderDate'] == null
        ? null
        : DateTime.tryParse(json['reminderDate'] as String);
    final rawTaskReminders = json['taskReminders'];
    if (rawTaskReminders != null && rawTaskReminders is! List) {
      throw const FormatException('Task taskReminders must be a list');
    }
    final reminderMetadataFallback = taskCreatedAt ??
        taskUpdatedAt ??
        DateTime.utc(1970, 1, 1);
    final loadedTaskReminders = (rawTaskReminders as List<dynamic>? ?? const [])
        .map(
          (item) => TaskReminder.fromJson(
            Map<String, dynamic>.from(item as Map),
            fallbackTaskId: taskId,
            fallbackCreatedAt: reminderMetadataFallback,
          ),
        )
        .toList();
    var nextReminderSequence =
        (json['nextReminderSequence'] as num?)?.toInt() ?? 1;
    for (final reminder in loadedTaskReminders) {
      if (reminder.sequence >= nextReminderSequence) {
        nextReminderSequence = reminder.sequence + 1;
      }
    }

    // Deterministically represent the legacy Task reminder exactly once.
    // Keep reminderDate intact for rollback and old-reader compatibility.
    var legacyReminderMigrationCompleted =
        json['legacyReminderMigrationCompleted'] as bool? ?? false;
    final legacyReminderId = 'legacy-task-reminder:$taskId';
    final hasMigratedLegacyReminder =
        loadedTaskReminders.any((reminder) => reminder.id == legacyReminderId);
    if (legacyReminderDate != null &&
        taskId.trim().isNotEmpty &&
        !legacyReminderMigrationCompleted) {
      if (hasMigratedLegacyReminder) {
        legacyReminderMigrationCompleted = true;
      } else {
        final sequence = nextReminderSequence;
        final title = taskTitle.trim().isEmpty
            ? 'یادآور کار — ${_toPersianDigits(sequence)}'
            : '$taskTitle — یادآور ${_toPersianDigits(sequence)}';
        loadedTaskReminders.add(
          TaskReminder(
            id: legacyReminderId,
            taskId: taskId,
            title: title,
            date: legacyReminderDate,
            status: 'active',
            createdAt: reminderMetadataFallback,
            updatedAt: reminderMetadataFallback,
            // Midnight is not sufficient evidence of an all-day reminder.
            isAllDay: false,
            sequence: sequence,
          ),
        );
        nextReminderSequence = sequence + 1;
        legacyReminderMigrationCompleted = true;
      }
    }
    final legacyFollowUpDate = json['followUpDate'] == null
        ? null
        : DateTime.tryParse(json['followUpDate'] as String);
    final priorityName = json['priority'] as String?;
    final loadedPriority = TaskPriority.values.firstWhere(
      (value) => value.name == priorityName,
      orElse: () => TaskPriority.none,
    );

    return Task(
      id: taskId,
      title: taskTitle,
      description: json['description'] as String? ?? '',
      createdAt: taskCreatedAt,
      updatedAt: taskUpdatedAt,
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
      legacyReminderMigrationCompleted: legacyReminderMigrationCompleted,
      taskReminders: loadedTaskReminders,
      nextReminderSequence: nextReminderSequence,
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

  static String _toPersianDigits(int value) => value
      .toString()
      .replaceAll('0', '۰')
      .replaceAll('1', '۱')
      .replaceAll('2', '۲')
      .replaceAll('3', '۳')
      .replaceAll('4', '۴')
      .replaceAll('5', '۵')
      .replaceAll('6', '۶')
      .replaceAll('7', '۷')
      .replaceAll('8', '۸')
      .replaceAll('9', '۹');

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
