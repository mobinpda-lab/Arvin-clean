/// Persistence-neutral identity used to associate existing canonical Tasks
/// with a person without creating a CRM or copying contact-provider payloads.
class Person {
  factory Person({
    required String id,
    required String displayName,
    bool isDeleted = false,
  }) {
    final normalizedId = id.trim();
    final normalizedName = displayName.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Person id must not be empty');
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Person display name must not be empty',
      );
    }
    return Person._(
      id: normalizedId,
      displayName: normalizedName,
      isDeleted: isDeleted,
    );
  }

  const Person._({
    required this.id,
    required this.displayName,
    this.isDeleted = false,
  });

  /// Stable Arvin-owned identity. It is deliberately not a phone number,
  /// email address or device-contact/provider identifier.
  final String id;

  /// Offline-safe label for rendering the relation without provider access.
  final String displayName;

  /// Historical relation whose identity remains, but which is no longer in
  /// the active People Directory.
  final bool isDeleted;

  String get displayLabel => isDeleted ? 'شخص حذف‌شده' : displayName;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'displayName': displayName,
        if (isDeleted) 'isDeleted': true,
      };

  factory Person.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawDisplayName = json['displayName'];
    final rawIsDeleted = json['isDeleted'];
    if (rawId is! String || rawDisplayName is! String ||
        (rawIsDeleted != null && rawIsDeleted is! bool)) {
      throw const FormatException('Invalid Person reference');
    }

    try {
      return Person(
        id: rawId,
        displayName: rawDisplayName,
        isDeleted: rawIsDeleted as bool? ?? false,
      );
    } on ArgumentError {
      throw const FormatException('Invalid Person reference');
    }
  }
}

/// Source-compatible alias; the canonical unified entity is Person.
typedef PersonReference = Person;

/// Pure relation between one existing canonical Task id and zero or more
/// lightweight people. No Task payload or Person database record is copied.
class TaskPersonContext {
  factory TaskPersonContext({
    required String taskId,
    Iterable<Person> people = const [],
  }) {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'Task id must not be empty');
    }

    final next = List<Person>.of(people);
    final seen = <String>{};
    for (final person in next) {
      if (!seen.add(person.id)) {
        throw ArgumentError.value(
          person.id,
          'people',
          'Duplicate Person id in one Task relation',
        );
      }
    }

    return TaskPersonContext._(
      taskId: normalizedTaskId,
      people: List<Person>.unmodifiable(next),
    );
  }

  const TaskPersonContext._({
    required this.taskId,
    required this.people,
  });

  final String taskId;
  final List<Person> people;
}
