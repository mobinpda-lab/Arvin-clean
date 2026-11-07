import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/task.dart';

/// G1-DRIFT relational schema foundation.
class G1DriftSchema implements QueryExecutorUser {
  static const int version = 14;

  static const List<String> _statements = <String>[
    '''CREATE TABLE IF NOT EXISTS tasks (
  id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
  title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
  updated_at TEXT NULL, due_date TEXT NULL, category TEXT NULL,
  notebook_kind TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
  trashed INTEGER NOT NULL, completed INTEGER NOT NULL, completed_at TEXT NULL,
  recurrence_json TEXT NULL, legacy_payload_json TEXT NULL)''',
    '''CREATE TABLE IF NOT EXISTS task_reminders (
  id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
  title TEXT NOT NULL, remind_at TEXT NOT NULL, is_all_day INTEGER NOT NULL DEFAULT 0,
  sequence INTEGER NOT NULL, is_enabled INTEGER NOT NULL DEFAULT 1,
  is_legacy_task_reminder INTEGER NOT NULL DEFAULT 0,
  UNIQUE (task_id, sequence))''',
    '''CREATE TABLE IF NOT EXISTS follow_up_records (
  id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
  completed_at TEXT NOT NULL, title TEXT NULL, note TEXT NOT NULL,
  result TEXT NULL, completed INTEGER NOT NULL,
  waiting_for_response INTEGER NOT NULL DEFAULT 0,
  ordinal INTEGER NOT NULL, UNIQUE (task_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS persons (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS follow_up_record_people (
  follow_up_id TEXT NOT NULL REFERENCES follow_up_records(id), person_id TEXT NOT NULL REFERENCES persons(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (follow_up_id, person_id))''',
    '''CREATE TABLE IF NOT EXISTS task_persons (
  task_id TEXT NOT NULL REFERENCES tasks(id), person_id TEXT NOT NULL REFERENCES persons(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, person_id))''',
    '''CREATE TABLE IF NOT EXISTS centers (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS project_templates (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS task_templates (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '', category TEXT NULL, priority TEXT NOT NULL DEFAULT 'medium', checklist_enabled INTEGER NOT NULL DEFAULT 0,
  tags_json TEXT NOT NULL DEFAULT '[]', checklist_json TEXT NOT NULL DEFAULT '[]',
  people_json TEXT NOT NULL DEFAULT '[]', reminders_json TEXT NOT NULL DEFAULT '[]',
  recurrence_json TEXT NULL, center_name_snapshot TEXT NULL, project_name_snapshot TEXT NULL,
  center_id_snapshot TEXT NULL, project_id_snapshot TEXT NULL,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL, is_archived INTEGER NOT NULL DEFAULT 0)''',
    '''CREATE TABLE IF NOT EXISTS project_template_tasks (
  id TEXT NOT NULL PRIMARY KEY, template_id TEXT NOT NULL REFERENCES project_templates(id),
  title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', category TEXT NULL,
  tags_json TEXT NOT NULL DEFAULT '[]', checklist_json TEXT NOT NULL DEFAULT '[]', ordinal INTEGER NOT NULL,
  UNIQUE(template_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS projects (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  color_value INTEGER NOT NULL DEFAULT 4283059371, is_archived INTEGER NOT NULL DEFAULT 0,
  center_id TEXT NULL REFERENCES centers(id), template_id TEXT NULL,
  template_name_snapshot TEXT NULL, legacy_payload_json TEXT NULL)''',
    '''CREATE TABLE IF NOT EXISTS project_items (
  project_id TEXT NOT NULL REFERENCES projects(id), task_id TEXT NOT NULL REFERENCES tasks(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (project_id, task_id))''',
    '''CREATE TABLE IF NOT EXISTS template_task_applications (
  template_task_id TEXT NOT NULL, project_id TEXT NOT NULL REFERENCES projects(id),
  task_id TEXT NOT NULL UNIQUE REFERENCES tasks(id), PRIMARY KEY(template_task_id, project_id))''',
    '''CREATE TABLE IF NOT EXISTS taxonomy_categories (
  name TEXT NOT NULL PRIMARY KEY, created_at TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS tags (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS task_tags (
  task_id TEXT NOT NULL REFERENCES tasks(id), tag_id TEXT NOT NULL REFERENCES tags(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, tag_id))''',
    '''CREATE TABLE IF NOT EXISTS checklist_items (
  task_id TEXT NOT NULL REFERENCES tasks(id), ordinal INTEGER NOT NULL,
  value TEXT NOT NULL, PRIMARY KEY (task_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS arvin_storage_meta (
  key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)''',
  ];

