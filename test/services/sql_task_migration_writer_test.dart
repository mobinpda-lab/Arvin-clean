import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/sql_task_migration_writer.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_migration_adapter.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  group('diagnostic diff semantics', () {
    test('classifies a key present only in Actual as extra_in_actual', () {
      final diff = _diagnosticDiff(
        <String, dynamic>{'actualOnly': false},
        <String, dynamic>{},
      );
      expect(diff['extra_in_actual'], ['actualOnly']);
      expect(diff['missing_from_actual'], isEmpty);
      expect(diff['changed_values'], isEmpty);
    });

    test('distinguishes absent from an explicitly null value', () {
      final diff = _diagnosticDiff(
        <String, dynamic>{},
        <String, dynamic>{'explicitNull': null},
      );
      expect(diff['extra_in_actual'], isEmpty);
      expect(diff['missing_from_actual'], ['explicitNull']);
      expect(diff['changed_values'], isEmpty);
    });

    test('preserves false and detects false versus null as changed', () {
      final diff = _diagnosticDiff(
        <String, dynamic>{'flag': false},
        <String, dynamic>{'flag': null},
      );
      expect(diff['extra_in_actual'], isEmpty);
      expect(diff['missing_from_actual'], isEmpty);
      expect(diff['changed_values'], {
        'flag': {'actual': false, 'expected': null},
      });
    });
  });

  late NativeDatabase database;

  setUp(() async {
    database = NativeDatabase.memory();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await database.close();
  });

  test('migrates tasks, relations, and the original JSON envelope', () async {
    final raw = jsonEncode([
      {
        'id': 'legacy-1',
        'title': 'تماس',
        'description': 'قرارداد',
        'createdAt': '2026-09-20T10:00:00Z',
        'followUpEnabled': true,
        'followUps': [
          {
            'id': 'fu-1',
            'dateTime': '2026-09-21T10:00:00Z',
            'note': 'تماس شد',
            'result': 'منتظر پاسخ',
            'completed': false,
          }
        ],
        'tags': ['مهم', 'مشتری'],
        'category': 'فروش',
        'checklist': ['ارسال قرارداد', 'تماس مجدد'],
        'people': [
          {'id': 'person-1', 'displayName': 'مشتری'},
        ],
        'archived': false,
        'trashed': false,
        'completed': true,
        'completedAt': '2026-09-22T12:30:00Z',
        'futureField': {'keep': true},
      }
    ]);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    final report = await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    expect(report.sourceCount, 1);
    expect(report.insertedCount, 1);
    expect(report.skippedExistingCount, 0);
    expect(report.sqlTaskCount, 1);

    final task = (await database.runSelect(
      'SELECT * FROM tasks WHERE id = ?',
      const ['legacy-1'],
    )).single;
    expect(task['title'], 'تماس');
    expect(task['completed'], 1);
    expect(
      DateTime.parse(task['completed_at'] as String),
      DateTime.parse('2026-09-22T12:30:00Z'),
    );
    expect(task['legacy_payload_json'], isNotNull);

    final restoredEnvelope =
        jsonDecode(task['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(restoredEnvelope['futureField'], {'keep': true});

    final followUps = await database.runSelect(
      'SELECT task_id, note, result, ordinal FROM follow_up_records WHERE task_id = ?',
      const ['legacy-1'],
    );
    expect(followUps.single['note'], 'تماس شد');
    expect(followUps.single['result'], 'منتظر پاسخ');

    final checklist = await database.runSelect(
      'SELECT value, ordinal FROM checklist_items WHERE task_id = ? ORDER BY ordinal',
      const ['legacy-1'],
    );
    expect(checklist.map((row) => row['value']), ['ارسال قرارداد', 'تماس مجدد']);

    final people = await database.runSelect(
      '''SELECT task_persons.person_id, persons.name
         FROM task_persons
         JOIN persons ON persons.id = task_persons.person_id
         WHERE task_persons.task_id = ?''',
      const ['legacy-1'],
    );
    expect(people.single['person_id'], 'person-1');
    // The migrated display name must match the exact source input.
    expect(people.single['name'], 'مشتری');

    final tags = await database.runSelect(
      '''SELECT tags.name
         FROM task_tags
         JOIN tags ON tags.id = task_tags.tag_id
         WHERE task_tags.task_id = ?
         ORDER BY task_tags.ordinal''',
      const ['legacy-1'],
    );
    expect(tags.map((row) => row['name']), ['مهم', 'مشتری']);
  });

  test('successful migration leaves the legacy JSON byte-for-byte unchanged', () async {
    const raw = '[{"id":"preserve-1","title":"قدیمی","followUps":[{"id":"history-1","dateTime":"2026-09-21T10:00:00Z","note":"تاریخچه"}]}]';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    expect(preferences.getString('arvin.tasks'), raw);
  });

  test('failed migration leaves the complete legacy document unchanged', () async {
    const raw = '[{"id":"task-a","title":"اول","followUps":[{"id":"same-follow-up","dateTime":"2026-09-21T10:00:00Z"}]},{"id":"task-b","title":"دوم","followUps":[{"id":"same-follow-up","dateTime":"2026-09-21T11:00:00Z"}]}]';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    await expectLater(
      const SqlTaskMigrationWriter().migrateFromPreferences(
        executor: database,
        preferences: preferences,
      ),
      throwsA(anything),
    );

    expect(preferences.getString('arvin.tasks'), raw);
    final tasks = await database.runSelect(
      'SELECT COUNT(*) AS count FROM tasks',
      const [],
    );
    expect(tasks.single['count'], 0);
  });

  test('re-running the same migration is idempotent', () async {
    final raw = '[{"id":"same-1","title":"یک بار"}]';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    final writer = const SqlTaskMigrationWriter();
    final first = await writer.migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );
    final second = await writer.migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    expect(first.insertedCount, 1);
    expect(second.insertedCount, 0);
    expect(second.skippedExistingCount, 1);

    final count = await database.runSelect(
      'SELECT COUNT(*) AS count FROM tasks',
      const [],
    );
    expect(count.single['count'], 1);
  });

  test('stores Recurrence rules in relational SQL rather than Task JSON', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', jsonEncode([
      {
        'id': 'recurrence-task',
        'title': 'کار زمان‌بندی‌شده',
        'recurrence': {
          'frequency': 'weekly',
          'interval': 2,
          'startDate': '2026-10-01T08:00:00.000Z',
          'endDate': '2026-12-01T08:00:00.000Z',
          'count': 5,
          'active': true,
          'trackingLevel': 'tracking',
        },
      },
    ]));

    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    final rule = (await database.runSelect(
      'SELECT frequency, interval, start_date, end_date, occurrence_count, active, tracking_level '
      'FROM task_recurrence_rules WHERE task_id = ?',
      const ['recurrence-task'],
    )).single;
    expect(rule['frequency'], 'weekly');
    expect(rule['interval'], 2);
    expect(rule['occurrence_count'], 5);
    expect(rule['tracking_level'], 'tracking');

    final taskRow = (await database.runSelect(
      'SELECT recurrence_json, legacy_payload_json FROM tasks WHERE id = ?',
      const ['recurrence-task'],
    )).single;
    expect(taskRow['recurrence_json'], isNull);
    final envelope = jsonDecode(taskRow['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(envelope.containsKey('recurrence'), isFalse);

    final loaded = await TaskStore(executor: database).load();
    expect(loaded.single.recurrence?.frequency.name, 'weekly');
    expect(loaded.single.recurrence?.interval, 2);
    expect(loaded.single.recurrence?.trackingLevel.name, 'tracking');
    await TaskStore(executor: database).save(loaded);
    final afterSave = await database.runSelect(
      'SELECT task_id, frequency FROM task_recurrence_rules WHERE task_id = ?',
      const ['recurrence-task'],
    );
    expect(afterSave.single['frequency'], 'weekly');
  });

  test('migrates Occurrence history and per-Occurrence checklists into relational SQL', () async {
    const first = '2026-10-01T08:00:00.000Z';
    const second = '2026-10-02T08:00:00.000Z';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', jsonEncode([
      {
        'id': 'occurrence-task',
        'title': 'کار تکرارشونده',
        'occurrenceHistory': {
          first: {
            'scheduledDate': first,
            'status': 'completed',
            'completionDate': '2026-10-01T08:30:00.000Z',
            'result': 'انجام شد',
          },
          second: {
            'scheduledDate': second,
            'status': 'skipped',
            'result': 'تعطیل بود',
          },
        },
        'checklistOccurrences': {
          first: ['[x] مرحله اول', '[ ] مرحله دوم'],
          second: ['[ ] مرحله اول'],
        },
      },
    ]));

    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    final occurrences = await database.runSelect(
      'SELECT scheduled_at, status, completed_at, result FROM task_occurrences '
      'WHERE task_id = ? ORDER BY ordinal',
      const ['occurrence-task'],
    );
    expect(occurrences, hasLength(2));
    expect(occurrences[0]['scheduled_at'], first);
    expect(occurrences[0]['status'], 'completed');
    expect(occurrences[0]['completed_at'], '2026-10-01T08:30:00.000Z');
    expect(occurrences[1]['status'], 'skipped');
    expect(occurrences[1]['result'], 'تعطیل بود');

    final checklistRows = await database.runSelect(
      'SELECT o.scheduled_at, c.ordinal, c.value FROM task_occurrences o '
      'JOIN occurrence_checklist_items c ON c.occurrence_id = o.id '
      'WHERE o.task_id = ? ORDER BY o.ordinal, c.ordinal',
      const ['occurrence-task'],
    );
    expect(checklistRows.map((row) => row['value']), [
      '[x] مرحله اول',
      '[ ] مرحله دوم',
      '[ ] مرحله اول',
    ]);

    final storedEnvelope = (await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const ['occurrence-task'],
    )).single;
    final envelope = jsonDecode(storedEnvelope['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(envelope.containsKey('occurrenceHistory'), isFalse);
    expect(envelope.containsKey('checklistOccurrences'), isFalse);

    final store = TaskStore(executor: database);
    final loaded = await store.load();
    expect(loaded.single.occurrenceHistory[first]?['status'], 'completed');
    expect(loaded.single.occurrenceHistory[second]?['status'], 'skipped');
    expect(loaded.single.checklistOccurrences[first], ['[x] مرحله اول', '[ ] مرحله دوم']);
    await store.save(loaded);
    final reopened = await store.load();
    expect(reopened.single.checklistOccurrences[second], ['[ ] مرحله اول']);
  });

  test('same ID with different content is a conflict and never skipped', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks','[{"id":"conflict-task","title":"نسخه منبع","futureField":{"version":1}}]');
    final writer=const SqlTaskMigrationWriter();
    await writer.migrateFromPreferences(executor:database,preferences:preferences);
    await database.runUpdate('UPDATE tasks SET title=? WHERE id=?',const ['نسخه مقصد متفاوت','conflict-task']);
    await expectLater(writer.migrateFromPreferences(executor:database,preferences:preferences),throwsA(isA<StateError>()));
    final row=(await database.runSelect('SELECT title FROM tasks WHERE id=?',const ['conflict-task'])).single;
    expect(row['title'],'نسخه مقصد متفاوت');
  });

  test('transaction rolls back all rows when one relation violates SQL constraints',
      () async {
    final raw = jsonEncode([
      {
        'id': 'task-a',
        'title': 'اول',
        'followUps': [
          {
            'id': 'same-follow-up',
            'dateTime': '2026-09-21T10:00:00Z',
            'note': 'اول',
          }
        ],
      },
      {
        'id': 'task-b',
        'title': 'دوم',
        'followUps': [
          {
            'id': 'same-follow-up',
            'dateTime': '2026-09-21T11:00:00Z',
            'note': 'دوم',
          }
        ],
      }
    ]);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    await expectLater(
      const SqlTaskMigrationWriter().migrateFromPreferences(
        executor: database,
        preferences: preferences,
      ),
      throwsA(anything),
    );

    final tasks = await database.runSelect(
      'SELECT COUNT(*) AS count FROM tasks',
      const [],
    );
    final followUps = await database.runSelect(
      'SELECT COUNT(*) AS count FROM follow_up_records',
      const [],
    );
    expect(tasks.single['count'], 0);
    expect(followUps.single['count'], 0);
  });


  test('round-trips canonical task JSON, IDs, order, and follow-up history through TaskStore', () async {
    final source = <Map<String, dynamic>>[
      {
        'id': 'roundtrip-1',
        'title': 'اول',
        'description': 'شرح اول',
        'createdAt': '2026-09-20T10:00:00.000Z',
        'dueDate': '2026-09-22T10:00:00.000Z',
        'followUpEnabled': true,
        'followUps': [
          {
            'id': 'history-1',
            'dateTime': '2026-09-21T10:00:00.000Z',
            'note': 'پیگیری اول',
            'result': 'منتظر پاسخ',
            'completed': false,
          },
          {
            'id': 'history-2',
            'dateTime': '2026-09-22T10:00:00.000Z',
            'note': 'پیگیری دوم',
            'result': 'پاسخ دریافت شد',
            'completed': true,
          },
        ],
        'tags': ['مهم', 'مشتری'],
        'category': 'فروش',
        'checklist': ['مرحله ۱', 'مرحله ۲'],
        'archived': false,
        'trashed': false,
        'completed': false,
      },
      {
        'id': 'roundtrip-2',
        'title': 'دوم',
        'description': 'شرح دوم',
        'followUps': [],
        'tags': ['بعدی'],
        'completed': true,
      },
    ];
    final raw = jsonEncode(source);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    final loaded = await TaskStore(executor: database).load();
    expect(loaded.map((task) => task.id), ['roundtrip-1', 'roundtrip-2']);
    expect(loaded.map((task) => task.toJson()), [
      Task.fromJson(source[0]).toJson(),
      Task.fromJson(source[1]).toJson(),
    ]);
    expect(loaded.first.followUps.map((item) => item.id), [
      'history-1',
      'history-2',
    ]);
    expect(loaded.first.followUps.map((item) => item.note), [
      'پیگیری اول',
      'پیگیری دوم',
    ]);
  });

  test('preserves complete Follow-up history across closing and reopening SQLite', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-follow-up-reopen-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    await database.close();
    database = NativeDatabase(databaseFile);

    const raw = '''
      [{"id":"persist-task","title":"پیگیری قرارداد","followUps":[
        {"id":"history-1","dateTime":"2026-09-21T10:00:00.000Z","title":"تماس اول","note":"شرح اول","result":"منتظر پاسخ","completed":true,"waitingForResponse":true,"personIds":["person-1","person-2"]},
        {"id":"history-2","dateTime":"2026-09-22T11:30:00.000Z","title":"تماس دوم","note":"شرح دوم","result":"پاسخ دریافت شد","completed":false,"waitingForResponse":false,"personIds":["person-3"]}
      ]}]
    ''';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    // Diagnostic-only interception: capture the real tasks row returned by
    // SQLite immediately before the existing envelope parity assertion.
    // No production code, schema, migration, or assertion is changed.
    final decodedLegacy =
        Map<String, dynamic>.from((jsonDecode(raw) as List).single as Map);
    final diagnosticRecord =
        const TaskMigrationAdapter().recordFromLegacyJson(decodedLegacy);
    final expectedEnvelope = _diagnosticStorageEnvelope(diagnosticRecord);
    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );

    await database.close();

    database = NativeDatabase(databaseFile);
    // NativeDatabase opens lazily. Initialize the reopened executor through
    // the same schema owner before issuing direct diagnostic SQL queries.
    await G1DriftSchema.install(database);
    final baselineTaskRows = await database.runSelect(
      'SELECT * FROM tasks WHERE id = ?',
      const ['persist-task'],
    );
    final baselineFollowUpRows = await database.runSelect(
      'SELECT * FROM follow_up_records WHERE task_id = ? ORDER BY ordinal',
      const ['persist-task'],
    );
    final capture = _PersistTaskEnvelopeCapture();
    final interceptedReopenExecutor = database.interceptWith(capture);
    Object? reopenError;
    StackTrace? reopenStack;
    List<Task> reopenedTasks = const <Task>[];
    try {
      reopenedTasks =
          await TaskStore(executor: interceptedReopenExecutor).load();
    } catch (error, stackTrace) {
      reopenError = error;
      reopenStack = stackTrace;
    }

    final actualRow = capture.actualTaskRow;
    final actualRaw = actualRow?['legacy_payload_json'];
    final actualEnvelope = actualRaw is String
        ? Map<String, dynamic>.from(jsonDecode(actualRaw) as Map)
        : null;
    final expectedBeforeNormalization =
        Map<String, dynamic>.from(expectedEnvelope);
    final actualBeforeNormalization = actualEnvelope == null
        ? null
        : Map<String, dynamic>.from(actualEnvelope);
    final actualAfterNormalization = actualEnvelope == null
        ? null
        : _diagnosticNormalizeEnvelope(actualEnvelope);
    final expectedAfterNormalization =
        _diagnosticNormalizeEnvelope(expectedEnvelope);

    print('ARVIN_ENVELOPE_FORENSICS_BEGIN task=persist-task phase=reopen');
    print('ORIGINAL_LEGACY_JSON:');
    print(const JsonEncoder.withIndent('  ').convert(jsonDecode(raw)));
    print('DECODER_OUTPUT:');
    print(const JsonEncoder.withIndent('  ').convert(diagnosticRecord.task.toJson()));
    print('TASK_TO_JSON:');
    print(const JsonEncoder.withIndent('  ').convert(diagnosticRecord.task.toJson()));
    print('SOURCE_ENVELOPE:');
    print(const JsonEncoder.withIndent('  ').convert(diagnosticRecord.sourceJson));
    print('EXPECTED_SQL_ENVELOPE:');
    print(const JsonEncoder.withIndent('  ').convert(expectedBeforeNormalization));
    print('ACTUAL_SQL_QUERY: SELECT * FROM tasks WHERE id = ? [persist-task]');
    print('ACTUAL_SQL_ROW_SOURCE: ${capture.actualTaskRow == null ? 'NOT_CAPTURED' : 'SQLITE_QUERY_RESULT'}');
    print('ACTUAL_SQL_ROW:');
    print(actualRow == null
        ? 'UNKNOWN: no SELECT * row captured during reopened TaskStore.load'
        : const JsonEncoder.withIndent('  ').convert(actualRow));
    print('ACTUAL_SQL_ENVELOPE:');
    print(actualEnvelope == null
        ? 'UNKNOWN: legacy_payload_json unavailable'
        : const JsonEncoder.withIndent('  ').convert(actualEnvelope));
    print('DIFF_BEFORE_NORMALIZATION:');
    print(_diagnosticDiff(actualBeforeNormalization, expectedBeforeNormalization));
    print('ACTUAL_ENVELOPE_AFTER_NORMALIZATION:');
    print(actualAfterNormalization == null
        ? 'UNKNOWN'
        : const JsonEncoder.withIndent('  ').convert(actualAfterNormalization));
    print('EXPECTED_ENVELOPE_AFTER_NORMALIZATION:');
    print(const JsonEncoder.withIndent('  ').convert(expectedAfterNormalization));
    print('DIFF_AFTER_NORMALIZATION:');
    print(_diagnosticDiff(actualAfterNormalization, expectedAfterNormalization));
    print('ROLLBACK_REQUESTED: ${capture.rollbackRequested}');
    print('ROLLBACK_EXECUTION_RESULT: ${capture.rollbackExecutionResult}');
    final rollbackVerified = capture.rollbackRequested &&
            capture.rollbackExecutionResult == 'SUCCESS' &&
            baselineTaskRows.length == 1
        ? await _verifyDiagnosticRollback(
            database,
            Map<String, Object?>.from(baselineTaskRows.single),
            baselineFollowUpRows
                .map((row) => Map<String, Object?>.from(row))
                .toList(growable: false),
          )
        : null;
    print('ROLLBACK_VERIFIED: ${rollbackVerified == null ? 'NOT_VERIFIED' : rollbackVerified ? 'PASS' : 'FAIL'}');
    if (reopenError != null) {
      print('REOPEN_ERROR: $reopenError');
      print('REOPEN_STACK: $reopenStack');
    }
    print('ARVIN_ENVELOPE_FORENSICS_END');
    if (reopenError != null) {
      Error.throwWithStackTrace(reopenError, reopenStack!);
    }

    expect(reopenedTasks, hasLength(1));
    final history = reopenedTasks.single.followUps;
    expect(history, hasLength(2));
    expect(history.map((item) => item.id), ['history-1', 'history-2']);
    expect(history.map((item) => item.dateTime), [
      DateTime.parse('2026-09-21T10:00:00.000Z'),
      DateTime.parse('2026-09-22T11:30:00.000Z'),
    ]);
    expect(history.map((item) => item.title), ['تماس اول', 'تماس دوم']);
    expect(history.map((item) => item.note), ['شرح اول', 'شرح دوم']);
    expect(history.map((item) => item.result), ['منتظر پاسخ', 'پاسخ دریافت شد']);
    expect(history.map((item) => item.completed), [true, false]);
    expect(history.map((item) => item.waitingForResponse), [true, false]);
    expect(history.map((item) => item.personIds), [
      ['person-1', 'person-2'],
      ['person-3'],
    ]);

    await database.close();
    database = NativeDatabase.memory();
    await directory.delete(recursive: true);
  });


  test('setCompleted true-false-true survives closing and reopening the same SQLite file', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-follow-up-cycle-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    await database.close();
    database = NativeDatabase(databaseFile);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', '[]');

    var store = TaskStore(executor: database);
    const originalTaskId = 'completion-cycle-task';
    const targetFollowUpId = 'completion-cycle-history';
    final originalTarget = FollowUp(
      id: targetFollowUpId,
      dateTime: DateTime.utc(2026, 9, 21, 10),
      title: 'تماس با مشتری',
      note: 'شرح تاریخی کامل',
      result: 'منتظر پاسخ',
      reminderDate: DateTime.utc(2026, 9, 22, 9),
      nextFollowUp: DateTime.utc(2026, 9, 23, 10),
      completed: false,
      waitingForResponse: true,
      personIds: const ['person-1', 'person-2'],
    );
    final sibling = FollowUp(
      id: 'completion-cycle-sibling',
      dateTime: DateTime.utc(2026, 9, 20, 9),
      title: 'سابقه دیگر',
      note: 'نباید تغییر کند',
      result: 'ثبت شد',
      completed: true,
      waitingForResponse: false,
      personIds: const ['person-3'],
    );
    await store.save([
      Task(
        id: originalTaskId,
        title: 'Task آزمایش چرخه تکمیل',
        dueDate: DateTime.utc(2026, 10, 1, 12),
        followUps: [originalTarget, sibling],
        taskReminders: [
          TaskReminder(
            id: 'completion-cycle-reminder',
            title: 'یادآور مستقل',
            date: DateTime.utc(2026, 9, 24, 8),
            sequence: 1,
          ),
        ],
      ),
    ]);

    Future<TaskStore> reopenStore() async {
      database = NativeDatabase(databaseFile);
      final reopenedStore = TaskStore(executor: database);
      final tasks = await reopenedStore.load();
      expect(tasks, hasLength(1));
      expect(tasks.single.id, originalTaskId);
      return reopenedStore;
    }

    store = await reopenStore();
    var repository = FollowUpRepository(store: store);
    for (final expectedCompleted in const [true, false, true]) {
      final changed = await repository.setCompleted(
        originalTaskId,
        targetFollowUpId,
        expectedCompleted,
      );
      expect(changed.completed, expectedCompleted);

      await database.close();
      store = await reopenStore();
      repository = FollowUpRepository(store: store);

      final persistedTasks = await store.load();
      final persistedTask = persistedTasks.single;
      expect(persistedTask.id, originalTaskId);
      expect(persistedTask.dueDate, DateTime.utc(2026, 10, 1, 12));
      expect(persistedTask.taskReminders, hasLength(1));
      expect(persistedTask.taskReminders.single.id, 'completion-cycle-reminder');

      final history = persistedTask.followUps;
      expect(history, hasLength(2));
      final persistedTarget = history.singleWhere((item) => item.id == targetFollowUpId);
      expect(persistedTarget.completed, expectedCompleted);
      expect(persistedTarget.id, originalTarget.id);
      expect(persistedTarget.dateTime, originalTarget.dateTime);
      expect(persistedTarget.title, originalTarget.title);
      expect(persistedTarget.note, originalTarget.note);
      expect(persistedTarget.result, originalTarget.result);
      expect(persistedTarget.toJson().containsKey('reminderDate'), isFalse);
      expect(persistedTarget.toJson().containsKey('nextFollowUp'), isFalse);
      expect(persistedTarget.waitingForResponse, originalTarget.waitingForResponse);
      expect(persistedTarget.personIds, originalTarget.personIds);
      expect(
        history.singleWhere((item) => item.id == sibling.id).toJson(),
        sibling.toJson(),
      );

      final sqlCompleted = await database.runSelect(
        'SELECT completed FROM follow_up_records WHERE id = ? AND task_id = ?',
        const [targetFollowUpId, originalTaskId],
      );
      expect(sqlCompleted, hasLength(1));
      expect(sqlCompleted.single['completed'], expectedCompleted ? 1 : 0);
    }

    await database.close();
    database = NativeDatabase.memory();
    await directory.delete(recursive: true);
  });
}

