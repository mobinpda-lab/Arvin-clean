export '../models/arvin_center.dart' show CenterDeleteBlocked;

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../models/arvin_center.dart';
import 'g1_drift_schema.dart';

/// Canonical Center directory and Center↔Project relationship operations.
class CenterStore {
  CenterStore({QueryExecutor? executor}) : _injectedExecutor = executor;
  static QueryExecutor? _sharedDatabase;
  static QueryExecutor? _testDatabase;
  final QueryExecutor? _injectedExecutor;

  QueryExecutor get _database {
    if (_injectedExecutor != null) return _injectedExecutor!;
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      return _testDatabase ??= NativeDatabase.memory();
    }
    return _sharedDatabase ??= driftDatabase(name: 'arvin');
  }

  static Future<void> resetTestDatabase() async {
    final db = _testDatabase;
    _testDatabase = null;
    if (db != null) await db.close();
  }

  Future<void> _ready() => G1DriftSchema.install(_database);

  Future<List<ArvinCenter>> load({bool includeArchived = true}) async {
    await _ready();
    final rows = await _database.runSelect(
      'SELECT id, name, is_archived, created_at FROM centers '
      "${includeArchived ? '' : 'WHERE is_archived = 0'} "
      'ORDER BY name COLLATE NOCASE, id',
      const [],
    );
    return List.unmodifiable(rows.map((row) => ArvinCenter(
      id: row['id'] as String,
      name: row['name'] as String,
      isArchived: (row['is_archived'] as num).toInt() == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
    )));
  }

  Future<List<String>> projectIds(String centerId) async {
    await _ready();
    final rows = await _database.runSelect(
      'SELECT project_id FROM center_projects WHERE center_id = ? ORDER BY project_id',
      <Object?>[centerId],
    );
    return List<String>.unmodifiable(rows.map((row) => row['project_id'] as String));
  }

  Future<void> create({required String id, required String name, DateTime? now}) async {
    final value = _normalize(name);
    await _ready();
    final duplicate = await _database.runSelect(
      'SELECT id FROM centers WHERE lower(trim(name)) = lower(trim(?)) LIMIT 1',
      [value],
    );
    if (duplicate.isNotEmpty) throw StateError('مرکزی با این نام وجود دارد.');
    await _database.runInsert(
      'INSERT INTO centers (id, name, is_archived, created_at) VALUES (?, ?, 0, ?)',
      [id, value, (now ?? DateTime.now()).toIso8601String()],
    );
  }

  Future<void> rename({required String id, required String name}) async {
    final value = _normalize(name);
    await _ready();
    final duplicate = await _database.runSelect(
      'SELECT id FROM centers WHERE lower(trim(name)) = lower(trim(?)) AND id <> ? LIMIT 1',
      [value, id],
    );
    if (duplicate.isNotEmpty) throw StateError('مرکزی با این نام وجود دارد.');
    final changed = await _database.runUpdate('UPDATE centers SET name = ? WHERE id = ?', [value, id]);
    if (changed != 1) throw StateError('مرکز پیدا نشد.');
  }

  Future<void> setArchived({required String id, required bool archived}) async {
    await _ready();
    final changed = await _database.runUpdate(
      'UPDATE centers SET is_archived = ? WHERE id = ?',
      [archived ? 1 : 0, id],
    );
    if (changed != 1) throw StateError('مرکز پیدا نشد.');
  }

  Future<void> addProjectRelationship({required String centerId, required String projectId}) async {
    await _ready();
    await _database.runInsert(
      'INSERT OR IGNORE INTO center_projects (center_id, project_id) VALUES (?, ?)',
      <Object?>[centerId, projectId],
    );
  }

  /// Removes one edge only. The Project and other Center edges remain intact.
  Future<void> removeProjectRelationship({required String centerId, required String projectId}) async {
    await _ready();
    await _database.runCustom('BEGIN');
    try {
      await _database.runDelete(
        'DELETE FROM center_projects WHERE center_id = ? AND project_id = ?',
        <Object?>[centerId, projectId],
      );
      final remaining = await _database.runSelect(
        'SELECT center_id FROM center_projects WHERE project_id = ? ORDER BY center_id',
        <Object?>[projectId],
      );
      await _database.runUpdate(
        'UPDATE projects SET center_id = ? WHERE id = ?',
        <Object?>[remaining.length == 1 ? remaining.single['center_id'] : null, projectId],
      );
      await _database.runCustom('COMMIT');
    } catch (_) {
      try { await _database.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  Future<void> delete({required String id}) async {
    await _ready();
    await _database.runCustom('BEGIN');
    try {
      final rows = await _database.runSelect(
        '''SELECT
          (SELECT COUNT(DISTINCT project_id) FROM center_projects WHERE center_id = ?) AS canonical_projects,
          (SELECT COUNT(DISTINCT id) FROM projects WHERE center_id = ?) AS legacy_projects,
          (SELECT COUNT(*) FROM tasks WHERE center_id = ?) AS task_refs''',
        <Object?>[id, id, id],
      );
      final row = rows.single;
      final projectIds = <String>{};
      final canonical = await projectIdsForDelete(id);
      projectIds.addAll(canonical);
      final count = projectIds.length +
          (row['legacy_projects'] as num).toInt() +
          (row['task_refs'] as num).toInt();
      if (count > 0) throw CenterDeleteBlocked(id, count);
      final changed = await _database.runDelete('DELETE FROM centers WHERE id = ?', [id]);
      if (changed != 1) throw StateError('مرکز پیدا نشد.');
      await _database.runCustom('COMMIT');
    } catch (_) {
      try { await _database.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  Future<List<String>> projectIdsForDelete(String centerId) async {
    final rows = await _database.runSelect(
      'SELECT project_id FROM center_projects WHERE center_id = ?',
      <Object?>[centerId],
    );
    return rows.map((row) => row['project_id'] as String).toList();
  }

  String _normalize(String name) {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError.value(name, 'name', 'نام مرکز الزامی است.');
    return value;
  }
}
