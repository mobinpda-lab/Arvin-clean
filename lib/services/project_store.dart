import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_project.dart';
import 'g1_drift_schema.dart';
import 'project_plan_codec.dart';
import 'task_store.dart';
import 'task_storage_lock.dart';
import 'arvin_async_trace.dart';

/// Canonical local persistence for Arvin Projects.
///
/// Project membership stores only canonical Task ids through [ProjectPlan].
/// The collection now uses the same SQLite/Drift database as canonical Tasks;
/// legacy SharedPreferences is read only once for migration.
class ProjectStore {
  ProjectStore({
    this.codec = const ProjectPlanCodec(),
    QueryExecutor? executor,
  }) : _injectedExecutor = executor;

  static const String key = 'arvin.projects';
  static QueryExecutor? _sharedDatabase;
  static QueryExecutor? _testDatabase;
  static final Expando<Future<void>> _readyByExecutor =
      Expando<Future<void>>('project-store-ready');
  static final Expando<bool> _closingByExecutor =
      Expando<bool>('project-store-closing');

  final ProjectPlanCodec codec;
  final QueryExecutor? _injectedExecutor;

  static Future<void> resetTestDatabase() async {
    final executor = _testDatabase;
    if (executor == null) return;

    _closingByExecutor[executor] = true;
    final pending = _readyByExecutor[executor];
    if (pending != null) {
      try {
        await pending;
      } catch (_) {
        // A failed initialization still has to be drained before close.
      }
    }
    await TaskStorageLock.synchronized<void>(() => executor.close());
    if (identical(_testDatabase, executor)) _testDatabase = null;
    _readyByExecutor[executor] = null;
    _closingByExecutor[executor] = null;
  }

