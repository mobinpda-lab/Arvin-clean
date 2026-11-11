import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/sql_task_migration_writer.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('COMMAND 06-H captures raw relational SQL evidence before TaskStore.load',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const raw = '''
[{"id":"persist-task","title":"پیگیری قرارداد","followUps":[
 {"id":"history-1","dateTime":"2026-09-21T10:00:00.000Z","title":"تماس اول","note":"شرح اول","result":"منتظر پاسخ","completed":true,"waitingForResponse":true,"personIds":["person-1","person-2"]},
 {"id":"history-2","dateTime":"2026-09-22T11:30:00.000Z","title":"تماس دوم","note":"شرح دوم","result":"پاسخ دریافت شد","completed":false,"waitingForResponse":false,"personIds":["person-3"]}
]}]
''';
    await preferences.setString('arvin.tasks', raw);

    final directory = await Directory.systemTemp.createTemp('arvin-06-h-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    var database = NativeDatabase(databaseFile);
    try {
      final migration = await const SqlTaskMigrationWriter()
          .migrateFromPreferences(executor: database, preferences: preferences);
      await database.close();

      database = NativeDatabase(databaseFile);
      await G1DriftSchema.install(database);

      // These SQL reads intentionally precede TaskStore.load and do not use
      // QueryInterceptor or TaskStore as the source of relational evidence.
      final taskRows = await database.runSelect(
        "SELECT * FROM tasks WHERE id = 'persist-task'", const []);
      final followUpRows = await database.runSelect(
        "SELECT * FROM follow_up_records WHERE task_id = 'persist-task' ORDER BY ordinal",
        const []);
      final followUpPeopleRows = await database.runSelect('''
        SELECT * FROM follow_up_record_people
        WHERE follow_up_id IN (
          SELECT id FROM follow_up_records WHERE task_id = 'persist-task'
        )
        ORDER BY follow_up_id, ordinal
      ''', const []);
      final personRows = await database.runSelect(
        'SELECT * FROM persons ORDER BY id', const []);
      final foreignKeyViolations = await database.runSelect(
        'PRAGMA foreign_key_check', const []);
      final foreignKeys = await database.runSelect(
        'PRAGMA foreign_keys', const []);

      final actualTaskIds = taskRows.map((r) => r['id']).toList();
      final actualFollowUpIds = followUpRows.map((r) => r['id']).toList();
      final actualPersonIds = personRows.map((r) => r['id']).toList();
      final actualLinks = followUpPeopleRows.map((r) => <String, Object?>{
        'follow_up_id': r['follow_up_id'],
        'person_id': r['person_id'],
        'ordinal': r['ordinal'],
      }).toList();

      final evidence = <String, Object?>{
        'command': '06-H',
        'phase': 'direct_sql_after_reopen_before_task_store_load',
        'database_path': databaseFile.path,
        'migration': {
          'source_count': migration.sourceCount,
          'inserted_count': migration.insertedCount,
          'skipped_existing_count': migration.skippedExistingCount,
          'sql_task_count': migration.sqlTaskCount,
        },
        'sql': {
          'tasks_query': "SELECT * FROM tasks WHERE id = 'persist-task'",
          'tasks': taskRows,
          'follow_up_records_query':
              "SELECT * FROM follow_up_records WHERE task_id = 'persist-task' ORDER BY ordinal",
          'follow_up_records': followUpRows,
          'follow_up_record_people_query':
              'SELECT * FROM follow_up_record_people WHERE follow_up_id IN (SELECT id FROM follow_up_records WHERE task_id = \'persist-task\') ORDER BY follow_up_id, ordinal',
          'follow_up_record_people': followUpPeopleRows,
          'persons_query': 'SELECT * FROM persons ORDER BY id',
          'persons': personRows,
          'foreign_key_check': foreignKeyViolations,
          'foreign_keys': foreignKeys,
        },
        'expected': {
          'task_ids': ['persist-task'],
          'follow_up_ids_in_ordinal_order': ['history-1', 'history-2'],
          'person_ids': ['person-1', 'person-2', 'person-3'],
          'follow_up_person_links_in_order': [
            {'follow_up_id': 'history-1', 'person_id': 'person-1', 'ordinal': 0},
            {'follow_up_id': 'history-1', 'person_id': 'person-2', 'ordinal': 1},
            {'follow_up_id': 'history-2', 'person_id': 'person-3', 'ordinal': 0},
          ],
          'foreign_key_violations': [],
        },
        'actual_comparison': {
          'task_ids': actualTaskIds,
          'follow_up_ids_in_ordinal_order': actualFollowUpIds,
          'person_ids': actualPersonIds,
          'follow_up_person_links_in_order': actualLinks,
          'foreign_key_violations': foreignKeyViolations,
          'foreign_keys': foreignKeys,
        },
      };

      // Persist the raw capture before invoking TaskStore. This file is the
      // primary artifact even if the subsequent envelope load fails.
      final artifactDirectory = Directory('build/arvin-command-06-h');
      await artifactDirectory.create(recursive: true);
      final artifact = File('${artifactDirectory.path}/raw-sql-evidence.json');
      await artifact.writeAsString(
        const JsonEncoder.withIndent('  ').convert(evidence),
        flush: true,
      );
      final hashResult = await Process.run('sha256sum', [artifact.path]);
      if (hashResult.exitCode != 0) {
        throw StateError('SHA256 generation failed: ${hashResult.stderr}');
      }
      final hashLine = (hashResult.stdout as String).trim();
      final hashFile = File('${artifactDirectory.path}/raw-sql-evidence.json.sha256');
      await hashFile.writeAsString('$hashLine\n', flush: true);
      final verifyResult = await Process.run('sha256sum', ['-c', hashFile.path]);
      if (verifyResult.exitCode != 0) {
        throw StateError('SHA256 verification failed: ${verifyResult.stdout} ${verifyResult.stderr}');
      }

      print('ARVIN_COMMAND_06_H_RAW_SQL_EVIDENCE_BEGIN');
      print(const JsonEncoder.withIndent('  ').convert(evidence));
      print('ARTIFACT_PATH: ${artifact.path}');
      print('SHA256: $hashLine');
      print('ARVIN_COMMAND_06_H_RAW_SQL_EVIDENCE_END');

      // Relational acceptance checks are independent of TaskStore.
      expect(actualTaskIds, ['persist-task']);
      expect(actualFollowUpIds, ['history-1', 'history-2']);
      expect(actualPersonIds, ['person-1', 'person-2', 'person-3']);
      expect(actualLinks, [
        {'follow_up_id': 'history-1', 'person_id': 'person-1', 'ordinal': 0},
        {'follow_up_id': 'history-1', 'person_id': 'person-2', 'ordinal': 1},
        {'follow_up_id': 'history-2', 'person_id': 'person-3', 'ordinal': 0},
      ]);
      expect(foreignKeyViolations, isEmpty);

      // Isolate TaskStore/envelope outcome after the SQL artifact is durable.
      Object? taskStoreError;
      StackTrace? taskStoreStack;
      try {
        await TaskStore(executor: database).load();
      } catch (error, stackTrace) {
        taskStoreError = error;
        taskStoreStack = stackTrace;
      }
      final loadResult = <String, Object?>{
        'status': taskStoreError == null ? 'SUCCESS' : 'FAILURE',
        if (taskStoreError != null) 'error': taskStoreError.toString(),
        if (taskStoreStack != null) 'stack': taskStoreStack.toString(),
      };
      await File('${artifactDirectory.path}/task-store-load-result.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(loadResult), flush: true);
      print('TASK_STORE_LOAD_RESULT: ${jsonEncode(loadResult)}');
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
