import 'dart:convert';
import 'dart:io';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/g1_many_to_many_hierarchy_migration.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _V19FixtureUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 19;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('D04: physical SQLite backup of migrated v20 restores to an independent file', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-d04-v20-physical-');
    final sourceFile = File('${directory.path}/migrated-source.sqlite');
    final backupFile = File('${directory.path}/migrated-backup.sqlite');
    final source = NativeDatabase(sourceFile);
    await source.ensureOpen(_V19FixtureUser());
    await _createHistoricalV19Fixture(source);
    await source.close();

    final migrated = NativeDatabase(sourceFile);
    await migrated.ensureOpen(G1DriftSchema());
    final sourceParity = await migrated.runSelect(
      '''SELECT id, task_id, completed_at, title, note, result,
                completed, waiting_for_response, ordinal
         FROM follow_up_records ORDER BY task_id, ordinal''',
      const [],
    );
    await migrated.close();

    // This is a byte-for-byte SQLite database copy after the migrated source
    // has been cleanly closed; it does not serialize the database as JSON.
    await sourceFile.copy(backupFile.path);
    expect(await sourceFile.exists(), isTrue);
    expect(await backupFile.exists(), isTrue);
    expect(await backupFile.length(), greaterThan(0));
    expect(sourceFile.path == backupFile.path, isFalse);

    final restored = NativeDatabase(backupFile);
    try {
      await restored.ensureOpen(G1DriftSchema());
      expect((await restored.runSelect('PRAGMA user_version', const [])).single.values.first, 20);
      expect((await restored.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
      expect(
        await restored.runSelect('SELECT * FROM center_projects ORDER BY center_id, project_id', const []),
        [{'center_id': 'center-a', 'project_id': 'project-a'}],
      );
      expect(await restored.runSelect('SELECT * FROM project_categories', const []), isEmpty);
      expect(
        await restored.runSelect(
          '''SELECT id, task_id, completed_at, title, note, result,
                    completed, waiting_for_response, ordinal
             FROM follow_up_records ORDER BY task_id, ordinal''',
          const [],
        ),
        sourceParity,
      );
      expect(await restored.runSelect('SELECT id FROM persons WHERE id = ?', const ['person-legacy']), hasLength(1));
      expect(await restored.runSelect('SELECT * FROM follow_up_record_people', const []), hasLength(1));
      expect(await restored.runSelect('SELECT * FROM task_tags', const []), hasLength(2));
      expect(await restored.runSelect('SELECT id FROM task_reminders ORDER BY id', const []), hasLength(3));
      expect(await restored.runSelect('PRAGMA foreign_key_check(center_projects)', const []), isEmpty);
      expect(await restored.runSelect('PRAGMA foreign_key_check(project_categories)', const []), isEmpty);
      expect(await restored.runSelect('PRAGMA foreign_key_check(tasks)', const []), isEmpty);
      expect(await restored.runSelect('PRAGMA foreign_key_check(projects)', const []), hasLength(1));
      expect(await restored.runSelect('PRAGMA foreign_key_check(project_items)', const []), hasLength(1));
    } finally {
      await restored.close();
      await directory.delete(recursive: true);
    }
  });

  test('D02: missing, NULL, FALSE and TRUE legacy field states remain distinct', () async {
    final fullDirectory = await Directory.systemTemp.createTemp('arvin-d02-values-');
    final fullFile = File('${fullDirectory.path}/with-legacy-column.sqlite');
    final source = NativeDatabase(fullFile);
    await source.ensureOpen(_V19FixtureUser());
    await _createHistoricalV19Fixture(source);
    await source.close();

    final upgraded = NativeDatabase(fullFile);
    try {
      await upgraded.ensureOpen(G1DriftSchema());
      for (final entry in <String, Object?>{
        'task-null': null,
        'task-false': false,
        'task-true': true,
      }.entries) {
        final raw = (await upgraded.runSelect(
          'SELECT legacy_payload_json FROM tasks WHERE id = ?',
          [entry.key],
        )).single['legacy_payload_json'] as String;
        final payload = jsonDecode(raw) as Map<String, dynamic>;
        expect(payload.containsKey('followUpEnabled'), isTrue);
        expect(payload['followUpEnabled'], entry.value, reason: entry.key);
      }
      final explicitNullRaw = (await upgraded.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const ['task-primary'],
      )).single['legacy_payload_json'] as String;
      final explicitNullPayload = jsonDecode(explicitNullRaw) as Map<String, dynamic>;
      expect(explicitNullPayload['followUpDate'], isNull);
      expect(explicitNullPayload['reminderDate'], isNull);
      expect(
        await upgraded.runSelect(
          'SELECT id FROM task_reminders WHERE remind_at = ?',
          const ['2026-11-04T09:00:00.000'],
        ),
        isEmpty,
        reason: 'Explicit JSON NULL must not be overwritten by stale legacy SQL reminder_date.',
      );
    } finally {
      await upgraded.close();
      await fullDirectory.delete(recursive: true);
    }

    // A second independent v19 shape omits the legacy SQL column entirely.
    // Absence must not be rewritten as an explicit NULL or FALSE.
    final missingDirectory = await Directory.systemTemp.createTemp('arvin-d02-missing-');
    final missingFile = File('${missingDirectory.path}/missing-field.sqlite');
    final missingSource = NativeDatabase(missingFile);
    await missingSource.ensureOpen(_V19FixtureUser());
    await missingSource.runCustom('''CREATE TABLE centers(
      id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
      is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL
    )''');
    await missingSource.runCustom('''CREATE TABLE projects(
      id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
      name TEXT NOT NULL, color_value INTEGER NOT NULL DEFAULT 4283059371,
      is_archived INTEGER NOT NULL DEFAULT 0, center_id TEXT NULL
    )''');
    await missingSource.runCustom('''CREATE TABLE tasks(
      id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL,
      priority TEXT NOT NULL, archived INTEGER NOT NULL, trashed INTEGER NOT NULL,
      completed INTEGER NOT NULL, legacy_payload_json TEXT NULL
    )''');
    await missingSource.runCustom('''CREATE TABLE project_items(
      project_id TEXT NOT NULL, task_id TEXT NOT NULL, ordinal INTEGER NOT NULL,
      PRIMARY KEY(project_id, task_id)
    )''');
    await missingSource.runCustom('''CREATE TABLE taxonomy_categories(
      name TEXT NOT NULL PRIMARY KEY, created_at TEXT NOT NULL
    )''');
    await missingSource.runCustom('''CREATE TABLE arvin_storage_meta(
      key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL
    )''');
    await missingSource.runCustom("INSERT INTO tasks VALUES ('task-missing', 'بدون فیلد', '', 'medium', 0, 0, 0, '{\"custom\":\"kept\"}')");
    await missingSource.close();

    final missingUpgrade = NativeDatabase(missingFile);
    try {
      await missingUpgrade.ensureOpen(G1DriftSchema());
      final raw = (await missingUpgrade.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const ['task-missing'],
      )).single['legacy_payload_json'] as String;
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      expect(payload['custom'], 'kept');
      expect(payload.containsKey('followUpEnabled'), isFalse);
      expect((await missingUpgrade.runSelect('PRAGMA user_version', const [])).single.values.first, 20);
    } finally {
      await missingUpgrade.close();
      await missingDirectory.delete(recursive: true);
    }
  });

  test('D03: Person, Follow-up, Reminder, Tag and metadata parity is exact', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-d03-entities-');
    final file = File('${directory.path}/entities-v19.sqlite');
    final source = NativeDatabase(file);
    await source.ensureOpen(_V19FixtureUser());
    await _createHistoricalV19Fixture(source);

    final people = await source.runSelect(
      'SELECT id, name, created_at, updated_at FROM people ORDER BY id',
      const [],
    );
    final taskPeople = await source.runSelect(
      'SELECT task_id, person_id, ordinal FROM task_people ORDER BY task_id, person_id',
      const [],
    );
    final followUps = await source.runSelect(
      '''SELECT id, task_id, date_time, title, note, result, completed,
                waiting_for_response, ordinal
         FROM follow_ups ORDER BY task_id, ordinal''',
      const [],
    );
    final followUpPeople = await source.runSelect(
      'SELECT follow_up_id, person_id, ordinal FROM follow_up_people ORDER BY follow_up_id, person_id',
      const [],
    );
    final reminders = await source.runSelect(
      '''SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled
         FROM task_reminders ORDER BY id''',
      const [],
    );
    final tags = await source.runSelect('SELECT id, name FROM tags ORDER BY id', const []);
    final taskTags = await source.runSelect(
      'SELECT task_id, tag_id, ordinal FROM task_tags ORDER BY task_id, tag_id',
      const [],
    );
    await source.close();

    final upgraded = NativeDatabase(file);
    try {
      await upgraded.ensureOpen(G1DriftSchema());
      expect(
        await upgraded.runSelect(
          'SELECT id, name, created_at, updated_at FROM persons ORDER BY id',
          const [],
        ),
        people,
      );
      expect(
        await upgraded.runSelect(
          'SELECT task_id, person_id, ordinal FROM task_persons ORDER BY task_id, person_id',
          const [],
        ),
        taskPeople,
      );
      expect(
        await upgraded.runSelect(
          '''SELECT id, task_id, completed_at, title, note, result, completed,
                    waiting_for_response, ordinal
             FROM follow_up_records ORDER BY task_id, ordinal''',
          const [],
        ),
        followUps.map((row) => {
          'id': row['id'],
          'task_id': row['task_id'],
          'completed_at': row['date_time'],
          'title': row['title'],
          'note': row['note'],
          'result': row['result'],
          'completed': row['completed'],
          'waiting_for_response': row['waiting_for_response'],
          'ordinal': row['ordinal'],
        }).toList(),
      );
      expect(
        await upgraded.runSelect(
          'SELECT follow_up_id, person_id, ordinal FROM follow_up_record_people ORDER BY follow_up_id, person_id',
          const [],
        ),
        followUpPeople,
      );
      expect(
        await upgraded.runSelect('SELECT id, name FROM tags ORDER BY id', const []),
        tags,
      );
      expect(
        await upgraded.runSelect(
          'SELECT task_id, tag_id, ordinal FROM task_tags ORDER BY task_id, tag_id',
          const [],
        ),
        taskTags,
      );
      final migratedReminders = await upgraded.runSelect(
        '''SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled
           FROM task_reminders ORDER BY id''',
        const [],
      );
      expect(migratedReminders, containsAll(reminders));
      expect(migratedReminders, hasLength(reminders.length + 1));
      expect(
        migratedReminders.any((row) => row['id'] == 'reminder-v19-disabled' &&
            row['is_all_day'] == 1 && row['is_enabled'] == 0),
        isTrue,
      );
      expect(
        await upgraded.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const ['owner-metadata'],
        ),
        [{'value': 'preserve-me'}],
      );
      final followUpPayloadRaw = (await upgraded.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const ['task-primary'],
      )).single['legacy_payload_json'] as String;
      final followUpPayload = jsonDecode(followUpPayloadRaw) as Map<String, dynamic>;
      final followUpMetadata = followUpPayload['legacyFollowUpMetadata'] as Map<String, dynamic>;
      final historicalFollowUps = followUpMetadata['followUps'] as List<dynamic>;
      expect(historicalFollowUps, hasLength(2));
      expect((historicalFollowUps.first as Map<String, dynamic>)['nextFollowUp'],
          '2026-11-05T09:00:00.000');
      expect((historicalFollowUps.first as Map<String, dynamic>)['nextFollowUpAllDay'], 0);
      expect(
        await upgraded.runSelect(
          'SELECT person_id FROM person_directory WHERE person_id = ?',
          const ['person-legacy'],
        ),
        [{'person_id': 'person-legacy'}],
      );
      expect(await upgraded.runSelect('PRAGMA foreign_key_check(tasks)', const []), isEmpty);
      expect(await upgraded.runSelect('PRAGMA foreign_key_check(project_categories)', const []), isEmpty);
    } finally {
      await upgraded.close();
      await directory.delete(recursive: true);
    }
  });

  test('D02+D03: real v19 lifecycle preserves historical entities, links, NULL and booleans', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-v19-parity-');
    final file = File('${directory.path}/historical-v19.sqlite');
    final source = NativeDatabase(file);
    await source.ensureOpen(_V19FixtureUser());
    await _createHistoricalV19Fixture(source);

    final sourceVersion = await source.runSelect('PRAGMA user_version', const []);
    expect((sourceVersion.single.values.first as num).toInt(), 19);

    final sourceTasks = await source.runSelect(
      '''SELECT id, title, due_date, category, archived, trashed, completed, completed_at
         FROM tasks ORDER BY id''',
      const [],
    );
    final sourceProjects = await source.runSelect(
      'SELECT id, name, center_id FROM projects ORDER BY id',
      const [],
    );
    final sourceProjectItems = await source.runSelect(
      'SELECT project_id, task_id, ordinal FROM project_items ORDER BY project_id, task_id',
      const [],
    );
    final sourceTags = await source.runSelect('SELECT id, name FROM tags ORDER BY id', const []);
    final sourceTaskTags = await source.runSelect(
      'SELECT task_id, tag_id, ordinal FROM task_tags ORDER BY task_id, tag_id',
      const [],
    );
    final sourcePeople = await source.runSelect(
      'SELECT id, name, created_at, updated_at FROM people ORDER BY id',
      const [],
    );
    final sourceTaskPeople = await source.runSelect(
      'SELECT task_id, person_id, ordinal FROM task_people ORDER BY task_id, person_id',
      const [],
    );
    final sourceFollowUps = await source.runSelect(
      '''SELECT id, task_id, date_time, title, note, result, completed,
                waiting_for_response, ordinal
         FROM follow_ups ORDER BY task_id, ordinal''',
      const [],
    );
    final sourceFollowUpPeople = await source.runSelect(
      'SELECT follow_up_id, person_id, ordinal FROM follow_up_people ORDER BY follow_up_id, person_id',
      const [],
    );
    final sourceReminders = await source.runSelect(
      '''SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled
         FROM task_reminders ORDER BY id''',
      const [],
    );

    await source.close();

    // Open the independently created v19 file through the real Drift
    // QueryExecutorUser lifecycle. This is not a direct helper invocation.
    final upgraded = NativeDatabase(file);
    try {
      await upgraded.ensureOpen(G1DriftSchema());

      expect((await upgraded.runSelect('PRAGMA user_version', const [])).single.values.first, 20);
      expect(
        await upgraded.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const [G1ManyToManyHierarchyMigration.markerKey],
        ),
        [{'value': '20'}],
      );

      final destinationTasks = await upgraded.runSelect(
        '''SELECT id, title, due_date, category, archived, trashed, completed, completed_at
           FROM tasks ORDER BY id''',
        const [],
      );
      expect(destinationTasks, sourceTasks, reason: 'Core Task IDs and stored values must remain identical.');

      final destinationProjects = await upgraded.runSelect(
        'SELECT id, name, center_id FROM projects ORDER BY id',
        const [],
      );
      expect(destinationProjects, sourceProjects, reason: 'Legacy Project IDs and source Center values must remain intact.');

      expect(
        await upgraded.runSelect(
          'SELECT project_id, task_id, ordinal FROM project_items ORDER BY project_id, task_id',
          const [],
        ),
        sourceProjectItems,
        reason: 'Legacy memberships, including unresolved evidence, must remain available.',
      );
      expect(
        await upgraded.runSelect('SELECT id, name FROM tags ORDER BY id', const []),
        sourceTags,
      );
      expect(
        await upgraded.runSelect(
          'SELECT task_id, tag_id, ordinal FROM task_tags ORDER BY task_id, tag_id',
          const [],
        ),
        sourceTaskTags,
      );

      final destinationPeople = await upgraded.runSelect(
        'SELECT id, name, created_at, updated_at FROM persons ORDER BY id',
        const [],
      );
      expect(destinationPeople, sourcePeople, reason: 'Person IDs, labels and timestamps must be preserved.');
      expect(
        await upgraded.runSelect(
          'SELECT task_id, person_id, ordinal FROM task_persons ORDER BY task_id, person_id',
          const [],
        ),
        sourceTaskPeople,
      );
      expect(
        await upgraded.runSelect(
          '''SELECT id, task_id, completed_at, title, note, result, completed,
                    waiting_for_response, ordinal
             FROM follow_up_records ORDER BY task_id, ordinal''',
          const [],
        ),
        sourceFollowUps,
        reason: 'Every historical Follow-up record and its nullable result must survive.',
      );
      expect(
        await upgraded.runSelect(
          'SELECT follow_up_id, person_id, ordinal FROM follow_up_record_people ORDER BY follow_up_id, person_id',
          const [],
        ),
        sourceFollowUpPeople,
      );
      final destinationReminders = await upgraded.runSelect(
        '''SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled
           FROM task_reminders ORDER BY id''',
        const [],
      );
      expect(destinationReminders, containsAll(sourceReminders));
      expect(destinationReminders, hasLength(sourceReminders.length + 1),
          reason: 'The legacy Follow-up reminder is migrated once as an independent Task Reminder.');
      expect(destinationReminders.any((row) => row['id'] == 'reminder-v19-disabled' &&
          row['is_all_day'] == 1 && row['is_enabled'] == 0), isTrue);

      final nullTask = (await upgraded.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const ['task-null'],
      )).single;
      final nullPayload = jsonDecode(nullTask['legacy_payload_json'] as String) as Map<String, dynamic>;
      expect(nullPayload.containsKey('followUpEnabled'), isTrue);
      expect(nullPayload['followUpEnabled'], isNull);

      final falseTask = (await upgraded.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const ['task-false'],
      )).single;
      final falsePayload = jsonDecode(falseTask['legacy_payload_json'] as String) as Map<String, dynamic>;
      expect(falsePayload['followUpEnabled'], isFalse);
      expect(falsePayload['customFlag'], isFalse);
      expect(falsePayload['customNull'], isNull);

      final trueTask = (await upgraded.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const ['task-true'],
      )).single;
      final truePayload = jsonDecode(trueTask['legacy_payload_json'] as String) as Map<String, dynamic>;
      expect(truePayload['followUpEnabled'], isTrue);
      expect(truePayload['customFlag'], isTrue);

      expect(
        await upgraded.runSelect(
          'SELECT person_id FROM person_directory WHERE person_id = ?',
          const ['person-legacy'],
        ),
        [{'person_id': 'person-legacy'}],
      );
      expect(
        await upgraded.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const ['owner-metadata'],
        ),
        [{'value': 'preserve-me'}],
      );

      expect(
        await upgraded.runSelect('SELECT center_id, project_id FROM center_projects ORDER BY center_id, project_id', const []),
        [{'center_id': 'center-a', 'project_id': 'project-a'}],
      );
      expect(await upgraded.runSelect('SELECT * FROM project_categories', const []), isEmpty,
          reason: 'Task category labels do not establish Project↔Category membership.');

      final exceptions = await upgraded.runSelect(
        'SELECT entity_id, issue_code FROM rev10_hierarchy_migration_exceptions ORDER BY entity_id, issue_code',
        const [],
      );
      expect(exceptions.any((row) => row['entity_id'] == 'project-orphan' &&
          row['issue_code'] == 'PROJECT_CENTER_REFERENCE_MISSING'), isTrue);
      expect(exceptions.any((row) => row['entity_id'] == 'task-ambiguous' &&
          row['issue_code'] == 'TASK_MULTIPLE_LEGACY_PROJECTS'), isTrue);
      expect(exceptions.any((row) => row['entity_id'] == 'task-missing-project' &&
          row['issue_code'] == 'TASK_PROJECT_REFERENCE_MISSING'), isTrue);

      expect(await upgraded.runSelect('PRAGMA foreign_key_check(center_projects)', const []), isEmpty);
      expect(await upgraded.runSelect('PRAGMA foreign_key_check(project_categories)', const []), isEmpty);
      expect(await upgraded.runSelect('PRAGMA foreign_key_check(tasks)', const []), isEmpty);
      expect(await upgraded.runSelect('PRAGMA foreign_key_check(projects)', const []), hasLength(1));
      expect(await upgraded.runSelect('PRAGMA foreign_key_check(project_items)', const []), hasLength(1));
      expect((await upgraded.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
    } finally {
      await upgraded.close();
    }

    final reopened = NativeDatabase(file);
    try {
      await reopened.ensureOpen(G1DriftSchema());
      expect((await reopened.runSelect('PRAGMA user_version', const [])).single.values.first, 20);
      expect(await reopened.runSelect('SELECT id FROM follow_up_records ORDER BY id', const []), hasLength(2));
      expect(await reopened.runSelect('SELECT id FROM task_reminders ORDER BY id', const []), hasLength(3));
      expect(await reopened.runSelect('SELECT * FROM center_projects', const []), hasLength(1));
      expect(await reopened.runSelect('PRAGMA integrity_check', const []), [{'integrity_check': 'ok'}]);
    } finally {
      await reopened.close();
      await directory.delete(recursive: true);
    }
  });
}

