import 'dart:io';

import 'package:drift/native.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:flutter_test/flutter_test.dart';

const _taskGuard = '''
SELECT CASE WHEN NEW.center_id IS NOT NULL AND NEW.project_id IS NOT NULL
 AND NOT EXISTS (SELECT 1 FROM projects p WHERE p.id=NEW.project_id AND p.center_id=NEW.center_id)
 THEN RAISE(ABORT, 'task center/project mismatch') END;
SELECT CASE WHEN NEW.project_id IS NOT NULL AND NEW.category_id IS NOT NULL
 AND NOT EXISTS (SELECT 1 FROM categories c WHERE c.id=NEW.category_id AND c.project_id=NEW.project_id)
 THEN RAISE(ABORT, 'task project/category mismatch') END;
SELECT CASE WHEN NEW.center_id IS NOT NULL AND NEW.category_id IS NOT NULL
 AND NOT EXISTS (SELECT 1 FROM categories c JOIN projects p ON p.id=c.project_id
                 WHERE c.id=NEW.category_id AND p.center_id=NEW.center_id)
 THEN RAISE(ABORT, 'task center/category mismatch') END;
''';

Future<NativeDatabase> _open(File file, {bool install = false}) async {
  final db = NativeDatabase(file);
  // NativeDatabase opens lazily; initialize the executor with the canonical
  // schema owner before issuing direct SQL. Do not install the production
  // schema here: this diagnostic intentionally creates its own minimal schema.
  await db.ensureOpen(G1DriftSchema());
  await db.runCustom('PRAGMA foreign_keys = ON');
  expect((await db.runSelect('PRAGMA foreign_keys', const [])).single.values.single, 1);
  if (!install) return db;

  await db.runCustom('CREATE TABLE centers(id TEXT PRIMARY KEY, name TEXT NOT NULL)');
  await db.runCustom('''
    CREATE TABLE projects(
      id TEXT PRIMARY KEY,
      center_id TEXT NOT NULL REFERENCES centers(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
      UNIQUE(center_id, id)
    )
  ''');
  await db.runCustom('''
    CREATE TABLE categories(
      id TEXT PRIMARY KEY,
      project_id TEXT NOT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
      UNIQUE(project_id, id)
    )
  ''');
  await db.runCustom('''
    CREATE TABLE tasks(
      id TEXT PRIMARY KEY, title TEXT NOT NULL,
      center_id TEXT NULL REFERENCES centers(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
      project_id TEXT NULL REFERENCES projects(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
      category_id TEXT NULL REFERENCES categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT
    )
  ''');
  await db.runCustom('CREATE TABLE tags(id TEXT PRIMARY KEY, name TEXT NOT NULL UNIQUE)');
  await db.runCustom('''
    CREATE TABLE task_tags(
      task_id TEXT NOT NULL REFERENCES tasks(id) ON DELETE RESTRICT,
      tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE RESTRICT,
      PRIMARY KEY(task_id, tag_id)
    )
  ''');
  await db.runCustom('''
    CREATE TRIGGER tasks_links_insert BEFORE INSERT ON tasks BEGIN
      $_taskGuard
    END
  ''');
  await db.runCustom('''
    CREATE TRIGGER tasks_links_update BEFORE UPDATE OF center_id, project_id, category_id ON tasks BEGIN
      $_taskGuard
    END
  ''');
  await db.runCustom('''
    CREATE TRIGGER projects_owner_update BEFORE UPDATE OF center_id ON projects
    WHEN NEW.center_id != OLD.center_id AND (
      EXISTS(SELECT 1 FROM categories c WHERE c.project_id=OLD.id)
      OR EXISTS(SELECT 1 FROM tasks t WHERE t.project_id=OLD.id)
      OR EXISTS(SELECT 1 FROM tasks t JOIN categories c ON c.id=t.category_id WHERE c.project_id=OLD.id)
    )
    BEGIN SELECT RAISE(ABORT, 'project owner change blocked by dependents'); END
  ''');
  await db.runCustom('''
    CREATE TRIGGER categories_owner_update BEFORE UPDATE OF project_id ON categories
    WHEN NEW.project_id != OLD.project_id
      AND EXISTS(SELECT 1 FROM tasks t WHERE t.category_id=OLD.id)
    BEGIN SELECT RAISE(ABORT, 'category owner change blocked by tasks'); END
  ''');

  for (final row in [
    ['center-a', 'مرکز الف'], ['center-b', 'مرکز ب']
  ]) {
    await db.runInsert('INSERT INTO centers(id,name) VALUES(?,?)', row);
  }
  for (final row in [
    ['project-a', 'center-a'], ['project-b', 'center-b']
  ]) {
    await db.runInsert('INSERT INTO projects(id,center_id) VALUES(?,?)', row);
  }
  for (final row in [
    ['category-a', 'project-a'], ['category-b', 'project-b']
  ]) {
    await db.runInsert('INSERT INTO categories(id,project_id) VALUES(?,?)', row);
  }
  for (final row in [
    ['tag-a', 'مهم'], ['tag-b', 'فوری'], ['tag-c', 'شخصی']
  ]) {
    await db.runInsert('INSERT INTO tags(id,name) VALUES(?,?)', row);
  }
  return db;
}

