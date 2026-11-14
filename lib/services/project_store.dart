import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_project.dart';
import 'center_store.dart';
import 'g1_drift_schema.dart';
import 'project_plan_codec.dart';
import 'sql_project_migration_writer.dart';
import 'task_store.dart';

typedef ProjectStoreFailureInjector = FutureOr<void> Function(String stage);

/// The single SQL owner for Project rows and their canonical junction edges.
/// save() is an additive/partial Upsert; omitted Projects and relationships
/// are never interpreted as delete instructions.
class ProjectStore {
  ProjectStore({
    this.codec = const ProjectPlanCodec(),
    QueryExecutor? executor,
    this.failureInjector,
  }) : _injectedExecutor = executor;

  static const String key = 'arvin.projects';
  static QueryExecutor? _sharedDatabase;
  static QueryExecutor? _testDatabase;
  final ProjectPlanCodec codec;
  final QueryExecutor? _injectedExecutor;
  final ProjectStoreFailureInjector? failureInjector;

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

  Future<void> _inject(String stage) async => await failureInjector?.call(stage);

  Future<void> _ensureReady() async {
    final executor = _database;
    await G1DriftSchema.install(executor);
    await TaskStore(executor: executor).load();
    final marker = await executor.runSelect(
      "SELECT value FROM arvin_storage_meta WHERE key = 'legacy_projects_migrated'",
      const [],
    );
    if (marker.isNotEmpty && marker.single['value'] == '1') return;
    final preferences = await SharedPreferences.getInstance();
    await SqlProjectMigrationWriter(codec: codec).migrateFromPreferences(
      executor: executor,
      preferences: preferences,
    );
  }

  Future<List<ProjectPlan>> load() async {
    final executor = _database;
    await _ensureReady();
    final rows = await executor.runSelect(
      'SELECT * FROM projects ORDER BY storage_ordinal, id', const [],
    );
    final result = <ProjectPlan>[];
    for (final row in rows) {
      final id = row['id'] as String;
      final itemRows = await executor.runSelect(
        'SELECT task_id FROM project_items WHERE project_id = ? ORDER BY ordinal',
        <Object?>[id],
      );
      final centerRows = await executor.runSelect(
        'SELECT center_id FROM center_projects WHERE project_id = ? ORDER BY center_id',
        <Object?>[id],
      );
      final categoryRows = await executor.runSelect(
        'SELECT category_id FROM project_categories WHERE project_id = ? ORDER BY category_id',
        <Object?>[id],
      );
      final rawEnvelope = row['legacy_payload_json'];
      final envelope = rawEnvelope is String && rawEnvelope.trim().isNotEmpty
          ? jsonDecode(rawEnvelope) : <String, dynamic>{};
      if (envelope is! Map) {
        throw FormatException('Project legacy envelope is invalid for ${id}');
      }
      result.add(codec.decode(<String, dynamic>{
        ...Map<String, dynamic>.from(envelope),
        'id': id,
        'title': row['name'],
        'colorValue': row['color_value'],
        'isArchived': (row['is_archived'] as num?)?.toInt() == 1,
        'centerIds': centerRows.map((item) => item['center_id'] as String).toList(),
        'centerId': centerRows.length == 1 ? centerRows.single['center_id'] : null,
        'categoryIds': categoryRows.map((item) => item['category_id'] as String).toList(),
        'templateId': row['template_id'],
        'templateNameSnapshot': row['template_name_snapshot'],
        'itemIds': itemRows.map((item) => item['task_id'] as String).toList(),
      }));
    }
    return List<ProjectPlan>.unmodifiable(result);
  }

