import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_project.dart';
import 'g1_drift_schema.dart';
import 'project_plan_codec.dart';

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

  final ProjectPlanCodec codec;
  final QueryExecutor? _injectedExecutor;

  static Future<void> resetTestDatabase() async {
    final executor = _testDatabase;
    _testDatabase = null;
    if (executor != null) await executor.close();
  }

  QueryExecutor get _database {
    final injected = _injectedExecutor;
    if (injected != null) return injected;
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      return _testDatabase ??= NativeDatabase.memory();
    }
    return _sharedDatabase ??= driftDatabase(name: 'arvin');
  }

  Future<void> _ensureReady() async {
    final executor = _database;
    await G1DriftSchema.install(executor);
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
          final project = projects[ordinal];
          await _insertProject(executor, project);
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
  }

  Future<List<ProjectPlan>> load() async {
    final executor = _database;
    await _ensureReady();
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
      result.add(codec.decode({
        'id': row['id'],
        'title': row['name'],
        'colorValue': row['color_value'],
        'isArchived': (row['is_archived'] as num?)?.toInt() == 1,
        'itemIds': itemRows.map((item) => item['task_id'] as String).toList(),
      }));
    }
    return List<ProjectPlan>.unmodifiable(result);
  }

  Future<void> save(Iterable<ProjectPlan> projects) async {
    final executor = _database;
    await _ensureReady();
    final values = List<ProjectPlan>.of(projects);
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
  }

  Future<void> clear() => save(const <ProjectPlan>[]);

  Future<void> _insertProject(QueryExecutor executor, ProjectPlan project) async {
    await executor.runInsert(
      '''INSERT INTO projects
         (id, name, color_value, is_archived, legacy_payload_json)
         VALUES (?, ?, ?, ?, ?)''',
      <Object?>[
        project.id,
        project.title,
        project.colorValue,
        project.isArchived ? 1 : 0,
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
