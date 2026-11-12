import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/person_reference.dart';
import '../models/task.dart';
import '../models/goal_project.dart';
import 'project_plan_codec.dart';
import 'g1_drift_schema.dart';
import 'occurrence_sql_codec.dart';
import 'recurrence_sql_codec.dart';
import 'sql_task_migration_writer.dart';
import 'task_taxonomy_mutation_service.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

enum TemplateTaskAppendResult { appended, alreadyPresent, ineligible }

class TaskStore {
  static const key = 'arvin.tasks';
  static DatabaseConnection? _sharedDatabase;
  static QueryExecutor? _testDatabase;

  /// Clears only the in-memory SQL executor cache used by Flutter tests.
  /// Production databases are never touched.
  static Future<void> resetTestDatabase() async {
    if (Platform.environment['FLUTTER_TEST'] != 'true') return;
    final executor = _testDatabase;
    _testDatabase = null;
    if (executor != null) await executor.close();
  }

  final QueryExecutor? _injectedExecutor;

  TaskStore({QueryExecutor? executor}) : _injectedExecutor = executor;

  Future<List<Task>> load() =>
      TaskStorageLock.synchronized<List<Task>>(_loadUnlocked);

  Future<List<String>> loadCategories() async {
    return TaskStorageLock.synchronized<List<String>>(() async {
      final executor = _database;
      await _ensureReady();
      final rows = await executor.runSelect(
        'SELECT name FROM taxonomy_categories ORDER BY name',
        const [],
      );
      return rows.map((row) => row['name'] as String).toList(growable: false);
    });
  }

  Future<List<PersonReference>> loadPeopleDirectory() async {
    return TaskStorageLock.synchronized<List<PersonReference>>(() async {
      final executor = _database;
      await _ensureReady();
      final rows = await executor.runSelect(
        '''SELECT persons.id, persons.name FROM person_directory
           JOIN persons ON persons.id = person_directory.person_id
           ORDER BY persons.name, persons.id''',
        const [],
      );
      return rows.map((row) => PersonReference(
        id: row['id'] as String,
        displayName: row['name'] as String,
      )).toList(growable: false);
    });
  }