Future<void> _createHistoricalV19Fixture(QueryExecutor db) async {
  await db.runCustom('PRAGMA foreign_keys = OFF');
  await db.runCustom('''CREATE TABLE centers(
    id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
    is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL
  )''');
  await db.runCustom('''CREATE TABLE projects(
    id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
    name TEXT NOT NULL, color_value INTEGER NOT NULL DEFAULT 4283059371,
    is_archived INTEGER NOT NULL DEFAULT 0,
    center_id TEXT NULL REFERENCES centers(id), template_id TEXT NULL,
    template_name_snapshot TEXT NULL, legacy_payload_json TEXT NULL
  )''');
  await db.runCustom('''CREATE TABLE tasks(
    id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
    title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
    updated_at TEXT NULL, due_date TEXT NULL, category TEXT NULL,
    notebook_kind TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
    trashed INTEGER NOT NULL, completed INTEGER NOT NULL, completed_at TEXT NULL,
    is_favorite INTEGER NOT NULL DEFAULT 0, recurrence_json TEXT NULL,
    legacy_payload_json TEXT NULL, follow_up_enabled INTEGER NULL,
    follow_up_date TEXT NULL, reminder_date TEXT NULL
  )''');
  await db.runCustom('''CREATE TABLE project_items(
    project_id TEXT NOT NULL REFERENCES projects(id),
    task_id TEXT NOT NULL REFERENCES tasks(id), ordinal INTEGER NOT NULL,
    PRIMARY KEY(project_id, task_id)
  )''');
  await db.runCustom('''CREATE TABLE taxonomy_categories(
    name TEXT NOT NULL PRIMARY KEY, created_at TEXT NOT NULL
  )''');
  await db.runCustom('''CREATE TABLE tags(
    id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL
  )''');
  await db.runCustom('''CREATE TABLE task_tags(
    task_id TEXT NOT NULL REFERENCES tasks(id), tag_id TEXT NOT NULL REFERENCES tags(id),
    ordinal INTEGER NOT NULL, PRIMARY KEY(task_id, tag_id)
  )''');
  await db.runCustom('''CREATE TABLE people(
    id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
    created_at TEXT NOT NULL, updated_at TEXT NOT NULL
  )''');
  await db.runCustom('''CREATE TABLE task_people(
    task_id TEXT NOT NULL REFERENCES tasks(id), person_id TEXT NOT NULL,
    person_json TEXT NOT NULL, ordinal INTEGER NOT NULL,
    PRIMARY KEY(task_id, person_id)
  )''');
  await db.runCustom('''CREATE TABLE follow_ups(
    id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
    date_time TEXT NOT NULL, title TEXT NULL, note TEXT NOT NULL,
    result TEXT NULL, completed INTEGER NOT NULL,
    waiting_for_response INTEGER NOT NULL DEFAULT 0, ordinal INTEGER NOT NULL,
    next_follow_up TEXT NULL, next_follow_up_all_day INTEGER NULL,
    reminder_date TEXT NULL, UNIQUE(task_id, ordinal)
  )''');
  await db.runCustom('''CREATE TABLE follow_up_people(
    follow_up_id TEXT NOT NULL REFERENCES follow_ups(id), person_id TEXT NOT NULL,
    ordinal INTEGER NOT NULL, PRIMARY KEY(follow_up_id, person_id)
  )''');
  await db.runCustom('''CREATE TABLE task_reminders(
    id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
    title TEXT NOT NULL, remind_at TEXT NOT NULL, is_all_day INTEGER NOT NULL DEFAULT 0,
    sequence INTEGER NOT NULL, is_enabled INTEGER NOT NULL DEFAULT 1,
    is_legacy_task_reminder INTEGER NOT NULL DEFAULT 0,
    UNIQUE(task_id, sequence)
  )''');
  await db.runCustom('''CREATE TABLE arvin_storage_meta(
    key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL
  )''');

  const timestamp = '2026-11-01T08:00:00.000';
  await db.runCustom("INSERT INTO centers VALUES ('center-a', 'مرکز تاریخی', 0, '$timestamp')");
  await db.runCustom("INSERT INTO projects(id, storage_ordinal, name, center_id) VALUES ('project-a', 0, 'پروژه تاریخی', 'center-a')");
  await db.runCustom("INSERT INTO projects(id, storage_ordinal, name, center_id) VALUES ('project-orphan', 1, 'پروژه با مرکز ناموجود', 'missing-center')");

  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at, legacy_payload_json,
     follow_up_enabled, follow_up_date, reminder_date)
    VALUES
    ('task-primary', 0, 'کار اصلی', '', NULL, 'عملیات', 'medium', 0, 0, 0, NULL,
     '{"centerId":"center-a","followUpEnabled":false,"followUpDate":null,"reminderDate":null,"customFlag":false,"customNull":null}',
     1, '2026-11-03T09:00:00.000', '2026-11-04T09:00:00.000')''');
  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at, legacy_payload_json,
     follow_up_enabled)
    VALUES
    ('task-null', 1, 'کار NULL', '', NULL, NULL, 'medium', 0, 0, 0, NULL,
     '{"followUpEnabled":null}', 1)''');
  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at, legacy_payload_json,
     follow_up_enabled)
    VALUES
    ('task-false', 2, 'کار FALSE', '', NULL, NULL, 'medium', 0, 0, 0, NULL,
     '{"followUpEnabled":false,"customFlag":false,"customNull":null}', 1)''');
  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at, legacy_payload_json,
     follow_up_enabled)
    VALUES
    ('task-true', 3, 'کار TRUE', '', NULL, NULL, 'medium', 1, 0, 1, '$timestamp',
     '{"followUpEnabled":true,"customFlag":true}', 0)''');
  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at)
    VALUES
    ('task-ambiguous', 4, 'کار مبهم', '', NULL, NULL, 'medium', 0, 0, 0, NULL)''');
  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at)
    VALUES
    ('task-missing-project', 5, 'کار با پروژه ناموجود', '', NULL, NULL, 'medium', 0, 0, 0, NULL)''');
  await db.runCustom('''INSERT INTO tasks
    (id, storage_ordinal, title, description, due_date, category, priority,
     archived, trashed, completed, completed_at)
    VALUES
    ('task-standalone', 6, 'کار مستقل', '', NULL, NULL, 'medium', 0, 0, 0, NULL)''');

  await db.runCustom("INSERT INTO project_items VALUES ('project-a', 'task-primary', 0)");
  await db.runCustom("INSERT INTO project_items VALUES ('project-a', 'task-ambiguous', 0)");
  await db.runCustom("INSERT INTO project_items VALUES ('project-orphan', 'task-ambiguous', 1)");
  await db.runCustom("INSERT INTO project_items VALUES ('missing-project', 'task-missing-project', 0)");

  await db.runCustom("INSERT INTO taxonomy_categories VALUES ('عملیات', '$timestamp')");
  await db.runCustom("INSERT INTO tags VALUES ('tag-a', 'مهم')");
  await db.runCustom("INSERT INTO tags VALUES ('tag-b', 'فوری')");
  await db.runCustom("INSERT INTO task_tags VALUES ('task-primary', 'tag-a', 0)");
  await db.runCustom("INSERT INTO task_tags VALUES ('task-primary', 'tag-b', 1)");

  await db.runCustom("INSERT INTO people VALUES ('person-legacy', 'شخص تاریخی', '$timestamp', '$timestamp')");
  await db.runCustom('''INSERT INTO task_people VALUES
    ('task-primary', 'person-legacy', '{"id":"person-legacy","displayName":"شخص تاریخی"}', 0)''');

  await db.runCustom('''INSERT INTO follow_ups
    (id, task_id, date_time, title, note, result, completed, waiting_for_response,
     ordinal, next_follow_up, next_follow_up_all_day, reminder_date)
    VALUES
    ('followup-1', 'task-primary', '$timestamp', 'پیگیری اول', 'یادداشت اول', NULL, 0, 1,
     0, '2026-11-05T09:00:00.000', 0, '2026-11-06T09:00:00.000')''');
  await db.runCustom('''INSERT INTO follow_ups
    (id, task_id, date_time, title, note, result, completed, waiting_for_response,
     ordinal, next_follow_up, next_follow_up_all_day, reminder_date)
    VALUES
    ('followup-2', 'task-primary', '2026-11-02T08:00:00.000', 'پیگیری دوم', 'یادداشت دوم', 'نتیجه', 1, 0,
     1, NULL, NULL, NULL)''');
  await db.runCustom("INSERT INTO follow_up_people VALUES ('followup-1', 'person-legacy', 0)");

  await db.runCustom('''INSERT INTO task_reminders
    (id, task_id, title, remind_at, is_all_day, sequence, is_enabled, is_legacy_task_reminder)
    VALUES ('reminder-v19', 'task-primary', 'یادآور قدیمی', '2026-11-07T09:00:00.000', 0, 0, 1, 1)''');
  await db.runCustom('''INSERT INTO task_reminders
    (id, task_id, title, remind_at, is_all_day, sequence, is_enabled, is_legacy_task_reminder)
    VALUES ('reminder-v19-disabled', 'task-true', 'یادآور غیرفعال', '2026-11-08', 1, 0, 0, 1)''');
  await db.runCustom("INSERT INTO arvin_storage_meta VALUES ('owner-metadata', 'preserve-me')");
  await db.runCustom('PRAGMA foreign_keys = ON');
}
