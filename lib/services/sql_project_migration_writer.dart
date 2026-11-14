import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_project.dart';
import 'g1_drift_schema.dart';
import 'project_plan_codec.dart';

/// Single migration boundary for legacy Project preferences into relational SQL.
class SqlProjectMigrationWriter {
  const SqlProjectMigrationWriter({this.codec = const ProjectPlanCodec()});
  static const String legacyKey = 'arvin.projects';
  final ProjectPlanCodec codec;

  Future<SqlProjectMigrationReport> migrateFromPreferences({
    required QueryExecutor executor,
    required SharedPreferences preferences,
  }) async {
    await G1DriftSchema.install(executor);
    final raw = preferences.getString(legacyKey);
    final entries = <({ProjectPlan project, Map<String, dynamic> source})>[];
    if (raw != null && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const FormatException('Projects must be a JSON list');
      final ids = <String>{};
      for (final item in decoded) {
        if (item is! Map) throw const FormatException('Project must be a JSON object');
        final source = Map<String, dynamic>.from(item);
        final project = codec.decode(source);
        if (!ids.add(project.id)) throw FormatException('Duplicate Project id: ${project.id}');
        entries.add((project: project, source: source));
      }
    }

    var inserted = 0;
    var skippedExisting = 0;
    await executor.runCustom('BEGIN');
    try {
      for (var ordinal = 0; ordinal < entries.length; ordinal++) {
        final entry = entries[ordinal];
        final existing = await executor.runSelect(
          'SELECT id FROM projects WHERE id = ? LIMIT 1',
          <Object?>[entry.project.id],
        );
        if (existing.isNotEmpty) {
          await _ensureCanonicalRelations(executor, entry.project);
          await _assertProjectParity(executor, entry.project, entry.source, ordinal);
          skippedExisting++;
          continue;
        }
        await executor.runInsert(
          '''INSERT INTO projects (
            id, storage_ordinal, name, color_value, is_archived,
            center_id, template_id, template_name_snapshot, legacy_payload_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          <Object?>[
            entry.project.id, ordinal, entry.project.title,
            entry.project.colorValue, entry.project.isArchived ? 1 : 0,
            entry.project.centerId, entry.project.templateId,
            entry.project.templateNameSnapshot, jsonEncode(entry.source),
          ],
        );
        await _ensureCanonicalRelations(executor, entry.project);
        for (var itemOrdinal = 0; itemOrdinal < entry.project.itemIds.length; itemOrdinal++) {
          await executor.runInsert(
            'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
            <Object?>[entry.project.id, entry.project.itemIds[itemOrdinal], itemOrdinal],
          );
        }
        inserted++;
      }

      if (entries.isNotEmpty) {
        final rows = await executor.runSelect(
          'SELECT id, storage_ordinal FROM projects ORDER BY storage_ordinal, id',
          const [],
        );
        if (rows.length != entries.length) {
          throw StateError('Project row-count mismatch before commit: source=${entries.length}, target=${rows.length}');
        }
        for (var ordinal = 0; ordinal < entries.length; ordinal++) {
          if (rows[ordinal]['id'] != entries[ordinal].project.id ||
              (rows[ordinal]['storage_ordinal'] as num?)?.toInt() != ordinal) {
            throw StateError('Project identity/order mismatch at ordinal $ordinal before commit.');
          }
          await _assertProjectParity(
            executor, entries[ordinal].project, entries[ordinal].source, ordinal,
          );
        }
      }
      final foreignKeyViolations = await executor.runSelect('PRAGMA foreign_key_check', const []);
      if (foreignKeyViolations.isNotEmpty) {
        throw StateError('Project migration foreign-key violations: $foreignKeyViolations');
      }
      await executor.runCustom(
        "INSERT INTO arvin_storage_meta (key, value) VALUES ('legacy_projects_migrated', '1') "
        "ON CONFLICT(key) DO UPDATE SET value = '1'",
      );
      await executor.runCustom('COMMIT');
    } catch (_) {
      try { await executor.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }

    final countRows = await executor.runSelect('SELECT COUNT(*) AS count FROM projects', const []);
    return SqlProjectMigrationReport(
      sourceCount: entries.length, insertedCount: inserted,
      skippedExistingCount: skippedExisting,
      sqlProjectCount: (countRows.single['count'] as num).toInt(),
    );
  }

  Future<void> _ensureCanonicalRelations(QueryExecutor executor, ProjectPlan project) async {
    for (final centerId in project.centerIds) {
      await executor.runInsert(
        'INSERT OR IGNORE INTO center_projects (center_id, project_id) VALUES (?, ?)',
        <Object?>[centerId, project.id],
      );
    }
    for (final categoryId in project.categoryIds) {
      final category = await executor.runSelect(
        'SELECT id FROM categories WHERE id = ?',
        <Object?>[categoryId],
      );
      if (category.isEmpty) {
        throw StateError('Project ${project.id} references unknown Category $categoryId.');
      }
      await executor.runInsert(
        'INSERT OR IGNORE INTO project_categories (project_id, category_id) VALUES (?, ?)',
        <Object?>[project.id, categoryId],
      );
    }
  }

  Future<void> _assertProjectParity(
    QueryExecutor executor, ProjectPlan project,
    Map<String, dynamic> source, int ordinal,
  ) async {
    final rows = await executor.runSelect(
      'SELECT * FROM projects WHERE id = ?', <Object?>[project.id],
    );
    if (rows.length != 1) throw StateError('Missing or duplicate SQL Project ${project.id}.');
    final row = rows.single;
    final expected = <String, Object?>{
      'storage_ordinal': ordinal, 'name': project.title,
      'color_value': project.colorValue, 'is_archived': project.isArchived ? 1 : 0,
      'center_id': project.centerId, 'template_id': project.templateId,
      'template_name_snapshot': project.templateNameSnapshot,
    };
    for (final entry in expected.entries) {
      if (row[entry.key] != entry.value) {
        throw StateError('Project field conflict ${project.id}.${entry.key}.');
      }
    }
    final rawEnvelope = row['legacy_payload_json'];
    if (rawEnvelope is! String ||
        _canonicalJson(jsonDecode(rawEnvelope)) != _canonicalJson(source)) {
      throw StateError('Project unknown-field/envelope conflict for ${project.id}.');
    }
    final membership = await executor.runSelect(
      'SELECT task_id, ordinal FROM project_items WHERE project_id = ? ORDER BY ordinal',
      <Object?>[project.id],
    );
    final expectedMembership = List.generate(
      project.itemIds.length,
      (index) => <String, Object?>{'task_id': project.itemIds[index], 'ordinal': index},
    );
    final actualMembership = membership.map((item) => <String, Object?>{
      'task_id': item['task_id'], 'ordinal': item['ordinal'],
    }).toList();
    if (_canonicalJson(actualMembership) != _canonicalJson(expectedMembership)) {
      throw StateError('Project membership/order parity conflict for ${project.id}.');
    }
  }

  Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{for (final key in keys) key: _canonicalize(value[key])};
    }
    if (value is List) return value.map(_canonicalize).toList(growable: false);
    return value;
  }
  String _canonicalJson(Object? value) => jsonEncode(_canonicalize(value));
}

class SqlProjectMigrationReport {
  const SqlProjectMigrationReport({
    this.sourceCount = 0, this.insertedCount = 0,
    this.skippedExistingCount = 0, this.sqlProjectCount = 0,
  });
  final int sourceCount;
  final int insertedCount;
  final int skippedExistingCount;
  final int sqlProjectCount;
}
