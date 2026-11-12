import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/sql_task_migration_writer.dart';
import 'package:arvin/services/task_store.dart';

void main() {
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
      [{
        "id":"persist-task",
        "title":"پیگیری قرارداد",
        "futureTaskField":{"retain":true},
        "followUpEnabled":false,
        "followUpDate":null,
        "reminderDate":null,
        "taskReminders":[
          {"id":"reminder-1","title":"یادآور اول","date":"2026-10-01T08:00:00.000Z","sequence":1,"isEnabled":false},
          {"id":"reminder-2","title":"یادآور دوم","date":"2026-10-02T08:00:00.000Z","sequence":2,"isEnabled":true}
        ],
        "followUps":[
          {"id":"history-1","dateTime":"2026-09-21T10:00:00.000Z","title":"تماس اول","note":"شرح اول","result":"منتظر پاسخ","completed":true,"waitingForResponse":true,"personIds":["person-1","person-2"],"futureFollowUpField":{"retain":true}},
          {"id":"history-2","dateTime":"2026-09-22T11:30:00.000Z","title":"تماس دوم","note":"شرح دوم","result":"پاسخ دریافت شد","completed":false,"waitingForResponse":false,"personIds":["person-3"]}
        ]
      }]
    ''';
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('arvin.tasks', raw);

    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );
    await database.close();

    database = NativeDatabase(databaseFile);
    var store = TaskStore(executor: database);

    void verifyRoundTrip(List<Task> tasks) {
      expect(tasks, hasLength(1));
      final task = tasks.single;
      final history = task.followUps;
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
      expect(task.taskReminders.map((item) => item.id), [
        'reminder-1',
        'reminder-2',
      ]);
      expect(task.taskReminders.map((item) => item.sequence), [1, 2]);
      expect(task.taskReminders.map((item) => item.isEnabled), [false, true]);
      expect(task.legacyFollowUpMetadata['taskLevel'], {
        'followUpEnabled': false,
        'followUpDate': null,
        'reminderDate': null,
      });
      final legacyMetadata = task.legacyFollowUpMetadata;
      expect(legacyMetadata['unknownFields'], {
        'futureTaskField': {'retain': true},
      });
      final legacyFollowUps = legacyMetadata['followUps'] as List;
      final preservedFollowUp = legacyFollowUps.whereType<Map>().singleWhere(
        (item) => item['id'] == 'history-1',
      );
      expect(preservedFollowUp['futureFollowUpField'], isA<Map>());
      expect(
        (preservedFollowUp['futureFollowUpField'] as Map)['retain'],
        isTrue,
      );
    }

    var reopenedTasks = await store.load();
    verifyRoundTrip(reopenedTasks);
    // Five independent save -> close -> reopen -> load cycles. Every cycle
    // validates Follow-up IDs/order/person links, Reminder identity/order and
    // the opaque Missing/NULL/boolean and future-field compatibility payload.
    for (var cycle = 1; cycle <= 5; cycle++) {
      await store.save(reopenedTasks);
      await database.close();
      database = NativeDatabase(databaseFile);
      store = TaskStore(executor: database);
      reopenedTasks = await store.load();
      verifyRoundTrip(reopenedTasks);
    }

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
