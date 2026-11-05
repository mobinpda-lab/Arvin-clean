import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/task.dart';
import '../models/task_template.dart';
import 'g1_drift_schema.dart';

/// Canonical Task Template persistence on the existing G1 Drift database.
class TaskTemplateStore {
  TaskTemplateStore({QueryExecutor? executor}) : _injectedExecutor = executor;

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
    final database = _testDatabase;
    _testDatabase = null;
    if (database != null) await database.close();
  }

  Future<void> _ready() => G1DriftSchema.install(_database);

  Future<List<TaskTemplate>> load({bool includeArchived = true}) async {
    await _ready();
    final rows = await _database.runSelect(
      'SELECT * FROM task_templates ${includeArchived ? '' : 'WHERE is_archived = 0'} ORDER BY name COLLATE NOCASE, id',
      const [],
    );
    return List<TaskTemplate>.unmodifiable(rows.map(TaskTemplate.fromColumns));
  }

  Future<TaskTemplate> createFromTask({
    required Task task,
    required String name,
    String? centerNameSnapshot,
    String? projectNameSnapshot,
    String? centerIdSnapshot,
    String? projectIdSnapshot,
    DateTime? now,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(name, 'name', 'نام الگو الزامی است.');
    }
    if (task.title.trim().isEmpty) {
      throw ArgumentError('کار بدون عنوان قابل تبدیل به الگو نیست.');
    }
    final timestamp = now ?? DateTime.now();
    final template = TaskTemplate.fromTask(
      id: 'task-template-${timestamp.microsecondsSinceEpoch}',
      name: normalized,
      task: task,
      centerNameSnapshot: centerNameSnapshot,
      projectNameSnapshot: projectNameSnapshot,
      centerIdSnapshot: centerIdSnapshot,
      projectIdSnapshot: projectIdSnapshot,
      now: timestamp,
    );
    await save(template);
    return template;
  }

  Future<void> save(TaskTemplate template) async {
    if (template.name.trim().isEmpty || template.title.trim().isEmpty) {
      throw ArgumentError('نام الگو و عنوان کار الزامی است.');
    }
    await _ready();
    final values = template.toColumns();
    final columns = values.keys.toList(growable: false);
    final placeholders = List.filled(columns.length, '?').join(', ');
    final updates = columns.where((column) => column != 'id')
        .map((column) => '$column = excluded.$column').join(', ');
    await _database.runInsert(
      'INSERT INTO task_templates (${columns.join(', ')}) VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $updates',
      columns.map((column) => values[column]).toList(growable: false),
    );
  }

  Future<void> setArchived({required String id, required bool archived}) async {
    await _ready();
    final changed = await _database.runUpdate(
      'UPDATE task_templates SET is_archived = ?, updated_at = ? WHERE id = ?',
      [archived ? 1 : 0, DateTime.now().toIso8601String(), id],
    );
    if (changed != 1) throw StateError('الگوی کار پیدا نشد.');
  }

  Future<void> delete({required String id}) async {
    await _ready();
    final changed = await _database.runDelete(
      'DELETE FROM task_templates WHERE id = ?',
      [id],
    );
    if (changed != 1) throw StateError('الگوی کار پیدا نشد.');
  }
}
