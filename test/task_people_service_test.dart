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
