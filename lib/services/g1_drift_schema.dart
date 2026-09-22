import 'package:drift/drift.dart';

/// G1-DRIFT relational schema foundation.
///
/// This class deliberately uses Drift's low-level SQL executor instead of
/// generated table classes. It creates only the persistence schema; it does
/// not change TaskStore, read/write ownership, or the legacy SharedPreferences
/// migration boundary.
class G1DriftSchema implements QueryExecutorUser {
  static const int version = 3;

  static const List<String> _statements = <String>[
    '''
CREATE TABLE IF NOT EXISTS tasks (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TEXT NULL,
  updated_at TEXT NULL,
  due_date TEXT NULL,
  follow_up_enabled INTEGER NOT NULL,
  follow_up_date TEXT NULL,
  category TEXT NULL,
  notebook_kind TEXT NULL,
  reminder_date TEXT NULL,
  priority TEXT NOT NULL,
  archived INTEGER NOT NULL,
  trashed INTEGER NOT NULL,
  completed INTEGER NOT NULL,
  recurrence_json TEXT NULL,
  legacy_payload_json TEXT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS follow_ups (
  id TEXT NOT NULL PRIMARY KEY,
  task_id TEXT NOT NULL REFERENCES tasks(id),
  date_time TEXT NOT NULL,
  note TEXT NOT NULL,
  result TEXT NULL,
  reminder_date TEXT NULL,
  next_follow_up TEXT NULL,
  completed INTEGER NOT NULL,
  ordinal INTEGER NOT NULL,
  UNIQUE (task_id, ordinal)
)
''',
    '''
CREATE TABLE IF NOT EXISTS projects (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  color_value INTEGER NOT NULL DEFAULT 12462507,
  is_archived INTEGER NOT NULL DEFAULT 0,
  legacy_payload_json TEXT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS project_items (
  project_id TEXT NOT NULL REFERENCES projects(id),
  task_id TEXT NOT NULL REFERENCES tasks(id),
  ordinal INTEGER NOT NULL,
  PRIMARY KEY (project_id, task_id)
)
''',
    '''
CREATE TABLE IF NOT EXISTS tags (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS task_tags (
  task_id TEXT NOT NULL REFERENCES tasks(id),
  tag_id TEXT NOT NULL REFERENCES tags(id),
  ordinal INTEGER NOT NULL,
  PRIMARY KEY (task_id, tag_id)
)
''',
    '''
CREATE TABLE IF NOT EXISTS checklist_items (
  task_id TEXT NOT NULL REFERENCES tasks(id),
  ordinal INTEGER NOT NULL,
  value TEXT NOT NULL,
  PRIMARY KEY (task_id, ordinal)
)
''',
    '''
CREATE TABLE IF NOT EXISTS task_people (
  task_id TEXT NOT NULL REFERENCES tasks(id),
  person_id TEXT NOT NULL,
  person_json TEXT NOT NULL,
  ordinal INTEGER NOT NULL,
  PRIMARY KEY (task_id, person_id)
)
''',
  ];

  @override
  int get schemaVersion => version;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {
    // Schema installation is deliberately explicit and remains outside
    // Drift's generated database migration hooks.
  }

  /// Installs the schema atomically and is safe to call again.
  ///
  /// Opening the executor first is required by Drift's QueryExecutor contract.
  /// No existing legacy storage is read, written, deleted, or renamed here.
  static Future<void> install(QueryExecutor executor) async {
    final schema = G1DriftSchema();
    await executor.ensureOpen(schema);
    await executor.runCustom('PRAGMA foreign_keys = ON');
    await executor.runCustom('BEGIN');
    try {
      for (final statement in _statements) {
        await executor.runCustom(statement);
      }

      final taskColumns = await executor.runSelect(
        "PRAGMA table_info('tasks')",
        const [],
      );
      final hasLegacyPayload = taskColumns.any(
        (row) => row['name'] == 'legacy_payload_json',
      );
      if (!hasLegacyPayload) {
        await executor.runCustom(
          'ALTER TABLE tasks ADD COLUMN legacy_payload_json TEXT NULL',
        );
      }

      final projectColumns = await executor.runSelect(
        "PRAGMA table_info('projects')",
        const [],
      );
      if (!projectColumns.any((row) => row['name'] == 'color_value')) {
        await executor.runCustom(
          'ALTER TABLE projects ADD COLUMN color_value INTEGER NOT NULL DEFAULT 12462507',
        );
      }
      if (!projectColumns.any((row) => row['name'] == 'is_archived')) {
        await executor.runCustom(
          'ALTER TABLE projects ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (!projectColumns.any((row) => row['name'] == 'legacy_payload_json')) {
        await executor.runCustom(
          'ALTER TABLE projects ADD COLUMN legacy_payload_json TEXT NULL',
        );
      }

      await executor.runCustom('PRAGMA user_version = 3');
      await executor.runCustom('COMMIT');
    } catch (_) {
      try {
        await executor.runCustom('ROLLBACK');
      } catch (_) {
        // Preserve the original schema error.
      }
      rethrow;
    }
  }
}