  @override
  int get schemaVersion => version;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}

  // Store constructors may request the same schema concurrently (for example
  // both operational template tabs are mounted by TabBarView). Serialize the
  // idempotent migration per executor so nested BEGIN transactions are avoided.
  static final Expando<Object> _installations =
      Expando<Object>('G1DriftSchema.install');

  static Future<void> install(QueryExecutor executor) {
    final current = _installations[executor] as Future<void>?;
    if (current != null) return current;
    final completer = Completer<void>();
    _installations[executor] = completer.future;
    () async {
      try {
        await _installSchema(executor);
        completer.complete();
      } catch (error, stackTrace) {
        _installations[executor] = null;
        completer.completeError(error, stackTrace);
      }
    }();
    return completer.future;
  }

  static Future<void> _installSchema(QueryExecutor executor) async {
    final schema = G1DriftSchema();
    await executor.ensureOpen(schema);
    await executor.runCustom('PRAGMA foreign_keys = OFF');
    await executor.runCustom('PRAGMA busy_timeout = 5000');
    await executor.runCustom('PRAGMA synchronous = NORMAL');
    await executor.runCustom('BEGIN');
    try {
      for (final statement in _statements) {
        await executor.runCustom(statement);
      }
      final projectTemplateColumns = await executor.runSelect("PRAGMA table_info('project_templates')", const []);
      if (!projectTemplateColumns.any((row) => row['name'] == 'center_id')) {
        await executor.runCustom('ALTER TABLE project_templates ADD COLUMN center_id TEXT NULL');
      }
      if (!projectTemplateColumns.any((row) => row['name'] == 'color_value')) {
        await executor.runCustom('ALTER TABLE project_templates ADD COLUMN color_value INTEGER NOT NULL DEFAULT 4283059371');
      }
      final taskTemplateColumns = await executor.runSelect("PRAGMA table_info('task_templates')", const []);
      if (!taskTemplateColumns.any((row) => row['name'] == 'checklist_enabled')) {
        await executor.runCustom('ALTER TABLE task_templates ADD COLUMN checklist_enabled INTEGER NOT NULL DEFAULT 0');
      }
      if (!taskTemplateColumns.any((row) => row['name'] == 'center_id_snapshot')) {
        await executor.runCustom('ALTER TABLE task_templates ADD COLUMN center_id_snapshot TEXT NULL');
      }
      if (!taskTemplateColumns.any((row) => row['name'] == 'project_id_snapshot')) {
        await executor.runCustom('ALTER TABLE task_templates ADD COLUMN project_id_snapshot TEXT NULL');
      }
      final taskColumns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
      if (!taskColumns.any((row) => row['name'] == 'storage_ordinal')) {
        await executor.runCustom('ALTER TABLE tasks ADD COLUMN storage_ordinal INTEGER NOT NULL DEFAULT 0');
      }
      if (!taskColumns.any((row) => row['name'] == 'legacy_payload_json')) {
        await executor.runCustom('ALTER TABLE tasks ADD COLUMN legacy_payload_json TEXT NULL');
      }
      if (!taskColumns.any((row) => row['name'] == 'completed_at')) {
        await executor.runCustom('ALTER TABLE tasks ADD COLUMN completed_at TEXT NULL');
      }
      final legacyFollowUpTable = await _hasTable(executor, 'follow_ups');
      if (legacyFollowUpTable) {
        final followUpColumns = await executor.runSelect("PRAGMA table_info('follow_ups')", const []);
        if (!followUpColumns.any((row) => row['name'] == 'title')) {
          await executor.runCustom('ALTER TABLE follow_ups ADD COLUMN title TEXT NULL');
        }
        if (!followUpColumns.any((row) => row['name'] == 'waiting_for_response')) {
          await executor.runCustom(
            'ALTER TABLE follow_ups ADD COLUMN waiting_for_response INTEGER NOT NULL DEFAULT 0',
          );
        }
      }
      final projectColumns = await executor.runSelect("PRAGMA table_info('projects')", const []);
      if (!projectColumns.any((row) => row['name'] == 'color_value')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN color_value INTEGER NOT NULL DEFAULT 4283059371');
      }
      if (!projectColumns.any((row) => row['name'] == 'is_archived')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0');
      }
      if (!projectColumns.any((row) => row['name'] == 'center_id')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN center_id TEXT NULL REFERENCES centers(id)');
      }
      if (!projectColumns.any((row) => row['name'] == 'template_id')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN template_id TEXT NULL');
      }
      if (!projectColumns.any((row) => row['name'] == 'template_name_snapshot')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN template_name_snapshot TEXT NULL');
      }
      await executor.runCustom('CREATE UNIQUE INDEX IF NOT EXISTS idx_projects_active_template_center ON projects(template_id, center_id) WHERE template_id IS NOT NULL AND center_id IS NOT NULL AND is_archived = 0');
      if (!projectColumns.any((row) => row['name'] == 'legacy_payload_json')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN legacy_payload_json TEXT NULL');
      }
      await migrateTaskPeople(executor);
      await migrateCanonicalEntities(executor);
      await _rebuildTaskTableWithoutLegacyScheduleColumns(executor);
      // Do not write PRAGMA user_version here. The canonical migration marker
      // is arvin_storage_meta, and this install path can be reached by more
      // than one SQLite connection (for example app + Android smoke tooling).
      // A user_version write acquires a database-wide lock and can fail even
      // though the schema itself is already installed. Schema DDL above is
      // idempotent and the marker remains the canonical cutover boundary.
      final foreignKeyViolations = await executor.runSelect('PRAGMA foreign_key_check', const []);
      if (foreignKeyViolations.isNotEmpty) {
        throw StateError('Canonical schema rebuild produced foreign-key violations: $foreignKeyViolations');
      }
      await executor.runCustom('COMMIT');
      await executor.runCustom('PRAGMA foreign_keys = ON');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      try { await executor.runCustom('PRAGMA foreign_keys = ON'); } catch (_) {}
      rethrow;
    }
  }

  /// Copies historical task-person identities into the canonical directory.
  /// Existing directory rows win for creation time; names are refreshed from
  /// the current task relation. Re-running this migration is safe.
  static Future<void> migrateTaskPeople(QueryExecutor executor) async {
    if (!await _hasTable(executor, 'task_people')) return;
    final rows = await executor.runSelect(
      'SELECT person_id, person_json FROM task_people ORDER BY task_id, ordinal',
      const [],
    );
    final now = DateTime.now().toIso8601String();
    for (final row in rows) {
      final id = row['person_id'];
      final raw = row['person_json'];
      if (id is! String || id.trim().isEmpty || raw is! String) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) continue;
        final name = (decoded['displayName'] ?? decoded['name']);
        if (name is! String || name.trim().isEmpty) continue;
        await executor.runInsert(
          '''INSERT INTO persons (id, name, created_at, updated_at) VALUES (?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET name = excluded.name, updated_at = excluded.updated_at''',
          <Object?>[id.trim(), name.trim(), now, now],
        );
      } on FormatException {
        continue;
      }
    }
  }

  /// Moves old Follow-up scheduling and people storage into canonical
  /// independent tables, then retires the legacy tables. Safe to rerun.
  static Future<void> migrateCanonicalEntities(QueryExecutor executor) async {
    final hasPeople = await _hasTable(executor, 'people');
    if (hasPeople) {
      final directoryRows = await executor.runSelect(
        'SELECT id, name, created_at, updated_at FROM people',
        const [],
      );
      for (final row in directoryRows) {
        await executor.runInsert(
          '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
             VALUES (?, ?, ?, ?)''',
          <Object?>[row['id'], row['name'], row['created_at'], row['updated_at']],
        );
      }
    }

    final hasLegacyTaskPeople = await _hasTable(executor, 'task_people');
    if (hasLegacyTaskPeople) {
      final taskPeopleRows = await executor.runSelect(
        'SELECT task_id, person_id, ordinal FROM task_people ORDER BY task_id, ordinal',
        const [],
      );
      for (final row in taskPeopleRows) {
        await executor.runInsert(
          'INSERT OR IGNORE INTO task_persons (task_id, person_id, ordinal) VALUES (?, ?, ?)',
          <Object?>[row['task_id'], row['person_id'], row['ordinal']],
        );
      }
      await executor.runCustom('DROP TABLE task_people');
    }

    final hasLegacyFollowUps = await _hasTable(executor, 'follow_ups');
    final hasLegacyFollowUpPeople = await _hasTable(executor, 'follow_up_people');
    if (hasLegacyFollowUps) {
      final legacyFollowUps = await executor.runSelect(
        'SELECT * FROM follow_ups ORDER BY task_id, ordinal',
        const [],
      );
      for (final row in legacyFollowUps) {
        await executor.runInsert(
          '''INSERT OR IGNORE INTO follow_up_records
             (id, task_id, completed_at, title, note, result, completed, waiting_for_response, ordinal)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            row['id'], row['task_id'], row['date_time'], row['title'], row['note'],
            row['result'], row['completed'], row['waiting_for_response'], row['ordinal'],
          ],
        );
      }
    }

    if (hasLegacyFollowUpPeople) {
      final legacyFollowUpPeople = await executor.runSelect(
        'SELECT follow_up_id, person_id, ordinal FROM follow_up_people ORDER BY follow_up_id, ordinal',
        const [],
      );
      for (final row in legacyFollowUpPeople) {
        final personId = row['person_id'] as String;
        await executor.runInsert(
          '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
             VALUES (?, ?, ?, ?)''',
          <Object?>[
            personId,
            personId,
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
          ],
        );
        await executor.runInsert(
          '''INSERT OR IGNORE INTO follow_up_record_people
             (follow_up_id, person_id, ordinal) VALUES (?, ?, ?)''',
          <Object?>[row['follow_up_id'], personId, row['ordinal']],
        );
      }
    }

    final taskColumns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
    final hasLegacyTaskReminder = taskColumns.any((row) => row['name'] == 'reminder_date');
    final reminderColumn = hasLegacyTaskReminder ? 'reminder_date' : 'NULL AS reminder_date';
    final taskRows = await executor.runSelect(
      'SELECT id, title, $reminderColumn, legacy_payload_json FROM tasks ORDER BY storage_ordinal, id',
      const [],
    );
    for (final row in taskRows) {
      final payload = <String, dynamic>{};
      final raw = row['legacy_payload_json'];
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) {
          throw const FormatException('Task payload must be a JSON object during reminder cutover.');
        }
        payload.addAll(Map<String, dynamic>.from(decoded));
      }
      payload['id'] = row['id'];
      payload['title'] = row['title'];
      payload['reminderDate'] ??= row['reminder_date'];
      final task = Task.fromJson(payload);
      for (final reminder in task.taskReminders) {
        await executor.runInsert(
          '''INSERT OR IGNORE INTO task_reminders
             (id, task_id, title, remind_at, is_all_day, sequence, is_enabled, is_legacy_task_reminder)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            reminder.id, task.id, reminder.title, reminder.date.toIso8601String(),
            reminder.isAllDay ? 1 : 0, reminder.sequence, reminder.isEnabled ? 1 : 0,
            reminder.isLegacyTaskReminder ? 1 : 0,
          ],
        );
      }
    }

    // Older SQL Follow-up rows may have a reminder date even when the JSON
    // envelope predates the TaskReminder conversion. Preserve it independently.
    if (hasLegacyFollowUps) {
      final legacyFollowUpReminders = await executor.runSelect(
        'SELECT id, task_id, reminder_date FROM follow_ups WHERE reminder_date IS NOT NULL ORDER BY task_id, ordinal',
        const [],
      );
      for (final legacy in legacyFollowUpReminders) {
        final taskRows = await executor.runSelect(
          'SELECT legacy_payload_json FROM tasks WHERE id = ?',
          <Object?>[legacy['task_id']],
        );
        var isAllDay = false;
        if (taskRows.isNotEmpty) {
          final rawPayload = taskRows.single['legacy_payload_json'];
          if (rawPayload is String && rawPayload.trim().isNotEmpty) {
            final decoded = jsonDecode(rawPayload);
            if (decoded is Map && decoded['followUps'] is List) {
              for (final rawFollowUp in decoded['followUps'] as List) {
                if (rawFollowUp is Map && rawFollowUp['id'] == legacy['id']) {
                  isAllDay = rawFollowUp['reminderAllDay'] == true;
                  break;
                }
              }
            }
          }
        }
        final sequenceRows = await executor.runSelect(
          'SELECT COALESCE(MAX(sequence), 0) + 1 AS next_sequence FROM task_reminders WHERE task_id = ?',
          <Object?>[legacy['task_id']],
        );
        final sequence = (sequenceRows.single['next_sequence'] as num).toInt();
        await executor.runInsert(
          '''INSERT OR IGNORE INTO task_reminders
             (id, task_id, title, remind_at, is_all_day, sequence, is_enabled, is_legacy_task_reminder)
             VALUES (?, ?, ?, ?, ?, ?, 1, 0)''',
          <Object?>[
            'follow-up-reminder-${legacy['task_id']}-${legacy['id']}',
            legacy['task_id'],
            'یادآور پیگیری',
            legacy['reminder_date'],
            isAllDay ? 1 : 0,
            sequence,
          ],
        );
      }
    }

    if (hasLegacyFollowUpPeople) {
      await executor.runCustom('DROP TABLE follow_up_people');
    }
    if (hasLegacyFollowUps) {
      await executor.runCustom('DROP TABLE follow_ups');
    }
    if (hasPeople) {
      await executor.runCustom('DROP TABLE people');
    }
  }

  static Future<void> _rebuildTaskTableWithoutLegacyScheduleColumns(
    QueryExecutor executor,
  ) async {
    final columns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
    const retired = {'follow_up_enabled', 'follow_up_date', 'reminder_date'};
    if (!columns.any((row) => retired.contains(row['name']))) return;

    await executor.runCustom('''
      CREATE TABLE tasks_canonical_v14 (
        id TEXT NOT NULL PRIMARY KEY,
        storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NULL,
        updated_at TEXT NULL,
        due_date TEXT NULL,
        category TEXT NULL,
        notebook_kind TEXT NULL,
        priority TEXT NOT NULL,
        archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        completed_at TEXT NULL,
        recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )
    ''');
    await executor.runCustom('''
      INSERT INTO tasks_canonical_v14 (
        id, storage_ordinal, title, description, created_at, updated_at, due_date,
        category, notebook_kind, priority, archived, trashed, completed,
        completed_at, recurrence_json, legacy_payload_json
      )
      SELECT
        id, storage_ordinal, title, description, created_at, updated_at, due_date,
        category, notebook_kind, priority, archived, trashed, completed,
        completed_at, recurrence_json, legacy_payload_json
      FROM tasks
    ''');
    await executor.runCustom('DROP TABLE tasks');
    await executor.runCustom('ALTER TABLE tasks_canonical_v14 RENAME TO tasks');
  }

  static Future<bool> _hasTable(QueryExecutor executor, String table) async {
    final rows = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>[table],
    );
    return rows.isNotEmpty;
  }

  static Future<bool> isLegacyMigrationComplete(QueryExecutor executor) async {
    final rows = await executor.runSelect(
      "SELECT value FROM arvin_storage_meta WHERE key = 'legacy_tasks_migrated'",
      const [],
    );
    return rows.isNotEmpty && rows.single['value'] == '1';
  }

  static Future<void> markLegacyMigrationComplete(QueryExecutor executor) async {
    await executor.runCustom(
      "INSERT INTO arvin_storage_meta (key, value) VALUES ('legacy_tasks_migrated', '1') "
      "ON CONFLICT(key) DO UPDATE SET value = '1'",
    );
  }
}
