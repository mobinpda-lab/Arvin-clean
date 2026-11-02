import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../models/project_template.dart';
import 'g1_drift_schema.dart';

class ProjectTemplateStore {
  ProjectTemplateStore({QueryExecutor? executor}) : _injectedExecutor = executor;
  static QueryExecutor? _sharedDatabase, _testDatabase;
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

  Future<List<ProjectTemplate>> load({bool includeArchived = true}) async {
    await _ready();
    final rows = await _database.runSelect(
      'SELECT id, name, is_archived, created_at, updated_at FROM project_templates ${includeArchived ? '' : 'WHERE is_archived = 0'} ORDER BY name COLLATE NOCASE, id',
      const [],
    );
    final result = <ProjectTemplate>[];
    for (final row in rows) {
      final taskRows = await _database.runSelect(
        'SELECT id, title, description, category, tags_json, checklist_json FROM project_template_tasks WHERE template_id = ? ORDER BY ordinal',
        [row['id']],
      );
      result.add(ProjectTemplate(
        id: row['id'] as String, name: row['name'] as String,
        isArchived: (row['is_archived'] as num).toInt() == 1,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        tasks: taskRows.map((task) => ProjectTemplateTask(
          id: task['id'] as String, title: task['title'] as String,
          description: task['description'] as String, category: task['category'] as String?,
          tags: _decodeStrings(task['tags_json']), checklist: _decodeStrings(task['checklist_json']),
        )),
      ));
    }
    return List.unmodifiable(result);
  }

  Future<void> save(ProjectTemplate template) async {
    final name = template.name.trim();
    if (name.isEmpty) throw ArgumentError.value(template.name, 'name', 'نام قالب الزامی است.');
    if (template.tasks.any((task) => task.title.trim().isEmpty)) throw ArgumentError('عنوان همه کارهای قالب باید تکمیل باشد.');
    final ids = template.tasks.map((task) => task.id).toSet();
    if (ids.length != template.tasks.length) throw ArgumentError('شناسه کارهای قالب تکراری است.');
    await _ready();
    final now = DateTime.now().toIso8601String();
    await _database.runCustom('BEGIN');
    try {
      await _database.runInsert(
        '''INSERT INTO project_templates (id, name, is_archived, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?)
           ON CONFLICT(id) DO UPDATE SET name = excluded.name, is_archived = excluded.is_archived, updated_at = excluded.updated_at''',
        [template.id, name, template.isArchived ? 1 : 0, template.createdAt.toIso8601String(), now],
      );
      await _database.runDelete('DELETE FROM project_template_tasks WHERE template_id = ?', [template.id]);
      for (var i = 0; i < template.tasks.length; i++) {
        final task = template.tasks[i];
        await _database.runInsert(
          '''INSERT INTO project_template_tasks
             (id, template_id, title, description, category, tags_json, checklist_json, ordinal)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
          [task.id, template.id, task.title.trim(), task.description, task.category,
           jsonEncode(task.tags), jsonEncode(task.checklist), i],
        );
      }
      await _database.runCustom('COMMIT');
    } catch (_) {
      try { await _database.runCustom('ROLLBACK'); } catch (_) {}
      rethrow;
    }
  }

  Future<void> setArchived({required String id, required bool archived}) async {
    await _ready();
    final changed = await _database.runUpdate(
      'UPDATE project_templates SET is_archived = ?, updated_at = ? WHERE id = ?',
      [archived ? 1 : 0, DateTime.now().toIso8601String(), id],
    );
    if (changed != 1) throw StateError('قالب پروژه پیدا نشد.');
  }

  Future<void> delete({required String id}) async {
    await _ready();
    final rows = await _database.runSelect('SELECT COUNT(*) AS count FROM projects WHERE template_id = ?', [id]);
    final count = (rows.single['count'] as num).toInt();
    if (count > 0) throw ProjectTemplateDeleteBlocked(id, count);
    await _database.runCustom('BEGIN');
    try {
      await _database.runDelete('DELETE FROM project_template_tasks WHERE template_id = ?', [id]);
      final changed = await _database.runDelete('DELETE FROM project_templates WHERE id = ?', [id]);
      if (changed != 1) throw StateError('قالب پروژه پیدا نشد.');
      await _database.runCustom('COMMIT');
    } catch (_) { try { await _database.runCustom('ROLLBACK'); } catch (_) {} rethrow; }
  }

  List<String> _decodeStrings(Object? raw) {
    if (raw is! String) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Template task list is invalid.');
    return decoded.whereType<String>().toList(growable: false);
  }
}
