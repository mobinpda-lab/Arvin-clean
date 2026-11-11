import 'dart:convert';
import 'dart:io';
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

  test('seeds pre-existing directory membership once and never resurrects deleted entries', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-person-directory-cutover-');
    final file = File('${directory.path}/arvin.sqlite');
    var first = NativeDatabase(file);
    await first.ensureOpen(G1DriftSchema());
    await first.runCustom(
      '''CREATE TABLE persons (
         id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
         created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
    );
    await first.runInsert(
      'INSERT INTO persons (id, name, created_at, updated_at) VALUES (?, ?, ?, ?)',
      const <Object?>['legacy-person', 'شخص قدیمی', '2026-11-01', '2026-11-01'],
    );
    await G1DriftSchema.install(first);
    final seeded = await first.runSelect('SELECT person_id FROM person_directory', const []);
    expect(seeded.map((row) => row['person_id']), ['legacy-person']);
    await first.runCustom('DELETE FROM person_directory');
    await first.close();

    final reopened = NativeDatabase(file);
    try {
      await G1DriftSchema.install(reopened);
      expect(await reopened.runSelect('SELECT person_id FROM person_directory', const []), isEmpty);
      final historical = await reopened.runSelect('SELECT id, name FROM persons WHERE id = ?', const ['legacy-person']);
      expect(historical.single['name'], 'شخص قدیمی');
    } finally {
      await reopened.close();
      await directory.delete(recursive: true);
    }
  });

  test('creates the complete G1 relational schema', () async {
    await G1DriftSchema.install(database);
    expect(G1DriftSchema.version, 17);

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
    expect(
      taskColumns.map((row) => row['name']),
      isNot(contains('follow_up_enabled')),
    );
    expect(taskColumns.map((row) => row['name']), isNot(contains('follow_up_date')));
    expect(taskColumns.map((row) => row['name']), isNot(contains('reminder_date')));


    final projectColumns = await database.runSelect(
      "PRAGMA table_info('projects')",
      const [],
    );
    expect(
      projectColumns.map((row) => row['name']),
      containsAll(<String>[
        'storage_ordinal',
        'color_value',
        'is_archived',
        'legacy_payload_json',
      ]),
    );

    expect(
      tables.map((row) => row['name']),
      containsAll(<String>[
        'tasks',
        'follow_up_records',
        'task_reminders',
        'persons',
        'person_directory',
        'follow_up_record_people',
        'projects',
        'project_items',
        'task_templates',
        'tags',
        'task_tags',
        'checklist_items',
        'task_occurrences',
        'occurrence_checklist_items',
        'task_recurrence_rules',
        'task_persons',
      ]),
    );

    expect(
      tables.map((row) => row['name']),
      isNot(contains('follow_ups')),
    );
    expect(tables.map((row) => row['name']), isNot(contains('follow_up_people')));
    expect(tables.map((row) => row['name']), isNot(contains('people')));
    expect(tables.map((row) => row['name']), isNot(contains('task_people')));

    final taskTemplateColumns = await database.runSelect(
      "PRAGMA table_info('task_templates')",
      const [],
    );
    expect(taskTemplateColumns.map((row) => row['name']), contains('checklist_enabled'));

    final taskPersonForeignKeys = await database.runSelect(
      "PRAGMA foreign_key_list('task_persons')",
      const [],
    );
    expect(taskPersonForeignKeys.map((row) => row['table']), contains('persons'));
    final followUpPersonForeignKeys = await database.runSelect(
      "PRAGMA foreign_key_list('follow_up_record_people')",
      const [],
    );
    expect(followUpPersonForeignKeys.map((row) => row['table']), contains('persons'));

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
      'dueDate': '2026-11-08T00:00:00.000',
      'allDay': true,
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
         (id, title, description, due_date, priority, archived, trashed,
          completed, legacy_payload_json)
         VALUES (?, ?, '', '2026-11-08T00:00:00.000', 'none', 0, 0, 0, ?)''',
      <Object?>['canonical-task', 'کار کانونی', jsonEncode(payload)],
    );
    // Recreate the pre-v12 layout to exercise the real upgrade/cutover path.
    await database.runCustom(
      '''CREATE TABLE follow_ups (
         id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
         date_time TEXT NOT NULL, title TEXT NULL, note TEXT NOT NULL, result TEXT NULL,
         reminder_date TEXT NULL, next_follow_up TEXT NULL, completed INTEGER NOT NULL,
         waiting_for_response INTEGER NOT NULL DEFAULT 0, ordinal INTEGER NOT NULL,
         UNIQUE(task_id, ordinal))''',
    );
    await database.runCustom(
      '''CREATE TABLE follow_up_people (
         follow_up_id TEXT NOT NULL REFERENCES follow_ups(id), person_id TEXT NOT NULL,
         ordinal INTEGER NOT NULL, PRIMARY KEY(follow_up_id, person_id))''',
    );
    await database.runCustom(
      '''CREATE TABLE people (
         id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
         created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
    );
    await database.runCustom(
      '''CREATE TABLE task_people (
         task_id TEXT NOT NULL, person_id TEXT NOT NULL,
         person_json TEXT NOT NULL, ordinal INTEGER NOT NULL,
         PRIMARY KEY (task_id, person_id))''',
    );
    await database.runCustom(
      '''INSERT INTO task_people (task_id, person_id, person_json, ordinal)
         VALUES ('canonical-task', 'task-person-old',
                 '{"id":"task-person-old","displayName":"شخص قدیمی"}', 0)''',
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

    await G1DriftSchema.migrateTaskPeople(database);
    await G1DriftSchema.migrateCanonicalEntities(database);

    final reminders = await database.runSelect(
      'SELECT id, is_all_day, remind_at FROM task_reminders WHERE task_id = ? ORDER BY sequence',
      <Object?>['canonical-task'],
    );
    expect(reminders.map((row) => row['id']), [
      'reminder-one',
      'reminder-two',
      'follow-up-reminder-canonical-task-legacy-follow-up',
    ]);
    expect(reminders.map((row) => row['is_all_day']), [0, 1, 0]);
    expect(reminders[1]['remind_at'], '2026-11-09');
    final migratedDueDate = await database.runSelect(
      'SELECT due_date FROM tasks WHERE id = ?',
      const <Object?>['canonical-task'],
    );
    expect(migratedDueDate.single['due_date'], '2026-11-08');
    final migratedFollowUpReminder = await database.runSelect(
      'SELECT remind_at FROM task_reminders WHERE id = ?',
      <Object?>['follow-up-reminder-canonical-task-legacy-follow-up'],
    );
    expect(migratedFollowUpReminder.single['remind_at'], '2026-11-07T09:00:00.000');
    final legacyPayloadRows = await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const <Object?>['canonical-task'],
    );
    final legacyPayload = Map<String, dynamic>.from(
      jsonDecode(legacyPayloadRows.single['legacy_payload_json'] as String) as Map,
    );
    final compatibility = legacyPayload['legacyFollowUpMetadata'] as Map;
    expect(compatibility['followUps'], [
      {
        'id': 'legacy-follow-up',
        'nextFollowUp': '2026-11-10T09:00:00.000',
      },
    ]);

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
    final taskPersonRows = await database.runSelect(
      '''SELECT task_persons.person_id, persons.name
         FROM task_persons JOIN persons ON persons.id = task_persons.person_id
         WHERE task_persons.task_id = ?''',
      <Object?>['canonical-task'],
    );
    expect(taskPersonRows.single['person_id'], 'task-person-old');
    expect(taskPersonRows.single['name'], 'شخص قدیمی');

    final recordColumns = await database.runSelect(
      "PRAGMA table_info('follow_up_records')",
      const [],
    );
    expect(recordColumns.map((row) => row['name']), isNot(contains('next_follow_up')));
    expect(recordColumns.map((row) => row['name']), isNot(contains('reminder_date')));

    final retiredTables = await database.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('follow_ups', 'follow_up_people', 'people', 'task_people')",
      const [],
    );
    expect(retiredTables.map((row) => row['name']), containsAll(<String>['follow_ups','follow_up_people','people','task_people']));
  });

  test('legacy Task reminder migration persists its marker and is idempotent', () async {
    await G1DriftSchema.install(database);
    await database.runCustom('ALTER TABLE tasks ADD COLUMN reminder_date TEXT NULL');
    final payload = <String, dynamic>{
      'id': 'legacy-reminder-task',
      'title': 'یادآور قدیمی',
      'reminderDate': '2026-11-08T09:00:00.000',
    };
    await database.runInsert(
      '''INSERT INTO tasks
         (id, title, description, priority, archived, trashed, completed, legacy_payload_json)
         VALUES (?, ?, '', 'none', 0, 0, 0, ?)''',
      <Object?>['legacy-reminder-task', 'یادآور قدیمی', jsonEncode(payload)],
    );

    await G1DriftSchema.migrateCanonicalEntities(database);
    await G1DriftSchema.migrateCanonicalEntities(database);

    final reminders = await database.runSelect(
      'SELECT id FROM task_reminders WHERE task_id = ?',
      const <Object?>['legacy-reminder-task'],
    );
    expect(reminders.map((row) => row['id']), ['legacy-task-reminder-legacy-reminder-task']);
    final stored = await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const <Object?>['legacy-reminder-task'],
    );
    final storedPayload = jsonDecode(stored.single['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(storedPayload['legacyTaskReminderMigrationVersion'], 1);
    expect(storedPayload['taskReminders'], isA<List<dynamic>>());
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
      "(id, title, description, priority, archived, trashed, completed) "
      "VALUES ('task-1', 'عنوان', '', 'none', 0, 0, 0)",
    );

    await database.runCustom(
      "INSERT INTO follow_up_records "
      "(id, task_id, completed_at, note, completed, ordinal) "
      "VALUES ('fu-1', 'task-1', '2026-09-22T10:00:00Z', 'اول', 0, 0)",
    );

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_up_records "
        "(id, task_id, completed_at, note, completed, ordinal) "
        "VALUES ('fu-2', 'task-1', '2026-09-22T11:00:00Z', 'تکراری', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );

    final ordered = await database.runSelect(
      'SELECT ordinal FROM follow_up_records WHERE task_id = ? ORDER BY ordinal',
      <Object?>['task-1'],
    );
    expect(ordered.single['ordinal'], 0);
  });

  test('foreign-key references prevent orphan relationship rows', () async {
    await G1DriftSchema.install(database);

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_up_records "
        "(id, task_id, completed_at, note, completed, ordinal) "
        "VALUES ('fu-orphan', 'missing', '2026-09-22T10:00:00Z', '', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );
  });
  test('upgrades an existing pre-taxonomy schema without losing task data', () async {
    await database.ensureOpen(G1DriftSchema());
    // Pre-taxonomy layout intentionally lacks recurrence_json. The G1 upgrade
    // must add the column before importing the recurrence envelope.
    await database.runCustom("CREATE TABLE tasks (id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL, updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL, follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL, reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL, trashed INTEGER NOT NULL, completed INTEGER NOT NULL, storage_ordinal INTEGER NOT NULL DEFAULT 0, legacy_payload_json TEXT NULL)");
    const legacyOccurrenceDate = '2026-11-01T08:00:00.000Z';
    await database.runInsert(
      '''INSERT INTO tasks (
        id, title, description, follow_up_enabled, priority, archived,
        trashed, completed, legacy_payload_json
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'legacy-task', 'قدیمی', '', 0, 'none', 0, 0, 1,
        jsonEncode(<String, dynamic>{
          'id': 'legacy-task',
          'title': 'قدیمی',
          'recurrence': <String, dynamic>{
            'frequency': 'daily',
            'interval': 1,
            'active': true,
            'trackingLevel': 'normal',
          },
          'occurrenceHistory': <String, dynamic>{
            legacyOccurrenceDate: <String, dynamic>{
              'scheduledDate': legacyOccurrenceDate,
              'status': 'completed',
              'completionDate': '2026-11-01T09:00:00.000Z',
              'result': 'done',
            },
          },
          'checklistOccurrences': <String, dynamic>{
            legacyOccurrenceDate: <String>['[x] مرحله اول'],
          },
        }),
      ],
    );
    await database.runCustom(
      "INSERT INTO tasks (id, title, description, follow_up_enabled, follow_up_date, priority, archived, trashed, completed) "
      "VALUES ('legacy-followup-enabled', 'پیگیری فعال', '', 1, '2026-11-10T10:30:00.000', 'none', 0, 0, 0)",
    );
    await database.runCustom(
      "INSERT INTO tasks (id, title, description, follow_up_enabled, follow_up_date, priority, archived, trashed, completed) "
      "VALUES ('legacy-followup-disabled', 'پیگیری غیرفعال', '', 0, '2026-11-11T09:00:00.000', 'none', 0, 0, 0)",
    );
    await database.runCustom(
      "INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) "
      "VALUES ('legacy-followup-no-date', 'بدون تاریخ پیگیری', '', 0, 'none', 0, 0, 0)",
    );
    await G1DriftSchema.install(database);
    final taxonomyTables = await database.runSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'taxonomy_categories'", const []);
    expect(taxonomyTables, hasLength(1));
    final tasks = await database.runSelect("SELECT id, title FROM tasks WHERE id = ?", <Object?>['legacy-task']);
    expect(tasks, hasLength(1));
    expect(tasks.single['title'], 'قدیمی');
    final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
    expect(columns.map((row) => row['name']), containsAll(<String>['legacy_payload_json', 'completed_at']));
    expect(columns.map((row) => row['name']), contains('recurrence_json'));
    final recurrenceRule = await database.runSelect(
      'SELECT frequency FROM task_recurrence_rules WHERE task_id = ?',
      const <Object?>['legacy-task'],
    );
    expect(recurrenceRule.single['frequency'], 'daily');
    final occurrenceRows = await database.runSelect(
      'SELECT scheduled_at, status FROM task_occurrences WHERE task_id = ?',
      const <Object?>['legacy-task'],
    );
    expect(occurrenceRows.single['scheduled_at'], legacyOccurrenceDate);
    expect(occurrenceRows.single['status'], 'completed');
    final occurrenceChecklist = await database.runSelect(
      'SELECT value FROM occurrence_checklist_items',
      const [],
    );
    expect(occurrenceChecklist.single['value'], '[x] مرحله اول');
    final migratedEnvelope = (await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const <Object?>['legacy-task'],
    )).single;
    final migratedJson = jsonDecode(migratedEnvelope['legacy_payload_json'] as String) as Map<String, dynamic>;
    expect(migratedJson.containsKey('occurrenceHistory'), isFalse);
    expect(migratedJson.containsKey('checklistOccurrences'), isFalse);
    final migratedTask = await database.runSelect('SELECT completed, completed_at FROM tasks WHERE id = ?', <Object?>['legacy-task']);
    expect(migratedTask.single['completed'], 1);
    // A pre-timestamp completed task stays unknown; migration must not invent a time.
    expect(migratedTask.single['completed_at'], isNull);
    // Legacy source columns remain until field/relation parity and backup/restore acceptance authorize retirement.
    expect(columns.map((row) => row['name']), containsAll(<String>['follow_up_enabled','follow_up_date','reminder_date']));

    final migratedPayloads = await database.runSelect(
      'SELECT id, legacy_payload_json FROM tasks '
      'WHERE id IN (?, ?, ?) ORDER BY id',
      const <Object?>[
        'legacy-followup-disabled',
        'legacy-followup-enabled',
        'legacy-followup-no-date',
      ],
    );
    expect(migratedPayloads, hasLength(3));
    final payloadById = <String, Map<String, dynamic>>{
      for (final row in migratedPayloads)
        row['id'] as String:
            Map<String, dynamic>.from(jsonDecode(row['legacy_payload_json'] as String) as Map),
    };
    expect(
      (payloadById['legacy-followup-enabled']!['legacyFollowUpMetadata'] as Map)['taskLevel'],
      {
        'followUpEnabled': true,
        'followUpDate': '2026-11-10T10:30:00.000',
      },
    );
    expect(
      (payloadById['legacy-followup-disabled']!['legacyFollowUpMetadata'] as Map)['taskLevel'],
      {
        'followUpEnabled': false,
        'followUpDate': '2026-11-11T09:00:00.000',
      },
    );
    expect(
      (payloadById['legacy-followup-no-date']!['legacyFollowUpMetadata'] as Map)['taskLevel'],
      {'followUpEnabled': false},
    );
    for (final payload in payloadById.values) {
      expect(payload.containsKey('reminderDate'), isFalse);
    }
    expect(
      payloadById['legacy-followup-no-date']!.containsKey('followUpDate'),
      isFalse,
    );
    final migratedSchedules = await database.runSelect(
      'SELECT id FROM task_reminders '
      'WHERE task_id IN (?, ?)',
      const <Object?>['legacy-followup-disabled', 'legacy-followup-enabled'],
    );
    expect(migratedSchedules, isEmpty);

    await G1DriftSchema.migrateCanonicalEntities(database);
    final repeatedPayload = await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const <Object?>['legacy-followup-enabled'],
    );
    final repeatedMetadata = Map<String, dynamic>.from(
      (jsonDecode(repeatedPayload.single['legacy_payload_json'] as String) as Map),
    )['legacyFollowUpMetadata'] as Map;
    expect(repeatedMetadata['taskLevel'], {
      'followUpEnabled': true,
      'followUpDate': '2026-11-10T10:30:00.000',
    });
  });

  test('legacy task_people migration preserves canonical names and stable Task links', () async {
    await database.ensureOpen(G1DriftSchema());
    await database.runCustom(
      '''CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
        updated_at TEXT NULL, due_date TEXT NULL, category TEXT NULL,
        notebook_kind TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL, completed INTEGER NOT NULL, completed_at TEXT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0, recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL)''',
    );
    await database.runInsert(
      '''INSERT INTO tasks
         (id, storage_ordinal, title, description, priority, archived, trashed,
          completed, legacy_payload_json)
         VALUES (?, 0, ?, '', 'none', 0, 0, 0, ?)''',
      <Object?>[
        'migration-task',
        'کار مهاجرت',
        jsonEncode(<String, dynamic>{
          'id': 'migration-task',
          'title': 'کار مهاجرت',
          'futureField': <String, dynamic>{'keep': true},
        }),
      ],
    );
    await database.runCustom(
      '''CREATE TABLE persons (
         id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
         created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
    );
    await database.runCustom(
      '''INSERT INTO persons (id, name, created_at, updated_at)
         VALUES ('stable-person', 'نام کانونی جدید', '2026-11-01', '2026-11-09')''',
    );
    await database.runCustom(
      '''CREATE TABLE task_people (
         task_id TEXT NOT NULL, person_id TEXT NOT NULL,
         person_json TEXT NOT NULL, ordinal INTEGER NOT NULL,
         PRIMARY KEY (task_id, person_id))''',
    );
    await database.runCustom(
      '''INSERT INTO task_people (task_id, person_id, person_json, ordinal)
         VALUES ('migration-task', 'stable-person',
                 '{"id":"stable-person","displayName":"نام قدیمی در Task"}', 0)''',
    );

    await G1DriftSchema.install(database);

    final person = await database.runSelect(
      'SELECT id, name FROM persons WHERE id = ?',
      const <Object?>['stable-person'],
    );
    expect(person.single['name'], 'نام کانونی جدید');
    final relation = await database.runSelect(
      'SELECT task_id, person_id FROM task_persons WHERE task_id = ?',
      const <Object?>['migration-task'],
    );
    expect(relation, hasLength(1));
    expect(relation.single['person_id'], 'stable-person');
    final directory = await database.runSelect(
      'SELECT person_id FROM person_directory WHERE person_id = ?',
      const <Object?>['stable-person'],
    );
    expect(directory, hasLength(1));
    final payloadRows = await database.runSelect(
      'SELECT legacy_payload_json FROM tasks WHERE id = ?',
      const <Object?>['migration-task'],
    );
    final payload = jsonDecode(payloadRows.single['legacy_payload_json'] as String)
        as Map<String, dynamic>;
    expect(payload['futureField'], <String, dynamic>{'keep': true});
    final retiredSource = await database.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'task_people'",
      const [],
    );
    expect(retiredSource, hasLength(1));
    expect(
      await database.runSelect('PRAGMA foreign_key_check', const []),
      isEmpty,
    );
  });

  test('malformed legacy task_people payload aborts migration without retiring source rows', () async {
    await database.ensureOpen(G1DriftSchema());
    await database.runCustom(
      '''CREATE TABLE task_people (
         task_id TEXT NOT NULL, person_id TEXT NOT NULL,
         person_json TEXT NOT NULL, ordinal INTEGER NOT NULL,
         PRIMARY KEY (task_id, person_id))''',
    );
    await database.runCustom(
      '''INSERT INTO task_people (task_id, person_id, person_json, ordinal)
         VALUES ('legacy-task', 'broken-person', 'not-json', 0)''',
    );

    await expectLater(
      G1DriftSchema.install(database),
      throwsA(isA<FormatException>()),
    );

    final source = await database.runSelect(
      'SELECT person_id, person_json FROM task_people',
      const [],
    );
    expect(source, hasLength(1));
    expect(source.single['person_id'], 'broken-person');
    expect(source.single['person_json'], 'not-json');
    final foreignKeys = await database.runSelect('PRAGMA foreign_keys', const []);
    expect(foreignKeys.single['foreign_keys'], 1);
    final canonicalTables = await database.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'persons'",
      const [],
    );
    expect(canonicalTables, isEmpty);
  });

}