  QueryExecutor get _database {
    final injected = _injectedExecutor;
    if (injected != null) return injected;
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      return _testDatabase ??= NativeDatabase.memory();
    }
    return _sharedDatabase ??= driftDatabase(name: 'arvin');
  }

  void _ensureNotClosing(QueryExecutor executor) {
    if (_closingByExecutor[executor] == true) {
      throw StateError('ProjectStore database shutdown has begun');
    }
  }

  Future<void> _ensureReady() {
    final executor = _database;
    _ensureNotClosing(executor);
    final pending = _readyByExecutor[executor];
    if (pending != null) return pending;

    late final Future<void> shared;
    shared = _initialize(executor).catchError((Object error, StackTrace stackTrace) {
      if (identical(_readyByExecutor[executor], shared)) {
        _readyByExecutor[executor] = null;
      }
      Error.throwWithStackTrace(error, stackTrace);
    });
    _readyByExecutor[executor] = shared;
    return shared;
  }

  Future<void> _initialize(QueryExecutor executor) async {
    await TaskStorageLock.synchronized<void>(
      () => G1DriftSchema.install(executor),
    );
    // Tasks own the referenced identity. Initialize them in their own lock
    // operation before the Project migration lock is acquired.
    await arvinTraceFuture(
      'project.store.task_prerequisite',
      TaskStore(executor: executor).load(),
    );

    await TaskStorageLock.synchronized<void>(() async {
      final marker = await executor.runSelect(
        "SELECT value FROM arvin_storage_meta WHERE key = 'legacy_projects_migrated'",
        const [],
      );
      if (marker.isNotEmpty && marker.single['value'] == '1') return;

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null && raw.trim().isNotEmpty) {
        final projects = codec.decodeList(jsonDecode(raw));
        await executor.runCustom('BEGIN');
        try {
          for (var ordinal = 0; ordinal < projects.length; ordinal++) {
            await _insertProject(executor, projects[ordinal]);
          }
          await executor.runCustom('COMMIT');
        } catch (_) {
          try { await executor.runCustom('ROLLBACK'); } catch (_) {}
          rethrow;
        }
      }

      await executor.runCustom(
        "INSERT INTO arvin_storage_meta (key, value) VALUES ('legacy_projects_migrated', '1') "
        "ON CONFLICT(key) DO UPDATE SET value = '1'",
      );
    });
  }

  Future<List<ProjectPlan>> load() async {
    await _ensureReady();
    final executor = _database;
    _ensureNotClosing(executor);
    return TaskStorageLock.synchronized<List<ProjectPlan>>(() async {
      final rows = await executor.runSelect(
        'SELECT * FROM projects ORDER BY id',
        const [],
      );
      final result = <ProjectPlan>[];
      for (final row in rows) {
        final itemRows = await executor.runSelect(
          'SELECT task_id FROM project_items WHERE project_id = ? ORDER BY ordinal',
          <Object?>[row['id']],
        );
        final rawEnvelope = row['legacy_payload_json'];
        Map<String, dynamic> envelope = <String, dynamic>{};
        if (rawEnvelope is String && rawEnvelope.trim().isNotEmpty) {
          final decoded = jsonDecode(rawEnvelope);
          if (decoded is! Map) {
            throw FormatException('Project metadata is invalid for ${row['id']}');
          }
          envelope = Map<String, dynamic>.from(decoded);
        }
        final projectEnvelope = <String, dynamic>{
          ...envelope,
          'id': row['id'],
          'title': row['name'],
          'colorValue': row['color_value'],
          'isArchived': (row['is_archived'] as num?)?.toInt() == 1,
          'itemIds': itemRows.map((item) => item['task_id'] as String).toList(),
        };
        final legacyCenterId = row['legacy_center_id'];
        if (legacyCenterId is String) {
          projectEnvelope['legacyCenterId'] = legacyCenterId;
        }
        result.add(codec.decode(projectEnvelope));
      }
      return List<ProjectPlan>.unmodifiable(result);
    });
  }

  /// Backward-compatible entry point; saves are additive upserts, never a
  /// collection-wide delete/recreate operation.
  Future<void> save(Iterable<ProjectPlan> projects) => upsert(projects);

  /// Transactionally upserts only the supplied Project identities. Existing
  /// membership is changed only when itemIds was explicitly supplied. Deletes
  /// are explicit and blocked while a Project still references Tasks.
  Future<void> upsert(
    Iterable<ProjectPlan> projects, {
    Iterable<String> deleteProjectIds = const <String>[],
  }) async {
    await _ensureReady();
    final executor = _database;
    _ensureNotClosing(executor);
    await TaskStorageLock.synchronized<void>(() async {
    final values = List<ProjectPlan>.of(projects);
    final ids = values.map((project) => project.id).toSet();
    if (ids.length != values.length) {
      throw ArgumentError('Duplicate Project id in upsert batch.');
    }
    final deletes = deleteProjectIds.toSet();
    if (deletes.length != deleteProjectIds.length) {
      throw ArgumentError('Duplicate Project id in delete batch.');
    }
    if (deletes.any(ids.contains)) {
      throw ArgumentError('A Project cannot be upserted and deleted in one batch.');
    }

    await executor.runCustom('BEGIN');
    try {
      for (final project in values) {
        await _upsertProject(executor, project);
      }
      for (final projectId in deletes) {
        final references = await executor.runSelect(
          'SELECT task_id FROM project_items WHERE project_id = ? LIMIT 1',
          <Object?>[projectId],
        );
        if (references.isNotEmpty) throw ProjectDeleteBlocked(projectId);
        final deleted = await executor.runDelete(
          'DELETE FROM projects WHERE id = ?',
          <Object?>[projectId],
        );
        if (deleted != 1) throw StateError('Unknown Project: $projectId');
      }
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
    });
  }

  /// Explicit full-snapshot replacement, reserved for restore/clear flows.
  /// Ordinary editing and assignment must use [upsert].
  Future<void> replaceAll(Iterable<ProjectPlan> projects) async {
    await _ensureReady();
    final executor = _database;
    _ensureNotClosing(executor);
    await TaskStorageLock.synchronized<void>(() async {
    final values = List<ProjectPlan>.of(projects);
    final ids = values.map((project) => project.id).toSet();
    if (ids.length != values.length) {
      throw ArgumentError('Duplicate Project id in replacement snapshot.');
    }
    await executor.runCustom('BEGIN');
    try {
      await executor.runCustom('DELETE FROM project_items');
      await executor.runCustom('DELETE FROM projects');
      for (final project in values) {
        await _insertProject(executor, project);
      }
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
    });
  }

  /// Explicitly removes only unreferenced Projects. If any Project still owns
  /// Task links, the whole clear is rejected and all records remain intact.
  Future<void> clear() async {
    final current = await load();
    await upsert(
      const <ProjectPlan>[],
      deleteProjectIds: current.map((project) => project.id),
    );
  }

  Future<void> _upsertProject(QueryExecutor executor, ProjectPlan project) async {
    final existing = await executor.runSelect(
      'SELECT legacy_payload_json, legacy_center_id FROM projects WHERE id = ?',
      <Object?>[project.id],
    );
    Map<String, dynamic> previousEnvelope = <String, dynamic>{};
    if (existing.isNotEmpty) {
      final raw = existing.single['legacy_payload_json'];
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) {
          throw FormatException('Project metadata is invalid for ${project.id}');
        }
        previousEnvelope = Map<String, dynamic>.from(decoded);
      }
    }
    final envelope = <String, dynamic>{
      ...previousEnvelope,
      ...codec.encode(project),
    };
    final legacyCenterId = project.legacyFields.containsKey('legacyCenterId')
        ? project.legacyFields['legacyCenterId']
        : existing.isNotEmpty
            ? existing.single['legacy_center_id']
            : null;
    if (legacyCenterId is String) {
      envelope['legacyCenterId'] = legacyCenterId;
    }
    await executor.runInsert(
      '''INSERT INTO projects
         (id, name, color_value, is_archived, legacy_center_id, legacy_payload_json)
         VALUES (?, ?, ?, ?, ?, ?)
         ON CONFLICT(id) DO UPDATE SET
           name = excluded.name,
           color_value = excluded.color_value,
           is_archived = excluded.is_archived,
           legacy_center_id = excluded.legacy_center_id,
           legacy_payload_json = excluded.legacy_payload_json''',
      <Object?>[
        project.id,
        project.title,
        project.colorValue,
        project.isArchived ? 1 : 0,
        legacyCenterId,
        jsonEncode(envelope),
      ],
    );
    if (project.itemIdsSpecified) {
      await executor.runDelete(
        'DELETE FROM project_items WHERE project_id = ?',
        <Object?>[project.id],
      );
      final seenTaskIds = <String>{};
      for (var ordinal = 0; ordinal < project.itemIds.length; ordinal++) {
        final taskId = project.itemIds[ordinal];
        if (!seenTaskIds.add(taskId)) {
          throw ArgumentError('Duplicate Task id $taskId in Project ${project.id}.');
        }
        await executor.runInsert(
          '''INSERT INTO project_items (project_id, task_id, ordinal)
             VALUES (?, ?, ?)''',
          <Object?>[project.id, taskId, ordinal],
        );
      }
    }
  }

  Future<void> _insertProject(QueryExecutor executor, ProjectPlan project) async {
    final legacyCenterId = project.legacyFields['legacyCenterId'];
    await executor.runInsert(
      '''INSERT INTO projects
         (id, name, color_value, is_archived, legacy_center_id, legacy_payload_json)
         VALUES (?, ?, ?, ?, ?, ?)''',
      <Object?>[
        project.id,
        project.title,
        project.colorValue,
        project.isArchived ? 1 : 0,
        legacyCenterId,
        jsonEncode(codec.encode(project)),
      ],
    );
    for (var ordinal = 0; ordinal < project.itemIds.length; ordinal++) {
      await executor.runInsert(
        '''INSERT INTO project_items (project_id, task_id, ordinal)
           VALUES (?, ?, ?)''',
        <Object?>[project.id, project.itemIds[ordinal], ordinal],
      );
    }
  }
}
