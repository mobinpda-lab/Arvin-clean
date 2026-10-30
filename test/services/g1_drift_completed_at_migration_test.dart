import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/services/g1_drift_schema.dart';

void main() {
  test('schema installer adds nullable completed_at to an existing task table', () async {
    final database = NativeDatabase.memory();
    await database.ensureOpen(G1DriftSchema());
    try {
      await database.runCustom('''CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
        updated_at TEXT NULL, due_date TEXT NULL, follow_up_enabled INTEGER NOT NULL,
        follow_up_date TEXT NULL, category TEXT NULL, notebook_kind TEXT NULL,
        reminder_date TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
        trashed INTEGER NOT NULL, completed INTEGER NOT NULL, recurrence_json TEXT NULL,
        legacy_payload_json TEXT NULL
      )''');
      await database.runInsert(
        'INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        ['old-task', 'قدیمی', '', 1, 'none', 0, 0, 1],
      );
      await G1DriftSchema.install(database);
      final columns = await database.runSelect("PRAGMA table_info('tasks')", const []);
      final completedAt = columns.singleWhere((row) => row['name'] == 'completed_at');
      expect(completedAt['notnull'], 0);
      final rows = await database.runSelect('SELECT id, completed, completed_at, follow_up_enabled FROM tasks WHERE id = ?', ['old-task']);
      expect(rows.single['completed'], 1);
      expect(rows.single['completed_at'], isNull);
      expect(rows.single['follow_up_enabled'], 1);
    } finally { await database.close(); }
  });
}
