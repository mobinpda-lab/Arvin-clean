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
    expect(task['completed_at'], '2026-09-22T12:30:00Z');
    expect(task['legacy_payload_json'], isNotNull);

    final restoredEnvelope =
        jsonDecode(task['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(restoredEnvelope['futureField'], {'keep': true});

    final followUps = await database.runSelect(
      'SELECT task_id, note, result, ordinal FROM follow_ups WHERE task_id = ?',
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
      'SELECT person_id, person_json FROM task_people WHERE task_id = ?',
      const ['legacy-1'],
    );
    expect(people.single['person_id'], 'person-1');

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
      'SELECT COUNT(*) AS count FROM follow_ups',
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

    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: database,
      preferences: preferences,
    );
    await database.close();

    database = NativeDatabase(databaseFile);
    final reopenedTasks = await TaskStore(executor: database).load();
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
      expect(persistedTarget.reminderDate, originalTarget.reminderDate);
      expect(persistedTarget.nextFollowUp, originalTarget.nextFollowUp);
      expect(persistedTarget.waitingForResponse, originalTarget.waitingForResponse);
      expect(persistedTarget.personIds, originalTarget.personIds);
      expect(
        history.singleWhere((item) => item.id == sibling.id).toJson(),
        sibling.toJson(),
      );

      final sqlCompleted = await database.runSelect(
        'SELECT completed FROM follow_ups WHERE id = ? AND task_id = ?',
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
