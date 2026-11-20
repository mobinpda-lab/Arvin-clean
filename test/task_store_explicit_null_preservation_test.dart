import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test(
    'TaskStore preserves explicit NULL envelope fields through mutation and SQLite reopen',
    () async {
      final directory =
          await Directory.systemTemp.createTemp('arvin-explicit-null-envelope-');
      final databaseFile = File('${directory.path}/arvin.sqlite');
      var database = NativeDatabase(databaseFile);

      const taskId = 'explicit-null-envelope-task';
      final unknownValue = <String, dynamic>{
        'version': 7,
        'nested': <String, dynamic>{'keep': true, 'value': 'future-data'},
      };
      final originalEnvelope = <String, dynamic>{
        'id': taskId,
        'title': 'Original title',
        'description': 'Original description',
        'createdAt': null,
        'updatedAt': null,
        'dueDate': null,
        'category': null,
        'notebookKind': null,
        'templateTaskId': null,
        'focusDate': null,
        'recurrence': null,
        'priority': 'medium',
        'archived': false,
        'trashed': false,
        'completed': false,
        'isFavorite': false,
        'followUps': <dynamic>[],
        'tags': <dynamic>[],
        'checklist': <dynamic>[],
        'unknownFutureField': unknownValue,
      };

      try {
        await G1DriftSchema.install(database);
        await G1DriftSchema.markLegacyMigrationComplete(database);
        await database.runInsert(
          '''INSERT INTO tasks (
            id, storage_ordinal, title, description, created_at, updated_at, due_date,
            category, notebook_kind, priority, archived, trashed, completed,
            recurrence_json, legacy_payload_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            taskId,
            0,
            'Original title',
            'Original description',
            null,
            null,
            null,
            null,
            null,
            'medium',
            0,
            0,
            0,
            null,
            jsonEncode(originalEnvelope),
          ],
        );

        final store = TaskStore(executor: database);
        final loaded = await store.load();
        expect(loaded, hasLength(1));
        expect(loaded.single.id, taskId);
        expect(loaded.single.notebookKind, isNull);
        expect(loaded.single.templateTaskId, isNull);
        expect(loaded.single.focusDate, isNull);
        expect(loaded.single.recurrence, isNull);

        await store.mutate<void>((tasks) {
          tasks.single.title = 'Updated title';
        });

        var rows = await database.runSelect(
          'SELECT id, title, legacy_payload_json FROM tasks WHERE id = ?',
          <Object?>[taskId],
        );
        expect(rows, hasLength(1));
        expect(rows.single['title'], 'Updated title');
        var envelope = Map<String, dynamic>.from(
          jsonDecode(rows.single['legacy_payload_json'] as String) as Map,
        );
        for (final key in const [
          'notebookKind',
          'templateTaskId',
          'focusDate',
          'recurrence',
        ]) {
          expect(envelope.containsKey(key), isTrue, reason: '$key must remain explicit');
          expect(envelope[key], isNull, reason: '$key must remain NULL');
        }
        expect(envelope['unknownFutureField'], unknownValue);

        await database.close();
        database = NativeDatabase(databaseFile);
        final reopenedStore = TaskStore(executor: database);
        final reopened = await reopenedStore.load();
        expect(reopened, hasLength(1));
        expect(reopened.single.id, taskId);
        expect(reopened.single.title, 'Updated title');
        expect(reopened.single.notebookKind, isNull);
        expect(reopened.single.templateTaskId, isNull);
        expect(reopened.single.focusDate, isNull);
        expect(reopened.single.recurrence, isNull);

        rows = await database.runSelect(
          'SELECT id, legacy_payload_json FROM tasks WHERE id = ?',
          <Object?>[taskId],
        );
        envelope = Map<String, dynamic>.from(
          jsonDecode(rows.single['legacy_payload_json'] as String) as Map,
        );
        for (final key in const [
          'notebookKind',
          'templateTaskId',
          'focusDate',
          'recurrence',
        ]) {
          expect(envelope.containsKey(key), isTrue, reason: '$key lost after reopen');
          expect(envelope[key], isNull, reason: '$key changed after reopen');
        }
        expect(envelope['unknownFutureField'], unknownValue);

        // The same decoded Task object is the source for portable backup JSON.
        final backupJson = reopened.single.toJson();
        for (final key in const [
          'notebookKind',
          'templateTaskId',
          'focusDate',
          'recurrence',
        ]) {
          expect(backupJson.containsKey(key), isTrue, reason: '$key lost from backup JSON');
          expect(backupJson[key], isNull, reason: '$key changed in backup JSON');
        }

        final integrity = await database.runSelect('PRAGMA integrity_check', const []);
        expect(integrity.single.values.single, 'ok');
        final foreignKeys =
            await database.runSelect('PRAGMA foreign_key_check', const []);
        expect(foreignKeys, isEmpty);
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('Task JSON preserves explicit NULL keys and never restores stale non-NULL values', () {
    const keys = <String>[
      'notebookKind',
      'templateTaskId',
      'focusDate',
      'recurrence',
    ];
    final explicitNullTask = Task.fromJson(<String, dynamic>{
      'id': 'explicit-null-json-task',
      'title': 'NULL صریح',
      for (final key in keys) key: null,
    });
    final explicitNullJson = explicitNullTask.toJson();
    for (final key in keys) {
      expect(explicitNullJson.containsKey(key), isTrue, reason: '$key was omitted');
      expect(explicitNullJson[key], isNull, reason: '$key was not NULL');
    }

    final populatedTask = Task.fromJson(<String, dynamic>{
      'id': 'populated-json-task',
      'title': 'مقادیر معتبر',
      'notebookKind': 'note',
      'templateTaskId': 'template-original',
      'focusDate': '2026-11-20',
      'recurrence': <String, dynamic>{
        'frequency': 'weekly',
        'interval': 2,
      },
    });
    final populatedJson = populatedTask.toJson();
    expect(populatedJson['notebookKind'], 'note');
    expect(populatedJson['templateTaskId'], 'template-original');
    expect(populatedJson['focusDate'], '2026-11-20');
    expect((populatedJson['recurrence'] as Map)['frequency'], 'weekly');
    expect((populatedJson['recurrence'] as Map)['interval'], 2);

    // Clearing a formerly populated field must not resurrect the old value.
    populatedTask.notebookKind = null;
    populatedTask.templateTaskId = null;
    populatedTask.focusDate = null;
    populatedTask.recurrence = null;
    final clearedJson = populatedTask.toJson();
    for (final key in keys) {
      expect(clearedJson.containsKey(key), isFalse, reason: '$key was restored after clear');
    }
  });

  test('fresh SQLite insert preserves explicit NULLs, Task IDs and Person/Follow-up relations', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-explicit-null-insert-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    var database = NativeDatabase(databaseFile);
    const taskId = 'explicit-null-insert-task';
    const personId = 'explicit-null-insert-person';
    const followUpId = 'explicit-null-insert-follow-up';

    try {
      final store = TaskStore(executor: database);
      await store.save(<Task>[
        Task.fromJson(<String, dynamic>{
          'id': taskId,
          'title': 'Task with explicit NULL',
          'notebookKind': null,
          'templateTaskId': null,
          'focusDate': null,
          'recurrence': null,
          'people': <Map<String, dynamic>>[
            <String, dynamic>{'id': personId, 'displayName': 'شخص پایدار'},
          ],
          'followUps': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': followUpId,
              'completedAt': '2026-11-20T10:00:00.000',
              'note': 'تاریخچه باید باقی بماند',
              'personIds': <String>[personId],
            },
          ],
        }),
      ]);

      var row = (await database.runSelect(
        'SELECT id, notebook_kind, recurrence_json, legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>[taskId],
      )).single;
      expect(row['notebook_kind'], isNull);
      expect(row['recurrence_json'], isNull);
      var envelope = Map<String, dynamic>.from(
        jsonDecode(row['legacy_payload_json'] as String) as Map,
      );
      for (final key in const ['notebookKind', 'templateTaskId', 'focusDate', 'recurrence']) {
        expect(envelope.containsKey(key), isTrue, reason: '$key lost on fresh insert');
        expect(envelope[key], isNull, reason: '$key changed on fresh insert');
      }

      await database.close();
      database = NativeDatabase(databaseFile);
      final reopenedStore = TaskStore(executor: database);
      final reopened = await reopenedStore.load();
      expect(reopened, hasLength(1));
      expect(reopened.single.id, taskId);
      expect(reopened.single.people.single.id, personId);
      expect(reopened.single.followUps.single.id, followUpId);
      expect(reopened.single.followUps.single.personIds, <String>[personId]);
      final portableJson = reopened.single.toJson();
      for (final key in const ['notebookKind', 'templateTaskId', 'focusDate', 'recurrence']) {
        expect(portableJson.containsKey(key), isTrue, reason: '$key lost after reopen');
        expect(portableJson[key], isNull, reason: '$key changed after reopen');
      }

      final taskLinks = await database.runSelect(
        'SELECT person_id FROM task_persons WHERE task_id = ?',
        const <Object?>[taskId],
      );
      final followUpLinks = await database.runSelect(
        'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?',
        const <Object?>[followUpId],
      );
      expect(taskLinks.map((value) => value['person_id']), <String>[personId]);
      expect(followUpLinks.map((value) => value['person_id']), <String>[personId]);
      row = (await database.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>[taskId],
      )).single;
      envelope = Map<String, dynamic>.from(
        jsonDecode(row['legacy_payload_json'] as String) as Map,
      );
      for (final key in const ['notebookKind', 'templateTaskId', 'focusDate', 'recurrence']) {
        expect(envelope.containsKey(key), isTrue, reason: '$key lost after reopen');
        expect(envelope[key], isNull, reason: '$key changed after reopen');
      }
      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      expect(integrity.single.values.single, 'ok');
      expect(await database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
