import 'package:drift/drift.dart';

/// Isolated REV10 hierarchy candidate for file-backed migration tests.
///
/// This candidate is deliberately NOT called by G1DriftSchema.install or app
/// startup. Invoke it only against a disposable database copy until legacy
/// exception resolution and dependent writer migration are accepted.
class G1HierarchyCandidateSchema {
  const G1HierarchyCandidateSchema();

  static const int candidateVersion = 1;
  static const String markerKey = 'rev10_hierarchy_candidate_v1';

  Future<void> install(QueryExecutor executor) async {
    await executor.runCustom('PRAGMA foreign_keys = ON');
    final fkState = await executor.runSelect('PRAGMA foreign_keys', const []);
    if (fkState.isEmpty || (fkState.single.values.first as num).toInt() != 1) {
      throw StateError('REV10 candidate requires SQLite foreign_keys=ON.');
    }

    await executor.runCustom('BEGIN');
    try {
      for (final table in ['centers', 'projects', 'tasks', 'project_items', 'taxonomy_categories']) {
        final rows = await executor.runSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          <Object?>[table],
        );
        if (rows.isEmpty) throw StateError('Required G1 table is missing: $table');
      }

      final projectFks = await executor.runSelect("PRAGMA foreign_key_list('projects')", const []);
      if (!projectFks.any((row) => row['table'] == 'centers' && row['from'] == 'center_id')) {
        throw StateError('projects.center_id is not a real Center foreign key.');
      }

      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS categories (
          id TEXT NOT NULL PRIMARY KEY,
          project_id TEXT NOT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
          name TEXT NOT NULL,
          storage_ordinal INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(project_id, name)
        )
      ''');

      final taskColumns = await executor.runSelect("PRAGMA table_info('tasks')", const []);
      final additions = <String, String>{
        'center_id': 'TEXT NULL REFERENCES centers(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
        'project_id': 'TEXT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
        'category_id': 'TEXT NULL REFERENCES categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
      };
      for (final entry in additions.entries) {
        if (!taskColumns.any((row) => row['name'] == entry.key)) {
          await executor.runCustom('ALTER TABLE tasks ADD COLUMN ${entry.key} ${entry.value}');
        }
      }

      final indexes = <String>[
        'CREATE INDEX IF NOT EXISTS idx_projects_center_archive_order ON projects(center_id, is_archived, storage_ordinal)',
        'CREATE INDEX IF NOT EXISTS idx_categories_project_archive_order ON categories(project_id, is_archived, storage_ordinal)',
        'CREATE INDEX IF NOT EXISTS idx_tasks_center_id ON tasks(center_id)',
        'CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id)',
        'CREATE INDEX IF NOT EXISTS idx_tasks_category_id ON tasks(category_id)',
        'CREATE INDEX IF NOT EXISTS idx_task_tags_tag_task ON task_tags(tag_id, task_id)',
      ];
      for (final statement in indexes) {
        await executor.runCustom(statement);
      }

      await executor.runCustom('''
        CREATE TABLE IF NOT EXISTS arvin_hierarchy_migration_exceptions (
          exception_key TEXT NOT NULL PRIMARY KEY,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          issue_code TEXT NOT NULL,
          source_evidence TEXT NULL,
          resolution_status TEXT NOT NULL DEFAULT 'UNRESOLVED',
          detected_at TEXT NOT NULL
        )
      ''');

      await _installTriggers(executor);
      await _recordExceptions(executor);

      await executor.runInsert(
        '''INSERT INTO arvin_storage_meta(key, value) VALUES (?, ?)
           ON CONFLICT(key) DO UPDATE SET value = excluded.value''',
        <Object?>[markerKey, '$candidateVersion'],
      );

      final violations = await executor.runSelect('PRAGMA foreign_key_check', const []);
      if (violations.isNotEmpty) {
        throw StateError('REV10 candidate FK check failed: $violations');
      }
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  Future<void> _installTriggers(QueryExecutor executor) async {
    await executor.runCustom('''
      CREATE TRIGGER IF NOT EXISTS rev10_projects_owner_insert
      BEFORE INSERT ON projects
      WHEN NEW.center_id IS NULL
        OR NOT EXISTS(SELECT 1 FROM centers c WHERE c.id = NEW.center_id)
      BEGIN SELECT RAISE(ABORT, 'Project requires one existing Center'); END
    ''');
    await executor.runCustom('''
      CREATE TRIGGER IF NOT EXISTS rev10_projects_owner_update
      BEFORE UPDATE OF center_id ON projects
      WHEN NEW.center_id IS NULL
        OR NOT EXISTS(SELECT 1 FROM centers c WHERE c.id = NEW.center_id)
      BEGIN SELECT RAISE(ABORT, 'Project requires one existing Center'); END
    ''');
    await executor.runCustom('''
      CREATE TRIGGER IF NOT EXISTS rev10_projects_owner_change_guard
      BEFORE UPDATE OF center_id ON projects
      WHEN NEW.center_id IS NOT OLD.center_id
        AND (
          EXISTS(SELECT 1 FROM project_items pi WHERE pi.project_id = OLD.id)
          OR EXISTS(SELECT 1 FROM categories c WHERE c.project_id = OLD.id)
          OR EXISTS(SELECT 1 FROM tasks t WHERE t.project_id = OLD.id)
        )
      BEGIN
        SELECT RAISE(ABORT, 'Project Center change requires explicit dependent migration');
      END
    ''');
    await executor.runCustom('''
      CREATE TRIGGER IF NOT EXISTS rev10_categories_owner_update
      BEFORE UPDATE OF project_id ON categories
      WHEN NEW.project_id IS NOT OLD.project_id
        AND EXISTS(SELECT 1 FROM tasks t WHERE t.category_id = OLD.id)
      BEGIN
        SELECT RAISE(ABORT, 'Category Project change requires explicit dependent migration');
      END
    ''');

    const guard = '''
      SELECT CASE WHEN NEW.center_id IS NOT NULL AND NEW.project_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM projects p
          WHERE p.id = NEW.project_id AND p.center_id = NEW.center_id
        )
        THEN RAISE(ABORT, 'Task Center/Project ownership mismatch') END;
      SELECT CASE WHEN NEW.project_id IS NOT NULL AND NEW.category_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM categories c
          WHERE c.id = NEW.category_id AND c.project_id = NEW.project_id
        )
        THEN RAISE(ABORT, 'Task Project/Category ownership mismatch') END;
      SELECT CASE WHEN NEW.center_id IS NOT NULL AND NEW.category_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM categories c JOIN projects p ON p.id = c.project_id
          WHERE c.id = NEW.category_id AND p.center_id = NEW.center_id
        )
        THEN RAISE(ABORT, 'Task Center/Category ownership mismatch') END;
    ''';
    await executor.runCustom('''
      CREATE TRIGGER IF NOT EXISTS rev10_tasks_hierarchy_insert
      BEFORE INSERT ON tasks BEGIN
        $guard
      END
    ''');
    await executor.runCustom('''
      CREATE TRIGGER IF NOT EXISTS rev10_tasks_hierarchy_update
      BEFORE UPDATE OF center_id, project_id, category_id ON tasks BEGIN
        $guard
      END
    ''');
  }

  Future<void> _recordExceptions(QueryExecutor executor) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await executor.runInsert(
      '''INSERT OR IGNORE INTO arvin_hierarchy_migration_exceptions
         (exception_key, entity_type, entity_id, issue_code, source_evidence, detected_at)
         SELECT 'project:' || id || ':missing_center', 'project', id,
                'PROJECT_CENTER_MISSING', legacy_payload_json, ?
         FROM projects WHERE center_id IS NULL''',
      <Object?>[now],
    );

    final multiple = await executor.runSelect(
      '''SELECT task_id, group_concat(project_id, ',') AS project_ids
         FROM project_items GROUP BY task_id HAVING COUNT(*) > 1''',
      const [],
    );
    for (final row in multiple) {
      final id = row['task_id'] as String;
      await executor.runInsert(
        '''INSERT OR IGNORE INTO arvin_hierarchy_migration_exceptions
           (exception_key, entity_type, entity_id, issue_code, source_evidence, detected_at)
           VALUES (?, 'task', ?, 'TASK_MULTIPLE_PROJECTS', ?, ?)''',
        <Object?>['task:$id:multiple_projects', id, row['project_ids']?.toString(), now],
      );
    }

    final categories = await executor.runSelect(
      'SELECT name FROM taxonomy_categories ORDER BY name',
      const [],
    );
    for (final row in categories) {
      final name = row['name'] as String;
      await executor.runInsert(
        '''INSERT OR IGNORE INTO arvin_hierarchy_migration_exceptions
           (exception_key, entity_type, entity_id, issue_code, source_evidence, detected_at)
           VALUES (?, 'legacy_category', ?, 'CATEGORY_PROJECT_OWNER_UNKNOWN', ?, ?)''',
        <Object?>['legacy_category:$name:owner_unknown', name, name, now],
      );
    }

    final duplicateTags = await executor.runSelect(
      '''SELECT name, group_concat(id, ',') AS tag_ids
         FROM tags GROUP BY name HAVING COUNT(*) > 1''',
      const [],
    );
    for (final row in duplicateTags) {
      final name = row['name'] as String;
      await executor.runInsert(
        '''INSERT OR IGNORE INTO arvin_hierarchy_migration_exceptions
           (exception_key, entity_type, entity_id, issue_code, source_evidence, detected_at)
           VALUES (?, 'tag', ?, 'DUPLICATE_TAG_NAME', ?, ?)''',
        <Object?>['tag_name:$name:duplicate', name, row['tag_ids']?.toString(), now],
      );
    }

    final blankPeople = await executor.runSelect(
      "SELECT id FROM persons WHERE TRIM(name) = '' ORDER BY id",
      const [],
    );
    for (final row in blankPeople) {
      final id = row['id'] as String;
      await executor.runInsert(
        '''INSERT OR IGNORE INTO arvin_hierarchy_migration_exceptions
           (exception_key, entity_type, entity_id, issue_code, detected_at)
           VALUES (?, 'person', ?, 'PERSON_DISPLAY_NAME_MISSING', ?)''',
        <Object?>['person:$id:blank_name', id, now],
      );
    }
  }
}
