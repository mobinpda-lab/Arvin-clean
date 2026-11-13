import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_people_service.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Task richTask({Iterable<PersonReference> people = const []}) => Task(
        id: 'task-1',
        title: 'کار اصلی',
        description: 'توضیح',
        createdAt: DateTime(2026, 8, 1, 10),
        updatedAt: DateTime(2026, 8, 2, 11),
        followUpEnabled: true,
        followUpDate: DateTime(2026, 8, 28, 9),
        tags: const ['مهم', 'پیگیری'],
        category: 'کاری',
        checklist: const ['یک', 'دو'],
        reminderDate: DateTime(2026, 8, 28, 8, 30),
        archived: false,
        trashed: false,
        completed: false,
        followUps: [
          FollowUp(
            id: 'follow-1',
            dateTime: DateTime(2026, 8, 20, 12),
            note: 'تماس',
            result: 'منتظر',
            nextFollowUp: DateTime(2026, 8, 28, 9),
          ),
        ],
        people: people,
      );

  test('add local Person persists only through canonical TaskStore', () async {
    final store = TaskStore();
    final original = richTask();
    await store.save([original]);
    final service = TaskPeopleService(
      store: store,
      personIdFactory: () => 'person-1',
    );

    final updated = await service.addLocalPerson(
      taskId: original.id,
      displayName: '  علی رضایی  ',
    );

    expect(updated.people, hasLength(1));
    expect(updated.people.single.id, 'person-1');
    expect(updated.people.single.displayName, 'علی رضایی');

    final reloaded = (await store.load()).single;
    expect(reloaded.people.single.id, 'person-1');
    expect((await store.loadPeopleDirectory()).map((person) => person.id), contains('person-1'));
    expect(reloaded.title, original.title);
    expect(reloaded.description, original.description);
    expect(reloaded.tags, original.tags);
    expect(reloaded.category, original.category);
    expect(reloaded.checklist, original.checklist);
    expect(reloaded.reminderDate, original.reminderDate);
    expect(reloaded.followUpEnabled, original.followUpEnabled);
    expect(reloaded.followUps.single.id, original.followUps.single.id);
    expect(reloaded.followUps.single.note, original.followUps.single.note);
    expect(reloaded.archived, original.archived);
    expect(reloaded.trashed, original.trashed);
    expect(reloaded.completed, original.completed);
  });

  test('Person creation and Task linking roll back together and survive file reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-person-atomic-');
    final file = File('${directory.path}/arvin.sqlite');
    var executor = NativeDatabase(file);
    addTearDown(() async {
      try {
        await executor.close();
      } catch (_) {}
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    const personId = 'person-from-follow-up';
    final store = TaskStore(executor: executor);
    await store.save([
      Task(
        id: 'task-person-atomic',
        title: 'کار دارای سابقه پیگیری',
        followUps: [
          FollowUp(
            id: 'follow-up-person-atomic',
            dateTime: DateTime(2026, 8, 20, 12),
            note: 'سابقه مستقل شخص',
            personIds: const [personId],
          ),
        ],
      ),
    ]);
    final service = TaskPeopleService(
      store: store,
      personIdFactory: () => personId,
    );

    await executor.runCustom('''
      CREATE TRIGGER reject_person_directory_insert
      BEFORE INSERT ON person_directory
      BEGIN
        SELECT RAISE(ABORT, 'injected directory write failure');
      END
    ''');

    await expectLater(
      service.addLocalPerson(
        taskId: 'task-person-atomic',
        displayName: 'سارا احمدی',
      ),
      throwsA(anything),
    );

    final rolledBack = (await store.load()).single;
    expect(rolledBack.people, isEmpty);
    expect(rolledBack.followUps.single.personIds, [personId]);
    expect(await store.loadPeopleDirectory(), isEmpty);
    final unchangedPerson = await executor.runSelect(
      'SELECT name FROM persons WHERE id = ?',
      const [personId],
    );
    expect(unchangedPerson.single['name'], '');

    await executor.runCustom('DROP TRIGGER reject_person_directory_insert');
    await service.addLocalPerson(
      taskId: 'task-person-atomic',
      displayName: 'سارا احمدی',
    );

    await executor.close();
    executor = NativeDatabase(file);
    final reopenedStore = TaskStore(executor: executor);
    final reopenedTask = (await reopenedStore.load()).single;
    final directoryPeople = await reopenedStore.loadPeopleDirectory();

    expect(reopenedTask.people, hasLength(1));
    expect(reopenedTask.people.single.id, personId);
    expect(reopenedTask.people.single.displayName, 'سارا احمدی');
    expect(reopenedTask.followUps.single.personIds, [personId]);
    expect(directoryPeople, hasLength(1));
    expect(directoryPeople.single.id, personId);
    expect(directoryPeople.single.displayName, 'سارا احمدی');
  });

  test('update Person changes the canonical directory label across Task references', () async {
    final store = TaskStore();
    final person = PersonReference(id: 'person-shared', displayName: 'سارا');
    await store.save([
      Task(id: 'task-1', title: 'کار اول', people: [person]),
      Task(id: 'task-2', title: 'کار دوم', people: [person]),
    ]);
    final service = TaskPeopleService(store: store);
    final staleTaskSnapshot = (await store.load()).first;

    final updated = await service.updatePerson(
      taskId: 'task-1',
      personId: person.id,
      displayName: '  سارا احمدی  ',
    );

    expect(updated.people.single.displayName, 'سارا احمدی');
    // A Task snapshot captured before the rename must not roll the canonical
    // Person display name back when it is saved later.
    // TaskStore.save replaces the complete Task collection. Preserve the
    // second Task while replaying the stale snapshot of the first one.
    final currentTasks = await store.load();
    await store.save([
      staleTaskSnapshot,
      ...currentTasks.where((task) => task.id != staleTaskSnapshot.id),
    ]);
    final tasks = await store.load();
    expect(tasks.map((task) => task.people.single.displayName),
        ['سارا احمدی', 'سارا احمدی']);
    final directory = await store.loadPeopleDirectory();
    expect(directory, hasLength(1));
    expect(directory.single.id, person.id);
    expect(directory.single.displayName, 'سارا احمدی');
  });

  test('duplicate Person id is rejected without overwriting Task', () async {
    final store = TaskStore();
    final original = richTask(
      people: [PersonReference(id: 'person-1', displayName: 'علی')],
    );
    await store.save([original]);
    final service = TaskPeopleService(store: store);

    await expectLater(
      service.addLocalPerson(
        taskId: original.id,
        displayName: 'رضا',
        personId: 'person-1',
      ),
      throwsStateError,
    );

    final reloaded = (await store.load()).single;
    expect(reloaded.people, hasLength(1));
    expect(reloaded.people.single.displayName, 'علی');
  });

  test('remove Person replaces immutable relation and preserves Task envelope', () async {
    final store = TaskStore();
    final original = richTask(
      people: [
        PersonReference(id: 'person-1', displayName: 'علی'),
        PersonReference(id: 'person-2', displayName: 'رضا'),
      ],
    );
    await store.save([original]);
    final service = TaskPeopleService(store: store);

    final updated = await service.removePerson(
      taskId: original.id,
      personId: 'person-1',
    );

    expect(updated.people.map((person) => person.id), ['person-2']);
    expect(() => updated.people.add(PersonReference(id: 'x', displayName: 'x')),
        throwsUnsupportedError);

    final reloaded = (await store.load()).single;
    expect(reloaded.people.map((person) => person.id), ['person-2']);
    expect(reloaded.title, original.title);
    expect(reloaded.followUps.single.id, 'follow-1');
    expect(reloaded.checklist, original.checklist);
    expect(reloaded.reminderDate, original.reminderDate);
  });

  test('missing Task and invalid names fail closed', () async {
    final service = TaskPeopleService(store: TaskStore());

    await expectLater(
      service.addLocalPerson(taskId: 'missing', displayName: 'علی'),
      throwsStateError,
    );
    await expectLater(
      service.addLocalPerson(taskId: 'missing', displayName: '   '),
      throwsArgumentError,
    );
  });
}
