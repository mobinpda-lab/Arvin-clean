import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'removing a Person from the directory preserves historical Task relation across file reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'arvin-person-directory-history-',
      );
      final file = File('${directory.path}/arvin.sqlite');
      final task = Task(
        id: 'history-task-1',
        title: 'پیگیری تاریخی',
      );
      final person = PersonReference(
        id: 'history-person-1',
        displayName: 'شخص تاریخی',
      );

      final firstDatabase = NativeDatabase(file);
      try {
        final firstStore = TaskStore(executor: firstDatabase);
        await firstStore.save(<Task>[task]);
        await firstStore.savePeopleDirectory(<PersonReference>[person]);
        await firstDatabase.runInsert(
          'INSERT INTO task_persons (task_id, person_id, ordinal) VALUES (?, ?, ?)',
          <Object?>[task.id, person.id, 0],
        );

        await firstStore.savePeopleDirectory(const <PersonReference>[]);
        expect(await firstStore.loadPeopleDirectory(), isEmpty);
        expect(await firstStore.loadPersonDirectoryExclusions(), hasLength(1));
        expect(
          (await firstStore.loadPersonDirectoryExclusions()).single['personId'],
          person.id,
        );
        final retainedBeforeClose = await firstDatabase.runSelect(
          '''SELECT persons.id, persons.name, task_persons.task_id
             FROM persons
             JOIN task_persons ON task_persons.person_id = persons.id
             WHERE persons.id = ?''',
          <Object?>[person.id],
        );
        expect(retainedBeforeClose, hasLength(1));
        expect(retainedBeforeClose.single['name'], person.displayName);
        expect(retainedBeforeClose.single['task_id'], task.id);
      } finally {
        await firstDatabase.close();
      }

      final reopenedDatabase = NativeDatabase(file);
      try {
        final reopenedStore = TaskStore(executor: reopenedDatabase);
        expect(await reopenedStore.loadPeopleDirectory(), isEmpty);
        expect(await reopenedStore.loadPersonDirectoryExclusions(), hasLength(1));
        expect(
          (await reopenedStore.loadPersonDirectoryExclusions()).single['personId'],
          person.id,
        );

        final retainedAfterReopen = await reopenedDatabase.runSelect(
          '''SELECT persons.id, persons.name, task_persons.task_id
             FROM persons
             JOIN task_persons ON task_persons.person_id = persons.id
             WHERE persons.id = ?''',
          <Object?>[person.id],
        );
        expect(retainedAfterReopen, hasLength(1));
        expect(retainedAfterReopen.single['name'], person.displayName);
        expect(retainedAfterReopen.single['task_id'], task.id);

        await reopenedStore.savePeopleDirectory(<PersonReference>[person]);
        expect(
          (await reopenedStore.loadPeopleDirectory()).map((value) => value.id),
          contains(person.id),
        );
        expect(await reopenedStore.loadPersonDirectoryExclusions(), isEmpty);
        final relationAfterReAdd = await reopenedDatabase.runSelect(
          'SELECT task_id, person_id FROM task_persons WHERE task_id = ? AND person_id = ?',
          <Object?>[task.id, person.id],
        );
        expect(relationAfterReAdd, hasLength(1));
      } finally {
        await reopenedDatabase.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