  /// Replaces only the active directory membership atomically. Historical
  /// Person rows and Task/Follow-up relations are never deleted.
  Future<void> savePeopleDirectory(Iterable<PersonReference> people) async {
    final normalized = <String, PersonReference>{};
    for (final person in people) {
      if (normalized.containsKey(person.id)) {
        throw ArgumentError.value(person.id, 'people', 'Duplicate person id');
      }
      normalized[person.id] = person;
    }
    await TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      final oldRows = await executor.runSelect('SELECT id, created_at, updated_at FROM persons', const []);
      final oldById = <String, Map<String, Object?>>{
        for (final row in oldRows) row['id'] as String: row,
      };
      await executor.runCustom('BEGIN');
      try {
        await executor.runCustom('DELETE FROM person_directory');
        final now = DateTime.now().toIso8601String();
        for (final person in normalized.values) {
          final old = oldById[person.id];
          await executor.runInsert(
            '''INSERT INTO persons (id, name, created_at, updated_at)
               VALUES (?, ?, ?, ?)
               ON CONFLICT(id) DO UPDATE
                 SET name = excluded.name, updated_at = excluded.updated_at''',
            <Object?>[person.id, person.displayName, old?['created_at'] ?? now, now],
          );
          await executor.runInsert(
            'INSERT OR IGNORE INTO person_directory (person_id) VALUES (?)',
            <Object?>[person.id],
          );
        }
        await executor.runCustom('COMMIT');
      } catch (_) {
        try { await executor.runCustom('ROLLBACK'); } catch (_) {}
        rethrow;
      }
    });
  }

  Future<void> mergePeopleDirectory(Iterable<PersonReference> incoming) async {
    final merged = <String, PersonReference>{
      for (final person in await loadPeopleDirectory()) person.id: person,
    };
    for (final person in incoming) {
      merged[person.id] = person;
    }
    await savePeopleDirectory(merged.values);
  }

  Future<List<String>> loadTags() async {
    return TaskStorageLock.synchronized<List<String>>(() async {
      final executor = _database;
      await _ensureReady();
      final rows = await executor.runSelect(
        'SELECT name FROM tags ORDER BY name',
        const [],
      );
      return rows.map((row) => row['name'] as String).toList(growable: false);
    });
  }

  Future<Map<String, int>> loadTemplateCategoryReferenceCounts() async {
    return TaskStorageLock.synchronized<Map<String, int>>(() async {
      final executor = _database;
      await _ensureReady();
      return _loadTemplateCategoryReferenceCountsUnlocked(executor);
    });
  }

  Future<Map<String, int>> loadTemplateTagReferenceCounts() async {
    return TaskStorageLock.synchronized<Map<String, int>>(() async {
      final executor = _database;
      await _ensureReady();
      return _loadTemplateTagReferenceCountsUnlocked(executor);
    });
  }

  Future<Map<String, int>> _loadTemplateCategoryReferenceCountsUnlocked(
    QueryExecutor executor,
  ) async {
    final rows = await executor.runSelect(
      '''SELECT category FROM task_templates WHERE category IS NOT NULL
         UNION ALL
         SELECT category FROM project_template_tasks WHERE category IS NOT NULL''',
      const [],
    );
    final counts = <String, int>{};
    for (final row in rows) {
      final value = (row['category'] as String?)?.trim();
      if (value == null || value.isEmpty) continue;
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return Map<String, int>.unmodifiable(counts);
  }

  Future<Map<String, int>> _loadTemplateTagReferenceCountsUnlocked(
    QueryExecutor executor,
  ) async {
    final rows = await executor.runSelect(
      '''SELECT tags_json FROM task_templates
         UNION ALL
         SELECT tags_json FROM project_template_tasks''',
      const [],
    );
    final counts = <String, int>{};
    for (final row in rows) {
      final raw = row['tags_json'];
      if (raw is! String || raw.isEmpty) continue;
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Template taxonomy tags must be a JSON list.');
      }
      final rowTags = <String>{};
      for (final item in decoded) {
        if (item is! String) continue;
        final value = item.trim();
        if (value.isNotEmpty) rowTags.add(value);
      }
      for (final value in rowTags) {
        counts[value] = (counts[value] ?? 0) + 1;
      }
    }
    return Map<String, int>.unmodifiable(counts);
  }

  Future<int> _taskCategoryReferenceCount(
    QueryExecutor executor,
    String category,
  ) async {
    final rows = await executor.runSelect(
      'SELECT COUNT(*) AS count FROM tasks WHERE TRIM(category) = ?',
      <Object?>[category],
    );
    return (rows.single['count'] as num).toInt();
  }

  Future<int> _taskTagReferenceCount(
    QueryExecutor executor,
    String tag,
  ) async {
    final rows = await executor.runSelect(
      '''SELECT COUNT(DISTINCT task_tags.task_id) AS count
         FROM task_tags JOIN tags ON tags.id = task_tags.tag_id
         WHERE tags.name = ?''',
      <Object?>[tag],
    );
    return (rows.single['count'] as num).toInt();
  }

  Future<void> _renameTemplateTagReferences(
    QueryExecutor executor, {
    required String table,
    required String from,
    required String to,
  }) async {
    final rows = await executor.runSelect('SELECT id, tags_json FROM $table', const []);
    for (final row in rows) {
      final raw = row['tags_json'];
      if (raw is! String || raw.isEmpty) continue;
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw FormatException('Invalid tags_json in $table');
      if (!decoded.any((value) => value == from)) continue;
      final updated = <dynamic>[];
      var targetWritten = false;
      for (final value in decoded) {
        if (value == from || value == to) {
          if (!targetWritten) {
            updated.add(to);
            targetWritten = true;
          }
        } else {
          updated.add(value);
        }
      }
      await executor.runUpdate(
        'UPDATE $table SET tags_json = ? WHERE id = ?',
        <Object?>[jsonEncode(updated), row['id']],
      );
    }
  }

  Future<String> createCategory(String value) async {
    final name = value.trim();
    if (name.isEmpty) throw ArgumentError.value(value, 'value');
    return TaskStorageLock.synchronized<String>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runInsert(
        'INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
        <Object?>[name, DateTime.now().toIso8601String()],
      );
      return name;
    });
  }

  Future<String> createTag(String value) async {
    final name = value.trim();
    if (name.isEmpty) throw ArgumentError.value(value, 'value');
    return TaskStorageLock.synchronized<String>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runInsert(
        'INSERT OR IGNORE INTO tags (id, name) VALUES (?, ?)',
        <Object?>[_tagId(name), name],
      );
      return name;
    });
  }

  /// Adds portable taxonomy catalog entries without deleting any local
  /// entries. Both catalogs are written in one transaction so a failed restore
  /// cannot leave only half of the incoming catalog applied.
  Future<void> mergeCatalogs({
    Iterable<String> categories = const <String>[],
    Iterable<String> tags = const <String>[],
  }) async {
    final normalizedCategories = categories.map((value) => value.trim()).toList();
    final normalizedTags = tags.map((value) => value.trim()).toList();
    if (normalizedCategories.any((value) => value.isEmpty) ||
        normalizedTags.any((value) => value.isEmpty)) {
      throw ArgumentError('Catalog entries must not be empty');
    }
    if (normalizedCategories.toSet().length != normalizedCategories.length ||
        normalizedTags.toSet().length != normalizedTags.length) {
      throw ArgumentError('Catalog entries must be unique');
    }

    await TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runCustom('BEGIN');
      try {
        for (final category in normalizedCategories) {
          await executor.runInsert(
            'INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
            <Object?>[category, DateTime.now().toIso8601String()],
          );
        }
        for (final tag in normalizedTags) {
          await executor.runInsert(
            'INSERT OR IGNORE INTO tags (id, name) VALUES (?, ?)',
            <Object?>[_tagId(tag), tag],
          );
        }
        await executor.runCustom('COMMIT');
      } catch (_) {
        try {
          await executor.runCustom('ROLLBACK');
        } catch (_) {}
        rethrow;
      }
    });
  }

  Future<void> renameCategoryCatalog(String from, String to) async {
    final source = from.trim();
    final target = to.trim();
    if (source.isEmpty || target.isEmpty || source == target) return;
    await TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runCustom('BEGIN');
      try {
        await executor.runInsert(
          'INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
          <Object?>[target, DateTime.now().toIso8601String()],
        );
        await executor.runDelete(
          'DELETE FROM taxonomy_categories WHERE name = ?',
          <Object?>[source],
        );
        await executor.runCustom('COMMIT');
      } catch (_) {
        try { await executor.runCustom('ROLLBACK'); } catch (_) {}
        rethrow;
      }
    });
  }

  Future<void> deleteCategoryCatalog(String value) async {
    final name = value.trim();
    if (name.isEmpty) return;
    await TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runCustom('BEGIN');
      try {
        final taskCount = await _taskCategoryReferenceCount(executor, name);
        final templateCounts = await _loadTemplateCategoryReferenceCountsUnlocked(executor);
        final count = taskCount + (templateCounts[name] ?? 0);
        if (count > 0) {
          throw TaskTaxonomyDeleteBlocked(
            kind: 'category',
            value: name,
            referenceCount: count,
          );
        }
        await executor.runDelete(
          'DELETE FROM taxonomy_categories WHERE name = ?',
          <Object?>[name],
        );
        await executor.runCustom('COMMIT');
      } catch (_) {
        try { await executor.runCustom('ROLLBACK'); } catch (_) {}
        rethrow;
      }
    });
  }

  Future<void> renameTagCatalog(String from, String to) async {
    final source = from.trim();
    final target = to.trim();
    if (source.isEmpty || target.isEmpty || source == target) return;
    await TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runInsert(
        'INSERT OR IGNORE INTO tags (id, name) VALUES (?, ?)',
        <Object?>[_tagId(target), target],
      );
      await executor.runDelete(
        'DELETE FROM tags WHERE name = ?',
        <Object?>[source],
      );
    });
  }

  Future<void> deleteTagCatalog(String value) async {
    final name = value.trim();
    if (name.isEmpty) return;
    await TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      await executor.runCustom('BEGIN');
      try {
        final taskCount = await _taskTagReferenceCount(executor, name);
        final templateCounts = await _loadTemplateTagReferenceCountsUnlocked(executor);
        final count = taskCount + (templateCounts[name] ?? 0);
        if (count > 0) {
          throw TaskTaxonomyDeleteBlocked(
            kind: 'tag',
            value: name,
            referenceCount: count,
          );
        }
        await executor.runDelete(
          'DELETE FROM tags WHERE name = ?',
          <Object?>[name],
        );
        await executor.runCustom('COMMIT');
      } catch (_) {
        try { await executor.runCustom('ROLLBACK'); } catch (_) {}
        rethrow;
      }
    });
  }

  /// Persists Task reference changes and the matching taxonomy catalog rename
  /// in the same SQLite transaction. Either both changes commit or neither does.
  Future<void> renameCategoryAndTasks(
    List<Task> tasks, {
    required String from,
    required String to,
  }) async {
    final source = from.trim();
    final target = to.trim();
    if (source.isEmpty || target.isEmpty || source == target) return;
    await TaskStorageLock.synchronized<void>(() => _saveUnlocked(
          tasks,
          beforeCommit: (executor) async {
            await executor.runInsert(
              'INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
              <Object?>[target, DateTime.now().toIso8601String()],
            );
            await executor.runUpdate(
              'UPDATE task_templates SET category = ? WHERE TRIM(category) = ?',
              <Object?>[target, source],
            );
            await executor.runUpdate(
              'UPDATE project_template_tasks SET category = ? WHERE TRIM(category) = ?',
              <Object?>[target, source],
            );
            await executor.runDelete(
              'DELETE FROM taxonomy_categories WHERE name = ?',
              <Object?>[source],
            );
          },
        ));
  }

  /// Persists Task reference changes and the matching taxonomy catalog rename
  /// in the same SQLite transaction. Either both changes commit or neither does.
  Future<void> renameTagAndTasks(
    List<Task> tasks, {
    required String from,
    required String to,
  }) async {
    final source = from.trim();
    final target = to.trim();
    if (source.isEmpty || target.isEmpty || source == target) return;
    await TaskStorageLock.synchronized<void>(() => _saveUnlocked(
          tasks,
          beforeCommit: (executor) async {
            await executor.runInsert(
              'INSERT OR IGNORE INTO tags (id, name) VALUES (?, ?)',
              <Object?>[_tagId(target), target],
            );
            await _renameTemplateTagReferences(
              executor,
              table: 'task_templates',
              from: source,
              to: target,
            );
            await _renameTemplateTagReferences(
              executor,
              table: 'project_template_tasks',
              from: source,
              to: target,
            );
            await executor.runDelete(
              'DELETE FROM tags WHERE name = ?',
              <Object?>[source],
            );
          },
        ));
  }

  Future<void> save(List<Task> tasks) =>
      TaskStorageLock.synchronized<void>(() => _saveUnlocked(tasks));

  /// Creates one generated Project and all its independent canonical Tasks in
  /// a single SQLite transaction. The partial unique index on active
  /// (template_id, center_id) is the final duplicate/concurrency guard.
  Future<void> createProjectFromTemplate(ProjectPlan project, List<Task> tasks) {
    return TaskStorageLock.synchronized<void>(() async {
      if (project.centerId == null || project.templateId == null) {
        throw ArgumentError('Generated Projects require Center and Template identities.');
      }
      if (tasks.any((task) => task.templateTaskId == null)) {
        throw ArgumentError('Every generated Task must retain its template-task origin.');
      }
      final executor = _database;
      await _ensureReady();
      await executor.runCustom('BEGIN');
      try {
        for (final task in tasks) { await _insertNewTask(executor, task); }
        await executor.runInsert(
          '''INSERT INTO projects
             (id, name, color_value, is_archived, center_id, template_id, template_name_snapshot, legacy_payload_json)
             VALUES (?, ?, ?, 0, ?, ?, ?, ?)''',
          <Object?>[project.id, project.title, project.colorValue, project.centerId,
            project.templateId, project.templateNameSnapshot, jsonEncode(const ProjectPlanCodec().encode(project))],
        );
        for (var i = 0; i < project.itemIds.length; i++) {
          await executor.runInsert('INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
            <Object?>[project.id, project.itemIds[i], i]);
          final task = tasks.firstWhere((item) => item.id == project.itemIds[i]);
          await executor.runInsert('INSERT INTO template_task_applications (template_task_id, project_id, task_id) VALUES (?, ?, ?)',
            <Object?>[task.templateTaskId, project.id, task.id]);
        }
        await executor.runCustom('COMMIT');
      } catch (_) { try { await executor.runCustom('ROLLBACK'); } catch (_) {} rethrow; }
    });
  }

  /// Append-only and idempotent: checks the destination's real persisted state
  /// and origin mapping inside the same transaction as Task + membership writes.
  Future<TemplateTaskAppendResult> appendTemplateTaskToProject({
    required String projectId,
    required String templateId,
    required Task task,
  }) {
    return TaskStorageLock.synchronized<TemplateTaskAppendResult>(() async {
      final originId = task.templateTaskId;
      if (originId == null || originId.trim().isEmpty) throw ArgumentError('Template origin is required.');
      final executor = _database;
      await _ensureReady();
      await executor.runCustom('BEGIN');
      try {
        final existing = await executor.runSelect(
          'SELECT task_id FROM template_task_applications WHERE template_task_id = ? AND project_id = ?',
          <Object?>[originId, projectId],
        );
        if (existing.isNotEmpty) { await executor.runCustom('COMMIT'); return TemplateTaskAppendResult.alreadyPresent; }
        final projectRows = await executor.runSelect(
          'SELECT template_id, is_archived FROM projects WHERE id = ?', <Object?>[projectId]);
        if (projectRows.isEmpty || projectRows.single['template_id'] != templateId ||
            (projectRows.single['is_archived'] as num).toInt() == 1) {
          await executor.runCustom('COMMIT'); return TemplateTaskAppendResult.ineligible;
        }
        final activeRows = await executor.runSelect(
          '''SELECT COUNT(*) AS count FROM project_items pi JOIN tasks t ON t.id = pi.task_id
             WHERE pi.project_id = ? AND t.completed = 0 AND t.archived = 0 AND t.trashed = 0''',
          <Object?>[projectId],
        );
        if ((activeRows.single['count'] as num).toInt() == 0) {
          await executor.runCustom('COMMIT'); return TemplateTaskAppendResult.ineligible;
        }
        await _insertNewTask(executor, task);
        final ordinalRows = await executor.runSelect(
          'SELECT COALESCE(MAX(ordinal), -1) + 1 AS next_ordinal FROM project_items WHERE project_id = ?',
          <Object?>[projectId],
        );
        await executor.runInsert(
          'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
          <Object?>[projectId, task.id, (ordinalRows.single['next_ordinal'] as num).toInt()],
        );
        await executor.runInsert(
          'INSERT INTO template_task_applications (template_task_id, project_id, task_id) VALUES (?, ?, ?)',
          <Object?>[originId, projectId, task.id],
        );
        await executor.runCustom('COMMIT');
        return TemplateTaskAppendResult.appended;
      } catch (_) { try { await executor.runCustom('ROLLBACK'); } catch (_) {} rethrow; }
    });
  }

  Future<void> _insertNewTask(QueryExecutor executor, Task task) async {
    final rows = await executor.runSelect('SELECT COALESCE(MAX(storage_ordinal), -1) + 1 AS next_ordinal FROM tasks', const []);
    final ordinal = (rows.single['next_ordinal'] as num).toInt();
    await executor.runInsert(
      '''INSERT INTO tasks (id, storage_ordinal, title, description, created_at, updated_at, due_date,
         category, notebook_kind, priority, archived, trashed, completed, completed_at,
         is_favorite, recurrence_json, legacy_payload_json)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        task.id, ordinal, task.title, task.description, task.createdAt?.toIso8601String(),
        task.updatedAt?.toIso8601String(), task.dueDateStorageValue, task.category,
        task.notebookKind?.name, task.priority.name, task.archived ? 1 : 0,
        task.trashed ? 1 : 0, task.completed ? 1 : 0, task.completedAt?.toIso8601String(),
        task.isFavorite ? 1 : 0,
        task.recurrence == null ? null : jsonEncode(task.recurrence!.toJson()),
        jsonEncode(_canonicalEnvelope(task)),
      ],
    );
    await _writeRelations(executor, task);
    final category = task.category?.trim();
    if (category != null && category.isNotEmpty) {
      await executor.runInsert('INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
        <Object?>[category, DateTime.now().toIso8601String()]);
    }
  }

  /// Updates only Task description metadata without rewriting relation tables.
  /// In particular, historical Follow-up rows are never deleted/reinserted here.
  Future<void> updateDescription(
    String taskId,
    String description,
    DateTime updatedAt,
  ) {
    return TaskStorageLock.synchronized<void>(() async {
      final executor = _database;
      await _ensureReady();
      final rows = await executor.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        <Object?>[taskId],
      );
      if (rows.isEmpty) {
        throw StateError('Task not found: $taskId');
      }

      final rawPayload = rows.single['legacy_payload_json'];
      final payload = <String, dynamic>{};
      if (rawPayload is String && rawPayload.trim().isNotEmpty) {
        final decoded = jsonDecode(rawPayload);
        if (decoded is! Map) {
          throw const FormatException('Task legacy payload is not a JSON object.');
        }
        payload.addAll(Map<String, dynamic>.from(decoded));
      }
      payload['description'] = description;
      payload['updatedAt'] = updatedAt.toIso8601String();

      final changed = await executor.runUpdate(
        '''UPDATE tasks
           SET description = ?, updated_at = ?, legacy_payload_json = ?
           WHERE id = ?''',
        <Object?>[
          description,
          updatedAt.toIso8601String(),
          jsonEncode(payload),
          taskId,
        ],
      );
      if (changed != 1) {
        throw StateError('Task description update affected $changed rows.');
      }
    });
  }


  Future<T> mutate<T>(TaskMutation<T> mutation) {
    return TaskStorageLock.synchronized<T>(() async {
      final tasks = await _loadUnlocked();
      final result = mutation(tasks);
      await _saveUnlocked(tasks);
      return result;
    });
  }

  Future<void> addFollowUp(String taskId, FollowUp followUp) async {
    await mutate<void>((tasks) {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index < 0) throw StateError('Task not found: $taskId');
      final task = tasks[index];
      task.followUps = [...task.followUps, followUp];
      task.updatedAt = DateTime.now();
    });
  }

  Future<TaskReminder> addTaskReminder(
    String taskId,
    DateTime date, {
    String title = 'یادآور پیگیری',
    bool isAllDay = false,
  }) {
    return mutate<TaskReminder>((tasks) {
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index < 0) throw StateError('Task not found: $taskId');
      final task = tasks[index];
      final highestSequence = task.taskReminders.isEmpty
          ? 0
          : task.taskReminders
              .map((item) => item.sequence)
              .reduce((a, b) => a > b ? a : b);
      final sequence = [
        task.nextReminderSequence,
        highestSequence + 1,
      ].reduce((a, b) => a > b ? a : b);
      final reminder = TaskReminder(
        id: 'reminder-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        date: date,
        isAllDay: isAllDay,
        sequence: sequence,
      );
      task.taskReminders = [...task.taskReminders, reminder];
      task.nextReminderSequence = sequence + 1;
      task.updatedAt = DateTime.now();
      return reminder;
    });
  }

  Future<List<FollowUp>> loadFollowUps(String taskId) async {
    final tasks = await load();
    for (final task in tasks) {
      if (task.id == taskId) return List<FollowUp>.of(task.followUps);
    }
    return const [];
  }

  QueryExecutor get _database {
    final injected = _injectedExecutor;
    if (injected != null) return injected;

    // Flutter tests run sequentially in this process. Use one in-memory
    // executor per test so every TaskStore instance in the test sees the same
    // SQL state, regardless of async callback Zone changes.
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      return _testDatabase ??= NativeDatabase.memory();
    }

    return _sharedDatabase ??= driftDatabase(name: 'arvin');
  }

  Future<void> _ensureReady() async {
    final executor = _database;
    await G1DriftSchema.install(executor);
    if (await G1DriftSchema.isLegacyMigrationComplete(executor)) {
      await G1DriftSchema.migrateTaskPeople(executor);
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: executor,
      preferences: preferences,
    );
    await G1DriftSchema.migrateTaskPeople(executor);
    await _seedCategoryCatalog(executor);
    await G1DriftSchema.markLegacyMigrationComplete(executor);
  }

  Future<void> _seedCategoryCatalog(QueryExecutor executor) async {
    final rows = await executor.runSelect(
      'SELECT DISTINCT category FROM tasks WHERE category IS NOT NULL AND TRIM(category) <> ?',
      <Object?>[''],
    );
    for (final row in rows) {
      final category = (row['category'] as String).trim();
      await executor.runInsert(
        'INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
        <Object?>[category, DateTime.now().toIso8601String()],
      );
    }
  }

  Future<List<Task>> _loadUnlocked() async {
    final executor = _database;
    await _ensureReady();
    final rows = await executor.runSelect(
      'SELECT * FROM tasks ORDER BY storage_ordinal, id',
      const [],
    );
    final tasks = <Task>[];
    for (final row in rows) {
      tasks.add(await _decodeTask(executor, row));
    }
    return tasks;
  }

  Future<Task> _decodeTask(
    QueryExecutor executor,
    Map<String, Object?> row,
  ) async {
    final envelope = _decodeEnvelope(row['legacy_payload_json']);
    envelope['id'] = row['id'];
    envelope['title'] = row['title'];
    envelope['description'] = row['description'];
    envelope['createdAt'] = row['created_at'];
    envelope['updatedAt'] = row['updated_at'];
    envelope['dueDate'] = row['due_date'];
    envelope['category'] = row['category'];
    envelope['notebookKind'] = row['notebook_kind'];
    envelope['priority'] = row['priority'];
    envelope['archived'] = (row['archived'] as num?)?.toInt() == 1;
    envelope['trashed'] = (row['trashed'] as num?)?.toInt() == 1;
    envelope['completed'] = (row['completed'] as num?)?.toInt() == 1;
    envelope['isFavorite'] = (row['is_favorite'] as num?)?.toInt() == 1;
    final completedAt = row['completed_at'];
    if (completedAt is String && completedAt.isNotEmpty) {
      envelope['completedAt'] = completedAt;
    }

    final recurrenceRule = await RecurrenceSqlCodec.readTask(
      executor,
      row['id'] as String,
    );
    if (recurrenceRule != null) {
      envelope['recurrence'] = recurrenceRule.toJson();
    } else {
      // Read-only fallback for databases that predate the normalized rule table.
      final recurrence = row['recurrence_json'];
      if (recurrence is String && recurrence.trim().isNotEmpty) {
        envelope['recurrence'] = jsonDecode(recurrence);
      } else if (envelope['recurrence'] is Map) {
        envelope['recurrence'] = Map<String, dynamic>.from(envelope['recurrence'] as Map);
      } else {
        envelope['recurrence'] = null;
      }
    }

    final reminderRows = await executor.runSelect(
      'SELECT * FROM task_reminders WHERE task_id = ? ORDER BY sequence, id',
      <Object?>[row['id']],
    );
    envelope['taskReminders'] = reminderRows.map((reminder) => <String, dynamic>{
      'id': reminder['id'],
      'title': reminder['title'],
      'date': reminder['remind_at'],
      'isAllDay': (reminder['is_all_day'] as num?)?.toInt() == 1,
      'sequence': reminder['sequence'],
      'isEnabled': (reminder['is_enabled'] as num?)?.toInt() != 0,
    }).toList(growable: false);

    // Capture retired fields from the original JSON Follow-up list before
    // the canonical SQL records replace that list below. Otherwise unknown
    // per-record metadata is irretrievably hidden from the model decoder.
    final legacyFollowUpMetadata = decodeLegacyFollowUpMetadata(envelope);
    if (legacyFollowUpMetadata.isNotEmpty) {
      envelope['legacyFollowUpMetadata'] = legacyFollowUpMetadata;
    }

    final followUps = await executor.runSelect(
      'SELECT * FROM follow_up_records WHERE task_id = ? ORDER BY ordinal',
      <Object?>[row['id']],
    );
    final followUpJson = <Map<String, dynamic>>[];
    for (final followUpRow in followUps) {
      final value = <String, dynamic>{
        'id': followUpRow['id'],
        'completedAt': followUpRow['completed_at'],
        'title': followUpRow['title'],
        'note': followUpRow['note'],
        'result': followUpRow['result'],
        'completed': (followUpRow['completed'] as num?)?.toInt() == 1,
        'waitingForResponse':
            (followUpRow['waiting_for_response'] as num?)?.toInt() == 1,
      };
      var personRows = await executor.runSelect(
        'SELECT person_id FROM follow_up_record_people WHERE follow_up_id = ? ORDER BY ordinal',
        <Object?>[followUpRow['id']],
      );
      value['personIds'] =
          personRows.map((item) => item['person_id'] as String).toList();
      followUpJson.add(value);
    }
    envelope['followUps'] = followUpJson;

    final checklist = await executor.runSelect(
      'SELECT value FROM checklist_items WHERE task_id = ? ORDER BY ordinal',
      <Object?>[row['id']],
    );
    envelope['checklist'] =
        checklist.map((item) => item['value'] as String).toList();

    final tags = await executor.runSelect(
      '''SELECT tags.name FROM task_tags
         JOIN tags ON tags.id = task_tags.tag_id
         WHERE task_tags.task_id = ? ORDER BY task_tags.ordinal''',
      <Object?>[row['id']],
    );
    envelope['tags'] = tags.map((item) => item['name'] as String).toList();

    final people = await executor.runSelect(
      '''SELECT persons.id, persons.name,
                CASE WHEN person_directory.person_id IS NULL THEN 1 ELSE 0 END AS is_deleted
         FROM task_persons
         JOIN persons ON persons.id = task_persons.person_id
         LEFT JOIN person_directory ON person_directory.person_id = persons.id
         WHERE task_persons.task_id = ?
         ORDER BY task_persons.ordinal''',
      <Object?>[row['id']],
    );
    envelope['people'] = people
        .map((item) => <String, dynamic>{
              'id': item['id'],
              'displayName': item['name'],
              'isDeleted': (item['is_deleted'] as num?)?.toInt() == 1,
            })
        .toList(growable: false);

    final occurrenceData = await OccurrenceSqlCodec.readTask(
      executor,
      row['id'] as String,
    );
    envelope['occurrenceHistory'] = occurrenceData.history;
    envelope['checklistOccurrences'] = occurrenceData.checklists;

    final hasLegacyFocus = envelope.containsKey('isSelectedForToday');
    final rawFocusDate = envelope['focusDate'];
    final invalidFocusDate = rawFocusDate is String &&
        DateTime.tryParse(rawFocusDate) == null;
    if (invalidFocusDate) envelope.remove('focusDate');
    final task = Task.fromJson(envelope);
    // Convert the legacy timeless boolean exactly once. Persist the canonical
    // date-only value during the first read so it cannot be reinterpreted as
    // a fresh selection on every subsequent local day.
    if (hasLegacyFocus || invalidFocusDate) {
      final canonical = _canonicalEnvelope(task, previousPayload: envelope);
      await executor.runUpdate(
        'UPDATE tasks SET legacy_payload_json = ? WHERE id = ?',
        <Object?>[jsonEncode(canonical), task.id],
      );
    }
    return task;
  }

  Map<String, dynamic> _decodeEnvelope(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('SQL legacy envelope must be an object');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _saveUnlocked(
    List<Task> tasks, {
    Future<void> Function(QueryExecutor executor)? beforeCommit,
  }) async {
    final executor = _database;
    await _ensureReady();

    await executor.runCustom('BEGIN');
    try {
      // Project membership is canonical SQL data owned by ProjectStore, but
      // project_items references tasks. Preserve those relationship rows while
      // this legacy-compatible TaskStore rewrite replaces the task rows.
      final templateApplications = await executor.runSelect(
        'SELECT template_task_id, project_id, task_id FROM template_task_applications', const [],
      );
      final projectItems = await executor.runSelect(
        'SELECT project_id, task_id, ordinal FROM project_items ORDER BY project_id, ordinal',
        const [],
      );
      // Keep unknown legacy fields when an existing SQL Task is rewritten.
      // Read them before deleting the task rows; otherwise _canonicalEnvelope
      // cannot recover the previous envelope after the DELETE.
      final legacyPayloads = <String, Map<String, dynamic>>{};
      final legacyRecurrencePayloads = <String, Object?>{};
      final existingTasks = await executor.runSelect(
        'SELECT id, legacy_payload_json, recurrence_json FROM tasks',
        const [],
      );
      for (final row in existingTasks) {
        if (row['id'] is String && row['recurrence_json'] != null) {
          legacyRecurrencePayloads[row['id'] as String] = row['recurrence_json'];
        }
        final raw = row['legacy_payload_json'];
        if (row['id'] is String && raw is String && raw.trim().isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            legacyPayloads[row['id'] as String] =
                Map<String, dynamic>.from(decoded);
          }
        }
      }
      await executor.runCustom('DELETE FROM template_task_applications');
      await executor.runCustom('DELETE FROM project_items');
      await executor.runCustom('DELETE FROM task_tags');
      await executor.runCustom('DELETE FROM task_persons');
      await executor.runCustom('DELETE FROM checklist_items');
      await executor.runCustom('DELETE FROM occurrence_checklist_items');
      await executor.runCustom('DELETE FROM task_occurrences');
      await executor.runCustom('DELETE FROM task_recurrence_rules');
      await executor.runCustom('DELETE FROM task_reminders');
      await executor.runCustom('DELETE FROM follow_up_record_people');
      await executor.runCustom('DELETE FROM follow_up_records');
      await executor.runCustom('DELETE FROM tasks');

      for (var ordinal = 0; ordinal < tasks.length; ordinal++) {
        final task = tasks[ordinal];
        final envelope = _canonicalEnvelope(
          task,
          previousPayload: legacyPayloads[task.id],
        );
        await executor.runInsert(
          '''INSERT INTO tasks (
            id, storage_ordinal, title, description, created_at, updated_at, due_date,
            category, notebook_kind, priority, archived, trashed, completed, completed_at,
            is_favorite, recurrence_json, legacy_payload_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            task.id,
            ordinal,
            task.title,
            task.description,
            task.createdAt?.toIso8601String(),
            task.updatedAt?.toIso8601String(),
            task.dueDateStorageValue,
            task.category,
            task.notebookKind?.name,
            task.priority.name,
            task.archived ? 1 : 0,
            task.trashed ? 1 : 0,
            task.completed ? 1 : 0,
            task.completedAt?.toIso8601String(),
            task.isFavorite ? 1 : 0,
            legacyRecurrencePayloads[task.id],
            jsonEncode(envelope),
          ],
        );
        await _writeRelations(executor, task);
      }
      await G1DriftSchema.migrateTaskPeople(executor);
      for (final row in projectItems) {
        await executor.runInsert(
          '''INSERT INTO project_items (project_id, task_id, ordinal)
             VALUES (?, ?, ?)''',
          <Object?>[row['project_id'], row['task_id'], row['ordinal']],
        );
      }
      for (final row in templateApplications) {
        await executor.runInsert(
          'INSERT INTO template_task_applications (template_task_id, project_id, task_id) VALUES (?, ?, ?)',
          <Object?>[row['template_task_id'], row['project_id'], row['task_id']],
        );
      }
      // Keep categories used by canonical Tasks visible in the independent catalog.
      for (final task in tasks) {
        final category = task.category?.trim();
        if (category != null && category.isNotEmpty) {
          await executor.runInsert(
            'INSERT OR IGNORE INTO taxonomy_categories (name, created_at) VALUES (?, ?)',
            <Object?>[category, DateTime.now().toIso8601String()],
          );
        }
      }

      await beforeCommit?.call(executor);
      await executor.runCustom('COMMIT');
    } catch (_) {
      try {
        await executor.runCustom('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }

  Map<String, dynamic> _canonicalEnvelope(
    Task task, {
    Map<String, dynamic>? previousPayload,
  }) {
    final knownKeys = <String>{
      'id', 'title', 'description', 'createdAt', 'updatedAt', 'dueDate',
      'followUpEnabled', 'followUpDate', 'tags', 'category', 'checklist',
      'checklistOccurrences', 'occurrenceHistory', 'notebookKind', 'reminderDate', 'priority', 'archived', 'trashed',
      'completed', 'completedAt', 'isFavorite', 'isSelectedForToday', 'focusDate', 'templateTaskId', 'followUps', 'recurrence', 'people',
      'taskReminders', 'legacyFollowUpMetadata',
    };
    final preserved = <String, dynamic>{};
    final previous = previousPayload;
    if (previous != null) {
      for (final entry in previous.entries) {
        if (!knownKeys.contains(entry.key)) preserved[entry.key] = entry.value;
      }
    }
    final canonical = Map<String, dynamic>.from(task.toJson())
      ..remove('id')
      ..remove('title')
      ..remove('description')
      ..remove('createdAt')
      ..remove('updatedAt')
      ..remove('dueDate')
      ..remove('category')
      ..remove('notebookKind')
      ..remove('priority')
      ..remove('archived')
      ..remove('trashed')
      ..remove('completed')
      ..remove('completedAt')
      ..remove('isFavorite')
      ..remove('tags')
      ..remove('checklist')
      ..remove('followUps')
      ..remove('people')
      ..remove('taskReminders')
      ..remove('recurrence')
      ..remove('occurrenceHistory')
      ..remove('checklistOccurrences');
    preserved.addAll(canonical);
    return preserved;
  }

  Future<void> _writeRelations(QueryExecutor executor, Task task) async {
    final now = DateTime.now().toIso8601String();
    for (final person in task.people) {
      if (person.isDeleted) {
        // A historical relation may be rewritten without reactivating the
        // Person in the directory or overwriting its last known display name.
        await executor.runInsert(
          '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
             VALUES (?, ?, ?, ?)''',
          <Object?>[person.id, person.displayName, now, now],
        );
      } else {
        final existingPerson = await executor.runSelect(
          'SELECT id FROM persons WHERE id = ?',
          <Object?>[person.id],
        );
        // The Person row owns the canonical display name. Task snapshots
        // may be stale, so relation writes must not overwrite an explicit
        // directory rename with an older embedded displayName.
        await executor.runInsert(
          '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
             VALUES (?, ?, ?, ?)''',
          <Object?>[person.id, person.displayName, now, now],
        );
        // Seed directory membership only when this is a genuinely new Person.
        // A stale Task snapshot must not silently re-add someone whose active
        // directory membership was removed after that snapshot was loaded.
        if (existingPerson.isEmpty) {
          await executor.runInsert(
            'INSERT OR IGNORE INTO person_directory (person_id) VALUES (?)',
            <Object?>[person.id],
          );
        }
      }
    }
    for (final followUp in task.followUps) {
      for (final personId in followUp.personIds) {
        await executor.runInsert(
          '''INSERT OR IGNORE INTO persons (id, name, created_at, updated_at)
             VALUES (?, '', ?, ?)''',
          <Object?>[personId, now, now],
        );
      }
    }
    for (final reminder in task.taskReminders) {
      await executor.runInsert(
        '''INSERT INTO task_reminders
           (id, task_id, title, remind_at, is_all_day, sequence, is_enabled)
           VALUES (?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          reminder.id, task.id, reminder.title, reminder.storageDateValue,
          reminder.isAllDay ? 1 : 0, reminder.sequence, reminder.isEnabled ? 1 : 0,
        ],
      );
    }
    for (var ordinal = 0; ordinal < task.followUps.length; ordinal++) {
      final followUp = task.followUps[ordinal];
      await executor.runInsert(
        '''INSERT INTO follow_up_records
           (id, task_id, completed_at, title, note, result, completed, waiting_for_response, ordinal)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          followUp.id, task.id, followUp.completedAt.toIso8601String(),
          followUp.title, followUp.note, followUp.result,
          followUp.completed ? 1 : 0, followUp.waitingForResponse ? 1 : 0, ordinal,
        ],
      );
      for (var personOrdinal = 0; personOrdinal < followUp.personIds.length; personOrdinal++) {
        await executor.runInsert(
          'INSERT INTO follow_up_record_people (follow_up_id, person_id, ordinal) VALUES (?, ?, ?)',
          <Object?>[followUp.id, followUp.personIds[personOrdinal], personOrdinal],
        );
      }
    }
    for (var ordinal = 0; ordinal < task.checklist.length; ordinal++) {
      await executor.runInsert(
        'INSERT INTO checklist_items (task_id, ordinal, value) VALUES (?, ?, ?)',
        <Object?>[task.id, ordinal, task.checklist[ordinal]],
      );
    }
    for (var ordinal = 0; ordinal < task.people.length; ordinal++) {
      final person = task.people[ordinal];
      await executor.runInsert(
        'INSERT INTO task_persons (task_id, person_id, ordinal) VALUES (?, ?, ?)',
        <Object?>[task.id, person.id, ordinal],
      );
    }
    for (var ordinal = 0; ordinal < task.tags.length; ordinal++) {
      final tag = task.tags[ordinal];
      final tagId = _tagId(tag);
      await executor.runInsert(
        'INSERT OR IGNORE INTO tags (id, name) VALUES (?, ?)',
        <Object?>[tagId, tag],
      );
      await executor.runInsert(
        'INSERT INTO task_tags (task_id, tag_id, ordinal) VALUES (?, ?, ?)',
        <Object?>[task.id, tagId, ordinal],
      );
    }
    await OccurrenceSqlCodec.writeTask(executor, task);
    await RecurrenceSqlCodec.writeTask(executor, task);
  }

  static String _tagId(String value) =>
      'legacy-tag-${base64UrlEncode(utf8.encode(value)).replaceAll('=', '')}';
}