Future<({Directory dir, File file, NativeDatabase db})> _fixture() async {
  final dir = await Directory.systemTemp.createTemp('arvin-optional-links-');
  final file = File('${dir.path}/candidate.sqlite');
  return (dir: dir, file: file, db: await _open(file, install: true));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final scenarios = <({
    String name, String? center, String? project, String? category, List<String> tags
  })>[
    (name: '01 no links or tags', center: null, project: null, category: null, tags: const []),
    (name: '02 Center only', center: 'center-a', project: null, category: null, tags: const []),
    (name: '03 Project only', center: null, project: 'project-a', category: null, tags: const []),
    (name: '04 Category only', center: null, project: null, category: 'category-a', tags: const []),
    (name: '05 Tag only', center: null, project: null, category: null, tags: const ['tag-a']),
    (name: '06 Center and Project', center: 'center-a', project: 'project-a', category: null, tags: const []),
    (name: '07 Project and Category', center: null, project: 'project-a', category: 'category-a', tags: const []),
    (name: '08 complete hierarchy', center: 'center-a', project: 'project-a', category: 'category-a', tags: const []),
    (name: '09 multiple Tags', center: null, project: null, category: null, tags: const ['tag-a', 'tag-b', 'tag-c']),
  ];

  for (final s in scenarios) {
    test('file-backed SQLite scenario ${s.name}', () async {
      final f = await _fixture();
      var db = f.db;
      try {
        await db.runInsert(
          'INSERT INTO tasks(id,title,center_id,project_id,category_id) VALUES(?,?,?,?,?)',
          <Object?>['task-1', 'before', s.center, s.project, s.category],
        );
        for (final tag in s.tags) {
          await db.runInsert('INSERT INTO task_tags(task_id,tag_id) VALUES(?,?)', ['task-1', tag]);
        }
        var row = (await db.runSelect('SELECT * FROM tasks WHERE id=?', const ['task-1'])).single;
        expect(row['center_id'], s.center);
        expect(row['project_id'], s.project);
        expect(row['category_id'], s.category);
        await db.runUpdate('UPDATE tasks SET title=? WHERE id=?', const ['after', 'task-1']);
        await db.close();
        db = await _open(f.file);
        row = (await db.runSelect('SELECT * FROM tasks WHERE id=?', const ['task-1'])).single;
        expect(row['title'], 'after');
        expect(row['center_id'], s.center);
        expect(row['project_id'], s.project);
        expect(row['category_id'], s.category);
        final actualTags = (await db.runSelect(
          'SELECT tag_id FROM task_tags WHERE task_id=? ORDER BY tag_id', const ['task-1'],
        )).map((r) => r['tag_id']).toList();
        expect(actualTags, s.tags.toList()..sort());
      } finally {
        await db.close();
        await f.dir.delete(recursive: true);
      }
    });
  }

  test('file-backed SQLite scenario 10 clear all and persist NULL after reopen', () async {
    final f = await _fixture();
    var db = f.db;
    try {
      await db.runInsert(
        'INSERT INTO tasks(id,title,center_id,project_id,category_id) VALUES(?,?,?,?,?)',
        const ['task-clear', 'clear', 'center-a', 'project-a', 'category-a'],
      );
      await db.runInsert('INSERT INTO task_tags(task_id,tag_id) VALUES(?,?)', const ['task-clear', 'tag-a']);
      await db.runUpdate(
        'UPDATE tasks SET center_id=NULL,project_id=NULL,category_id=NULL WHERE id=?',
        const ['task-clear'],
      );
      await db.runDelete('DELETE FROM task_tags WHERE task_id=?', const ['task-clear']);
      await db.close();
      db = await _open(f.file);
      final row = (await db.runSelect(
        'SELECT center_id,project_id,category_id FROM tasks WHERE id=?', const ['task-clear'],
      )).single;
      expect(row['center_id'], isNull);
      expect(row['project_id'], isNull);
      expect(row['category_id'], isNull);
      expect(await db.runSelect('SELECT * FROM task_tags WHERE task_id=?', const ['task-clear']), isEmpty);
    } finally {
      await db.close();
      await f.dir.delete(recursive: true);
    }
  });

  test('SQLite rejects Center + Project with different owners', () async {
    final f = await _fixture();
    try {
      await expectLater(f.db.runInsert(
        'INSERT INTO tasks(id,title,center_id,project_id) VALUES(?,?,?,?)',
        const ['bad', 'bad', 'center-a', 'project-b'],
      ), throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite rejects Project + Category with different owners', () async {
    final f = await _fixture();
    try {
      await expectLater(f.db.runInsert(
        'INSERT INTO tasks(id,title,project_id,category_id) VALUES(?,?,?,?)',
        const ['bad', 'bad', 'project-a', 'category-b'],
      ), throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite rejects Center + Category mismatch without direct Project', () async {
    final f = await _fixture();
    try {
      await expectLater(f.db.runInsert(
        'INSERT INTO tasks(id,title,center_id,category_id) VALUES(?,?,?,?)',
        const ['bad', 'bad', 'center-a', 'category-b'],
      ), throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite rejects Project owner change while Categories or Tasks depend on it', () async {
    final f = await _fixture();
    try {
      await expectLater(f.db.runUpdate(
        'UPDATE projects SET center_id=? WHERE id=?', const ['center-b', 'project-a'],
      ), throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite rejects Category move while a Task references it', () async {
    final f = await _fixture();
    try {
      await f.db.runInsert('INSERT INTO tasks(id,title,category_id) VALUES(?,?,?)',
          const ['dependent', 'dependent', 'category-a']);
      await expectLater(f.db.runUpdate(
        'UPDATE categories SET project_id=? WHERE id=?', const ['project-b', 'category-a'],
      ), throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite restricts deleting Center with Project', () async {
    final f = await _fixture();
    try {
      await expectLater(f.db.runDelete('DELETE FROM centers WHERE id=?', const ['center-a']),
          throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite restricts deleting Project with Category', () async {
    final f = await _fixture();
    try {
      await expectLater(f.db.runDelete('DELETE FROM projects WHERE id=?', const ['project-a']),
          throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite restricts deleting Category with Task', () async {
    final f = await _fixture();
    try {
      await f.db.runInsert('INSERT INTO tasks(id,title,category_id) VALUES(?,?,?)',
          const ['dependent', 'dependent', 'category-a']);
      await expectLater(f.db.runDelete('DELETE FROM categories WHERE id=?', const ['category-a']),
          throwsA(anything));
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });

  test('SQLite reports nullable Task foreign-key columns and clean integrity', () async {
    final f = await _fixture();
    try {
      final columns = await f.db.runSelect("PRAGMA table_info('tasks')", const []);
      for (final name in ['center_id', 'project_id', 'category_id']) {
        final column = columns.singleWhere((r) => r['name'] == name);
        expect(column['notnull'], 0, reason: '$name must remain nullable');
      }
      expect(await f.db.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
      expect((await f.db.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
    } finally { await f.db.close(); await f.dir.delete(recursive: true); }
  });
}