// Test-only SQL interception for COMMAND 06. Captures the actual row returned
// by SQLite before parity validation throws and the migration rolls back.
class _PersistTaskEnvelopeCapture extends QueryInterceptor {
  Map<String, Object?>? actualTaskRow;
  bool rollbackRequested = false;
  String rollbackExecutionResult = 'NOT_REQUESTED';

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final rows = await executor.runSelect(statement, args);
    if (statement.trim().toLowerCase() ==
            'select * from tasks where id = ?' &&
        args.isNotEmpty &&
        args.first == 'persist-task' &&
        rows.isNotEmpty) {
      actualTaskRow = Map<String, Object?>.from(rows.single);
    }
    return rows;
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    if (statement.trim().toUpperCase() == 'ROLLBACK') {
      rollbackRequested = true;
      try {
        await executor.runCustom(statement, args);
        rollbackExecutionResult = 'SUCCESS';
      } catch (error) {
        rollbackExecutionResult = 'FAILURE: $error';
        rethrow;
      }
      return;
    }
    await executor.runCustom(statement, args);
  }
}

const Set<String> _diagnosticSqlOwnedTaskKeys = <String>{
  'id', 'title', 'description', 'createdAt', 'updatedAt', 'dueDate',
  'category', 'notebookKind', 'priority', 'archived', 'trashed',
  'completed', 'completedAt', 'isFavorite', 'tags', 'checklist',
  'followUps', 'people', 'taskReminders', 'recurrence',
  'occurrenceHistory', 'checklistOccurrences',
};

