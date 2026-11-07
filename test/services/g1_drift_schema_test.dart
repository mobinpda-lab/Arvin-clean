import 'dart:convert';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  test('creates the complete G1 relational schema', () async {
    await G1DriftSchema.install(database);

    final tables = await database.runSelect(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
      "ORDER BY name",
      const [],
    );

    final taskColumns = await database.runSelect(
      "PRAGMA table_info('tasks')",
      const [],
    );
    expect(
      taskColumns.map((row) => row['name']),
      contains('legacy_payload_json'),
    );

    final projectColumns = await database.runSelect(
      "PRAGMA table_info('projects')",
      const [],
    );
    expect(
      projectColumns.map((row) => row['name']),
      containsAll(<String>[
        'color_value',
        'is_archived',
        'legacy_payload_json',
      ]),
    );

    expect(
      tables.map((row) => row['name']),
      containsAll(<String>[
        'tasks',
        'follow_ups',
        'follow_up_records',
        'task_reminders',
        'persons',
        'follow_up_record_people',
        'projects',
        'project_items',
        'task_templates',
        'tags',
        'task_tags',
        'checklist_items',
        'task_people',
      ]),
    );

    final taskTemplateColumns = await database.runSelect(
      "PRAGMA table_info('task_templates')",
      const [],
    );
    expect(taskTemplateColumns.map((row) => row['name']), contains('checklist_enabled'));

    final foreignKeys = await database.runSelect(
      'PRAGMA foreign_keys',
      const [],
    );
    expect(foreignKeys.single['foreign_keys'], 1);
  });

  test('materializes multiple Task reminders, historical Follow-ups and Persons canonically', () async {
    await G1DriftSchema.install(database);
    final payload = <String, dynamic>{
      'id': 'canonical-task',
      'title': 'کار کانونی',
      'taskReminders': <Map<String, dynamic>>[
        {
          'id': 'reminder-one',
          'title': 'یادآور اول',
          'date': '2026-11-08T09:00:00.000',
          'isAllDay': false,
          'sequence': 1,
        },
        {
          'id': 'reminder-two',
          'title': 'یادآور دوم',
          'date': '2026-11-09T00:00:00.000',
          'isAllDay': true,
          'sequence': 2,
        },
      ],
      'followUps': <dynamic>[],
    };
    await database.runInsert(
      '''INSERT INTO tasks
         (id, title, description, follow_up_enabled, priority, archived, trashed,
          completed, legacy_payload_json)
         VALUES (?, ?, '', 0, 'none', 0, 0, 0, ?)''',
      <Object?>['canonical-task', jsonEncode(payload)],
    );
    await database.runCustom(
      '''INSERT INTO follow_ups
         (id, task_id, date_time, note, reminder_date, next_follow_up, completed, ordinal)
         VALUES ('legacy-follow-up', 'canonical-task', '2026-11-06T12:00:00.000',
                 'سابقه تاریخی', '2026-11-07T09:00:00.000',
                 '2026-11-10T09:00:00.000', 1, 0)''',
    );
    await database.runCustom(
      '''INSERT INTO people (id, name, created_at, updated_at)
         VALUES ('person-1', 'شخص یک', '2026-11-01', '2026-11-01')''',
    );
    await database.runCustom(
      '''INSERT INTO follow_up_people (follow_up_id, person_id, ordinal)
         VALUES ('legacy-follow-up', 'person-1', 0)''',
    );

    await G1DriftSchema.migrateCanonicalEntities(database);

    final reminders = await database.runSelect(
      'SELECT id, is_all_day FROM task_reminders WHERE task_id = ? ORDER BY sequence',
      <Object?>['canonical-task'],
    );
    expect(reminders.map((row) => row['id']), ['reminder-one', 'reminder-two']);
    expect(reminders.map((row) => row['is_all_day']), [0, 1]);

    final records = await database.runSelect(
      'SELECT id, completed_at FROM follow_up_records WHERE task_id = ?',
      <Object?>['canonical-task'],
    );
    expect(records, hasLength(1));
    expect(records.single['completed_at'], '2026-11-06T12:00:00.000');

    final recordPeople = await database.runSelect(
      'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ?',
      <Object?>['legacy-follow-up'],
    );
    expect(recordPeople.single['person_id'], 'person-1');

    final personRows = await database.runSelect(
      'SELECT name FROM persons WHERE id = ?',
      <Object?>['person-1'],
    );
    expect(personRows.single['name'], 'شخص یک');

    final recordColumns = await database.runSelect(
      "PRAGMA table_info('follow_up_records')",
      const [],
    );
    expect(recordColumns.map((row) => row['name']), isNot(contains('next_follow_up')));
    expect(recordColumns.map((row) => row['name']), isNot(contains('reminder_date')));
  });

  test('concurrent stores share one serialized schema installation', () async {
    await Future.wait([
      G1DriftSchema.install(database),
      G1DriftSchema.install(database),
      G1DriftSchema.install(database),
      G1DriftSchema.install(database),
    ]);
    final templates = await database.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'task_templates'",
      const [],
    );
    expect(templates, hasLength(1));
  });

  test('schema installation is idempotent', () async {
    await G1DriftSchema.install(database);
    await G1DriftSchema.install(database);

    final taskTable = await database.runSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'tasks'",
      const [],
    );
    expect(taskTable, hasLength(1));
  });

  test('follow-up ordering and relationship duplicates fail closed', () async {
    await G1DriftSchema.install(database);

    await database.runCustom(
      "INSERT INTO tasks "
      "(id, title, description, follow_up_enabled, priority, archived, trashed, completed) "
      "VALUES ('task-1', 'عنوان', '', 1, 'none', 0, 0, 0)",
    );

    await database.runCustom(
      "INSERT INTO follow_ups "
      "(id, task_id, date_time, note, completed, ordinal) "
      "VALUES ('fu-1', 'task-1', '2026-09-22T10:00:00Z', 'اول', 0, 0)",
    );

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_ups "
        "(id, task_id, date_time, note, completed, ordinal) "
        "VALUES ('fu-2', 'task-1', '2026-09-22T11:00:00Z', 'تکراری', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );

    final ordered = await database.runSelect(
      'SELECT ordinal FROM follow_ups WHERE task_id = ? ORDER BY ordinal',
      <Object?>['task-1'],
    );
    expect(ordered.single['ordinal'], 0);
  });

  test('foreign-key references prevent orphan relationship rows', () async {
    await G1DriftSchema.install(database);

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_ups "
        "(id, task_id, date_time, note, completed, ordinal) "
        "VALUES ('fu-orphan', 'missing', '2026-09-22T10:00:00Z', '', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );
  });
  test('upgrades an existing pre-taxonomy schema without losing task data', () async {
    await database.ensureOpen(G1DriftSchema());
    await database.runCustom("CREATE TABLE tasks (id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL, updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL, follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL, reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL, trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL)");
    await database.runCustom("INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES ('legacy-task', 'قدیمی', '', 0, 'none', 0, 0, 1)");
    await G1DriftSchema.install(database);
    final taxonomyTables = await database.runSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'taxonomy_categories'", const []);
    expect(taxonomyTables, hasLength(1));
    final tasks = await database.runSelect("SELECT id, title FROM tasks WHERE id = ?", <Object?>['legacy-task']);
    expect(tasks, hasLength(1));
    expect(tasks.single['title'], 'قدیمی');
    final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
    expect(columns.map((row) => row['name']), containsAll(<String>['legacy_payload_json', 'completed_at']));
    final migratedTask = await database.runSelect('SELECT completed, completed_at FROM tasks WHERE id = ?', <Object?>['legacy-task']);
    expect(migratedTask.single['completed'], 1);
    // A pre-timestamp completed task stays unknown; migration must not invent a time.
    expect(migratedTask.single['completed_at'], isNull);
  });
}
