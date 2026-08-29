import 'person_reference.dart';
import 'recurrence.dart';

class FollowUp {
  final String id;
  final DateTime dateTime;
  /// True when the FollowUp is attached to a calendar day without a user-specified time.
  /// The persisted DateTime remains backward-compatible; presentation layers must not
  /// display its time when this flag is true.
  final bool allDay;
  final String note;
  final String? result;
  final DateTime? reminderDate;
  final DateTime? nextFollowUp;

  const FollowUp({
    required this.id,
    required this.dateTime,
    this.allDay = false,
    this.note = '',
    this.result,
    this.reminderDate,
    this.nextFollowUp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'allDay': allDay,
        'note': note,
        'result': result,
        'reminderDate': reminderDate?.toIso8601String(),
        'nextFollowUp': nextFollowUp?.toIso8601String(),
      };

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      allDay: json['allDay'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.tryParse(json['reminderDate'] as String),
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.tryParse(json['nextFollowUp'] as String),
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
class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.followUpEnabled = false,
    this.followUpDate,
    this.tags = const [],
    this.category,
    this.checklist = const [],
    this.reminderDate,
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.followUps = const [],
    this.recurrence,
    Iterable<PersonReference> people = const [],
  }) : people = _normalizePeople(people);

  final String id;
  String title;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;

  /// Optional date/time when the Task itself is intended or due.
  ///
  /// This is deliberately independent from [reminderDate] and FollowUp
  /// timestamps. Undated Tasks/Notes remain valid with a null value.
  DateTime? dueDate;

  bool followUpEnabled;
  DateTime? followUpDate;
  List<String> tags;
  String? category;
  List<String> checklist;
  DateTime? reminderDate;
  bool archived;
  bool trashed;
  bool completed;
  List<FollowUp> followUps;
  RecurrenceRule? recurrence;

  /// Optional canonical Person references attached to this Task.
  /// The list is immutable so provider/UI code cannot mutate persistence state
  /// behind the Task boundary.
  final List<PersonReference> people;

  bool get isSimpleNote => !followUpEnabled && followUps.isEmpty;

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
        'followUpEnabled': followUpEnabled,
        'followUpDate': followUpDate?.toIso8601String(),
        'tags': tags,
        'category': category,
        'checklist': checklist,
        'reminderDate': reminderDate?.toIso8601String(),
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
    final legacyFollowUpDate = json['followUpDate'] == null
        ? null
        : DateTime.tryParse(json['followUpDate'] as String);

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
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.tryParse(json['reminderDate'] as String),
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

  /// The follow-up date rendered by the legacy Home view during migration.
  ///
  /// Prefer the latest canonical history entry when one exists while still
  /// preserving the legacy single followUpDate fallback for older data.
  DateTime? get legacyHomeFollowUpDate =>
      followUps.isEmpty ? followUpDate : lastFollowUpDate;
}
