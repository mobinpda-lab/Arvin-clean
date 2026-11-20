import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/g1_drift_schema.dart';
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
}
