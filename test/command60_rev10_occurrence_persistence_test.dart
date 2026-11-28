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

    final explicitOptionalTask = Task(
      id: 'rev10-explicit-optional-null-task',
      title: 'آزمون حفظ NULL و فیلد خالی',
      extensionData: const <String, dynamic>{
        'notebookKind': null,
        'priority': null,
        'recurrence': null,
        'people': <Object?>[],
      },
    );

    // Install #1 and initial file-backed write.
    var database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await TaskStore(executor: database).save(<Task>[task, explicitOptionalTask]);
      await G1DriftSchema.install(database); // Install #2 on the same file.
      final loadedTasks = await TaskStore(executor: database).load();
      final loaded = loadedTasks.singleWhere((value) => value.id == task.id);
      expect(loaded.toJson(), task.toJson());
      final loadedExplicitOptional = loadedTasks.singleWhere(
        (value) => value.id == explicitOptionalTask.id,
      );
      expect(loadedExplicitOptional.toJson(), explicitOptionalTask.toJson());
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
      final restoredTasks = await store.load();
      final restored = restoredTasks.singleWhere((value) => value.id == task.id);
      final restoredExplicitOptional = restoredTasks.singleWhere(
        (value) => value.id == explicitOptionalTask.id,
      );

      expect(restored.toJson(), task.toJson());
      expect(restoredExplicitOptional.toJson(), explicitOptionalTask.toJson());
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
