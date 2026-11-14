import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/task.dart';
import 'occurrence_sql_codec.dart';
import 'recurrence_sql_codec.dart';
import 'g1_many_to_many_hierarchy_migration.dart';

/// G1-DRIFT relational schema foundation.
class G1DriftSchema implements QueryExecutorUser {
  const G1DriftSchema({G1SqliteFailureInjector? failureInjector})
      : _failureInjector = failureInjector;

  static const int version = 20;

  final G1SqliteFailureInjector? _failureInjector;
  bool _lifecycleCompleted = false;

  static const List<String> _statements = <String>[
    '''CREATE TABLE IF NOT EXISTS tasks (
  id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
  title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
  updated_at TEXT NULL, due_date TEXT NULL, category TEXT NULL,
  notebook_kind TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
  trashed INTEGER NOT NULL, completed INTEGER NOT NULL, completed_at TEXT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  recurrence_json TEXT NULL, legacy_payload_json TEXT NULL)''',
    '''CREATE TABLE IF NOT EXISTS task_reminders (
  id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
  title TEXT NOT NULL, remind_at TEXT NOT NULL, is_all_day INTEGER NOT NULL DEFAULT 0,
  sequence INTEGER NOT NULL, is_enabled INTEGER NOT NULL DEFAULT 1,
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
    '''CREATE TABLE IF NOT EXISTS person_directory (
  person_id TEXT NOT NULL PRIMARY KEY REFERENCES persons(id))''',
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
  id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0, name TEXT NOT NULL,
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
    '''CREATE TABLE IF NOT EXISTS task_occurrences (
  id TEXT NOT NULL PRIMARY KEY, task_id TEXT NOT NULL REFERENCES tasks(id),
  scheduled_at TEXT NOT NULL, status TEXT NOT NULL, completed_at TEXT NULL,
  result TEXT NULL, ordinal INTEGER NOT NULL, UNIQUE(task_id, scheduled_at))''',
    '''CREATE TABLE IF NOT EXISTS occurrence_checklist_items (
  occurrence_id TEXT NOT NULL REFERENCES task_occurrences(id),
  ordinal INTEGER NOT NULL, value TEXT NOT NULL,
  PRIMARY KEY(occurrence_id, ordinal))''',
    '''CREATE TABLE IF NOT EXISTS task_recurrence_rules (
  task_id TEXT NOT NULL PRIMARY KEY REFERENCES tasks(id),
  frequency TEXT NOT NULL, interval INTEGER NOT NULL,
  start_date TEXT NULL, end_date TEXT NULL, occurrence_count INTEGER NULL,
  active INTEGER NOT NULL, tracking_level TEXT NOT NULL)''',
    '''CREATE TABLE IF NOT EXISTS arvin_storage_meta (
  key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)''',
  ];

  @override
  int get schemaVersion => version;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {
    // Drift supplies a _BeforeOpeningExecutor here. It deliberately starts
    // unopened so beforeOpen can opt into its non-blocking executor context.
    // Mark this callback executor open before issuing raw SQL; this does not
    // reopen the underlying database or advance the schema version.
    await executor.ensureOpen(this);
    await _runLifecycle(
      executor,
      versionBefore: details.versionBefore,
      failureInjector: _failureInjector,
    );
    // Drift writes PRAGMA user_version only after beforeOpen returns. This
    // seam deliberately models a process interruption after migration commit
    // and all lifecycle checks, but before Drift registers schema v20.
    await _failureInjector?.call('after_migration_commit_before_drift_version');
    _lifecycleCompleted = true;
  }

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
        final schema = G1DriftSchema();
        await executor.ensureOpen(schema);
        // Executors can be opened earlier by legacy importers and tests. In
        // that case Drift does not invoke beforeOpen again, so complete the
        // same lifecycle here before any store query is allowed to proceed.
        if (!schema._lifecycleCompleted) {
          final rows = await executor.runSelect('PRAGMA user_version', const []);
          final before = rows.isEmpty ? null : (rows.single.values.first as num).toInt();
          await _runLifecycle(
            executor,
            versionBefore: before,
            failureInjector: schema._failureInjector,
          );
          await schema._failureInjector?.call(
            'after_migration_commit_before_drift_version',
          );
          await executor.runCustom('PRAGMA user_version = 20');
          schema._lifecycleCompleted = true;
        }
        completer.complete();
      } catch (error, stackTrace) {
        _installations[executor] = null;
        completer.completeError(error, stackTrace);
      }
    }();
    return completer.future;
  }

  static Future<void> _runLifecycle(
    QueryExecutor executor, {
    required int? versionBefore,
    G1SqliteFailureInjector? failureInjector,
  }) async {
    if (versionBefore != null && versionBefore > version) {
      throw StateError('Database schema $versionBefore is newer than supported $version.');
    }
    await _installSchema(executor);
    final foreignKeys = await executor.runSelect('PRAGMA foreign_keys', const []);
    if (foreignKeys.isEmpty || (foreignKeys.single.values.first as num).toInt() != 1) {
      throw StateError('SQLite foreign keys must be enabled before REV10 v20 migration.');
    }
    final marker = await executor.runSelect(
      'SELECT value FROM arvin_storage_meta WHERE key = ?',
      const [G1ManyToManyHierarchyMigration.markerKey],
    );
    if (versionBefore != null && versionBefore >= version && marker.isEmpty) {
      throw StateError('Schema version is $version but the REV10 migration marker is missing.');
    }
    await failureInjector?.call('before_migration');
    await G1ManyToManyHierarchyMigration(
      failureInjector: failureInjector,
    ).migrate(executor);
    final completed = await executor.runSelect(
      'SELECT value FROM arvin_storage_meta WHERE key = ?',
      const [G1ManyToManyHierarchyMigration.markerKey],
    );
    if (completed.length != 1 || completed.single['value'] != '$version') {
      throw StateError('REV10 v20 migration completion marker is invalid: $completed');
    }
    for (final table in ['center_projects', 'project_categories']) {
      final rows = await executor.runSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        <Object?>[table],
      );
      if (rows.isEmpty) throw StateError('Required v20 relation table is missing: $table');
    }
    final taskColumns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
    final names = taskColumns.map((row) => row['name']).toSet();
    for (final column in ['center_id', 'project_id', 'category_id']) {
      if (!names.contains(column)) throw StateError('Required v20 Task column is missing: $column');
    }
    final violations = await executor.runSelect('PRAGMA foreign_key_check', const []);
    // Legacy v19 references are retained as evidence by the migration. Only
    // new canonical hierarchy tables and Task direct links must be clean.
    final hierarchyViolations = <Map<String, Object?>>[];
    for (final table in ['center_projects', 'project_categories', 'tasks']) {
      hierarchyViolations.addAll(await executor.runSelect('PRAGMA foreign_key_check($table)', const []));
    }
    if (hierarchyViolations.isNotEmpty) {
      throw StateError('REV10 v20 foreign-key verification failed: $hierarchyViolations');
    }
    if (violations.isNotEmpty) {
      // Keep unrelated historical violations visible; do not silently rewrite v19 evidence.
    }
  }

  static Future<void> _installSchema(QueryExecutor executor) async {
    // Seed the new active-directory relation exactly once from the pre-split
    // Persons table. Subsequent installs must never resurrect deleted entries.
    await executor.runCustom('PRAGMA foreign_keys = OFF');
    // Preserve pre-existing v19 FK exceptions as historical evidence. The
    // schema cutover may add canonical relations, but it must not reject or
    // erase a database merely because an older source row was already orphaned.
    final preexistingForeignKeyViolations = await executor.runSelect(
      'PRAGMA foreign_key_check',
      const [],
    );
    final preexistingForeignKeyKeys = preexistingForeignKeyViolations
        .map((row) => '${row['table']}|${row['rowid']}|${row['parent']}|${row['fkid']}')
        .toSet();
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
      // Keep pre-existing canonical relation rows valid when a database was
    // created by an earlier schema build that did not enforce Person FKs.
    final linkedPersonRows = await executor.runSelect(
      '''SELECT person_id FROM follow_up_record_people
         UNION SELECT person_id FROM task_persons''',
      const [],
    );
    final personTimestamp = DateTime.now().toIso8601String();
    for (final linkedPerson in linkedPersonRows) {
      final personId = linkedPerson['person_id'] as String;
      await executor.runInsert(
        '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
           VALUES (?, '', ?, ?)''',
        <Object?>[personId, personTimestamp, personTimestamp],
      );
    }

    final taskColumns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
      const taskColumnAdditions = <String, String>{
        'storage_ordinal': 'INTEGER NOT NULL DEFAULT 0',
        'description': "TEXT NOT NULL DEFAULT ''",
        'created_at': 'TEXT NULL',
        'updated_at': 'TEXT NULL',
        'due_date': 'TEXT NULL',
        'category': 'TEXT NULL',
        'notebook_kind': 'TEXT NULL',
        'priority': "TEXT NOT NULL DEFAULT 'medium'",
        'archived': 'INTEGER NOT NULL DEFAULT 0',
        'trashed': 'INTEGER NOT NULL DEFAULT 0',
        'completed': 'INTEGER NOT NULL DEFAULT 0',
        'completed_at': 'TEXT NULL',
        'is_favorite': 'INTEGER NOT NULL DEFAULT 0',
        'recurrence_json': 'TEXT NULL',
        'legacy_payload_json': 'TEXT NULL',
      };
      for (final entry in taskColumnAdditions.entries) {
        if (!taskColumns.any((row) => row['name'] == entry.key)) {
          await executor.runCustom(
            'ALTER TABLE tasks ADD COLUMN ${entry.key} ${entry.value}',
          );
        }
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
      if (!projectColumns.any((row) => row['name'] == 'storage_ordinal')) {
        await executor.runCustom('ALTER TABLE projects ADD COLUMN storage_ordinal INTEGER NOT NULL DEFAULT 0');
      }
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
      await _removeLegacyTaskReminderMarker(executor);
      // Import the canonical People directory before Task-person snapshots.
      // Otherwise migrateTaskPeople could create a placeholder row first and
      // INSERT OR IGNORE would preserve its synthetic timestamps/name instead
      // of the historical canonical Person record.
      await migrateCanonicalEntities(executor);
      await migrateTaskPeople(executor);
      await _retireLegacyTaskColumns(executor);
      await OccurrenceSqlCodec.migrateLegacyEnvelopes(executor);
      await RecurrenceSqlCodec.migrateLegacyRules(executor);
      final directorySeed = await executor.runSelect(
        "SELECT value FROM arvin_storage_meta WHERE key = 'person_directory_seeded_v1'",
        const [],
      );
      if (directorySeed.isEmpty) {
        await executor.runCustom(
          'INSERT OR IGNORE INTO person_directory (person_id) SELECT id FROM persons',
        );
        await executor.runCustom(
          "INSERT INTO arvin_storage_meta (key, value) VALUES ('person_directory_seeded_v1', '1') "
          "ON CONFLICT(key) DO UPDATE SET value = '1'",
        );
      }
      // The base schema transaction deliberately does not advance user_version.
      // Drift writes the authoritative schema version only after beforeOpen
      // completes; the M2M marker is an atomic migration-completion checkpoint.
      final foreignKeyViolations = await executor.runSelect('PRAGMA foreign_key_check', const []);
      final newlyIntroducedForeignKeyViolations = foreignKeyViolations
          .where((row) => !preexistingForeignKeyKeys.contains(
                '${row['table']}|${row['rowid']}|${row['parent']}|${row['fkid']}',
              ))
          .toList(growable: false);
      if (newlyIntroducedForeignKeyViolations.isNotEmpty) {
        throw StateError(
          'Canonical schema rebuild introduced foreign-key violations: '
          '$newlyIntroducedForeignKeyViolations',
        );
      }
      await executor.runCustom('COMMIT');
      await executor.runCustom('PRAGMA foreign_keys = ON');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      try { await executor.runCustom('PRAGMA foreign_keys = ON'); } catch (_) {}
      rethrow;
    }
  }

  /// Copies historical Task-person identities into canonical Person and
  /// relation tables. Active directory membership is seeded once at cutover;
  /// later migration passes must never reactivate a deleted Person.
  static Future<void> migrateTaskPeople(QueryExecutor executor) async {
    if (!await _hasTable(executor, 'task_people')) return;
    final rows = await executor.runSelect(
      'SELECT person_id, person_json FROM task_people ORDER BY task_id, ordinal',
      const [],
    );

    // Validate the complete legacy source before writing any canonical Person.
    // Silently skipping a malformed row is unsafe because the following
    // migration retires task_people; fail closed so the enclosing install
    // transaction can roll back and retain the original source table.
    final decodedPeople = <Map<String, String>>[];
    for (final row in rows) {
      final rawId = row['person_id'];
      final rawJson = row['person_json'];
      if (rawId is! String || rawId.trim().isEmpty || rawJson is! String) {
        throw const FormatException(
          'Legacy Task-person row has an invalid identity or payload.',
        );
      }
      final personId = rawId.trim();
      late final Object? decoded;
      try {
        decoded = jsonDecode(rawJson);
      } on FormatException {
        throw FormatException(
          'Legacy Task-person payload is invalid for Person $personId.',
        );
      }
      if (decoded is! Map) {
        throw FormatException(
          'Legacy Task-person payload must be an object for Person $personId.',
        );
      }
      final name = decoded['displayName'] ?? decoded['name'];
      if (name is! String || name.trim().isEmpty) {
        throw FormatException(
          'Legacy Task-person display name is missing for Person $personId.',
        );
      }
      decodedPeople.add(<String, String>{
        'id': personId,
        'name': name.trim(),
      });
    }

    final now = DateTime.now().toIso8601String();
    for (final person in decodedPeople) {
      // A Person row may already contain a newer canonical directory name.
      // Legacy Task snapshots must only fill a missing/blank name, never
      // overwrite the shared identity's current display name.
      await executor.runInsert(
        '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
           VALUES (?, ?, ?, ?)''',
        <Object?>[person['id'], person['name'], now, now],
      );
      await executor.runUpdate(
        '''UPDATE persons SET name = ?, updated_at = ?
           WHERE id = ? AND TRIM(name) = ?''',
        <Object?>[person['name'], now, person['id'], ''],
      );
    }
  }

  /// Removes the retired per-row legacy reminder marker without changing
  /// any canonical reminder value. Rebuild instead of DROP COLUMN so this
  /// migration also works on Android SQLite versions that predate DROP COLUMN.
  /// Unexpected columns, indexes, or triggers fail closed rather than being
  /// silently discarded during the rebuild.
  static Future<void> _removeLegacyTaskReminderMarker(
    QueryExecutor executor,
  ) async {
    if (!await _hasTable(executor, 'task_reminders')) return;
    const marker = 'is_legacy_task_reminder';
    const canonicalColumns = <String>[
      'id', 'task_id', 'title', 'remind_at', 'is_all_day', 'sequence', 'is_enabled',
    ];
    final columnRows = await executor.runSelect(
      "PRAGMA table_info('task_reminders')",
      const [],
    );
    final columnNames = columnRows.map((row) => row['name'] as String).toSet();
    if (!columnNames.contains(marker)) return;
    final missing = canonicalColumns.where((name) => !columnNames.contains(name));
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot safely migrate task_reminders: missing canonical columns $missing.',
      );
    }
    final unexpected = columnNames
        .where((name) => !canonicalColumns.contains(name) && name != marker)
        .toList()
      ..sort();
    if (unexpected.isNotEmpty) {
      throw StateError(
        'Cannot safely rebuild task_reminders: unrecognized columns $unexpected.',
      );
    }
    final customIndexes = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'index' "
      "AND tbl_name = 'task_reminders' AND sql IS NOT NULL",
      const [],
    );
    if (customIndexes.isNotEmpty) {
      throw StateError(
        'Cannot safely rebuild task_reminders with custom indexes: $customIndexes',
      );
    }
    final triggers = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'trigger' "
      "AND tbl_name = 'task_reminders'",
      const [],
    );
    if (triggers.isNotEmpty) {
      throw StateError(
        'Cannot safely rebuild task_reminders with triggers: $triggers',
      );
    }
    const retiredTable = 'task_reminders__legacy_marker_v1';
    if (await _hasTable(executor, retiredTable)) {
      throw StateError(
        'Cannot safely migrate task_reminders: temporary table $retiredTable already exists.',
      );
    }

    final before = await executor.runSelect(
      'SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled '
      'FROM task_reminders ORDER BY sequence, id',
      const [],
    );
    await executor.runCustom(
      'ALTER TABLE task_reminders RENAME TO $retiredTable',
    );
    await executor.runCustom('''
      CREATE TABLE task_reminders (
        id TEXT NOT NULL PRIMARY KEY,
        task_id TEXT NOT NULL REFERENCES tasks(id),
        title TEXT NOT NULL,
        remind_at TEXT NOT NULL,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        sequence INTEGER NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        UNIQUE (task_id, sequence)
      )
    ''');
    await executor.runCustom(
      'INSERT INTO task_reminders '
      '(id, task_id, title, remind_at, is_all_day, sequence, is_enabled) '
      'SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled '
      'FROM $retiredTable ORDER BY sequence, id',
    );
    final after = await executor.runSelect(
      'SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled '
      'FROM task_reminders ORDER BY sequence, id',
      const [],
    );
    if (before.length != after.length) {
      throw StateError(
        'Reminder migration row-count mismatch: before=${before.length}, after=${after.length}.',
      );
    }
    for (var index = 0; index < before.length; index++) {
      for (final column in canonicalColumns) {
        if (before[index][column] != after[index][column]) {
          throw StateError(
            'Reminder migration changed row ${before[index]['id']} column $column.',
          );
        }
      }
    }
    await executor.runCustom('DROP TABLE $retiredTable');
  }

  /// Removes retired Task-level SQL columns after their values have been
  /// copied into legacy_payload_json by migrateCanonicalEntities.
  /// Rebuilds only the known canonical shape; unknown columns, custom indexes,
  /// triggers, or outgoing foreign keys fail closed instead of being dropped.
  static Future<void> _retireLegacyTaskColumns(QueryExecutor executor) async {
    if (!await _hasTable(executor, 'tasks')) return;
    const canonicalColumns = <String>[
      'id', 'storage_ordinal', 'title', 'description', 'created_at',
      'updated_at', 'due_date', 'category', 'notebook_kind', 'priority',
      'archived', 'trashed', 'completed', 'completed_at', 'is_favorite',
      'recurrence_json', 'legacy_payload_json',
    ];
    const retiredColumns = <String>{
      'follow_up_enabled', 'follow_up_date', 'reminder_date',
    };
    final columnRows = await executor.runSelect(
      "PRAGMA table_info('tasks')",
      const [],
    );
    final columnNames = columnRows.map((row) => row['name'] as String).toSet();
    if (!columnNames.any(retiredColumns.contains)) {
      await executor.runDelete(
        'DELETE FROM arvin_storage_meta WHERE key = ?',
        const <Object?>['legacy_task_columns_retirement_deferred_v19'],
      );
      return;
    }

    final missing = canonicalColumns.where((name) => !columnNames.contains(name));
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot safely retire legacy Task columns: missing canonical columns $missing.',
      );
    }
    final unexpected = columnNames
        .where((name) => !canonicalColumns.contains(name) && !retiredColumns.contains(name))
        .toList()
      ..sort();
    if (unexpected.isNotEmpty) {
      await _deferLegacyTaskColumnRetirement(
        executor,
        'unrecognized columns: $unexpected',
      );
      return;
    }

    final tableDefinitionRows = await executor.runSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'tasks'",
      const [],
    );
    final tableDefinition = tableDefinitionRows.single['sql'] as String? ?? '';
    if (RegExp(
      r'\b(CHECK|COLLATE|GENERATED|UNIQUE|WITHOUT\s+ROWID)\b',
      caseSensitive: false,
    ).hasMatch(tableDefinition)) {
      await _deferLegacyTaskColumnRetirement(
        executor,
        'unrecognized table constraint or collation',
      );
      return;
    }
    final customIndexes = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'index' "
      "AND tbl_name = 'tasks' AND sql IS NOT NULL",
      const [],
    );
    if (customIndexes.isNotEmpty) {
      await _deferLegacyTaskColumnRetirement(
        executor,
        'custom indexes: $customIndexes',
      );
      return;
    }
    final triggers = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'tasks'",
      const [],
    );
    if (triggers.isNotEmpty) {
      await _deferLegacyTaskColumnRetirement(
        executor,
        'triggers: $triggers',
      );
      return;
    }
    final outgoingForeignKeys = await executor.runSelect(
      "PRAGMA foreign_key_list('tasks')",
      const [],
    );
    if (outgoingForeignKeys.isNotEmpty) {
      await _deferLegacyTaskColumnRetirement(
        executor,
        'outgoing foreign keys: $outgoingForeignKeys',
      );
      return;
    }

    const replacement = 'tasks__canonical_v19';
    if (await _hasTable(executor, replacement)) {
      await _deferLegacyTaskColumnRetirement(
        executor,
        'temporary table $replacement already exists',
      );
      return;
    }
    final projection = canonicalColumns.join(', ');
    final before = await executor.runSelect(
      'SELECT $projection FROM tasks ORDER BY storage_ordinal, id',
      const [],
    );
    await executor.runCustom('''
      CREATE TABLE $replacement (
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
        is_favorite INTEGER NOT NULL DEFAULT 0,
        recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )
    ''');
    await executor.runCustom(
      'INSERT INTO $replacement ($projection) '
      'SELECT $projection FROM tasks ORDER BY storage_ordinal, id',
    );
    final after = await executor.runSelect(
      'SELECT $projection FROM $replacement ORDER BY storage_ordinal, id',
      const [],
    );
    if (before.length != after.length) {
      throw StateError(
        'Task schema rebuild row-count mismatch: before=${before.length}, after=${after.length}.',
      );
    }
    for (var index = 0; index < before.length; index++) {
      for (final column in canonicalColumns) {
        if (before[index][column] != after[index][column]) {
          throw StateError(
            'Task schema rebuild changed row ${before[index]['id']} column $column.',
          );
        }
      }
    }

    await executor.runCustom('DROP TABLE tasks');
    await executor.runCustom('ALTER TABLE $replacement RENAME TO tasks');
    final finalColumns = await executor.runSelect(
      "PRAGMA table_info('tasks')",
      const [],
    );
    final finalNames = finalColumns.map((row) => row['name'] as String).toSet();
    if (retiredColumns.any(finalNames.contains) ||
        canonicalColumns.any((name) => !finalNames.contains(name))) {
      throw StateError('Task schema retirement verification failed: $finalNames');
    }
    await executor.runDelete(
      'DELETE FROM arvin_storage_meta WHERE key = ?',
      const <Object?>['legacy_task_columns_retirement_deferred_v19'],
    );
  }

  static Future<void> _deferLegacyTaskColumnRetirement(
    QueryExecutor executor,
    String reason,
  ) async {
    await executor.runInsert(
      '''INSERT INTO arvin_storage_meta (key, value) VALUES (?, ?)
         ON CONFLICT(key) DO UPDATE SET value = excluded.value''',
      <Object?>['legacy_task_columns_retirement_deferred_v19', reason],
    );
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
    }

    final hasLegacyFollowUps = await _hasTable(executor, 'follow_ups');
    final hasLegacyFollowUpPeople = await _hasTable(executor, 'follow_up_people');
    final legacyFollowUpMetadataByTask = <String, List<Map<String, dynamic>>>{};
    if (hasLegacyFollowUps) {
      final legacyFollowUps = await executor.runSelect(
        'SELECT * FROM follow_ups ORDER BY task_id, ordinal',
        const [],
      );
      for (final row in legacyFollowUps) {
        final rawNextFollowUp = row['next_follow_up'];
        if (rawNextFollowUp != null) {
          final taskId = row['task_id'] as String;
          legacyFollowUpMetadataByTask
              .putIfAbsent(taskId, () => <Map<String, dynamic>>[])
              .add(<String, dynamic>{
            'id': row['id'],
            'nextFollowUp': rawNextFollowUp,
            if (row['next_follow_up_all_day'] != null)
              'nextFollowUpAllDay': row['next_follow_up_all_day'],
          });
        }
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
    final hasLegacyTaskFollowUpEnabled = taskColumns.any((row) => row['name'] == 'follow_up_enabled');
    final hasLegacyTaskFollowUpDate = taskColumns.any((row) => row['name'] == 'follow_up_date');
    final reminderColumn = hasLegacyTaskReminder ? 'reminder_date' : 'NULL AS reminder_date';
    final followUpEnabledColumn = hasLegacyTaskFollowUpEnabled
        ? 'follow_up_enabled'
        : '0 AS follow_up_enabled';
    final followUpDateColumn = hasLegacyTaskFollowUpDate
        ? 'follow_up_date'
        : 'NULL AS follow_up_date';
    final taskOrderColumn = taskColumns.any(
      (row) => row['name'] == 'storage_ordinal',
    )
        ? 'storage_ordinal'
        : 'id';
    final taskRows = await executor.runSelect(
      'SELECT id, title, $reminderColumn, $followUpEnabledColumn, $followUpDateColumn, legacy_payload_json FROM tasks ORDER BY $taskOrderColumn, id',
      const [],
    );
    // Normalize legacy All-Day due dates to floating date-only values.
    for (final row in taskRows) {
      final rawPayload = row['legacy_payload_json'];
      if (rawPayload is! String || rawPayload.trim().isEmpty) continue;
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map || decoded['allDay'] != true) continue;
      final rawDueDate = decoded['dueDate'];
      if (rawDueDate is! String) continue;
      final parsedDueDate = DateTime.tryParse(rawDueDate);
      if (parsedDueDate == null) continue;
      final dateOnly = _dateOnlyStorageValue(parsedDueDate);
      await executor.runUpdate(
        'UPDATE tasks SET due_date = ? WHERE id = ?',
        <Object?>[dateOnly, row['id']],
      );
    }
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
      // Preserve source presence exactly. A missing legacy SQL column is not
      // equivalent to a present column containing NULL, and explicit JSON
      // NULL must not be overwritten by a stale SQL compatibility value.
      if (!payload.containsKey('reminderDate') && hasLegacyTaskReminder) {
        payload['reminderDate'] = row['reminder_date'];
      }
      if (!payload.containsKey('followUpDate') && hasLegacyTaskFollowUpDate) {
        payload['followUpDate'] = row['follow_up_date'];
      }
      if (!payload.containsKey('followUpEnabled') &&
          hasLegacyTaskFollowUpEnabled) {
        final rawEnabled = row['follow_up_enabled'];
        payload['followUpEnabled'] = rawEnabled == null
            ? null
            : (rawEnabled as num).toInt() == 1;
      }
      final legacyRecords = legacyFollowUpMetadataByTask[row['id']];
      if (legacyRecords != null && legacyRecords.isNotEmpty) {
        final rawMetadata = payload['legacyFollowUpMetadata'];
        final metadata = rawMetadata is Map
            ? Map<String, dynamic>.from(rawMetadata)
            : <String, dynamic>{};
        final rawRecords = metadata['followUps'];
        final records = rawRecords is List
            ? rawRecords
                .whereType<Map>()
                .map(Map<String, dynamic>.from)
                .toList(growable: true)
            : <Map<String, dynamic>>[];
        for (final record in legacyRecords) {
          final id = record['id'];
          final existingIndex = records.indexWhere(
            (item) => id != null && item['id'] == id,
          );
          if (existingIndex < 0) {
            records.add(record);
          } else {
            records[existingIndex] = <String, dynamic>{
              ...records[existingIndex],
              ...record,
            };
          }
        }
        metadata['followUps'] = records;
        payload['legacyFollowUpMetadata'] = metadata;
      }
      final task = Task.fromLegacyJson(payload);
      for (final reminder in task.taskReminders) {
        await executor.runInsert(
          '''INSERT OR IGNORE INTO task_reminders
             (id, task_id, title, remind_at, is_all_day, sequence, is_enabled)
             VALUES (?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            reminder.id, task.id, reminder.title, reminder.storageDateValue,
            reminder.isAllDay ? 1 : 0, reminder.sequence, reminder.isEnabled ? 1 : 0,
          ],
        );
      }
      // Persist the migration marker and canonical reminder collection in the
      // legacy envelope so subsequent installs do not re-run this conversion.
      final migratedEnvelope = Map<String, dynamic>.from(payload)
        ..addAll(task.toJson());
      await executor.runUpdate(
        'UPDATE tasks SET legacy_payload_json = ? WHERE id = ?',
        <Object?>[jsonEncode(migratedEnvelope), task.id],
      );
    }

    // Older SQL Follow-up rows may have a reminder date even when the JSON
    // envelope predates the TaskReminder conversion. Preserve it independently.
    if (hasLegacyFollowUps) {
      final legacyFollowUpColumns = await executor.runSelect(
        "PRAGMA table_info('follow_ups')",
        const [],
      );
      final hasLegacyFollowUpReminder = legacyFollowUpColumns.any(
        (row) => row['name'] == 'reminder_date',
      );
      if (hasLegacyFollowUpReminder) {
        final legacyFollowUpReminders = await executor.runSelect(
          'SELECT id, task_id, reminder_date FROM follow_ups '
          'WHERE reminder_date IS NOT NULL ORDER BY task_id, ordinal',
          const [],
        );
        for (final legacy in legacyFollowUpReminders) {
          final taskRows = await executor.runSelect(
            'SELECT legacy_payload_json FROM tasks WHERE id = ?',
            <Object?>[legacy['task_id']],
          );
          var isAllDay = _isDateOnlyStorageValue(legacy['reminder_date']);
          if (taskRows.isNotEmpty) {
            final rawPayload = taskRows.single['legacy_payload_json'];
            if (rawPayload is String && rawPayload.trim().isNotEmpty) {
              final decoded = jsonDecode(rawPayload);
              if (decoded is Map && decoded['followUps'] is List) {
                for (final rawFollowUp in decoded['followUps'] as List) {
                  if (rawFollowUp is Map && rawFollowUp['id'] == legacy['id']) {
                    isAllDay = isAllDay || rawFollowUp['reminderAllDay'] == true;
                    break;
                  }
                }
              }
            }
          }
          final rawDate = legacy['reminder_date'];
          if (rawDate is! String || rawDate.trim().isEmpty) {
            throw FormatException('Invalid legacy Follow-up reminder for ${legacy['id']}');
          }
          final parsed = DateTime.tryParse(rawDate);
          if (parsed == null) {
            throw FormatException('Invalid legacy Follow-up reminder date: $rawDate');
          }
          final sequenceRows = await executor.runSelect(
            'SELECT COALESCE(MAX(sequence), 0) + 1 AS next_sequence '
            'FROM task_reminders WHERE task_id = ?',
            <Object?>[legacy['task_id']],
          );
          final sequence = (sequenceRows.single['next_sequence'] as num).toInt();
          await executor.runInsert(
            '''INSERT OR IGNORE INTO task_reminders
               (id, task_id, title, remind_at, is_all_day, sequence, is_enabled)
               VALUES (?, ?, ?, ?, ?, ?, 1)''',
            <Object?>[
              'follow-up-reminder-${legacy['task_id']}-${legacy['id']}',
              legacy['task_id'],
              'یادآور پیگیری',
              isAllDay ? _dateOnlyStorageValue(parsed) : parsed.toIso8601String(),
              isAllDay ? 1 : 0,
              sequence,
            ],
          );
        }
      }
    }

    if (hasLegacyFollowUpPeople) {
    }
    if (hasLegacyFollowUps) {
    }
    if (hasPeople) {
    }
  }

  /// Removes the temporary per-reminder legacy marker while preserving
  /// every canonical reminder row and its stable ID.
  static String _dateOnlyStorageValue(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static bool _isDateOnlyStorageValue(Object? value) {
    if (value is! String || value.length != 10) return false;
    return value[4] == '-' &&
        value[7] == '-' &&
        int.tryParse(value.substring(0, 4)) != null &&
        int.tryParse(value.substring(5, 7)) != null &&
        int.tryParse(value.substring(8, 10)) != null;
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
