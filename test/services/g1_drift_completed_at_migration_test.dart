import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/services/g1_drift_schema.dart';

void main() {
  test(
    'schema installer adds nullable completed_at and preserves legacy scheduling data',
    () async {
      final database = NativeDatabase.memory();
      await database.ensureOpen(G1DriftSchema());
      try {
        await database.runCustom('''CREATE TABLE tasks_legacy_fixture (
          id TEXT NOT NULL PRIMARY KEY,
          storage_ordinal INTEGER NOT NULL DEFAULT 0,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NULL,
          updated_at TEXT NULL,
          due_date TEXT NULL,
          follow_up_enabled INTEGER NOT NULL,
          follow_up_date TEXT NULL,
          category TEXT NULL,
          notebook_kind TEXT NULL,
          reminder_date TEXT NULL,
          priority TEXT NOT NULL,
          archived INTEGER NOT NULL,
          trashed INTEGER NOT NULL,
          completed INTEGER NOT NULL,
          recurrence_json TEXT NULL,
          legacy_payload_json TEXT NULL
        )''');
        await database.runCustom('''
          INSERT INTO tasks_legacy_fixture (
            id, title, description, follow_up_enabled, follow_up_date,
            reminder_date, priority, archived, trashed, completed
          ) VALUES (
            'old-task', 'قدیمی', '', 1,
            '2030-01-02T03:04:05.000',
            '2030-01-02T04:05:06.000',
            'none', 0, 0, 1
          )
        ''');
        await database.runCustom('DROP TABLE tasks');
        await database.runCustom(
          'ALTER TABLE tasks_legacy_fixture RENAME TO tasks',
        );

        await G1DriftSchema.install(database);

        final columns = await database.runSelect(
          "PRAGMA table_info('tasks')",
          const [],
        );
        final columnNames = columns.map((row) => row['name']).toSet();
        final completedAt = columns.singleWhere(
          (row) => row['name'] == 'completed_at',
        );
        expect(completedAt['notnull'], 0);
        expect(columnNames, contains('follow_up_enabled'));
        expect(columnNames, contains('follow_up_date'));
        expect(columnNames, contains('reminder_date'));

        final rows = await database.runSelect(
          '''SELECT id, completed, completed_at, follow_up_enabled,
                    follow_up_date, reminder_date
             FROM tasks WHERE id = ?''',
          ['old-task'],
        );
        expect(rows, hasLength(1));
        expect(rows.single['completed'], 1);
        expect(rows.single['completed_at'], isNull);
        expect(rows.single['follow_up_enabled'], 1);
        expect(rows.single['follow_up_date'], '2030-01-02T03:04:05.000');
        expect(rows.single['reminder_date'], '2030-01-02T04:05:06.000');
      } finally {
        await database.close();
      }
    },
  );
}
