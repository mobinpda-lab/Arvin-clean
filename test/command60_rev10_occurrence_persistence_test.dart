import 'dart:convert';
import 'dart:io';

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

  test('REV10 schema 9 preserves Occurrence and Checklist envelopes across three installs and file reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-rev10-occurrence-');
    final file = File('${directory.path}/arvin.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    const occurrenceKey = '2026-11-20T06:00:00.000';
    final task = Task(
      id: 'rev10-occurrence-persistence-task',
      title: 'آزمون ماندگاری رخداد',
      checklist: const <String>['آماده‌سازی کیف', 'آماده‌کردن خوراکی'],
      checklistEnabled: true,
      checklistOccurrences: const <String, List<String>>{
        occurrenceKey: <String>['آماده‌سازی کیف'],
      },
      occurrenceHistory: const <String, Map<String, dynamic>>{
        occurrenceKey: <String, dynamic>{
          'scheduledDate': occurrenceKey,
          'status': 'completed',
          'completionDate': null,
          'result': null,
          'unknownStateField': <String, dynamic>{
            'source': 'rev10-fixture',
            'nested': <Object?>['keep', null, 17],
          },
        },
      },
      taskReminders: <TaskReminder>[
        TaskReminder(
          id: 'reminder-rev10-stable-01',
          title: 'یادآوری پایدار',
          date: DateTime(2026, 11, 20, 6),
          sequence: 1,
        ),
      ],
      nextReminderSequence: 2,
    );

    // Install #1 and initial file-backed write.
    var database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await TaskStore(executor: database).save(<Task>[task]);
      await G1DriftSchema.install(database); // Install #2 on the same file.
      final loaded = (await TaskStore(executor: database).load()).single;
      final expectedJson = task.toJson();
      final actualJson = loaded.toJson();
      for (final entry in expectedJson.entries) {
        expect(
          actualJson[entry.key],
          entry.value,
          reason: 'Persisted Task field changed: ${entry.key}',
        );
      }
      // Canonical decoding exposes model defaults in addition to the original
      // sparse constructor JSON. These are expected defaults, not data loss.
      expect(actualJson['notebookKind'], isNull);
      expect(actualJson['priority'], 'none');
      expect(actualJson['recurrence'], isNull);
      expect(actualJson['people'], isEmpty);
    } finally {
      await database.close();
    }

    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(0));

    // Install #3 after a real close/reopen with a fresh executor and Store.
    database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      final store = TaskStore(executor: database);
      final restored = (await store.load()).single;

      expect(restored.id, task.id);
      expect(restored.checklistOccurrences, task.checklistOccurrences);
      expect(restored.occurrenceHistory, task.occurrenceHistory);
      expect(restored.taskReminders.single.id, 'reminder-rev10-stable-01');

      final state = restored.occurrenceHistory[occurrenceKey]!;
      expect(state.containsKey('completionDate'), isTrue);
      expect(state['completionDate'], isNull);
      expect(state.containsKey('result'), isTrue);
      expect(state['result'], isNull);
      expect(state.containsKey('skippedReason'), isFalse);
      expect(state['unknownStateField'], <String, dynamic>{
        'source': 'rev10-fixture',
        'nested': <Object?>['keep', null, 17],
      });

      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
      expect(integrity.single.values.first, 'ok');
      expect(foreignKeys, isEmpty);

      final envelopeRows = await database.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        <Object?>[task.id],
      );
      expect(envelopeRows, hasLength(1));
      final envelope = jsonDecode(envelopeRows.single['legacy_payload_json'] as String)
          as Map<String, dynamic>;
      expect(envelope['occurrenceHistory'], task.toJson()['occurrenceHistory']);
      expect(envelope['checklistOccurrences'], task.toJson()['checklistOccurrences']);
    } finally {
      await database.close();
    }
  });
}
