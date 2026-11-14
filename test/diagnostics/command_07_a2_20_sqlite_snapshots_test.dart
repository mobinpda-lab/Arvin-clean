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

  test('COMMAND 07-A.2.20 records A-D SQL snapshots across five close/reopen cycles',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    const rawLegacyTasks = '''
[
  {
    "id": "command-07-a2-20-task",
    "title": "پیگیری قرارداد",
    "futureTaskField": {"retain": true},
    "followUpEnabled": false,
    "followUpDate": null,
    "reminderDate": null,
    "taskReminders": [
      {"id":"reminder-1","title":"یادآور اول","date":"2026-10-01T08:00:00.000Z","sequence":1,"isEnabled":false},
      {"id":"reminder-2","title":"یادآور دوم","date":"2026-10-02T08:00:00.000Z","sequence":2,"isEnabled":true}
    ],
    "followUps": [
      {"id":"history-1","dateTime":"2026-09-21T10:00:00.000Z","title":"تماس اول","note":"شرح اول","result":"منتظر پاسخ","completed":true,"waitingForResponse":true,"personIds":["person-1","person-2"],"futureFollowUpField":{"retain":true}},
      {"id":"history-2","dateTime":"2026-09-22T11:30:00.000Z","title":"تماس دوم","note":"شرح دوم","result":"پاسخ دریافت شد","completed":false,"waitingForResponse":false,"personIds":["person-3"]}
    ]
  }
]
''';
    await preferences.setString('arvin.tasks', rawLegacyTasks);

    final directory = await Directory.systemTemp.createTemp('arvin-command-07-a2-20-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    var database = NativeDatabase(databaseFile);
    var databaseOpen = true;

    Future<void> closeDatabase() async {
      if (!databaseOpen) return;
      await database.close();
      databaseOpen = false;
    }

    Future<void> reopenDatabase() async {
      await closeDatabase();
      database = NativeDatabase(databaseFile);
      databaseOpen = true;
      await G1DriftSchema.install(database);
    }

    Future<Map<String, Object?>> captureSnapshot(String phase) async {
      final taskRows = await database.runSelect(
        'SELECT id, storage_ordinal, title, legacy_payload_json FROM tasks ORDER BY storage_ordinal, id',
        const [],
      );
      final tasks = <Map<String, Object?>>[];
      for (final row in taskRows) {
        final rawEnvelope = row['legacy_payload_json'];
        final envelope = rawEnvelope is String
            ? Map<String, dynamic>.from(jsonDecode(rawEnvelope) as Map)
            : <String, dynamic>{};
        final metadata = envelope['legacyFollowUpMetadata'] is Map
            ? Map<String, dynamic>.from(envelope['legacyFollowUpMetadata'] as Map)
            : <String, dynamic>{};
        final rawFollowUpMetadata = metadata['followUps'];
        final followUpMetadata = rawFollowUpMetadata is List
            ? rawFollowUpMetadata.whereType<Map>().map(Map<String, dynamic>.from).toList()
            : <Map<String, dynamic>>[];
        final firstFutureFollowUp = followUpMetadata.where(
          (item) => item['id'] == 'history-1',
        );
        tasks.add(<String, Object?>{
          'id': row['id'],
          'storage_ordinal': row['storage_ordinal'],
          'title': row['title'],
          'futureTaskField': envelope['futureTaskField'],
          'taskLevelMetadata': metadata['taskLevel'],
          'unknownTaskFields': metadata['unknownFields'],
          'futureFollowUpField': firstFutureFollowUp.isEmpty
              ? null
              : firstFutureFollowUp.first['futureFollowUpField'],
        });
      }

      final reminders = await database.runSelect(
        'SELECT id, task_id, title, remind_at, is_all_day, sequence, is_enabled '
        'FROM task_reminders WHERE task_id = ? ORDER BY sequence, id',
        const <Object?>['command-07-a2-20-task'],
      );
      final followUps = await database.runSelect(
        'SELECT id, task_id, completed_at, title, note, result, completed, '
        'waiting_for_response, ordinal FROM follow_up_records '
        'WHERE task_id = ? ORDER BY ordinal',
        const <Object?>['command-07-a2-20-task'],
      );
      final followUpPeople = await database.runSelect(
        '''SELECT links.follow_up_id, links.person_id, links.ordinal
           FROM follow_up_record_people AS links
           JOIN follow_up_records AS records ON records.id = links.follow_up_id
           WHERE records.task_id = ?
           ORDER BY records.ordinal, links.ordinal''',
        const <Object?>['command-07-a2-20-task'],
      );
      final people = await database.runSelect(
        '''SELECT DISTINCT persons.id, persons.name
           FROM persons
           JOIN follow_up_record_people AS links ON links.person_id = persons.id
           JOIN follow_up_records AS records ON records.id = links.follow_up_id
           WHERE records.task_id = ?
           ORDER BY persons.id''',
        const <Object?>['command-07-a2-20-task'],
      );
      final foreignKeyViolations = await database.runSelect(
        'PRAGMA foreign_key_check',
        const [],
      );
      final foreignKeys = await database.runSelect(
        'PRAGMA foreign_keys',
        const [],
      );
      final taskColumns = await database.runSelect(
        "PRAGMA table_info('tasks')",
        const [],
      );
      final taskIndexes = await database.runSelect(
        "PRAGMA index_list('tasks')",
        const [],
      );
      // Capture the complete SQLite catalog, not only Task columns/indexes.
      // This makes D01 evidence cover every table, explicit/automatic index,
      // trigger definition and declared FK relationship on the same file.
      final schemaObjects = await database.runSelect(
        "SELECT type, name, tbl_name, sql FROM sqlite_master "
        "WHERE type IN ('table', 'index', 'trigger') ORDER BY type, name",
        const [],
      );
      final schemaTableNames = schemaObjects
          .where((row) => row['type'] == 'table')
          .map((row) => row['name'] as String)
          .where((name) => !name.startsWith('sqlite_'))
          .toList(growable: false);
      final foreignKeyDefinitions = <String, Object?>{};
      for (final tableName in schemaTableNames) {
        final rows = await database.runSelect(
          "PRAGMA foreign_key_list('$tableName')",
          const [],
        );
        if (rows.isNotEmpty) foreignKeyDefinitions[tableName] = rows;
      }
      final schemaIndexes = schemaObjects
          .where((row) => row['type'] == 'index')
          .toList(growable: false);
      final schemaTriggers = schemaObjects
          .where((row) => row['type'] == 'trigger')
          .toList(growable: false);

      return <String, Object?>{
        'phase': phase,
        'tasks': tasks,
        'task_reminders': reminders,
        'follow_up_records': followUps,
        'follow_up_record_people': followUpPeople,
        'persons': people,
        'foreign_key_check': foreignKeyViolations,
        'foreign_keys_enabled': foreignKeys.single['foreign_keys'],
        'task_columns': taskColumns.map((row) => row['name']).toList(),
        'task_indexes': taskIndexes.map((row) => row['name']).toList(),
        'schema_objects': schemaObjects,
        'schema_indexes': schemaIndexes,
        'schema_triggers': schemaTriggers,
        'foreign_key_definitions': foreignKeyDefinitions,
      };
    }

    void verifyLoadedTask(List<dynamic> loaded, String phase) {
      expect(loaded, hasLength(1), reason: phase);
      final task = loaded.single;
      expect(task.id, 'command-07-a2-20-task', reason: phase);
      expect(task.followUps.map((item) => item.id), ['history-1', 'history-2'], reason: phase);
      expect(task.followUps.map((item) => item.personIds), [
        ['person-1', 'person-2'],
        ['person-3'],
      ], reason: phase);
      expect(task.taskReminders.map((item) => item.id), ['reminder-1', 'reminder-2'], reason: phase);
      expect(task.taskReminders.map((item) => item.sequence), [1, 2], reason: phase);
      expect(task.taskReminders.map((item) => item.isEnabled), [false, true], reason: phase);
      expect(task.legacyFollowUpMetadata['taskLevel'], {
        'followUpEnabled': false,
        'followUpDate': null,
        'reminderDate': null,
      }, reason: phase);
      expect(task.legacyFollowUpMetadata['unknownFields'], {
        'futureTaskField': {'retain': true},
      }, reason: phase);
      final metadata = task.legacyFollowUpMetadata['followUps'] as List;
      final first = metadata.whereType<Map>().singleWhere((item) => item['id'] == 'history-1');
      expect(first['futureFollowUpField'], {'retain': true}, reason: phase);
    }

    String canonicalJson(Object? value) {
      Object? normalize(Object? item) {
        if (item is Map) {
          final keys = item.keys.map((key) => key.toString()).toList()..sort();
          return <String, Object?>{
            for (final key in keys) key: normalize(item[key]),
          };
        }
        if (item is List) return item.map(normalize).toList(growable: false);
        return item;
      }
      return jsonEncode(normalize(value));
    }

    Map<String, Object?> comparableSnapshot(Map<String, Object?> snapshot) =>
        <String, Object?>{
          for (final key in const [
            'tasks',
            'task_reminders',
            'follow_up_records',
            'follow_up_record_people',
            'persons',
            'foreign_key_check',
            'foreign_keys_enabled',
            'task_columns',
            'task_indexes',
            'schema_objects',
            'schema_indexes',
            'schema_triggers',
            'foreign_key_definitions',
          ])
            key: snapshot[key],
        };

    try {
      final migration = await const SqlTaskMigrationWriter().migrateFromPreferences(
        executor: database,
        preferences: preferences,
      );
      expect(migration.sourceCount, 1);
      expect(migration.insertedCount, 1);
      expect(migration.sqlTaskCount, 1);

      await reopenDatabase();
      // A: direct SQL state after closing and reopening, before TaskStore.load.
      final snapshotA = await captureSnapshot('A_after_migration_reopen_before_TaskStore_load');
      expect(snapshotA['foreign_key_check'], isEmpty);
      expect(snapshotA['foreign_keys_enabled'], 1);
      expect(
        (snapshotA['task_columns'] as List).toSet().intersection({
          'follow_up_enabled',
          'follow_up_date',
          'reminder_date',
        }),
        isEmpty,
      );
      final schemaNames = (snapshotA['schema_objects'] as List)
          .whereType<Map>()
          .map((row) => row['name'])
          .toSet();
      expect(schemaNames, containsAll({
        'tasks',
        'task_reminders',
        'follow_up_records',
        'follow_up_record_people',
        'persons',
      }));
      final foreignKeyDefinitions =
          snapshotA['foreign_key_definitions'] as Map<String, Object?>;
      expect(foreignKeyDefinitions['task_reminders'], isNotEmpty);
      expect(foreignKeyDefinitions['follow_up_records'], isNotEmpty);
      expect(foreignKeyDefinitions['follow_up_record_people'], isNotEmpty);

      var store = TaskStore(executor: database);
      var loaded = await store.load();
      verifyLoadedTask(loaded, 'B after first TaskStore.load');
      // B: direct SQL state after the first TaskStore load.
      final snapshotB = await captureSnapshot('B_after_first_TaskStore_load');

      Map<String, Object?>? snapshotC;
      Map<String, Object?>? snapshotD;
      // Five independent save -> close -> reopen -> load cycles on the same file.
      for (var cycle = 1; cycle <= 5; cycle++) {
        await store.save(loaded);
        await reopenDatabase();
        store = TaskStore(executor: database);
        loaded = await store.load();
        verifyLoadedTask(loaded, 'cycle $cycle');
        if (cycle == 1) {
          // C: after the first full save/close/reopen/load cycle.
          snapshotC = await captureSnapshot('C_after_cycle_1');
        }
        if (cycle == 5) {
          // D: after the fifth full save/close/reopen/load cycle.
          snapshotD = await captureSnapshot('D_after_cycle_5');
        }
      }

      final snapshotCValue = snapshotC ??
          (throw StateError('Snapshot C was not captured after cycle 1'));
      final snapshotDValue = snapshotD ??
          (throw StateError('Snapshot D was not captured after cycle 5'));
      for (final entry in <String, Map<String, Object?>>{
        'B': snapshotB,
        'C': snapshotCValue,
        'D': snapshotDValue,
      }.entries) {
        expect(
          canonicalJson(comparableSnapshot(entry.value)),
          canonicalJson(comparableSnapshot(snapshotA)),
          reason: 'SQLite relational/metadata snapshot changed at ${entry.key}.',
        );
      }
      expect(snapshotDValue['foreign_key_check'], isEmpty);
      expect(snapshotDValue['foreign_keys_enabled'], 1);

      final evidence = <String, Object?>{
        'command': '07-A.2.20',
        'source_sha': Platform.environment['TARGET_SHA'] ?? 'unknown',
        'database_kind': 'temporary file-backed SQLite; same file reopened for every cycle',
        'migration': {
          'source_count': migration.sourceCount,
          'inserted_count': migration.insertedCount,
          'skipped_existing_count': migration.skippedExistingCount,
          'sql_task_count': migration.sqlTaskCount,
        },
        'cycle_count': 5,
        'snapshot_contract': 'A=migration/reopen before TaskStore.load; B=after first load; C=after cycle 1; D=after cycle 5',
        'snapshots': {
          'A': snapshotA,
          'B': snapshotB,
          'C': snapshotCValue,
          'D': snapshotDValue,
        },
        'comparison': 'B, C and D match A for Task compatibility metadata, Reminder rows, Follow-up rows/order, Person links, Person identities, full sqlite_master catalog (tables/indexes/triggers), declared foreign-key definitions, columns and foreign-key integrity',
      };

      final artifactDirectory = Directory('build/arvin-command-07-a2-20');
      await artifactDirectory.create(recursive: true);
      final artifact = File('${artifactDirectory.path}/sqlite-snapshots-A-D.json');
      await artifact.writeAsString(
        const JsonEncoder.withIndent('  ').convert(evidence),
        flush: true,
      );
      final hashResult = await Process.run('sha256sum', [artifact.path]);
      expect(hashResult.exitCode, 0, reason: '${hashResult.stderr}');
      final hashLine = (hashResult.stdout as String).trim();
      final hashFile = File('${artifact.path}.sha256');
      await hashFile.writeAsString('$hashLine\n', flush: true);
      final verifyResult = await Process.run('sha256sum', ['-c', hashFile.path]);
      expect(verifyResult.exitCode, 0, reason: '${verifyResult.stdout}${verifyResult.stderr}');

      stdout.writeln('ARVIN_COMMAND_07_A2_20_SQLITE_SNAPSHOTS_BEGIN');
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(evidence));
      stdout.writeln('ARTIFACT_PATH: ${artifact.path}');
      stdout.writeln('SHA256: $hashLine');
      stdout.writeln('ARVIN_COMMAND_07_A2_20_SQLITE_SNAPSHOTS_END');
    } finally {
      await closeDatabase();
      await directory.delete(recursive: true);
    }
  });
}
