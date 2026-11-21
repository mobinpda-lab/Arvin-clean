import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

typedef G1HierarchyFailureInjector = FutureOr<void> Function(String stage);

/// Additive migration from the live canonical G1 schema v8 to the REV10
/// relationship-graph foundation v9. Legacy tables and text fields remain
/// intact until all readers, writers and backup paths have been migrated.
class G1Rev10HierarchyV9Migration {
  const G1Rev10HierarchyV9Migration({this.failureInjector});

  static const int sourceSchemaVersion = 8;
  static const int targetSchemaVersion = 9;
  static const String markerKey = 'rev10_hierarchy_schema_version';

  final G1HierarchyFailureInjector? failureInjector;

  Future<void> _inject(String stage) async {
    final injector = failureInjector;
    if (injector != null) await injector(stage);
  }

  Future<void> migrate(QueryExecutor executor) async {
    await executor.runCustom('PRAGMA foreign_keys = ON');
    final foreignKeys = await executor.runSelect('PRAGMA foreign_keys', const []);
    if (foreignKeys.isEmpty ||
        (foreignKeys.single.values.first as num).toInt() != 1) {
      throw StateError('REV10 v9 requires SQLite foreign_keys=ON.');
    }

    final marker = await executor.runSelect(
      'SELECT value FROM arvin_storage_meta WHERE key = ?',
      const [markerKey],
    );
    if (marker.isNotEmpty) {
      final version = int.tryParse(marker.single['value']?.toString() ?? '');
      if (version == targetSchemaVersion) return;
      throw StateError('Unexpected REV10 hierarchy marker: $version');
    }

    for (final table in [
      'tasks',
      'projects',
      'project_items',
      'taxonomy_categories',
      'arvin_storage_meta',
    ]) {
      await _requireTable(executor, table);
    }

    await executor.runCustom('BEGIN');
    try {
      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS centers (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS center_projects (
          center_id TEXT NOT NULL REFERENCES centers(id)
            ON UPDATE RESTRICT ON DELETE RESTRICT,
          project_id TEXT NOT NULL REFERENCES projects(id)
            ON UPDATE RESTRICT ON DELETE RESTRICT,
          PRIMARY KEY (center_id, project_id)
        )
      ''');
      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS categories (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          legacy_name TEXT NULL UNIQUE,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS project_categories (
          project_id TEXT NOT NULL REFERENCES projects(id)
            ON UPDATE RESTRICT ON DELETE RESTRICT,
          category_id TEXT NOT NULL REFERENCES categories(id)
            ON UPDATE RESTRICT ON DELETE RESTRICT,
          PRIMARY KEY (project_id, category_id)
        )
      ''');
      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS arvin_migration_exceptions (
          id TEXT NOT NULL PRIMARY KEY,
          migration_key TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          code TEXT NOT NULL,
          details_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE (migration_key, entity_type, entity_id, code)
        )
      ''');
      // v8 already owns a Center catalog and a single Project.center_id
      // edge. Preserve that historical edge by promoting it into the canonical
      // M2M relation; CREATE TABLE IF NOT EXISTS does not upgrade old columns.
      final centerColumns = await executor.runSelect(
        "PRAGMA table_info('centers')",
        const [],
      );
      if (!centerColumns.any((row) => row['name'] == 'updated_at')) {
        await executor.runCustom(
          'ALTER TABLE centers ADD COLUMN updated_at TEXT NULL',
        );
      }
      await executor.runCustom(
        '''UPDATE centers
           SET updated_at = created_at
           WHERE updated_at IS NULL OR TRIM(updated_at) = '' ''',
      );
      final centersWithoutUpdateTime = await executor.runSelect(
        "SELECT id FROM centers WHERE updated_at IS NULL OR TRIM(updated_at) = ''",
        const [],
      );
      if (centersWithoutUpdateTime.isNotEmpty) {
        throw StateError(
          'REV10 v8→v9 could not backfill Center updated_at: '
          '$centersWithoutUpdateTime',
        );
      }

      final projectColumns = await executor.runSelect(
        "PRAGMA table_info('projects')",
        const [],
      );
      // This preservation field is part of every destination schema, not
      // merely a repair column created when an orphan happens to be present.
      // Existing v8 databases need the additive upgrade; fresh v9 databases
      // already receive it from G1DriftSchema._statements.
      var hasLegacyCenterIdColumn =
          projectColumns.any((row) => row['name'] == 'legacy_center_id');
      if (!hasLegacyCenterIdColumn) {
        await executor.runCustom(
          'ALTER TABLE projects ADD COLUMN legacy_center_id TEXT NULL',
        );
        hasLegacyCenterIdColumn = true;
      }
      if (projectColumns.any((row) => row['name'] == 'center_id')) {
        final legacyCenterLinks = await executor.runSelect(
          '''SELECT id, center_id FROM projects
             WHERE center_id IS NOT NULL ORDER BY id''',
          const [],
        );
        for (final link in legacyCenterLinks) {
          final centerId = link['center_id'] as String;
          final center = await executor.runSelect(
            'SELECT id FROM centers WHERE id = ?',
            <Object?>[centerId],
          );
          if (center.isEmpty) {
            // Preserve the legacy Project.center_id value as source evidence,
            // but never manufacture a Center or an invalid M2M edge. The
            // exception is written inside this migration transaction: if
            // recording it fails, the transaction rolls back and no
            // completion marker can be committed.
            final projectId = link['id'] as String;
            // The historical column has an enforced FK. Keep the orphaned
            // identifier in a non-FK preservation column and the exception
            // ledger, then clear only the invalid FK edge so global FK checks
            // remain meaningful. The Project and all unrelated fields survive.
            await executor.runUpdate(
              'UPDATE projects SET legacy_center_id = ?, center_id = NULL WHERE id = ?',
              <Object?>[centerId, projectId],
            );
            await _recordException(
              executor,
              entityType: 'project',
              entityId: projectId,
              code: 'PROJECT_CENTER_REFERENCE_MISSING',
              details: <String, Object?>{
                'sourceEntity': 'projects',
                'sourceRecordId': projectId,
                'historicalCenterId': centerId,
                'migrationVersion': targetSchemaVersion,
                'exceptionType': 'MissingHistoricalCenter',
                'failureReason':
                    'Project.center_id references no row in centers.',
                'originalDataReference': 'projects.center_id',
                'recoveryStatus': 'pending',
              },
            );
            continue;
          }
          await executor.runInsert(
            '''INSERT OR IGNORE INTO center_projects (center_id, project_id)
               VALUES (?, ?)''',
            <Object?>[centerId, link['id']],
          );
        }
      }
      await _inject('after_relationship_tables');

      await _addTaskColumn(
        executor,
        'center_id',
        'TEXT NULL REFERENCES centers(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
      );
      await _addTaskColumn(
        executor,
        'project_id',
        'TEXT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
      );
      await _addTaskColumn(
        executor,
        'category_id',
        'TEXT NULL REFERENCES categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
      );

      await executor.runCustom('''
        CREATE INDEX IF NOT EXISTS idx_center_projects_project_center
          ON center_projects(project_id, center_id)
      ''');
      await executor.runCustom('''
        CREATE INDEX IF NOT EXISTS idx_project_categories_category_project
          ON project_categories(category_id, project_id)
      ''');
      await executor.runCustom(
        'CREATE INDEX IF NOT EXISTS idx_tasks_center_id ON tasks(center_id)',
      );
      await executor.runCustom(
        'CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id)',
      );
      await executor.runCustom(
        'CREATE INDEX IF NOT EXISTS idx_tasks_category_id ON tasks(category_id)',
      );

      // Current v8 has no Center catalog or Center→Project source relation.
      // Do not invent Centers or infer associations from names/payloads.
      // Preserve existing Project membership only when it is unambiguous.
      final projectRows = await executor.runSelect(
        'SELECT id FROM projects ORDER BY id',
        const [],
      );
      final projectIds = projectRows.map((row) => row['id'] as String).toSet();
      final memberships = await executor.runSelect(
        'SELECT task_id, project_id FROM project_items ORDER BY task_id, ordinal',
        const [],
      );
      final membershipsByTask = <String, List<String>>{};
      for (final row in memberships) {
        final taskId = row['task_id'] as String;
        (membershipsByTask[taskId] ??= <String>[]).add(row['project_id'] as String);
      }

      final taskRows = await executor.runSelect(
        'SELECT id, category FROM tasks ORDER BY id',
        const [],
      );
      for (final task in taskRows) {
        final taskId = task['id'] as String;
        final taskProjects = membershipsByTask[taskId] ?? const <String>[];
        String? projectId;
        if (taskProjects.length == 1 && projectIds.contains(taskProjects.single)) {
          projectId = taskProjects.single;
          await executor.runUpdate(
            'UPDATE tasks SET project_id = ? WHERE id = ?',
            <Object?>[projectId, taskId],
          );
        } else if (taskProjects.length > 1) {
          await _recordException(
            executor,
            entityType: 'task',
            entityId: taskId,
            code: 'TASK_MULTIPLE_LEGACY_PROJECTS',
            details: <String, Object?>{'projectIds': taskProjects},
          );
        } else if (taskProjects.length == 1) {
          await _recordException(
            executor,
            entityType: 'task',
            entityId: taskId,
            code: 'TASK_PROJECT_REFERENCE_MISSING',
            details: <String, Object?>{'projectId': taskProjects.single},
          );
        }
      }

      // Legacy global categories receive stable, explicitly unassigned IDs.
      // A Task's category text is never used to manufacture Project↔Category.
      final legacyNames = <String>{};
      final catalogRows = await executor.runSelect(
        'SELECT name FROM taxonomy_categories ORDER BY name',
        const [],
      );
      legacyNames.addAll(catalogRows.map((row) => row['name'] as String));
      for (final task in taskRows) {
        final name = (task['category'] as String?)?.trim();
        if (name != null && name.isNotEmpty) legacyNames.add(name);
      }

      final categoryIds = <String, String>{};
      final now = DateTime.now().toUtc().toIso8601String();
      for (final name in legacyNames.toList()..sort()) {
        final candidateId = _legacyCategoryId(name);
        await executor.runInsert(
          '''INSERT OR IGNORE INTO categories
             (id, name, legacy_name, is_archived, created_at, updated_at)
             VALUES (?, ?, ?, 0, ?, ?)''',
          <Object?>[candidateId, name, name, now, now],
        );
        final rows = await executor.runSelect(
          'SELECT id FROM categories WHERE legacy_name = ?',
          <Object?>[name],
        );
        if (rows.isEmpty) {
          throw StateError('Could not recover legacy Category identity: $name');
        }
        categoryIds[name] = rows.single['id'] as String;
      }

      for (final task in taskRows) {
        final taskId = task['id'] as String;
        final name = (task['category'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final categoryId = categoryIds[name]!;
        final taskProjects = membershipsByTask[taskId] ?? const <String>[];
        final hasUnambiguousProject =
            taskProjects.length == 1 && projectIds.contains(taskProjects.single);
        if (!hasUnambiguousProject) {
          await executor.runUpdate(
            'UPDATE tasks SET category_id = ? WHERE id = ?',
            <Object?>[categoryId, taskId],
          );
        } else {
          await _recordException(
            executor,
            entityType: 'task',
            entityId: taskId,
            code: 'TASK_PROJECT_CATEGORY_EDGE_UNRESOLVED',
            details: <String, Object?>{
              'projectId': taskProjects.single,
              'legacyCategory': name,
              'categoryId': categoryId,
            },
          );
        }
      }

      await _inject('after_legacy_relationship_transfer');

      final violations = <Map<String, Object?>>[];
      for (final table in [
        'center_projects',
        'project_categories',
        'tasks',
        'projects',
        'centers',
      ]) {
        violations.addAll(await executor.runSelect(
          'PRAGMA foreign_key_check($table)',
          const [],
        ));
      }
      if (violations.isNotEmpty) {
        throw StateError('REV10 v8→v9 foreign-key check failed: $violations');
      }
      await _inject('before_completion_marker');
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

  String _legacyCategoryId(String name) =>
      'category-legacy-${base64Url.encode(utf8.encode(name)).replaceAll('=', '')}';

  Future<void> _addTaskColumn(
    QueryExecutor executor,
    String name,
    String declaration,
  ) async {
    final rows = await executor.runSelect("PRAGMA table_info('tasks')", const []);
    if (!rows.any((row) => row['name'] == name)) {
      await executor.runCustom('ALTER TABLE tasks ADD COLUMN $name $declaration');
    }
  }

  Future<void> _requireTable(QueryExecutor executor, String name) async {
    final rows = await executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>[name],
    );
    if (rows.isEmpty) throw StateError('REV10 v9 requires table $name.');
  }

  Future<void> _recordException(
    QueryExecutor executor, {
    required String entityType,
    required String entityId,
    required String code,
    required Map<String, Object?> details,
  }) async {
    final id = 'rev10-v9:$entityType:$entityId:$code';
    await executor.runInsert(
      '''INSERT OR IGNORE INTO arvin_migration_exceptions
         (id, migration_key, entity_type, entity_id, code, details_json, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        id,
        markerKey,
        entityType,
        entityId,
        code,
        jsonEncode(details),
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }
}
