import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  test('portable restore merges Person records by stable ID and preserves local-only people', () async {
    final store = TaskStore();
    await store.savePersonDirectoryEntry(
      PersonReference(id: 'person-local', displayName: 'شخص محلی'),
    );
    await store.savePersonDirectoryEntry(
      PersonReference(id: 'person-shared', displayName: 'نام قدیمی'),
    );

    await store.restorePeopleDirectoryEntries([
      PersonReference(id: 'person-shared', displayName: 'نام پشتیبان'),
      PersonReference(id: 'person-imported', displayName: 'شخص واردشده'),
    ]);

    final people = await store.loadPeopleDirectory();
    expect(people.map((person) => person.id).toSet(), {
      'person-local',
      'person-shared',
      'person-imported',
    });
    expect(
      people.singleWhere((person) => person.id == 'person-shared').displayName,
      'نام پشتیبان',
    );
  });

  test('rollback replacement restores exact directory without deleting Tasks', () async {
    final store = TaskStore();
    await store.save([Task(id: 'task-kept', title: 'کار حفظ‌شده')]);
    final original = PersonReference(id: 'person-original', displayName: 'شخص اصلی');
    await store.savePersonDirectoryEntry(original);
    await store.savePersonDirectoryEntry(
      PersonReference(id: 'person-added', displayName: 'شخص افزوده'),
    );

    await store.restorePeopleDirectoryEntries([original], replace: true);

    final people = await store.loadPeopleDirectory();
    expect(people.map((person) => person.id), ['person-original']);
    expect((await store.load()).map((task) => task.id), ['task-kept']);
  });

  test('restore rejects duplicate stable Person IDs before mutating the directory', () async {
    final store = TaskStore();
    await store.savePersonDirectoryEntry(
      PersonReference(id: 'person-existing', displayName: 'شخص موجود'),
    );

    await expectLater(
      store.restorePeopleDirectoryEntries([
        PersonReference(id: 'duplicate', displayName: 'نام اول'),
        PersonReference(id: 'duplicate', displayName: 'نام دوم'),
      ]),
      throwsA(isA<FormatException>()),
    );

    expect(
      (await store.loadPeopleDirectory()).map((person) => person.id),
      ['person-existing'],
    );
  });
}
