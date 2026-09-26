import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'g1_drift_schema.dart';
import 'sql_task_migration_writer.dart';
import 'task_storage_lock.dart';

typedef TaskMutation<T> = T Function(List<Task> tasks);

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

  Future<void> save(List<Task> tasks) =>
      TaskStorageLock.synchronized<void>(() => _saveUnlocked(tasks));

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
      task.followUpEnabled = true;
      task.updatedAt = DateTime.now();
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
    if (await G1DriftSchema.isLegacyMigrationComplete(executor)) return;

    final preferences = await SharedPreferences.getInstance();
    await const SqlTaskMigrationWriter().migrateFromPreferences(
      executor: executor,
      preferences: preferences,
    );
    await _verifyLegacySourceBeforeCutover(executor, preferences);
    await G1DriftSchema.markLegacyMigrationComplete(executor);
  }

  Future<void> _verifyLegacySourceBeforeCutover(
    QueryExecutor executor,
    SharedPreferences preferences,
  ) async {
    final raw = preferences.getString(key);
    if (raw == null || raw.trim().isEmpty) return;

    final source = jsonDecode(raw);
    if (source is! List) {
      throw const FormatException('Canonical task storage must contain a list');
    }
    final rows = await executor.runSelect(
      'SELECT id FROM tasks ORDER BY storage_ordinal, id',
      const [],
    );
    final sqlIds = rows.map((row) => row['id'] as String).toList(growable: false);
    final sourceIds = <String>[];
    for (final item in source) {
      if (item is! Map || item['id'] is! String) {
        throw const FormatException('Legacy task entry must contain a string id');
      }
      sourceIds.add(item['id'] as String);
    }
    if (sqlIds.length != sourceIds.length ||
        !List<String>.from(sqlIds).toSet().containsAll(sourceIds) ||
        !List<String>.from(sourceIds).toSet().containsAll(sqlIds)) {
      throw StateError(
        'SQL migration identity mismatch: legacy=${sourceIds.length}, sql=${sqlIds.length}',
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
    envelope['followUpEnabled'] =
        (row['follow_up_enabled'] as num?)?.toInt() == 1;
    envelope['followUpDate'] = row['follow_up_date'];
    envelope['category'] = row['category'];
    envelope['notebookKind'] = row['notebook_kind'];
    envelope['reminderDate'] = row['reminder_date'];
    envelope['priority'] = row['priority'];
    envelope['archived'] = (row['archived'] as num?)?.toInt() == 1;
    envelope['trashed'] = (row['trashed'] as num?)?.toInt() == 1;
    envelope['completed'] = (row['completed'] as num?)?.toInt() == 1;

    final recurrence = row['recurrence_json'];
    envelope['recurrence'] =
        recurrence is String ? jsonDecode(recurrence) : null;

    final followUps = await executor.runSelect(
      'SELECT * FROM follow_ups WHERE task_id = ? ORDER BY ordinal',
      <Object?>[row['id']],
    );
    envelope['followUps'] = followUps.map(_followUpJson).toList();

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
      'SELECT person_json FROM task_people WHERE task_id = ? ORDER BY ordinal',
      <Object?>[row['id']],
    );
    envelope['people'] =
        people.map((item) => jsonDecode(item['person_json'] as String)).toList();

    return Task.fromJson(envelope);
  }

  Map<String, dynamic> _decodeEnvelope(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('SQL legacy envelope must be an object');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Map<String, dynamic> _followUpJson(Map<String, Object?> row) =>
      <String, dynamic>{
        'id': row['id'],
        'dateTime': row['date_time'],
        'note': row['note'],
        'result': row['result'],
        'reminderDate': row['reminder_date'],
        'nextFollowUp': row['next_follow_up'],
        'completed': (row['completed'] as num?)?.toInt() == 1,
      };

  Future<void> _saveUnlocked(List<Task> tasks) async {
    final executor = _database;
    await _ensureReady();

    await executor.runCustom('BEGIN');
    try {
      // Project membership is canonical SQL data owned by ProjectStore, but
      // project_items references tasks. Preserve those relationship rows while
      // this legacy-compatible TaskStore rewrite replaces the task rows.
      final projectItems = await executor.runSelect(
        'SELECT project_id, task_id, ordinal FROM project_items ORDER BY project_id, ordinal',
        const [],
      );
      // Keep unknown legacy fields when an existing SQL Task is rewritten.
      // Read them before deleting the task rows; otherwise _canonicalEnvelope
      // cannot recover the previous envelope after the DELETE.
      final legacyPayloads = <String, Map<String, dynamic>>{};
      final existingTasks = await executor.runSelect(
        'SELECT id, legacy_payload_json FROM tasks',
        const [],
      );
      for (final row in existingTasks) {
        final raw = row['legacy_payload_json'];
        if (row['id'] is String && raw is String && raw.trim().isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            legacyPayloads[row['id'] as String] =
                Map<String, dynamic>.from(decoded);
          }
        }
      }
      await executor.runCustom('DELETE FROM project_items');
      await executor.runCustom('DELETE FROM task_tags');
      await executor.runCustom('DELETE FROM tags');
      await executor.runCustom('DELETE FROM task_people');
      await executor.runCustom('DELETE FROM checklist_items');
      await executor.runCustom('DELETE FROM follow_ups');
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
            follow_up_enabled, follow_up_date, category, notebook_kind, reminder_date,
            priority, archived, trashed, completed, recurrence_json, legacy_payload_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            task.id,
            ordinal,
            task.title,
            task.description,
            task.createdAt?.toIso8601String(),
            task.updatedAt?.toIso8601String(),
            task.dueDate?.toIso8601String(),
            task.followUpEnabled ? 1 : 0,
            task.followUpDate?.toIso8601String(),
            task.category,
            task.notebookKind?.name,
            task.reminderDate?.toIso8601String(),
            task.priority.name,
            task.archived ? 1 : 0,
            task.trashed ? 1 : 0,
            task.completed ? 1 : 0,
            task.recurrence == null ? null : jsonEncode(task.recurrence!.toJson()),
            jsonEncode(envelope),
          ],
        );
        await _writeRelations(executor, task);
      }
      for (final row in projectItems) {
        await executor.runInsert(
          '''INSERT INTO project_items (project_id, task_id, ordinal)
             VALUES (?, ?, ?)''',
          <Object?>[row['project_id'], row['task_id'], row['ordinal']],
        );
      }


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
      'notebookKind', 'reminderDate', 'priority', 'archived', 'trashed',
      'completed', 'followUps', 'recurrence', 'people',
    };
    final preserved = <String, dynamic>{};
    final previous = previousPayload;
    if (previous != null) {
      for (final entry in previous.entries) {
        if (!knownKeys.contains(entry.key)) preserved[entry.key] = entry.value;
      }
    }
    final canonical = Map<String, dynamic>.from(task.toJson());
    preserved.addAll(canonical);
    return preserved;
  }

  Future<void> _writeRelations(QueryExecutor executor, Task task) async {
    for (var ordinal = 0; ordinal < task.followUps.length; ordinal++) {
      final followUp = task.followUps[ordinal];
      await executor.runInsert(
        '''INSERT INTO follow_ups
           (id, task_id, date_time, note, result, reminder_date, next_follow_up, completed, ordinal)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          followUp.id, task.id, followUp.dateTime.toIso8601String(), followUp.note,
          followUp.result, followUp.reminderDate?.toIso8601String(),
          followUp.nextFollowUp?.toIso8601String(), followUp.completed ? 1 : 0, ordinal,
        ],
      );
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
        'INSERT INTO task_people (task_id, person_id, person_json, ordinal) VALUES (?, ?, ?, ?)',
        <Object?>[task.id, person.id, jsonEncode(person.toJson()), ordinal],
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
  }

  static String _tagId(String value) =>
      'legacy-tag-${base64UrlEncode(utf8.encode(value)).replaceAll('=', '')}';
}
