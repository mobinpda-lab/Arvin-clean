import 'dart:convert';

import 'package:drift/drift.dart';

/// Additive REV10 hierarchy migration for the canonical G1 SQLite v19 schema.
///
/// This is intentionally separate from the rejected single-parent candidate.
/// It creates two independent junction tables and keeps every v19 source
/// column/table in place. Run only on disposable v19 fixtures until all
/// repository and consumer parity work is accepted.
class G1ManyToManyHierarchyMigration {
  const G1ManyToManyHierarchyMigration();

  static const int sourceSchemaVersion = 19;
  static const int targetSchemaVersion = 20;
  static const String markerKey = 'rev10_hierarchy_schema_version';

  Future<void> migrate(QueryExecutor executor, {int fromVersion = sourceSchemaVersion}) async {
    if (fromVersion != sourceSchemaVersion) {
      throw ArgumentError.value(fromVersion, 'fromVersion', 'Only schema v19 is supported.');
    }

    await executor.runCustom('PRAGMA foreign_keys = ON');
    final fk = await executor.runSelect('PRAGMA foreign_keys', const []);
    if (fk.isEmpty || (fk.single.values.first as num).toInt() != 1) {
      throw StateError('REV10 migration requires SQLite foreign_keys=ON.');
    }

    final meta = await executor.runSelect(
      'SELECT value FROM arvin_storage_meta WHERE key = ?',
      const [markerKey],
    );
    if (meta.isNotEmpty) {
      final version = int.tryParse(meta.single['value']?.toString() ?? '');
      if (version == targetSchemaVersion) return;
      throw StateError('Unexpected existing REV10 hierarchy marker: $version');
    }

    await _requireTable(executor, 'centers');
    await _requireTable(executor, 'projects');
    await _requireTable(executor, 'tasks');
    await _requireTable(executor, 'project_items');
    await _requireTable(executor, 'taxonomy_categories');
    await _requireTable(executor, 'arvin_storage_meta');
    await _requireColumn(executor, 'projects', 'center_id');
    await _requireColumn(executor, 'tasks', 'category');
    await _requireColumn(executor, 'tasks', 'legacy_payload_json');

    await executor.runCustom('BEGIN');
    try {
      await executor.runCustom('''
        CREATE TABLE center_projects (
          center_id TEXT NOT NULL REFERENCES centers(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
          project_id TEXT NOT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
          PRIMARY KEY (center_id, project_id)
        )
      ''');
      await executor.runCustom('''
        CREATE TABLE categories (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          legacy_name TEXT NULL UNIQUE,
          storage_ordinal INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await executor.runCustom('''
        CREATE TABLE project_categories (
          project_id TEXT NOT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
          category_id TEXT NOT NULL REFERENCES categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
          PRIMARY KEY (project_id, category_id)
        )
      ''');

      await _addTaskColumn(executor, 'center_id',
          'TEXT NULL REFERENCES centers(id) ON UPDATE RESTRICT ON DELETE RESTRICT');
      await _addTaskColumn(executor, 'project_id',
          'TEXT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT');
      await _addTaskColumn(executor, 'category_id',
          'TEXT NULL REFERENCES categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT');

      await executor.runCustom('''
        CREATE INDEX idx_center_projects_project_center
          ON center_projects(project_id, center_id)
      ''');
      await executor.runCustom('''
        CREATE INDEX idx_project_categories_category_project
          ON project_categories(category_id, project_id)
      ''');
      await executor.runCustom('CREATE INDEX idx_tasks_center_id ON tasks(center_id)');
      await executor.runCustom('CREATE INDEX idx_tasks_project_id ON tasks(project_id)');
      await executor.runCustom('CREATE INDEX idx_tasks_category_id ON tasks(category_id)');

      // The former projects.center_id value is direct evidence for exactly one
      // legacy edge. Copy only valid endpoints and classify broken references.
      final centerRows = await executor.runSelect('SELECT id FROM centers', const []);
      final centerIds = centerRows.map((r) => r['id'] as String).toSet();
      final projectRows = await executor.runSelect('SELECT id, center_id FROM projects ORDER BY id', const []);
      final projectIds = projectRows.map((r) => r['id'] as String).toSet();
      for (final project in projectRows) {
        final centerId = project['center_id'] as String?;
        if (centerId == null) continue;
        final projectId = project['id'] as String;
        if (!centerIds.contains(centerId)) {
          await _recordEntityException(executor, 'project', projectId,
              'PROJECT_CENTER_REFERENCE_MISSING', 'legacy projects.center_id=$centerId');
          continue;
        }
        await executor.runInsert(
          'INSERT OR IGNORE INTO center_projects(center_id, project_id) VALUES (?, ?)',
          <Object?>[centerId, projectId],
        );
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final legacyNames = <String>{};
      final catalog = await executor.runSelect(
        'SELECT name, created_at FROM taxonomy_categories ORDER BY name',
        const [],
      );
      final createdAtByName = <String, String>{
        for (final row in catalog)
          row['name'] as String: row['created_at'] as String,
      };
      legacyNames.addAll(createdAtByName.keys);

      final tasks = await executor.runSelect(
        'SELECT id, category, legacy_payload_json FROM tasks ORDER BY id',
        const [],
      );
      for (final row in tasks) {
        final name = (row['category'] as String?)?.trim();
        if (name != null && name.isNotEmpty) legacyNames.add(name);
      }

      final categoryIdByName = <String, String>{};
      var ordinal = 0;
      for (final name in legacyNames.toList()..sort()) {
        final id = _legacyCategoryId(name);
        categoryIdByName[name] = id;
        final created = createdAtByName[name] ?? now;
        await executor.runInsert(
          '''INSERT INTO categories
             (id, name, legacy_name, storage_ordinal, is_archived, created_at, updated_at)
             VALUES (?, ?, ?, ?, 0, ?, ?)''',
          <Object?>[id, name, name, ordinal++, created, created],
        );
      }

      for (final row in tasks) {
        final taskId = row['id'] as String;
        String? centerId;
        final rawPayload = row['legacy_payload_json'];
        if (rawPayload is String && rawPayload.trim().isNotEmpty) {
          try {
            final decoded = jsonDecode(rawPayload);
            if (decoded is Map && decoded['centerId'] is String) {
              final candidate = (decoded['centerId'] as String).trim();
              if (candidate.isNotEmpty) {
                if (centerIds.contains(candidate)) {
                  centerId = candidate;
                } else {
                  await _recordEntityException(executor, 'task', taskId,
                      'TASK_CENTER_REFERENCE_MISSING', 'legacy centerId=$candidate');
                }
              }
            }
          } on FormatException {
            await _recordEntityException(executor, 'task', taskId,
                'TASK_LEGACY_PAYLOAD_INVALID', rawPayload);
          }
        }

        final memberships = await executor.runSelect(
          'SELECT project_id FROM project_items WHERE task_id = ? ORDER BY project_id',
          <Object?>[taskId],
        );
        String? projectId;
        if (memberships.length == 1) {
          final candidate = memberships.single['project_id'] as String;
          if (projectIds.contains(candidate)) {
            projectId = candidate;
          } else {
            await _recordEntityException(executor, 'task', taskId,
                'TASK_PROJECT_REFERENCE_MISSING', 'legacy project_id=$candidate');
          }
        } else if (memberships.length > 1) {
          await _recordEntityException(executor, 'task', taskId,
              'TASK_MULTIPLE_LEGACY_PROJECTS',
              memberships.map((r) => r['project_id']).join(','));
        }

        final rawCategory = (row['category'] as String?)?.trim();
        final categoryId = rawCategory == null || rawCategory.isEmpty
            ? null
            : categoryIdByName[rawCategory];

        await executor.runUpdate(
          'UPDATE tasks SET center_id = ?, project_id = ?, category_id = ? WHERE id = ?',
          <Object?>[centerId, projectId, categoryId, taskId],
        );

        if (centerId != null && projectId != null) {
          final pair = await executor.runSelect(
            'SELECT 1 FROM center_projects WHERE center_id = ? AND project_id = ?',
            <Object?>[centerId, projectId],
          );
          if (pair.isEmpty) {
            await _recordEntityException(executor, 'task', taskId,
                'TASK_CENTER_PROJECT_PAIR_UNRESOLVED',
                'center=$centerId;project=$projectId');
          }
        }
        if (projectId != null && categoryId != null) {
          // Never manufacture Project↔Category edges from a Task's text value.
          await _recordEntityException(executor, 'task', taskId,
              'TASK_PROJECT_CATEGORY_EDGE_UNRESOLVED',
              'project=$projectId;category=$categoryId');
        }
        if (centerId != null && categoryId != null && projectId == null) {
          final path = await executor.runSelect(
            '''SELECT 1 FROM center_projects cp
               JOIN project_categories pc ON pc.project_id = cp.project_id
               WHERE cp.center_id = ? AND pc.category_id = ? LIMIT 1''',
            <Object?>[centerId, categoryId],
          );
          if (path.isEmpty) {
            await _recordEntityException(executor, 'task', taskId,
                'TASK_CENTER_CATEGORY_PATH_UNRESOLVED',
                'center=$centerId;category=$categoryId');
          }
        }
      }

      await _installTaskCompatibilityTriggers(executor);
      // Check only relations introduced or rewritten by this migration.
      // Historical projects.center_id violations are retained as evidence and
      // are classified in the exception ledger; they must not be silently
      // deleted or make an otherwise reversible migration lose source data.
      final violations = <Map<String, Object?>>[];
      for (final table in ['center_projects', 'project_categories', 'tasks']) {
        violations.addAll(await executor.runSelect(
          'PRAGMA foreign_key_check($table)',
          const [],
        ));
      }
      if (violations.isNotEmpty) {
        throw StateError('REV10 v19→v20 foreign-key check failed: $violations');
      }
      await executor.runInsert(
        '''INSERT INTO arvin_storage_meta(key, value) VALUES (?, ?)
           ON CONFLICT(key) DO UPDATE SET value = excluded.value''',
        <Object?>[markerKey, '$targetSchemaVersion'],
      );
      await executor.runCustom('COMMIT');
    } catch (_) {
      try {
        await executor.runCustom('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> _installTaskCompatibilityTriggers(QueryExecutor executor) async {
    const guard = '''
      SELECT CASE WHEN NEW.center_id IS NOT NULL AND NEW.project_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM center_projects cp
          WHERE cp.center_id = NEW.center_id AND cp.project_id = NEW.project_id
        )
        THEN RAISE(ABORT, 'Task Center/Project pair is not linked') END;
      SELECT CASE WHEN NEW.project_id IS NOT NULL AND NEW.category_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM project_categories pc
          WHERE pc.project_id = NEW.project_id AND pc.category_id = NEW.category_id
        )
        THEN RAISE(ABORT, 'Task Project/Category pair is not linked') END;
      SELECT CASE WHEN NEW.center_id IS NOT NULL AND NEW.category_id IS NOT NULL
        AND NEW.project_id IS NULL
        AND NOT EXISTS (
          SELECT 1 FROM center_projects cp
          JOIN project_categories pc ON pc.project_id = cp.project_id
          WHERE cp.center_id = NEW.center_id AND pc.category_id = NEW.category_id
        )
        THEN RAISE(ABORT, 'Task Center/Category has no linked Project path') END;
    ''';
    await executor.runCustom('''
      CREATE TRIGGER rev10_m2m_task_hierarchy_insert
      BEFORE INSERT ON tasks BEGIN $guard END
    ''');
    await executor.runCustom('''
      CREATE TRIGGER rev10_m2m_task_hierarchy_update
      BEFORE UPDATE OF center_id, project_id, category_id ON tasks BEGIN $guard END
    ''');
  }

  Future<void> _addTaskColumn(QueryExecutor executor, String name, String declaration) async {
    if (await _hasColumn(executor, 'tasks', name)) return;
    await executor.runCustom('ALTER TABLE tasks ADD COLUMN $name $declaration');
  }

  Future<void> _requireTable(QueryExecutor executor, String name) async {
    final rows = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>[name],
    );
    if (rows.isEmpty) throw StateError('Required v19 table is missing: $name');
  }

  Future<void> _requireColumn(QueryExecutor executor, String table, String column) async {
    if (!await _hasColumn(executor, table, column)) {
      throw StateError('Required v19 column is missing: $table.$column');
    }
  }

  Future<bool> _hasColumn(QueryExecutor executor, String table, String column) async {
    final rows = await executor.runSelect("PRAGMA table_info('$table')", const []);
    return rows.any((row) => row['name'] == column);
  }

  Future<void> _recordEntityException(
    QueryExecutor executor,
    String entityType,
    String entityId,
    String code,
    String evidence,
  ) async {
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS rev10_hierarchy_migration_exceptions (
        exception_key TEXT NOT NULL PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        issue_code TEXT NOT NULL,
        source_evidence TEXT NOT NULL,
        resolution_status TEXT NOT NULL DEFAULT 'UNRESOLVED'
      )
    ''');
    await executor.runInsert(
      '''INSERT OR IGNORE INTO rev10_hierarchy_migration_exceptions
         (exception_key, entity_type, entity_id, issue_code, source_evidence)
         VALUES (?, ?, ?, ?, ?)''',
      <Object?>['$entityType:$entityId:$code', entityType, entityId, code, evidence],
    );
  }

  String _legacyCategoryId(String name) =>
      'legacy-category-${base64Url.encode(utf8.encode(name)).replaceAll('=', '')}';
}
