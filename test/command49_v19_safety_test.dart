import 'dart:convert';
import 'dart:io';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _V7Inspector implements QueryExecutorUser {
  @override
  int get schemaVersion => 7;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

Future<Map<String, Object?>> snapshot(QueryExecutor executor) async {
  final definitions = await executor.runSelect(
    "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    const [],
  );
  final tables = <String, Object?>{};
  for (final definition in definitions) {
    final name = definition['name'] as String;
    final quoted = name.replaceAll('"', '""');
    final rows = await executor.runSelect('SELECT * FROM "$quoted"', const []);
    final normalized = rows.map((row) => <String, Object?>{
      for (final key in row.keys.toList()..sort()) key: row[key],
    }).toList()
      ..sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
    tables[name] = <String, Object?>{'sql': definition['sql'], 'rows': normalized};
  }
  final integrity = await executor.runSelect('PRAGMA integrity_check', const []);
  final foreignKeys = await executor.runSelect('PRAGMA foreign_key_check', const []);
  final version = await executor.runSelect('PRAGMA user_version', const []);
  return <String, Object?>{
    'user_version': version.single.values.first,
    'integrity': integrity.single.values.first,
    'foreign_key_violations': foreignKeys.length,
    'tables': tables,
  };
}

Map<String, Object?> tableRows(Map<String, Object?> value, String name) {
  final tables = value['tables'] as Map<String, Object?>;
  final table = tables[name] as Map<String, Object?>;
  return table;
}

Future<QueryExecutor> open(File file, {bool inspectV7 = false}) async {
  final executor = NativeDatabase(file);
  if (inspectV7) {
    await executor.ensureOpen(_V7Inspector());
  } else {
    await executor.ensureOpen(G1DriftSchema());
  }
  return executor;
}

Future<void> assertHealthy(QueryExecutor executor) async {
  final value = await snapshot(executor);
  expect(value['integrity'], 'ok');
  expect(value['foreign_key_violations'], 0);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final root = Directory(Platform.environment['ARVIN_COMMAND49_DIR']!);
  final sourcePath = Platform.environment['ARVIN_V7_AUGMENTED_FIXTURE']!;

  test('COMMAND 49-R: retry, rollback, restore, occurrence and TaskStore readback', () async {
    expect(G1DriftSchema.version, 19);
    final source = File(sourcePath);
    expect(await source.exists(), isTrue);

    // Independent primary working copy and byte-identical recovery backup.
    final primary = File('${root.path}/retry-primary.sqlite');
    final backup = File('${root.path}/v7-recovery-backup.sqlite');
    await primary.parent.create(recursive: true);
    await source.copy(primary.path);
    await source.copy(backup.path);
    expect(await backup.length(), greaterThan(0));

    final v7 = await open(primary, inspectV7: true);
    late final Map<String, Object?> preMigration;
    try {
      preMigration = await snapshot(v7);
      expect(preMigration['user_version'], 7);
      expect(preMigration['integrity'], 'ok');
      expect(preMigration['foreign_key_violations'], 0);
    } finally {
      await v7.close();
    }

    // First real execution of the historical installer.
    var db = await open(primary);
    try {
      await G1DriftSchema.install(db);
      await assertHealthy(db);
    } finally {
      await db.close();
    }

    // Re-open with a new executor to bypass the in-process Expando cache,
    // then execute the exact same unmodified installer a second time.
    db = await open(primary);
    late final Map<String, Object?> firstSnapshot;
    try {
      firstSnapshot = await snapshot(db);
      expect(firstSnapshot['user_version'], 19);
      await G1DriftSchema.install(db);
      await assertHealthy(db);
      final secondSnapshot = await snapshot(db);
      expect(secondSnapshot, firstSnapshot,
          reason: 'A second V19 install must not duplicate or mutate migrated data.');
      File('${root.path}/retry-first-snapshot.json')
          .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(firstSnapshot));
      File('${root.path}/retry-second-snapshot.json')
          .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(secondSnapshot));
    } finally {
      await db.close();
    }

    // TaskStore readback is tested through the actual historical repository.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = await open(primary);
    try {
      await db.runInsert(
        "INSERT INTO arvin_storage_meta (key, value) VALUES ('legacy_tasks_migrated', '1') ON CONFLICT(key) DO UPDATE SET value='1'",
        const [],
      );
      await db.runInsert(
        "INSERT INTO arvin_storage_meta (key, value) VALUES ('legacy_tags_migrated', '1') ON CONFLICT(key) DO UPDATE SET value='1'",
        const [],
      );
      final loaded = await TaskStore(executor: db).load();
      final completed = loaded.singleWhere((task) => task.id == 'task-done-002');
      expect(completed.completed, isTrue);
      expect(completed.completedAt?.toIso8601String(), '2026-11-10T09:30:00.000');
      expect(completed.priority, TaskPriority.medium);
      final recurring = loaded.singleWhere((task) => task.id == 'task-active-001');
      expect(recurring.recurrence, isNotNull);
      expect(recurring.recurrence!.interval, greaterThan(0));
      expect(recurring.occurrenceHistory, isNotEmpty);
      expect(recurring.checklistOccurrences, isNotEmpty);
      File('${root.path}/task-store-readback.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(loaded.map((task) => task.toJson()).toList()),
      );
      await assertHealthy(db);
    } finally {
      await db.close();
    }

    // Failure after schema DDL and Task rebuild, at the historical Recurrence
    // JSON transfer stage. This exercises the installer's real transaction,
    // not a replacement implementation or synthetic migration.
    final failureDbFile = File('${root.path}/failure-after-task-rebuild.sqlite');
    await source.copy(failureDbFile.path);
    final corrupt = await open(failureDbFile, inspectV7: true);
    final recurrenceRows = await corrupt.runSelect(
      "SELECT id, recurrence_json FROM tasks WHERE id='task-active-001'",
      const [],
    );
    expect(recurrenceRows, isNotEmpty);
    final originalRecurrence = recurrenceRows.single['recurrence_json'];
    await corrupt.runUpdate(
      "UPDATE tasks SET recurrence_json = ? WHERE id='task-active-001'",
      const <Object?>['{malformed-json'],
    );
    await corrupt.close();

    db = await open(failureDbFile);
    var failedAsExpected = false;
    try {
      await G1DriftSchema.install(db);
    } catch (error) {
      failedAsExpected = error is FormatException;
      File('${root.path}/failure-injection.log').writeAsStringSync(
        'EXPECTED_FAILURE=recurrence-json-decode\nERROR_TYPE=${error.runtimeType}\nERROR=$error\n',
      );
    } finally {
      await db.close();
    }
    expect(failedAsExpected, isTrue,
        reason: 'Malformed historical recurrence must fail closed.');

    // Verify transactional rollback restored the original v7 table layout/data.
    db = await open(failureDbFile, inspectV7: true);
    try {
      final afterFailure = await snapshot(db);
      final tables = afterFailure['tables'] as Map<String, Object?>;
      expect(tables.containsKey('follow_up_records'), isFalse);
      expect(tables.containsKey('task_occurrences'), isFalse);
      expect(tables.containsKey('follow_ups'), isTrue);
      final taskColumns = await db.runSelect("PRAGMA table_info('tasks')", const []);
      expect(taskColumns.any((row) => row['name'] == 'follow_up_enabled'), isTrue);
      expect(afterFailure['integrity'], 'ok');
      expect(afterFailure['foreign_key_violations'], 0);
      File('${root.path}/failure-rollback-snapshot.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(afterFailure),
      );

      // Repair only the deliberately corrupted field using the saved value,
      // then retry the same physical DB with the original installer.
      await db.runUpdate(
        "UPDATE tasks SET recurrence_json = ? WHERE id='task-active-001'",
        <Object?>[originalRecurrence],
      );
    } finally {
      await db.close();
    }

    db = await open(failureDbFile);
    try {
      await G1DriftSchema.install(db);
      await assertHealthy(db);
      final recovered = await snapshot(db);
      expect(recovered['user_version'], 19);
      expect((recovered['tables'] as Map).containsKey('task_occurrences'), isTrue);
      File('${root.path}/failure-retry-recovered-snapshot.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(recovered),
      );
    } finally {
      await db.close();
    }

    // Physical backup restoration after the controlled failed migration.
    final restoredFile = File('${root.path}/backup-restored-v7.sqlite');
    await backup.copy(restoredFile.path);
    db = await open(restoredFile, inspectV7: true);
    try {
      final restored = await snapshot(db);
      expect(restored, preMigration,
          reason: 'Restored backup must match the exact pre-migration V7 snapshot.');
      File('${root.path}/backup-restored-snapshot.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(restored),
      );
    } finally {
      await db.close();
    }

    File('${root.path}/command49-verdict.txt').writeAsStringSync(
      'V19_SECOND_INSTALL=PASS\n'
      'SECOND_INSTALL_SNAPSHOT_IDENTICAL=PASS\n'
      'TASK_STORE_READBACK=PASS\n'
      'OCCURRENCE_NONEMPTY_TRANSFER=PASS\n'
      'RECURRENCE_NONEMPTY_TRANSFER=PASS\n'
      'CONTROLLED_FAILURE_AFTER_TASK_REBUILD=PASS\n'
      'TRANSACTION_ROLLBACK=PASS\n'
      'SAME_DATABASE_RETRY_AFTER_REPAIR=PASS\n'
      'PHYSICAL_BACKUP_RESTORE=PASS\n'
      'RESTORED_V7_SNAPSHOT_IDENTICAL=PASS\n'
      'COMMIT_FAILURE_INJECTION=NOT_TESTED\n'
      'FAILURE_DURING_TASK_REBUILD=NOT_TESTED\n'
      'PRE_MIGRATION_ABORT=BACKUP_UNMODIFIED\n'
      'OVERALL=BLOCKED_PENDING_UNTESTED_FAILURE_POINTS\n',
    );
  });
}
