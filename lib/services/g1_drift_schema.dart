import 'package:drift/drift.dart';

/// G1-DRIFT relational schema foundation.
class G1DriftSchema implements QueryExecutorUser {
  static const int version = 4;

  static const List<String> _statements = <String>[
    '''CREATE TABLE IF NOT EXISTS tasks (
  id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL, description TEXT NOT NULL,
  created_at TEXT NULL, updated_at TEXT NULL, due_date TEXT NULL,
  follow_up_enabled INTEGER NOT NULL, follow_up_date TEXT NULL, category TEXT NULL,
  notebook_kind TEXT NULL, reminder_date TEXT NULL, priority TEXT NOT NULL,
  archived INTEGER NOT NULL, trashed INTEGER NOT NULL, completed INTEGER NOT NULL,
  recurrence_json TEXT NULL, legacy_payload_json TEXT NULL)''',
    '''CREATE TABLE IF NOT EXISTS follow_ups (
  id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
  date_time TEXT NOT NULL, note TEXT NOT NULL, result TEXT NULL,
  reminder_date TEXT NULL, next_follow_up TEXT NULL, completed INTEGER NOT NULL,
  ordinal INTEGER NOT NULL, UNIQUE (task_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS projects (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  color_value INTEGER NOT NULL DEFAULT 4283059371, is_archived INTEGER NOT NULL DEFAULT 0,
  legacy_payload_json TEXT NULL)''',
    '''CREATE TABLE IF NOT EXISTS project_items (
  project_id TEXT NOT NULL REFERENCES projects(id), task_id TEXT NOT NULL REFERENCES tasks(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (project_id, task_id))''',
    '''CREATE TABLE IF NOT EXISTS tags (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS task_tags (
  task_id TEXT NOT NULL REFERENCES tasks(id), tag_id TEXT NOT NULL REFERENCES tags(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, tag_id))''',
    '''CREATE TABLE IF NOT EXISTS checklist_items (
  task_id TEXT NOT NULL REFERENCES tasks(id), ordinal INTEGER NOT NULL,
  value TEXT NOT NULL, PRIMARY KEY (task_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS task_people (
  task_id TEXT NOT NULL REFERENCES tasks(id), person_id TEXT NOT NULL,
  person_json TEXT NOT NULL, ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, person_id))''',
    '''CREATE TABLE IF NOT EXISTS arvin_storage_meta (
  key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)''',
  ];

  @override
  int get schemaVersion => version;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}

  static Future<void> install(QueryExecutor executor) async {
    final schema = G1DriftSchema();
    await executor.ensureOpen(schema);
    await executor.runCustom('PRAGMA foreign_keys = ON');
    await executor.runCustom('PRAGMA busy_timeout = 5000');
    await executor.runCustom('PRAGMA synchronous = NORMAL');
    await executor.runCustom('BEGIN');
    try {
      for (final statement in _statements) {
        await executor.runCustom(statement);
      }
      final taskColumns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
      if (!taskColumns.any((row) => row['name'] == 'storage_ordinal')) {
        await executor.runCustom('ALTER TABLE tasks ADD COLUMN storage_ordinal INTEGER NOT NULL DEFAULT 0');
      }
      if (!taskColumns.any((row) => row['name'] == 'legacy_payload_json')) {
        await executor.runCustom('ALTER TABLE tasks ADD COLUMN legacy_payload_json TEXT NULL');
      }
      final projectColumns = await executor.runSelect("PRAGMA table_info('projects')", const []);
      if (!projectColumns.any((row) => row['name'] == 'color_value')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN color_value INTEGER NOT NULL DEFAULT 4283059371');
      }
      if (!projectColumns.any((row) => row['name'] == 'is_archived')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0');
      }
      if (!projectColumns.any((row) => row['name'] == 'legacy_payload_json')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN legacy_payload_json TEXT NULL');
      }
      await executor.runCustom('PRAGMA user_version = 4');
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
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
