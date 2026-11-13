import '../models/person_reference.dart';
import '../models/task.dart';
import 'task_store.dart';

typedef PersonIdFactory = String Function();

/// Task-facing People operations that reuse the existing canonical TaskStore.
///
/// This service deliberately does not own a parallel People repository, device
/// Contacts provider, phone/email payload, or sync path. Task associations,
/// Person identity, and active-directory membership remain in TaskStore's
/// canonical SQLite tables.
class TaskPeopleService {
  TaskPeopleService({
    TaskStore? store,
    PersonIdFactory? personIdFactory,
  })  : _store = store ?? TaskStore(),
        _personIdFactory = personIdFactory ?? _defaultPersonId;

  final TaskStore _store;
  final PersonIdFactory _personIdFactory;

  static String _defaultPersonId() =>
      'arvin-person-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  Future<Task> loadRequiredTask(String taskId) async {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'Task id must not be empty');
    }

    final tasks = await _store.load();
    final index = tasks.indexWhere((task) => task.id == normalizedTaskId);
    if (index < 0) throw StateError('Task not found: $normalizedTaskId');
    return tasks[index];
  }

  Future<Task> addLocalPerson({
    required String taskId,
    required String displayName,
    String? personId,
  }) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Person display name must not be empty',
      );
    }

    final person = PersonReference(
      id: personId ?? _personIdFactory(),
      displayName: normalizedName,
    );
    return _store.addPersonToTask(taskId: taskId, person: person);
  }

  Future<Task> updatePerson({
    required String taskId,
    required String personId,
    required String displayName,
  }) async {
    final normalizedPersonId = personId.trim();
    final normalizedName = displayName.trim();
    if (normalizedPersonId.isEmpty) {
      throw ArgumentError.value(
        personId,
        'personId',
        'Person id must not be empty',
      );
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Person display name must not be empty',
      );
    }

    final task = await loadRequiredTask(taskId);
    final matches = task.people.where((person) => person.id == normalizedPersonId);
    if (matches.isEmpty) {
      throw StateError('Person is not linked to Task: $normalizedPersonId');
    }
    final existing = matches.first;
    if (existing.isDeleted) {
      throw StateError('Cannot edit a Person removed from the active directory');
    }

    // Person identity is shared across Task references. Updating the canonical
    // directory row updates every historical/current Task projection without
    // replacing IDs or creating a second Person store.
    await _store.mergePeopleDirectory([
      PersonReference(id: existing.id, displayName: normalizedName),
    ]);
    return loadRequiredTask(taskId);
  }

  Future<Task> removePerson({
    required String taskId,
    required String personId,
  }) async {
    final normalizedPersonId = personId.trim();
    if (normalizedPersonId.isEmpty) {
      throw ArgumentError.value(
        personId,
        'personId',
        'Person id must not be empty',
      );
    }

    return _store.mutate<Task>((tasks) {
      final index = _requiredTaskIndex(tasks, taskId);
      final task = tasks[index];
      if (!task.people.any((person) => person.id == normalizedPersonId)) {
        throw StateError('Person is not linked to Task: $normalizedPersonId');
      }

      final updated = _withPeople(
        task,
        task.people.where((person) => person.id != normalizedPersonId),
      );
      tasks[index] = updated;
      return updated;
    });
  }

  int _requiredTaskIndex(List<Task> tasks, String taskId) {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'Task id must not be empty');
    }
    final index = tasks.indexWhere((task) => task.id == normalizedTaskId);
    if (index < 0) throw StateError('Task not found: $normalizedTaskId');
    return index;
  }

  Task _withPeople(Task task, Iterable<PersonReference> people) {
    final json = Map<String, dynamic>.from(task.toJson());
    final next = List<PersonReference>.of(people);
    if (next.isEmpty) {
      json.remove('people');
    } else {
      json['people'] = next.map((person) => person.toJson()).toList();
    }
    return Task.fromJson(json);
  }
}
