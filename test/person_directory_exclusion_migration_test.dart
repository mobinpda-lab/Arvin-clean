import 'dart:io';

import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('explicit Person Directory removal survives reopen while Task and Follow-up history remains', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-person-exclusion-');
    final file = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    final person = PersonReference(
      id: 'person-directory-exclusion-stable',
      displayName: 'شخص با شناسه پایدار',
    );

    var database = NativeDatabase(file);
    try {
      final store = TaskStore(executor: database);
      await store.savePeopleDirectory(<PersonReference>[person]);
      await store.save(<Task>[
        Task(
          id: 'task-person-directory-exclusion',
          title: 'کار با شخص',
          people: <PersonReference>[person],
          followUps: <FollowUp>[
            FollowUp(
              id: 'follow-up-person-directory-exclusion',
              dateTime: DateTime(2026, 11, 19, 9),
              personIds: <String>[person.id],
            ),
          ],
        ),
      ]);

      await store.savePeopleDirectory(const <PersonReference>[]);
      expect(await store.loadPeopleDirectory(), isEmpty);

      final retained = (await store.load()).single;
      expect(retained.people.single.id, person.id);
      expect(retained.people.single.displayName, person.displayName);
      expect(retained.followUps.single.id, 'follow-up-person-directory-exclusion');
      expect(retained.followUps.single.personIds, <String>[person.id]);

      final exclusions = await database.runSelect(
        'SELECT person_id FROM person_directory_exclusions',
        const [],
      );
      expect(exclusions.map((row) => row['person_id']), <String>[person.id]);
      final taskRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM task_people WHERE task_id = ? AND person_id = ?',
        <Object?>['task-person-directory-exclusion', person.id],
      );
      final followUpRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM follow_up_people WHERE follow_up_id = ? AND person_id = ?',
        <Object?>['follow-up-person-directory-exclusion', person.id],
      );
      expect(taskRelationCount.single['row_count'], 1);
      expect(followUpRelationCount.single['row_count'], 1);
    } finally {
      await database.close();
    }

    // Reopen and repeat schema installation. The excluded identity must not be
    // silently rehydrated from task_people or follow_up_people.
    database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await G1DriftSchema.install(database);
      final reopenedStore = TaskStore(executor: database);
      expect(await reopenedStore.loadPeopleDirectory(), isEmpty);

      final retained = (await reopenedStore.load()).single;
      expect(retained.people.single.id, person.id);
      expect(retained.followUps.single.personIds, <String>[person.id]);
      final taskRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM task_people WHERE task_id = ? AND person_id = ?',
        <Object?>['task-person-directory-exclusion', person.id],
      );
      final followUpRelationCount = await database.runSelect(
        'SELECT COUNT(*) AS row_count FROM follow_up_people WHERE follow_up_id = ? AND person_id = ?',
        <Object?>['follow-up-person-directory-exclusion', person.id],
      );
      expect(taskRelationCount.single['row_count'], 1);
      expect(followUpRelationCount.single['row_count'], 1);

      // Explicit re-add is the only operation that clears the exclusion.
      await reopenedStore.savePeopleDirectory(<PersonReference>[person]);
      expect((await reopenedStore.loadPeopleDirectory()).single.id, person.id);

      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
      expect(integrity.single.values.first, 'ok');
      expect(foreignKeys, isEmpty);
    } finally {
      await database.close();
    }

    // A final fresh executor proves re-addition and historical relations are durable.
    database = NativeDatabase(file);
    try {
      final finalStore = TaskStore(executor: database);
      expect((await finalStore.loadPeopleDirectory()).single.id, person.id);
      final retained = (await finalStore.load()).single;
      expect(retained.people.single.id, person.id);
      expect(retained.followUps.single.personIds, <String>[person.id]);
    } finally {
      await database.close();
    }
  });
}