Map<String, dynamic> _diagnosticStorageEnvelope(TaskMigrationRecord record) {
  final canonical = Map<String, dynamic>.from(record.task.toJson());
  for (final key in _diagnosticSqlOwnedTaskKeys) {
    canonical.remove(key);
  }
  final known = <String>{
    ...record.task.toJson().keys,
    ..._diagnosticSqlOwnedTaskKeys,
    'legacyTaskReminderMigrationVersion',
  };
  final unknown = <String, dynamic>{
    for (final entry in record.sourceJson.entries)
      if (!known.contains(entry.key)) entry.key: entry.value,
  };
  return <String, dynamic>{...unknown, ...canonical};
}

Map<String, dynamic> _diagnosticNormalizeEnvelope(
  Map<String, dynamic> envelope,
) {
  final normalized = Map<String, dynamic>.from(envelope);
  for (final key in _diagnosticSqlOwnedTaskKeys) {
    normalized.remove(key);
  }
  normalized.remove('legacyTaskReminderMigrationVersion');
  return normalized;
}

Object? _diagnosticCanonicalize(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _diagnosticCanonicalize(value[key]),
    };
  }
  if (value is List) {
    return value.map(_diagnosticCanonicalize).toList(growable: false);
  }
  return value;
}

String _diagnosticCanonicalJson(Object? value) =>
    jsonEncode(_diagnosticCanonicalize(value));

