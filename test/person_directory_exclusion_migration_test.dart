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
      expect(retained.people.single.isDeleted, isTrue);
      expect(retained.followUps.single.id, 'follow-up-person-directory-exclusion');
      expect(retained.followUps.single.personIds, <String>[person.id]);

      final exclusions = await database.runSelect(
        'SELECT person_id FROM person_directory_exclusions',
        const [],
      );
      expect(exclusions.map((row) => row['person_id']), <String>[person.id]);
      final taskLinks = await database.runSelect(
        'SELECT person_id FROM task_persons WHERE task_id = ?',
        const <Object?>['task-person-directory-exclusion'],
      );
      final followUpLinks = await database.runSelect(
        'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?',
        const <Object?>['follow-up-person-directory-exclusion'],
      );
      expect(taskLinks.map((row) => row['person_id']), <String>[person.id]);
      expect(followUpLinks.map((row) => row['person_id']), <String>[person.id]);
      // Simulate an incomplete/older seed marker so the next install must
      // evaluate the tombstone rather than relying on a one-time seed flag.
      await database.runCustom(
        "DELETE FROM arvin_storage_meta WHERE key = 'person_directory_seeded_v1'",
      );
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
      expect(retained.people.single.isDeleted, isTrue);

      // Rewriting a stale Task snapshot must not re-add the excluded Person.
      await reopenedStore.save(<Task>[retained]);
      expect(await reopenedStore.loadPeopleDirectory(), isEmpty);
      final stillExcluded = await database.runSelect(
        'SELECT person_id FROM person_directory_exclusions WHERE person_id = ?',
        <Object?>[person.id],
      );
      expect(stillExcluded, hasLength(1));

      // Explicit re-add is the only operation that clears the exclusion.
      await reopenedStore.savePeopleDirectory(<PersonReference>[person]);
      expect((await reopenedStore.loadPeopleDirectory()).single.id, person.id);
      final clearedExclusion = await database.runSelect(
        'SELECT person_id FROM person_directory_exclusions WHERE person_id = ?',
        <Object?>[person.id],
      );
      expect(clearedExclusion, isEmpty);
      await reopenedStore.save(<Task>[retained]);
      final taskLinksAfterReadd = await database.runSelect(
        'SELECT person_id FROM task_persons WHERE task_id = ?',
        const <Object?>['task-person-directory-exclusion'],
      );
      final followUpLinksAfterReadd = await database.runSelect(
        'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?',
        const <Object?>['follow-up-person-directory-exclusion'],
      );
      expect(taskLinksAfterReadd, hasLength(1));
      expect(followUpLinksAfterReadd, hasLength(1));

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
