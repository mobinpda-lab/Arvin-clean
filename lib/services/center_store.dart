import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../models/arvin_center.dart';
import 'g1_drift_schema.dart';

/// Canonical Center directory in the shared Arvin SQLite database.
class CenterStore {
  CenterStore({QueryExecutor? executor}) : _injectedExecutor = executor;
  static QueryExecutor? _sharedDatabase;
  static QueryExecutor? _testDatabase;
  final QueryExecutor? _injectedExecutor;
  QueryExecutor get _database {
    if (_injectedExecutor != null) return _injectedExecutor!;
    if (Platform.environment['FLUTTER_TEST'] == 'true') return _testDatabase ??= NativeDatabase.memory();
    return _sharedDatabase ??= driftDatabase(name: 'arvin');
  }
  static Future<void> resetTestDatabase() async {
    final db = _testDatabase; _testDatabase = null; if (db != null) await db.close();
  }
  Future<void> _ready() => G1DriftSchema.install(_database);
  Future<List<ArvinCenter>> load({bool includeArchived = true}) async {
    await _ready();
    final rows = await _database.runSelect(
      'SELECT id, name, is_archived, created_at FROM centers ${includeArchived ? '' : 'WHERE is_archived = 0'} ORDER BY name COLLATE NOCASE, id',
      const [],
    );
    return List.unmodifiable(rows.map((row) => ArvinCenter(
      id: row['id'] as String, name: row['name'] as String,
      isArchived: (row['is_archived'] as num).toInt() == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
    )));
  }
  Future<void> create({required String id, required String name, DateTime? now}) async {
    final value = _normalize(name); await _ready();
    final duplicate = await _database.runSelect(
      'SELECT id FROM centers WHERE lower(trim(name)) = lower(trim(?)) LIMIT 1', [value],
    );
    if (duplicate.isNotEmpty) throw StateError('مرکزی با این نام وجود دارد.');
    await _database.runInsert(
      'INSERT INTO centers (id, name, is_archived, created_at) VALUES (?, ?, 0, ?)',
      [id, value, (now ?? DateTime.now()).toIso8601String()],
    );
  }
  Future<void> rename({required String id, required String name}) async {
    final value = _normalize(name); await _ready();
    final duplicate = await _database.runSelect(
      'SELECT id FROM centers WHERE lower(trim(name)) = lower(trim(?)) AND id <> ? LIMIT 1', [value, id],
    );
    if (duplicate.isNotEmpty) throw StateError('مرکزی با این نام وجود دارد.');
    final changed = await _database.runUpdate('UPDATE centers SET name = ? WHERE id = ?', [value, id]);
    if (changed != 1) throw StateError('مرکز پیدا نشد.');
  }
  Future<void> setArchived({required String id, required bool archived}) async {
    await _ready();
    final changed = await _database.runUpdate('UPDATE centers SET is_archived = ? WHERE id = ?', [archived ? 1 : 0, id]);
    if (changed != 1) throw StateError('مرکز پیدا نشد.');
  }
  Future<void> delete({required String id}) async {
    await _ready();
    final rows = await _database.runSelect('SELECT COUNT(*) AS count FROM projects WHERE center_id = ?', [id]);
    final count = (rows.single['count'] as num).toInt();
    if (count > 0) throw CenterDeleteBlocked(id, count);
    final changed = await _database.runDelete('DELETE FROM centers WHERE id = ?', [id]);
    if (changed != 1) throw StateError('مرکز پیدا نشد.');
  }
  String _normalize(String name) {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError.value(name, 'name', 'نام مرکز الزامی است.');
    return value;
  }
}