  /// Upserts only the supplied identities. Existing rows, Task links,
  /// template applications, and unspecified relationships remain untouched.
  Future<void> save(Iterable<ProjectPlan> projects) async {
    final executor = _database;
    await _ensureReady();
    final values = List<ProjectPlan>.of(projects);
    final ids = <String>{};
    for (final project in values) {
      if (project.id.trim().isEmpty || !ids.add(project.id)) {
        throw ArgumentError('Project IDs must be non-empty and unique in one save.');
      }
    }

    await executor.runCustom('BEGIN');
    try {
      for (final project in values) {
        final existing = await executor.runSelect(
          'SELECT id, storage_ordinal, center_id, color_value, is_archived, template_id, template_name_snapshot, legacy_payload_json FROM projects WHERE id = ?',
          <Object?>[project.id],
        );
        final isNew = existing.isEmpty;
        final ordinal = isNew
            ? await _nextOrdinal(executor)
            : (existing.single['storage_ordinal'] as num).toInt();
        final oldEnvelope = isNew
            ? <String, dynamic>{}
            : _decodeEnvelope(existing.single['legacy_payload_json'], project.id);
        final payload = <String, dynamic>{
          ...oldEnvelope,
          ...project.legacyFields,
          ...codec.encode(project),
        };
        if (project.centerRelationshipsSpecified) {
          payload.remove('centerId');
          if (project.centerId != null) payload['centerId'] = project.centerId;
        }
        if (project.templateIdSpecified && project.templateId == null) payload.remove('templateId');
        if (project.templateNameSnapshotSpecified && project.templateNameSnapshot == null) {
          payload.remove('templateNameSnapshot');
        }

        if (isNew) {
          await executor.runInsert(
            '''INSERT INTO projects
               (id, storage_ordinal, name, color_value, is_archived, center_id,
                template_id, template_name_snapshot, legacy_payload_json)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
            <Object?>[
              project.id, ordinal, project.title, project.colorValue,
              project.isArchived ? 1 : 0,
              project.centerRelationshipsSpecified ? project.centerId : null,
              project.templateId, project.templateNameSnapshot, jsonEncode(payload),
            ],
          );
        } else {
          await executor.runUpdate(
            '''UPDATE projects SET name = ?, color_value = ?, is_archived = ?,
               center_id = ?, template_id = ?, template_name_snapshot = ?,
               legacy_payload_json = ? WHERE id = ?''',
            <Object?>[
              project.title,
              project.colorValueSpecified ? project.colorValue : existing.single['color_value'],
              project.isArchivedSpecified ? (project.isArchived ? 1 : 0) : existing.single['is_archived'],
              project.centerRelationshipsSpecified
                  ? project.centerId : existing.single['center_id'],
              project.templateIdSpecified ? project.templateId : existing.single['template_id'],
              project.templateNameSnapshotSpecified
                  ? project.templateNameSnapshot : existing.single['template_name_snapshot'],
              jsonEncode(payload), project.id,
            ],
          );
        }

        if (project.centerRelationshipsSpecified) {
          await _replaceCenters(executor, project.id, project.centerIds);
        }
        if (project.categoryRelationshipsSpecified) {
          await _replaceCategories(executor, project.id, project.categoryIds);
        }
        if (project.itemIdsSpecified) {
          await _replaceItems(executor, project.id, project.itemIds);
        }
        await _inject('after_project_${project.id}');
      }
      await _inject('before_commit');
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  Future<int> _nextOrdinal(QueryExecutor executor) async {
    final rows = await executor.runSelect(
      'SELECT COALESCE(MAX(storage_ordinal), -1) + 1 AS next_ordinal FROM projects',
      const [],
    );
    return (rows.single['next_ordinal'] as num).toInt();
  }

  Map<String, dynamic> _decodeEnvelope(Object? raw, String id) {
    if (raw == null) return <String, dynamic>{};
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Project legacy envelope is invalid for ${id}');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw FormatException('Project legacy envelope is invalid for ${id}');
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _replaceCenters(QueryExecutor executor, String projectId, Iterable<String> centerIds) async {
    await executor.runDelete('DELETE FROM center_projects WHERE project_id = ?', <Object?>[projectId]);
    for (final centerId in centerIds.toSet().toList()..sort()) {
      await executor.runInsert(
        'INSERT INTO center_projects (center_id, project_id) VALUES (?, ?)',
        <Object?>[centerId, projectId],
      );
    }
  }

  Future<void> _replaceCategories(QueryExecutor executor, String projectId, Iterable<String> categoryIds) async {
    await executor.runDelete('DELETE FROM project_categories WHERE project_id = ?', <Object?>[projectId]);
    for (final categoryId in categoryIds.toSet().toList()..sort()) {
      await executor.runInsert(
        'INSERT INTO project_categories (project_id, category_id) VALUES (?, ?)',
        <Object?>[projectId, categoryId],
      );
    }
  }

  Future<void> _replaceItems(QueryExecutor executor, String projectId, Iterable<String> taskIds) async {
    final ids = taskIds.toList();
    if (ids.toSet().length != ids.length) throw ArgumentError('Project Task IDs must be unique.');
    await executor.runDelete('DELETE FROM project_items WHERE project_id = ?', <Object?>[projectId]);
    for (var ordinal = 0; ordinal < ids.length; ordinal++) {
      await executor.runInsert(
        'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
        <Object?>[projectId, ids[ordinal], ordinal],
      );
    }
  }

  Future<void> delete(String projectId) async {
    final executor = _database;
    await _ensureReady();
    await executor.runCustom('BEGIN');
    try {
      final refs = await executor.runSelect(
        '''SELECT
          (SELECT COUNT(*) FROM project_items WHERE project_id = ?) AS items,
          (SELECT COUNT(*) FROM template_task_applications WHERE project_id = ?) AS templates,
          (SELECT COUNT(*) FROM tasks WHERE project_id = ?) AS task_refs''',
        <Object?>[projectId, projectId, projectId],
      );
      final row = refs.single;
      final count = (row['items'] as num).toInt() +
          (row['templates'] as num).toInt() +
          (row['task_refs'] as num).toInt();
      if (count > 0) throw ProjectDeleteBlocked(projectId);
      await executor.runDelete('DELETE FROM center_projects WHERE project_id = ?', [projectId]);
      await executor.runDelete('DELETE FROM project_categories WHERE project_id = ?', [projectId]);
      final deleted = await executor.runDelete('DELETE FROM projects WHERE id = ?', [projectId]);
      if (deleted != 1) throw StateError('Project not found: ${projectId}');
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  /// Explicitly destructive collection operation. It performs checked,
  /// per-Project deletion and never recreates the projects table.
  Future<void> clear() async {
    final executor = _database;
    final ids = (await load()).map((project) => project.id).toList();
    if (ids.isEmpty) return;
    await executor.runCustom('BEGIN');
    try {
      for (final id in ids) {
        final refs = await executor.runSelect(
          '''SELECT
            (SELECT COUNT(*) FROM project_items WHERE project_id = ?) AS items,
            (SELECT COUNT(*) FROM template_task_applications WHERE project_id = ?) AS templates,
            (SELECT COUNT(*) FROM tasks WHERE project_id = ?) AS task_refs''',
          <Object?>[id, id, id],
        );
        final row = refs.single;
        final count = (row['items'] as num).toInt() +
            (row['templates'] as num).toInt() +
            (row['task_refs'] as num).toInt();
        if (count > 0) throw ProjectDeleteBlocked(id);
      }
      for (final id in ids) {
        await executor.runDelete('DELETE FROM center_projects WHERE project_id = ?', [id]);
        await executor.runDelete('DELETE FROM project_categories WHERE project_id = ?', [id]);
        await executor.runDelete('DELETE FROM projects WHERE id = ?', [id]);
      }
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  Future<void> removeCenterRelationship(String projectId, String centerId) =>
      CenterStore(executor: _database).removeProjectRelationship(
        centerId: centerId,
        projectId: projectId,
      );

  Future<void> removeCategoryRelationship(String projectId, String categoryId) async {
    final executor = _database;
    await _ensureReady();
    await executor.runDelete(
      'DELETE FROM project_categories WHERE project_id = ? AND category_id = ?',
      <Object?>[projectId, categoryId],
    );
  }
}
