import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        'completed': false,
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
}
