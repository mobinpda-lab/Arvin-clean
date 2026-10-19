import 'dart:convert';

import 'package:drift/drift.dart';

/// G1-DRIFT relational schema foundation.
class G1DriftSchema implements QueryExecutorUser {
  static const int version = 6;

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
  date_time TEXT NOT NULL, title TEXT NULL, note TEXT NOT NULL, result TEXT NULL,
  reminder_date TEXT NULL, next_follow_up TEXT NULL, completed INTEGER NOT NULL,
  waiting_for_response INTEGER NOT NULL DEFAULT 0,
  ordinal INTEGER NOT NULL, UNIQUE (task_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS projects (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  color_value INTEGER NOT NULL DEFAULT 4283059371, is_archived INTEGER NOT NULL DEFAULT 0,
  legacy_payload_json TEXT NULL)''',
    '''CREATE TABLE IF NOT EXISTS project_items (
  project_id TEXT NOT NULL REFERENCES projects(id), task_id TEXT NOT NULL REFERENCES tasks(id),
  ordinal INTEGER NOT NULL, PRIMARY KEY (project_id, task_id))''',
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
    '''CREATE TABLE IF NOT EXISTS task_people (
  task_id TEXT NOT NULL REFERENCES tasks(id), person_id TEXT NOT NULL,
  person_json TEXT NOT NULL, ordinal INTEGER NOT NULL, PRIMARY KEY (task_id, person_id))''',
    '''CREATE TABLE IF NOT EXISTS people (
  id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS follow_up_people (
  follow_up_id TEXT NOT NULL REFERENCES follow_ups(id), person_id TEXT NOT NULL,
  ordinal INTEGER NOT NULL, PRIMARY KEY (follow_up_id, person_id))''',
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
      final followUpColumns = await executor.runSelect("PRAGMA table_info('follow_ups')", const []);
      if (!followUpColumns.any((row) => row['name'] == 'title')) {
        await executor.runCustom('ALTER TABLE follow_ups ADD COLUMN title TEXT NULL');
      }
      if (!followUpColumns.any((row) => row['name'] == 'waiting_for_response')) {
        await executor.runCustom(
          'ALTER TABLE follow_ups ADD COLUMN waiting_for_response INTEGER NOT NULL DEFAULT 0',
        );
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
      await migrateTaskPeople(executor);
      // Do not write PRAGMA user_version here. The canonical migration marker
      // is arvin_storage_meta, and this install path can be reached by more
      // than one SQLite connection (for example app + Android smoke tooling).
      // A user_version write acquires a database-wide lock and can fail even
      // though the schema itself is already installed. Schema DDL above is
      // idempotent and the marker remains the canonical cutover boundary.
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  /// Copies historical task-person identities into the canonical directory.
  /// Existing directory rows win for creation time; names are refreshed from
  /// the current task relation. Re-running this migration is safe.
  static Future<void> migrateTaskPeople(QueryExecutor executor) async {
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
          '''INSERT INTO people (id, name, created_at, updated_at) VALUES (?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET name = excluded.name, updated_at = excluded.updated_at''',
          <Object?>[id.trim(), name.trim(), now, now],
        );
      } on FormatException {
        continue;
      }
    }
  }

  /// Recovers Follow-up metadata that older SQL imports omitted while the
  /// canonical Task envelope still retains it. The marker makes this repair
  /// one-time; current SQL values win, except absent title/relations and a
  /// false waiting flag where the retained source explicitly says true.
  static Future<void> migrateFollowUpMetadata(QueryExecutor executor) async {
    final marker = await executor.runSelect(
      "SELECT value FROM arvin_storage_meta WHERE key = 'follow_up_metadata_backfill_v1'",
      const [],
    );
    if (marker.isNotEmpty && marker.single['value'] == '1') return;

    await executor.runCustom('BEGIN');
    try {
      final taskRows = await executor.runSelect(
        'SELECT id, legacy_payload_json FROM tasks ORDER BY storage_ordinal, id',
        const [],
      );
      for (final taskRow in taskRows) {
        final taskId = taskRow['id'];
        final rawPayload = taskRow['legacy_payload_json'];
        if (taskId is! String || rawPayload is! String || rawPayload.trim().isEmpty) {
          continue;
        }

        dynamic decoded;
        try {
          decoded = jsonDecode(rawPayload);
        } on FormatException {
          continue;
        }
        if (decoded is! Map || decoded['followUps'] is! List) continue;

        for (final rawFollowUp in decoded['followUps'] as List) {
          if (rawFollowUp is! Map) continue;
          final source = Map<String, dynamic>.from(rawFollowUp);
          final followUpId = source['id'];
          if (followUpId is! String || followUpId.trim().isEmpty) continue;
          final currentRows = await executor.runSelect(
            'SELECT title, waiting_for_response FROM follow_ups WHERE id = ? AND task_id = ?',
            <Object?>[followUpId, taskId],
          );
          if (currentRows.isEmpty) continue;
          final current = currentRows.single;
          final sourceTitle = source['title'];
          final currentTitle = current['title'];
          if (sourceTitle is String &&
              sourceTitle.trim().isNotEmpty &&
              (currentTitle == null ||
                  (currentTitle is String && currentTitle.trim().isEmpty))) {
            await executor.runCustom(
              'UPDATE follow_ups SET title = ? WHERE id = ? AND task_id = ?',
              <Object?>[sourceTitle.trim(), followUpId, taskId],
            );
          }

          if (source['waitingForResponse'] == true &&
              (current['waiting_for_response'] as num?)?.toInt() != 1) {
            await executor.runCustom(
              'UPDATE follow_ups SET waiting_for_response = 1 WHERE id = ? AND task_id = ?',
              <Object?>[followUpId, taskId],
            );
          }

          final rawPersonIds = source['personIds'];
          if (rawPersonIds is List) {
            final existingRows = await executor.runSelect(
              'SELECT person_id FROM follow_up_people WHERE follow_up_id = ?',
              <Object?>[followUpId],
            );
            final existingIds = existingRows
                .map((row) => row['person_id'])
                .whereType<String>()
                .toSet();
            final seen = <String>{};
            for (var personOrdinal = 0;
                personOrdinal < rawPersonIds.length;
                personOrdinal++) {
              final rawPersonId = rawPersonIds[personOrdinal];
              if (rawPersonId is! String) continue;
              final personId = rawPersonId.trim();
              if (personId.isEmpty ||
                  !seen.add(personId) ||
                  existingIds.contains(personId)) {
                continue;
              }
              await executor.runInsert(
                'INSERT OR IGNORE INTO follow_up_people (follow_up_id, person_id, ordinal) VALUES (?, ?, ?)',
                <Object?>[followUpId, personId, personOrdinal],
              );
            }
          }
        }
      }
      await executor.runCustom(
        "INSERT INTO arvin_storage_meta (key, value) VALUES ('follow_up_metadata_backfill_v1', '1') "
        "ON CONFLICT(key) DO UPDATE SET value = '1'",
      );
      await executor.runCustom('COMMIT');
    } catch (_) {
      try {
        await executor.runCustom('ROLLBACK');
      } catch (_) {}
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