Map<String, Object?> _diagnosticDiff(
  Map<String, dynamic>? actual,
  Map<String, dynamic> expected,
) {
  if (actual == null) return <String, Object?>{'status': 'UNKNOWN'};
  final keys = <String>{...actual.keys, ...expected.keys}.toList()..sort();
  final added = <String>[];
  final removed = <String>[];
  final changed = <String, Object?>{};
  for (final key in keys) {
    if (actual.containsKey(key) && !expected.containsKey(key)) {
      added.add(key);
    } else if (!actual.containsKey(key) && expected.containsKey(key)) {
      removed.add(key);
    } else if (actual.containsKey(key) &&
        expected.containsKey(key) &&
        _diagnosticCanonicalJson(actual[key]) !=
            _diagnosticCanonicalJson(expected[key])) {
      changed[key] = <String, Object?>{
        'actual': actual[key],
        'expected': expected[key],
      };
    }
  }
  return <String, Object?>{
    'extra_in_actual': added,
    'missing_from_actual': removed,
    'changed_values': changed,
  };
}


Future<bool> _verifyDiagnosticRollback(
  QueryExecutor executor,
  Map<String, Object?> baselineTaskRow,
  List<Map<String, Object?>> baselineFollowUpRows,
) async {
  final taskRows = await executor.runSelect(
    'SELECT * FROM tasks WHERE id = ?',
    const ['persist-task'],
  );
  final followUpRows = await executor.runSelect(
    'SELECT * FROM follow_up_records WHERE task_id = ? ORDER BY ordinal',
    const ['persist-task'],
  );
  return taskRows.length == 1 &&
      _diagnosticCanonicalJson(taskRows.single) ==
          _diagnosticCanonicalJson(baselineTaskRow) &&
      _diagnosticCanonicalJson(followUpRows) ==
          _diagnosticCanonicalJson(baselineFollowUpRows);
}
