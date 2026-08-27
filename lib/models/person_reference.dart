/// Persistence-neutral identity used to associate existing canonical Tasks
/// with a person without creating a CRM or copying contact-provider payloads.
class PersonReference {
  factory PersonReference({
    required String id,
    required String displayName,
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
    return PersonReference._(
      id: normalizedId,
      displayName: normalizedName,
    );
  }

  const PersonReference._({
    required this.id,
    required this.displayName,
  });

  /// Stable Arvin-owned identity. It is deliberately not a phone number,
  /// email address or device-contact/provider identifier.
  final String id;

  /// Offline-safe label for rendering the relation without provider access.
  final String displayName;
}

/// Pure relation between one existing canonical Task id and zero or more
/// lightweight people. No Task payload or Person database record is copied.
class TaskPersonContext {
  factory TaskPersonContext({
    required String taskId,
    Iterable<PersonReference> people = const [],
  }) {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'Task id must not be empty');
    }

    final next = List<PersonReference>.of(people);
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
      people: List<PersonReference>.unmodifiable(next),
    );
  }

  const TaskPersonContext._({
    required this.taskId,
    required this.people,
  });

  final String taskId;
  final List<PersonReference> people;
}
