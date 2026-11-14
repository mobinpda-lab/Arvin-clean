import 'person_reference.dart';
import 'recurrence.dart';

enum TaskPriority { high, medium, low, none }

extension TaskPriorityProduct on TaskPriority {
  int get sortOrder => switch (this) {
        TaskPriority.high => 1,
        TaskPriority.medium => 2,
        TaskPriority.low => 3,
        TaskPriority.none => 4,
      };
  String get label => switch (this) {
        TaskPriority.high => 'فوری و مهم',
        TaskPriority.medium => 'مهم، غیرفوری',
        TaskPriority.low => 'فوری، غیرمهم',
        TaskPriority.none => 'غیرفوری و غیرمهم',
      };
  String get code => switch (this) {
        TaskPriority.high => 'P1',
        TaskPriority.medium => 'P2',
        TaskPriority.low => 'P3',
        TaskPriority.none => 'P4',
      };
}

enum NotebookItemKind { note, checklist }

// Distinguishes omitted legacy constructor arguments from explicit null values.
const Object _legacyValueNotProvided = Object();

String _dateOnlyStorageValue(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

bool _isDateOnlyStorageValue(Object? value) {
  if (value is! String || value.length != 10) return false;
  return value[4] == '-' &&
      value[7] == '-' &&
      int.tryParse(value.substring(0, 4)) != null &&
      int.tryParse(value.substring(5, 7)) != null &&
      int.tryParse(value.substring(8, 10)) != null;
}

Map<String, dynamic> decodeLegacyFollowUpMetadata(
  Map<String, dynamic> json,
) {
  final metadata = <String, dynamic>{};
  final rawMetadata = json['legacyFollowUpMetadata'];
  if (rawMetadata is Map) {
    metadata.addAll(Map<String, dynamic>.from(rawMetadata));
  }

  // Presence is part of the legacy value: absent, explicit null, false and
  // true must remain distinguishable after a decode/encode round trip.
  final taskLevel = <String, dynamic>{};
  for (final field in const [
    'reminderDate',
    'reminderAllDay',
    'followUpDate',
    'followUpEnabled',
  ]) {
    if (json.containsKey(field)) taskLevel[field] = json[field];
  }
  if (taskLevel.isNotEmpty) {
    final existing = metadata['taskLevel'];
    metadata['taskLevel'] = <String, dynamic>{
      if (existing is Map) ...Map<String, dynamic>.from(existing),
      ...taskLevel,
    };
  }

  // Preserve unrecognized Task fields in the opaque compatibility envelope.
  const knownTaskFields = <String>{
    'id', 'title', 'description', 'createdAt', 'updatedAt', 'dueDate',
    'centerId', 'allDay', 'followUpEnabled', 'followUpDate', 'reminderDate',
    'reminderAllDay', 'tags', 'category', 'checklist', 'checklistEnabled',
    'checklistOccurrences', 'occurrenceHistory', 'notebookKind',
    'taskReminders', 'nextReminderSequence',
    'legacyTaskReminderMigrationVersion', 'legacyFollowUpMetadata',
    'priority', 'isFavorite', 'isSelectedForToday', 'focusDate', 'archived',
    'trashed', 'completed', 'completedAt', 'templateTaskId', 'followUps',
    'recurrence', 'people',
  };
  final unknownTaskFields = <String, dynamic>{
    for (final entry in json.entries)
      if (!knownTaskFields.contains(entry.key)) entry.key: entry.value,
  };
  if (unknownTaskFields.isNotEmpty) {
    final existing = metadata['unknownFields'];
    metadata['unknownFields'] = <String, dynamic>{
      if (existing is Map) ...Map<String, dynamic>.from(existing),
      ...unknownTaskFields,
    };
  }

  final rawFollowUps = json['followUps'];
  if (rawFollowUps is List) {
    final records = <Map<String, dynamic>>[];
    final existing = metadata['followUps'];
    if (existing is List) {
      for (final raw in existing) {
        if (raw is Map) records.add(Map<String, dynamic>.from(raw));
      }
    }
    const knownFollowUpFields = <String>{
      'id', 'completedAt', 'dateTime', 'title', 'note', 'result',
      'completed', 'waitingForResponse', 'personIds', 'reminderDate',
      'reminderAllDay',
    };
    for (final raw in rawFollowUps) {
      if (raw is! Map) continue;
      final source = Map<String, dynamic>.from(raw);
      final unknownFields = <String, dynamic>{
        for (final entry in source.entries)
          if (!knownFollowUpFields.contains(entry.key) &&
              entry.key != 'nextFollowUp' &&
              entry.key != 'nextFollowUpAllDay')
            entry.key: entry.value,
      };
      final hasLegacyFields = source.containsKey('nextFollowUp') ||
          source.containsKey('nextFollowUpAllDay') ||
          unknownFields.isNotEmpty;
      if (!hasLegacyFields) continue;

      final record = <String, dynamic>{
        if (source['id'] != null) 'id': source['id'],
        if (source.containsKey('nextFollowUp'))
          'nextFollowUp': source['nextFollowUp'],
        if (source.containsKey('nextFollowUpAllDay'))
          'nextFollowUpAllDay': source['nextFollowUpAllDay'],
        ...unknownFields,
      };
      final id = source['id'];
      final existingIndex = records.indexWhere(
        (item) => id != null && item['id'] == id,
      );
      if (existingIndex < 0) {
        records.add(record);
      } else {
        records[existingIndex] = <String, dynamic>{
          ...records[existingIndex],
          ...record,
        };
      }
    }
    if (records.isNotEmpty) metadata['followUps'] = records;
  }

  return metadata;
}

class FollowUpRecord {
  final String id;

  /// Canonical historical timestamp for this record.
  final DateTime completedAt;

  /// Source-compatible view for older screens; storage and serialization use completedAt.
  @Deprecated('Use completedAt.')
  DateTime get dateTime => completedAt;
  final String? title;
  final String note;
  final String? result;
  final bool completed;
  final bool waitingForResponse;
  final List<String> personIds;

  /// Retained only to serialize legacy dates as inert Task metadata.
  /// Never read by Reminder projection, delivery, Calendar, or alarm scheduling.
  final Object? _legacyNextFollowUp;

  /// Deprecated read-only compatibility projection; future scheduling is not stored.
  @Deprecated('Follow-up records are historical only.')
  DateTime? get nextFollowUp => null;

  FollowUpRecord({
    required this.id,
    DateTime? completedAt,
    @Deprecated('Use completedAt.')
    DateTime? dateTime,
    this.title,
    this.note = '',
    this.result,
    // Source-compatibility parameters only. They are intentionally ignored:
    // reminders belong to TaskReminder, and Follow-up records are historical.
    @Deprecated('Use TaskReminder on the parent Task.')
    DateTime? reminderDate,
    @Deprecated('Use TaskReminder.isAllDay on the parent Task.')
    bool reminderAllDay = false,
    @Deprecated('Follow-up records do not schedule future work.')
    Object? nextFollowUp = _legacyValueNotProvided,
    this.completed = false,
    this.waitingForResponse = false,
    this.personIds = const <String>[],
  })  : completedAt = completedAt ?? dateTime!,
        _legacyNextFollowUp = nextFollowUp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toIso8601String(),
        if (title?.trim().isNotEmpty == true) 'title': title!.trim(),
        'note': note,
        'result': result,
        'completed': completed,
        'waitingForResponse': waitingForResponse,
        if (personIds.isNotEmpty) 'personIds': personIds,
      };

  factory FollowUpRecord.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as String? ?? '',
      completedAt: DateTime.parse(
        (json['completedAt'] ?? json['dateTime']) as String,
      ),
      title: (json['title'] as String?)?.trim().isEmpty == true
          ? null
          : (json['title'] as String?)?.trim(),
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
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

/// Source-compatible type alias; the canonical entity is FollowUpRecord.
typedef FollowUp = FollowUpRecord;

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
    this.isEnabled = true,
  });

  final String id;
  final String title;
  final DateTime date;
  final bool isAllDay;
  final int sequence;

  /// Whether this independent reminder participates in notification scheduling.
  /// Missing values in older JSON payloads default to enabled.
  final bool isEnabled;

  /// Date-only reminders are serialized as YYYY-MM-DD, never synthetic midnight.
  String get storageDateValue =>
      isAllDay ? _dateOnlyStorageValue(date) : date.toIso8601String();

  TaskReminder copyWith({
    String? id,
    String? title,
    DateTime? date,
    bool? isAllDay,
    bool? isEnabled,
  }) => TaskReminder(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        isAllDay: isAllDay ?? this.isAllDay,
        sequence: sequence,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': storageDateValue,
        'isAllDay': isAllDay,
        'sequence': sequence,
        if (!isEnabled) 'isEnabled': false,
      };

  factory TaskReminder.fromJson(Map<String, dynamic> json) => TaskReminder(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        isAllDay: json['isAllDay'] as bool? ?? false,
        sequence: (json['sequence'] as num?)?.toInt() ?? 1,
        isEnabled: json['isEnabled'] as bool? ?? true,
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
    this.centerId,
    this.allDay = false,
    @Deprecated('Follow-up history is represented by FollowUpRecord entries.')
    Object? followUpEnabled = _legacyValueNotProvided,
    @Deprecated('Follow-up records do not schedule future work.')
    Object? followUpDate = _legacyValueNotProvided,
    this.tags = const [],
    this.category,
    this.checklist = const [],
    bool? checklistEnabled,
    this.checklistOccurrences = const {},
    this.occurrenceHistory = const {},
    this.notebookKind,
    @Deprecated('Legacy input only; use taskReminders.')
    DateTime? reminderDate,
    @Deprecated('Legacy input only; use TaskReminder.isAllDay.')
    bool reminderAllDay = false,
    Iterable<TaskReminder> taskReminders = const [],
    this.nextReminderSequence = 1,
    this.legacyTaskReminderMigrationVersion = 0,
    this.legacyFollowUpMetadata = const <String, dynamic>{},
    this.priority = TaskPriority.medium,
    this.isFavorite = false,
    bool isSelectedForToday = false,
    DateTime? focusDate,
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.completedAt,
    this.templateTaskId,
    this.followUps = const [],
    this.recurrence,
    Iterable<PersonReference> people = const [],
  }) : focusDate = focusDate == null
            ? (isSelectedForToday
                ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                : null)
            : DateTime(focusDate.year, focusDate.month, focusDate.day),
        checklistEnabled = checklistEnabled ??
            (checklist.isNotEmpty || notebookKind == NotebookItemKind.checklist),
        people = _normalizePeople(people),
        taskReminders = List<TaskReminder>.of(taskReminders) {
    // Direct legacy constructor inputs must not disappear before serialization.
    // Keep retired Task-level dates as inert metadata; they are never converted
    // into TaskReminder records and therefore cannot schedule delivery.
    final metadata = Map<String, dynamic>.from(legacyFollowUpMetadata);
    final taskLevel = <String, dynamic>{};
    if (!identical(followUpDate, _legacyValueNotProvided)) {
      if (followUpDate == null) {
        taskLevel['followUpDate'] = null;
      } else if (followUpDate is DateTime) {
        taskLevel['followUpDate'] = followUpDate.toIso8601String();
      } else {
        throw ArgumentError.value(followUpDate, 'followUpDate', 'Expected DateTime or null.');
      }
    }
    if (!identical(followUpEnabled, _legacyValueNotProvided)) {
      if (followUpEnabled == null || followUpEnabled is bool) {
        taskLevel['followUpEnabled'] = followUpEnabled;
      } else {
        throw ArgumentError.value(followUpEnabled, 'followUpEnabled', 'Expected bool or null.');
      }
    }
    if (taskLevel.isNotEmpty) {
      final existing = metadata['taskLevel'];
      metadata['taskLevel'] = <String, dynamic>{
        if (existing is Map) ...Map<String, dynamic>.from(existing),
        ...taskLevel,
      };
    }
    final records = <Map<String, dynamic>>[];
    final existingRecords = metadata['followUps'];
    if (existingRecords is List) {
      for (final raw in existingRecords) {
        if (raw is! Map) continue;
        final record = Map<String, dynamic>.from(raw);
        final recordId = record['id'];
        final existingIndex = records.indexWhere(
          (item) => recordId != null && item['id'] == recordId,
        );
        if (existingIndex < 0) {
          records.add(record);
        } else {
          records[existingIndex] = <String, dynamic>{
            ...records[existingIndex],
            ...record,
          };
        }
      }
    }
    for (final followUp in followUps) {
      final nextFollowUp = followUp._legacyNextFollowUp;
      if (identical(nextFollowUp, _legacyValueNotProvided)) continue;
      final record = <String, dynamic>{
        'id': followUp.id,
        'nextFollowUp': nextFollowUp is DateTime
            ? nextFollowUp.toIso8601String()
            : null,
      };
      final existingIndex = records.indexWhere(
        (item) => item['id'] == followUp.id,
      );
      if (existingIndex < 0) {
        records.add(record);
      } else {
        records[existingIndex] = <String, dynamic>{
          ...records[existingIndex],
          ...record,
        };
      }
    }
    if (records.isNotEmpty) metadata['followUps'] = records;
    legacyFollowUpMetadata = metadata;
  }

  final String id;
  String title;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dueDate;
  /// Independent canonical Center reference; Project membership remains separate.
  String? centerId;
  /// Date-only tasks serialize their due date as YYYY-MM-DD without a synthetic time.
  String? get dueDateStorageValue => dueDate == null
      ? null
      : (allDay ? _dateOnlyStorageValue(dueDate!) : dueDate!.toIso8601String());

  /// True when the due date is intentionally date-only (All-Day).
  /// The timestamp remains for date identity; consumers must not present its time.
  bool allDay;
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
  /// Independent reminders; all scheduling is represented in this collection.
  List<TaskReminder> taskReminders;
  /// Monotonic per-Task sequence; removed reminder numbers are never reused.
  int nextReminderSequence;
  /// Version 1 means legacy Task.reminderDate was considered for migration.
  /// Persisted even after deletion so a stale legacy field cannot resurrect it.
  int legacyTaskReminderMigrationVersion;
  /// Opaque, non-scheduling compatibility payload for retired Follow-up dates.
  /// Never read by notification or calendar scheduling services.
  Map<String, dynamic> legacyFollowUpMetadata;
  TaskPriority priority;
  bool isFavorite;
  /// Canonical local-calendar date for this Task's Focus membership.
  /// A date-only value expires automatically when the local day changes.
  DateTime? focusDate;
  /// Backward-compatible view of Focus membership for the current local day.
  bool get isSelectedForToday {
    final selected = focusDate;
    final now = DateTime.now();
    return selected != null && selected.year == now.year &&
        selected.month == now.month && selected.day == now.day;
  }

  set isSelectedForToday(bool selected) {
    if (!selected) {
      focusDate = null;
      return;
    }
    final now = DateTime.now();
    focusDate = DateTime(now.year, now.month, now.day);
  }
  bool archived;
  bool trashed;
  bool completed;
  DateTime? completedAt;
  /// Stable source definition ID for a task generated/propagated from a template.
  String? templateTaskId;
  List<FollowUp> followUps;
  RecurrenceRule? recurrence;
  final List<PersonReference> people;

  /// Legacy compatibility view only. No Follow-up scheduling state is stored.
  @Deprecated('Use followUps.isNotEmpty.')
  bool get followUpEnabled => followUps.isNotEmpty;

  @Deprecated('Follow-up history has no future scheduling date.')
  set followUpEnabled(bool value) {}

  @Deprecated('Follow-up history has no future scheduling date.')
  DateTime? get followUpDate => null;

  @Deprecated('Follow-up history has no future scheduling date.')
  set followUpDate(DateTime? value) {}

  /// Computed compatibility view of the earliest enabled reminder.
  /// The canonical reminder data lives only in [taskReminders]; dueDate is
  /// intentionally independent and never participates in this projection.
  DateTime? get reminderDate => earliestEnabledTaskReminder(this)?.date;

  /// First completion records a timestamp; repeated completion is idempotent.
  /// Explicit reopening clears it so the next completion records a fresh time.
  void setCompleted(bool value, {DateTime? at}) {
    if (value == completed) return;
    completed = value;
    completedAt = value ? (at ?? DateTime.now()) : null;
  }

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
        'dueDate': dueDate == null
            ? null
            : (allDay ? _dateOnlyStorageValue(dueDate!) : dueDate!.toIso8601String()),
        if (centerId != null && centerId!.trim().isNotEmpty) 'centerId': centerId,
        if (allDay) 'allDay': true,
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
        if (taskReminders.isNotEmpty)
          'taskReminders': taskReminders.map((item) => item.toJson()).toList(),
        if (nextReminderSequence > 1)
          'nextReminderSequence': nextReminderSequence,
        if (legacyTaskReminderMigrationVersion > 0)
          'legacyTaskReminderMigrationVersion': legacyTaskReminderMigrationVersion,
        if (legacyFollowUpMetadata.isNotEmpty)
          'legacyFollowUpMetadata': Map<String, dynamic>.from(legacyFollowUpMetadata),
        'priority': priority.name,
        'isFavorite': isFavorite,
        if (focusDate != null) 'focusDate': _dateOnlyStorageValue(focusDate!),
        'archived': archived,
        'trashed': trashed,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
        if (templateTaskId != null) 'templateTaskId': templateTaskId,
        'followUps': followUps.map((e) => e.toJson()).toList(),
        if (recurrence != null) 'recurrence': recurrence!.toJson(),
        if (people.isNotEmpty)
          'people': people.map((person) => person.toJson()).toList(),
      };

  /// Decodes current canonical Task JSON without running legacy migrations.
  factory Task.fromJson(Map<String, dynamic> json) => Task._decodeJson(json);

  /// Explicit compatibility boundary for sources known to contain legacy
  /// Task/Follow-up reminder fields.
  factory Task.fromLegacyJson(Map<String, dynamic> json) =>
      Task._decodeJson(json, migrateLegacyReminders: true);

  static Task _decodeJson(
    Map<String, dynamic> json, {
    bool migrateLegacyReminders = false,
  }) {
    var loadedFollowUps = <FollowUp>[];
    if (json['followUps'] is List) {
      loadedFollowUps = (json['followUps'] as List)
          .map((item) => FollowUp.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    final loadedPeople = _decodePeople(json['people']);
    final legacyFollowUpMetadata = decodeLegacyFollowUpMetadata(json);
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

    for (var index = 0; index < loadedTaskReminders.length; index++) {
      final reminder = loadedTaskReminders[index];
      if (reminder.id == 'legacy-task-reminder') {
        loadedTaskReminders[index] =
            reminder.copyWith(id: migratedTaskReminderId(json['id'] as String? ?? ''));
      }
    }

    final rawLegacyReminderDate = json['reminderDate'];
    final legacyReminderDate = migrateLegacyReminders && rawLegacyReminderDate is String
        ? DateTime.tryParse(rawLegacyReminderDate)
        : null;
    if (migrateLegacyReminders &&
        rawLegacyReminderDate is String &&
        rawLegacyReminderDate.trim().isNotEmpty &&
        legacyReminderDate == null) {
      throw const FormatException(
        'Invalid legacy Task reminderDate; refusing silent schedule loss.',
      );
    }
    final storedSequence = (json['nextReminderSequence'] as num?)?.toInt() ?? 1;
    final sequenceFromJson = storedSequence < 1 ? 1 : storedSequence;
    final storedMigrationVersion =
        (json['legacyTaskReminderMigrationVersion'] as num?)?.toInt() ?? 0;
    var migrationVersion = storedMigrationVersion < 0 ? 0 : storedMigrationVersion;
    if (migrationVersion < 1 && legacyReminderDate != null) {
      if (!loadedTaskReminders.any((item) => item.id == migratedTaskReminderId(json['id'] as String? ?? ''))) {
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
            id: migratedTaskReminderId(json['id'] as String? ?? ''),
            title: 'یادآوری: $taskTitle',
            date: legacyReminderDate,
            isAllDay: json['reminderAllDay'] == true ||
                _isDateOnlyStorageValue(rawLegacyReminderDate),
            sequence: migrationSequence,
          ),
        );
      }
      migrationVersion = 1;
    }

    // Explicit legacy Follow-up reminder dates are migrated to the same
    // independent TaskReminder collection. nextFollowUp alone is not an
    // opt-in reminder and must never schedule delivery.
    final rawFollowUps = json['followUps'];
    if (migrateLegacyReminders && rawFollowUps is List) {
      for (var index = 0; index < rawFollowUps.length; index++) {
        final rawFollowUp = rawFollowUps[index];
        if (rawFollowUp is! Map) continue;
        final rawDate = rawFollowUp['reminderDate'];
        if (rawDate is! String || rawDate.trim().isEmpty) continue;
        final reminderDate = DateTime.tryParse(rawDate);
        if (reminderDate == null) {
          throw FormatException('Invalid legacy Follow-up reminder date: $rawDate');
        }
        final followUpId = (rawFollowUp['id'] as String?)?.trim();
        final identity = followUpId?.isNotEmpty == true ? followUpId! : '$index';
        final reminderId = 'follow-up-reminder-${json['id'] ?? ''}-$identity';
        if (loadedTaskReminders.any((item) => item.id == reminderId)) continue;
        final highestSequence = loadedTaskReminders.isEmpty
            ? 0
            : loadedTaskReminders
                .map((item) => item.sequence)
                .reduce((a, b) => a > b ? a : b);
        loadedTaskReminders.add(
          TaskReminder(
            id: reminderId,
            title: 'یادآور پیگیری',
            date: reminderDate,
            isAllDay: rawFollowUp['reminderAllDay'] == true ||
                _isDateOnlyStorageValue(rawDate),
            sequence: highestSequence + 1,
          ),
        );
        if (migrationVersion < 2) migrationVersion = 2;
      }
    }

    final nextReminderSequence = [
      sequenceFromJson,
      if (loadedTaskReminders.isNotEmpty)
        loadedTaskReminders.map((item) => item.sequence).reduce((a, b) => a > b ? a : b) + 1,
    ].reduce((a, b) => a > b ? a : b);
    final rawPriority = json['priority'];
    final priorityName = rawPriority is String ? rawPriority.trim().toLowerCase() : '';
    final loadedPriority = switch (priorityName) {
      'high' || 'p1' => TaskPriority.high,
      'medium' || 'p2' => TaskPriority.medium,
      'low' || 'p3' => TaskPriority.low,
      'none' || 'p4' || '' => TaskPriority.none,
      _ => TaskPriority.none,
    };

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
      centerId: (json['centerId'] as String?)?.trim().isEmpty == true
          ? null
          : (json['centerId'] as String?)?.trim(),
      allDay: json['allDay'] as bool? ?? false,
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
      taskReminders: loadedTaskReminders,
      nextReminderSequence: nextReminderSequence,
      legacyTaskReminderMigrationVersion: migrationVersion,
      legacyFollowUpMetadata: legacyFollowUpMetadata,
      priority: loadedPriority,
      isFavorite: json['isFavorite'] as bool? ?? false,
      focusDate: (json['focusDate'] is String
              ? DateTime.tryParse(json['focusDate'] as String)
              : null) ??
          (json['isSelectedForToday'] == true ? DateTime.now() : null),
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'] as String),
      templateTaskId: json['templateTaskId'] as String?,
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

  /// Compatibility accessor retained for older Home callers. Presentation
  /// must never infer a recorded FollowUp from legacy scheduling metadata.
  DateTime? get legacyHomeFollowUpDate => lastFollowUpDate;
}
/// Stable ID retained for reminders migrated from pre-collection Task JSON.
String migratedTaskReminderId(String taskId) =>
    'legacy-task-reminder-$taskId';

