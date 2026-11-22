import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/center.dart';
import 'g1_drift_schema.dart';
import 'project_store.dart';
import 'arvin_async_trace.dart';

/// Canonical Center persistence over the existing G1 SQLite database.
///
/// This store does not create a second database or relationship catalog.
/// Center↔Project links are stored only in the schema-v9 center_projects table.
class CenterStore {
  CenterStore({QueryExecutor? executor}) : _injectedExecutor = executor;

  static QueryExecutor? _sharedDatabase;
  static QueryExecutor? _testDatabase;

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

  Future<void>? _readyFuture;

  Future<void> _ensureReady() {
    final pending = _readyFuture;
    if (pending != null) return pending;

    // Every Center read/mutation shares one initialization future per store.
    // In particular, a page loading several Center↔Project edges concurrently
    // must not fan out repeated schema installs and Project/Task prerequisites
    // against the same SQLite executor.
    final initialization = _initialize();
    _readyFuture = initialization;
    return initialization.catchError((Object error, StackTrace stackTrace) {
      // Permit a later operation to retry after a genuine initialization error.
      if (identical(_readyFuture, initialization)) _readyFuture = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  Future<void> _initialize() async {
    final executor = _database;
    await arvinTraceFuture('center.store.schema_install', G1DriftSchema.install(executor));
    // Reuse the canonical Project/Task initialization path. This ensures
    // legacy Projects are migrated before Center↔Project foreign keys are used.
    await arvinTraceFuture('center.store.project_prerequisite', ProjectStore(executor: executor).load());
  }

  Future<List<Center>> load({bool includeArchived = true}) async {
    final executor = _database;
    await _ensureReady();
    final rows = await executor.runSelect(
      includeArchived
          ? 'SELECT * FROM centers ORDER BY name COLLATE NOCASE, id'
          : 'SELECT * FROM centers WHERE is_archived = 0 ORDER BY name COLLATE NOCASE, id',
      const [],
    );
    return List<Center>.unmodifiable(rows.map(_decode));
  }

  /// Searches Center names while preserving the store's canonical sort order.
  /// Archived rows are excluded by default and can be included explicitly.
  Future<List<Center>> search(
    String query, {
    bool includeArchived = false,
  }) async {
    final needle = query.trim().toLowerCase();
    final centers = await load(includeArchived: includeArchived);
    if (needle.isEmpty) return centers;
    return List<Center>.unmodifiable(
      centers.where((center) => center.name.toLowerCase().contains(needle)),
    );
  }

  Future<Center?> findById(String centerId) async {
    final executor = _database;
    await _ensureReady();
    final rows = await executor.runSelect(
      'SELECT * FROM centers WHERE id = ?',
      <Object?>[centerId],
    );
    return rows.isEmpty ? null : _decode(rows.single);
  }

  Future<Center> create({
    required String id,
    required String name,
  }) async {
    final now = DateTime.now().toUtc();
    final center = Center(
      id: id,
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await upsert(<Center>[center]);
    return (await findById(id))!;
  }

  /// Additive identity-preserving upsert. Existing created_at is immutable.
  Future<void> upsert(Iterable<Center> centers) async {
    final executor = _database;
    await _ensureReady();
    final values = List<Center>.of(centers);
    final ids = values.map((center) => center.id).toSet();
    if (ids.length != values.length) {
      throw ArgumentError('Duplicate Center id in upsert batch.');
    }
    for (final center in values) {
      if (center.id.trim().isEmpty) {
        throw ArgumentError('Center id cannot be empty.');
      }
      if (center.name.trim().isEmpty) {
        throw ArgumentError('Center name cannot be empty.');
      }
    }

    await executor.runCustom('BEGIN');
    try {
      for (final center in values) {
        final existing = await executor.runSelect(
          'SELECT created_at FROM centers WHERE id = ?',
          <Object?>[center.id],
        );
        final createdAt = existing.isEmpty
            ? center.createdAt.toUtc().toIso8601String()
            : existing.single['created_at'] as String;
        await executor.runInsert(
          '''INSERT INTO centers
             (id, name, is_archived, created_at, updated_at)
             VALUES (?, ?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET
               name = excluded.name,
               is_archived = excluded.is_archived,
               updated_at = excluded.updated_at''',
          <Object?>[
            center.id,
            center.name.trim(),
            center.isArchived ? 1 : 0,
            createdAt,
            center.updatedAt.toUtc().toIso8601String(),
          ],
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

  Future<Center> rename(String centerId, String name) async {
    final current = await findById(centerId);
    if (current == null) throw StateError('Unknown Center: $centerId');
    final nextName = name.trim();
    if (nextName.isEmpty) throw ArgumentError('Center name cannot be empty.');
    await upsert(<Center>[
      current.copyWith(name: nextName, updatedAt: DateTime.now().toUtc()),
    ]);
    return (await findById(centerId))!;
  }

  Future<void> archive(String centerId) => _setArchived(centerId, true);

  Future<void> restore(String centerId) => _setArchived(centerId, false);

  Future<void> _setArchived(String centerId, bool archived) async {
    final executor = _database;
    await _ensureReady();
    final changed = await executor.runUpdate(
      'UPDATE centers SET is_archived = ?, updated_at = ? WHERE id = ?',
      <Object?>[
        archived ? 1 : 0,
        DateTime.now().toUtc().toIso8601String(),
        centerId,
      ],
    );
    if (changed != 1) throw StateError('Unknown Center: $centerId');
  }

  /// Idempotently creates one edge. Foreign keys reject unknown endpoints.
  Future<void> linkProject(String centerId, String projectId) async {
    final executor = _database;
    await _ensureReady();
    await executor.runInsert(
      '''INSERT OR IGNORE INTO center_projects (center_id, project_id)
         VALUES (?, ?)''',
      <Object?>[centerId, projectId],
    );
  }

  /// Removes only the requested edge; neither endpoint is deleted.
  Future<void> unlinkProject(String centerId, String projectId) async {
    final executor = _database;
    await _ensureReady();
    await executor.runDelete(
      'DELETE FROM center_projects WHERE center_id = ? AND project_id = ?',
      <Object?>[centerId, projectId],
    );
  }

  /// Explicitly replaces this Center's Project edges in one transaction.
  /// Omitted Project ids are unlinked only from this Center.
  Future<void> replaceProjectLinks(
    String centerId,
    Iterable<String> projectIds,
  ) async {
    final executor = _database;
    await _ensureReady();
    final values = List<String>.of(projectIds);
    if (values.toSet().length != values.length) {
      throw ArgumentError('Duplicate Project id in Center link replacement.');
    }
    await executor.runCustom('BEGIN');
    try {
      final center = await executor.runSelect(
        'SELECT id FROM centers WHERE id = ?',
        <Object?>[centerId],
      );
      if (center.isEmpty) throw StateError('Unknown Center: $centerId');
      await executor.runDelete(
        'DELETE FROM center_projects WHERE center_id = ?',
        <Object?>[centerId],
      );
      for (final projectId in values) {
        await executor.runInsert(
          'INSERT INTO center_projects (center_id, project_id) VALUES (?, ?)',
          <Object?>[centerId, projectId],
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

  Future<List<String>> projectIdsForCenter(String centerId) async {
    final executor = _database;
    await _ensureReady();
    final rows = await executor.runSelect(
      'SELECT project_id FROM center_projects WHERE center_id = ? ORDER BY project_id',
      <Object?>[centerId],
    );
    return List<String>.unmodifiable(
      rows.map((row) => row['project_id'] as String),
    );
  }

  Future<List<String>> centerIdsForProject(String projectId) async {
    final executor = _database;
    await _ensureReady();
    final rows = await executor.runSelect(
      'SELECT center_id FROM center_projects WHERE project_id = ? ORDER BY center_id',
      <Object?>[projectId],
    );
    return List<String>.unmodifiable(
      rows.map((row) => row['center_id'] as String),
    );
  }

  /// Deletion is allowed only after all graph edges and direct Task links end.
  Future<void> delete(String centerId) async {
    final executor = _database;
    await _ensureReady();
    await executor.runCustom('BEGIN');
    try {
      final center = await executor.runSelect(
        'SELECT id FROM centers WHERE id = ?',
        <Object?>[centerId],
      );
      if (center.isEmpty) throw StateError('Unknown Center: $centerId');
      final projectRows = await executor.runSelect(
        'SELECT COUNT(*) AS count FROM center_projects WHERE center_id = ?',
        <Object?>[centerId],
      );
      final taskRows = await executor.runSelect(
        'SELECT COUNT(*) AS count FROM tasks WHERE center_id = ?',
        <Object?>[centerId],
      );
      final projectCount = (projectRows.single['count'] as num).toInt();
      final taskCount = (taskRows.single['count'] as num).toInt();
      if (projectCount > 0 || taskCount > 0) {
        throw CenterDeleteBlocked(
          centerId: centerId,
          projectCount: projectCount,
          taskCount: taskCount,
        );
      }
      await executor.runDelete(
        'DELETE FROM centers WHERE id = ?',
        <Object?>[centerId],
      );
      await executor.runCustom('COMMIT');
    } catch (_) {
      try {
        await executor.runCustom('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }

  Center _decode(Map<String, Object?> row) {
    return Center(
      id: row['id'] as String,
      name: row['name'] as String,
      isArchived: (row['is_archived'] as num).toInt() == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
