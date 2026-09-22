import 'package:arvin/services/g1_drift_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  test('creates the complete G1 relational schema', () async {
    await G1DriftSchema.install(database);

    final tables = await database.runSelect(
      "SELECT name FROM sqlite_master "
      "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
      "ORDER BY name",
      const [],
    );

    expect(
      tables.map((row) => row['name']),
      containsAll(<String>[
        'tasks',
        'follow_ups',
        'projects',
        'project_items',
        'tags',
        'task_tags',
        'checklist_items',
        'task_people',
      ]),
    );

    final foreignKeys = await database.runSelect(
      'PRAGMA foreign_keys',
      const [],
    );
    expect(foreignKeys.single['foreign_keys'], 1);
  });

  test('schema installation is idempotent', () async {
    await G1DriftSchema.install(database);
    await G1DriftSchema.install(database);

    final taskTable = await database.runSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'tasks'",
      const [],
    );
    expect(taskTable, hasLength(1));
  });

  test('follow-up ordering and relationship duplicates fail closed', () async {
    await G1DriftSchema.install(database);

    await database.runCustom(
      "INSERT INTO tasks "
      "(id, title, description, follow_up_enabled, priority, archived, trashed, completed) "
      "VALUES ('task-1', 'عنوان', '', 1, 'none', 0, 0, 0)",
    );

    await database.runCustom(
      "INSERT INTO follow_ups "
      "(id, task_id, date_time, note, completed, ordinal) "
      "VALUES ('fu-1', 'task-1', '2026-09-22T10:00:00Z', 'اول', 0, 0)",
    );

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_ups "
        "(id, task_id, date_time, note, completed, ordinal) "
        "VALUES ('fu-2', 'task-1', '2026-09-22T11:00:00Z', 'تکراری', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );

    final ordered = await database.runSelect(
      'SELECT ordinal FROM follow_ups WHERE task_id = ? ORDER BY ordinal',
      <Object?>['task-1'],
    );
    expect(ordered.single['ordinal'], 0);
  });

  test('foreign-key references prevent orphan relationship rows', () async {
    await G1DriftSchema.install(database);

    await expectLater(
      database.runCustom(
        "INSERT INTO follow_ups "
        "(id, task_id, date_time, note, completed, ordinal) "
        "VALUES ('fu-orphan', 'missing', '2026-09-22T10:00:00Z', '', 0, 0)",
      ),
      throwsA(isA<Exception>()),
    );
  });
}