/// Recognizes a migrated record by its stable ID, without persisting a
/// per-reminder legacy classification flag.
bool isMigratedTaskReminder(Task task, TaskReminder reminder) =>
    reminder.id == migratedTaskReminderId(task.id);

/// Canonical eligibility rule shared by every reminder scheduling and
/// delivery entry point. A reminder is never eligible when disabled or when
/// its owning Task is completed, archived, or trashed.
bool isTaskReminderEligible(Task task, TaskReminder reminder) =>
    reminder.isEnabled && !task.completed && !task.archived && !task.trashed;

/// Resolves the actual alarm timestamp for a canonical TaskReminder.
/// Date-only reminders intentionally fire at 09:00 local time.
DateTime taskReminderScheduledAt(TaskReminder reminder) => reminder.isAllDay
    ? DateTime(reminder.date.year, reminder.date.month, reminder.date.day, 9)
    : reminder.date;

/// Returns the canonical earliest enabled reminder record, if one exists.
TaskReminder? earliestEnabledTaskReminder(Task task) {
  TaskReminder? earliest;
  for (final reminder in task.taskReminders) {
    if (!reminder.isEnabled) continue;
    if (earliest == null || reminder.date.isBefore(earliest.date)) {
      earliest = reminder;
    }
  }
  return earliest;
}

