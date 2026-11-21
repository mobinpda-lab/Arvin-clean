import 'dart:convert';
import 'dart:io';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('each hierarchy link independently preserves missing, explicit NULL and valid values through JSON and SQLite reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-hierarchy-presence-');
    final file = File('${directory.path}/hierarchy-presence.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    var database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await database.runCustom('PRAGMA foreign_keys = ON');
      await database.runInsert(
        'INSERT INTO projects (id, name, color_value, is_archived, legacy_payload_json) VALUES (?, ?, ?, ?, ?)',
        <Object?>['presence-project', 'Project', 4283059371, 0, '{}'],
      );
      await database.runInsert(
        'INSERT INTO categories (id, name, legacy_name, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>['presence-category', 'Category', null, 0, '2026-11-21T00:00:00.000Z', '2026-11-21T00:00:00.000Z'],
      );
      await database.runInsert(
        'INSERT INTO centers (id, name, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
        <Object?>['presence-center', 'Center', 0, '2026-11-21T00:00:00.000Z', '2026-11-21T00:00:00.000Z'],
      );

      const validValues = <String, String>{
        'centerId': 'presence-center',
        'projectId': 'presence-project',
        'categoryId': 'presence-category',
      };
      final cases = <Task>[];
      for (final entry in validValues.entries) {
        cases.add(Task.fromJson(<String, dynamic>{
          'id': '${entry.key}-missing',
          'title': '${entry.key} missing',
        }));
        cases.add(Task.fromJson(<String, dynamic>{
          'id': '${entry.key}-null',
          'title': '${entry.key} explicit null',
          entry.key: null,
        }));
        cases.add(Task.fromJson(<String, dynamic>{
          'id': '${entry.key}-valid',
          'title': '${entry.key} valid',
          entry.key: entry.value,
        }));
      }

      // Prove the three JSON states independently before persistence.
      for (final field in validValues.keys) {
        final missing = cases.singleWhere((task) => task.id == '$field-missing').toJson();
        final explicitNull = cases.singleWhere((task) => task.id == '$field-null').toJson();
        final valid = cases.singleWhere((task) => task.id == '$field-valid').toJson();
        expect(missing.containsKey(field), isFalse, reason: '$field must remain absent');
        expect(explicitNull.containsKey(field), isTrue, reason: '$field explicit NULL must remain present');
        expect(explicitNull[field], isNull, reason: '$field explicit NULL value');
        expect(valid[field], validValues[field], reason: '$field valid value');
      }

      await TaskStore(executor: database).save(cases);
      await database.close();

      // A fresh executor simulates process/database restart.
      database = NativeDatabase(file);
      await G1DriftSchema.install(database);
      final restored = await TaskStore(executor: database).load();

      for (final field in validValues.keys) {
        final missing = restored.singleWhere((task) => task.id == '$field-missing').toJson();
        final explicitNull = restored.singleWhere((task) => task.id == '$field-null').toJson();
        final valid = restored.singleWhere((task) => task.id == '$field-valid').toJson();
        expect(missing.containsKey(field), isFalse, reason: '$field missing after SQLite reopen');
        expect(explicitNull.containsKey(field), isTrue, reason: '$field NULL presence after SQLite reopen');
        expect(explicitNull[field], isNull, reason: '$field NULL value after SQLite reopen');
        expect(valid[field], validValues[field], reason: '$field valid value after SQLite reopen');
      }

      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
      expect(integrity.single.values.first, 'ok');
      expect(foreignKeys, isEmpty);
    } finally {
      await database.close();
    }
  });

  test('hierarchy optional presence survives actual fresh-process recovery and a second save', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final directory = await Directory.systemTemp.createTemp('arvin-hierarchy-process-');
    final file = File('${directory.path}/hierarchy-process.sqlite');
    var database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await database.runCustom('PRAGMA foreign_keys = ON');
      await database.runInsert(
        'INSERT INTO projects (id, name, color_value, is_archived, legacy_payload_json) VALUES (?, ?, ?, ?, ?)',
        <Object?>['process-project', 'Project', 4283059371, 0, '{}'],
      );
      await database.runInsert(
        'INSERT INTO categories (id, name, legacy_name, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>['process-category', 'Category', null, 0, '2026-11-21T00:00:00.000Z', '2026-11-21T00:00:00.000Z'],
      );
      await database.runInsert(
        'INSERT INTO centers (id, name, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
        <Object?>['process-center', 'Center', 0, '2026-11-21T00:00:00.000Z', '2026-11-21T00:00:00.000Z'],
      );

      const validValues = <String, String>{
        'centerId': 'process-center',
        'projectId': 'process-project',
        'categoryId': 'process-category',
      };
      final cases = <Task>[];
      for (final entry in validValues.entries) {
        cases.add(Task.fromJson(<String, dynamic>{
          'id': '${entry.key}-missing',
          'title': '${entry.key} missing',
          'futureEnvelopeField': <String, dynamic>{
            'nested': <Object?>['preserve', 7],
            'flag': true,
          },
        }));
        cases.add(Task.fromJson(<String, dynamic>{
          'id': '${entry.key}-null',
          'title': '${entry.key} explicit null',
          entry.key: null,
          'futureEnvelopeField': <String, dynamic>{
            'nested': <Object?>['preserve', 7],
            'flag': true,
          },
        }));
        cases.add(Task.fromJson(<String, dynamic>{
          'id': '${entry.key}-valid',
          'title': '${entry.key} valid',
          entry.key: entry.value,
          'futureEnvelopeField': <String, dynamic>{
            'nested': <Object?>['preserve', 7],
            'flag': true,
          },
        }));
      }

      await TaskStore(executor: database).save(cases);

      // Add a field that exists only in the persisted legacy envelope. It must
      // survive decoding, a save in another OS process, and a second reopen.
      final legacyRow = await database.runSelect(
        'SELECT legacy_payload_json FROM tasks WHERE id = ?',
        const <Object?>['projectId-null'],
      );
      final legacyEnvelope = Map<String, dynamic>.from(
        jsonDecode(legacyRow.single['legacy_payload_json'] as String) as Map,
      );
      legacyEnvelope['legacyEnvelopeOnlyField'] = <String, Object?>{
        'origin': 'legacy-sql-envelope',
        'revision': 3,
      };
      await database.runUpdate(
        'UPDATE tasks SET legacy_payload_json = ? WHERE id = ?',
        <Object?>[jsonEncode(legacyEnvelope), 'projectId-null'],
      );
    } finally {
      await database.close();
    }

    // Use the Flutter test runtime for the child processes. TaskStore imports
    // drift_flutter, which requires dart:ui; a plain `dart helper.dart` process
    // cannot load that library. The helper lives under .dart_tool so it is not
    // included in the parent test shard's file discovery.
    final helperDirectory = Directory('${Directory.current.path}/.dart_tool/arvin_process_tests');
    await helperDirectory.create(recursive: true);
    final helper = File('${helperDirectory.path}/task_hierarchy_process_restart_child_test.dart');
    await helper.writeAsString(r'''
import 'dart:convert';
import 'dart:io';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh Flutter process recovers and verifies hierarchy presence', () async {
    final databasePath = Platform.environment['ARVIN_HIERARCHY_DATABASE'];
    final stage = Platform.environment['ARVIN_HIERARCHY_STAGE'];
    if (databasePath == null || stage == null) {
      throw StateError('Missing process-recovery environment');
    }
    final database = NativeDatabase(File(databasePath));
    try {
      final store = TaskStore(executor: database);
      final tasks = await store.load();
      const values = <String, String>{
        'centerId': 'process-center',
        'projectId': 'process-project',
        'categoryId': 'process-category',
      };
      if (tasks.length != 9) {
        throw StateError('Expected nine hierarchy-presence Tasks; found ${tasks.length}');
      }
      for (final entry in values.entries) {
        final missing = tasks.singleWhere((task) => task.id == '${entry.key}-missing').toJson();
        final explicitNull = tasks.singleWhere((task) => task.id == '${entry.key}-null').toJson();
        final valid = tasks.singleWhere((task) => task.id == '${entry.key}-valid').toJson();
        if (missing.containsKey(entry.key)) {
          throw StateError('${entry.key} missing state was materialized');
        }
        if (!explicitNull.containsKey(entry.key) || explicitNull[entry.key] != null) {
          throw StateError('${entry.key} explicit NULL state was lost');
        }
        if (valid[entry.key] != entry.value) {
          throw StateError('${entry.key} valid value changed');
        }
      }
      for (final task in tasks) {
        final expectedUnknown = <String, Object?>{
          'nested': <Object?>['preserve', 7],
          'flag': true,
        };
        if (jsonEncode(task.toJson()['futureEnvelopeField']) != jsonEncode(expectedUnknown)) {
          throw StateError('Unknown nested field changed for ${task.id}');
        }
      }
      final legacyTask = tasks.singleWhere((task) => task.id == 'projectId-null');
      final legacyValue = legacyTask.toJson()['legacyEnvelopeOnlyField'];
      if (jsonEncode(legacyValue) != jsonEncode(<String, Object?>{
        'origin': 'legacy-sql-envelope',
        'revision': 3,
      })) {
        throw StateError('Legacy envelope-only field was not preserved');
      }

      if (stage == 'recover-and-save') {
        for (final task in tasks) {
          task.title = '${task.title} [saved-after-recovery]';
        }
        await store.save(tasks);
        stdout.writeln('RECOVERY_AND_SECONDARY_SAVE=PASS');
      } else if (stage == 'verify-second-save') {
        for (final task in tasks) {
          if (!task.title.endsWith(' [saved-after-recovery]')) {
            throw StateError('Second-save title missing for ${task.id}');
          }
        }
        stdout.writeln('SECOND_PROCESS_REOPEN_AFTER_RECOVERY_SAVE=PASS');
      } else if (stage == 'verify-third-process-reopen') {
        for (final task in tasks) {
          if (!task.title.endsWith(' [saved-after-recovery]')) {
            throw StateError('Third-process title missing for ${task.id}');
          }
        }
        final integrity = await database.runSelect('PRAGMA integrity_check', const []);
        final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
        if (integrity.isEmpty || integrity.single.values.first != 'ok') {
          throw StateError('Third-process SQLite integrity check failed: $integrity');
        }
        if (foreignKeys.isNotEmpty) {
          throw StateError('Third-process foreign-key check failed: $foreignKeys');
        }
        stdout.writeln('THIRD_PROCESS_REOPEN_AND_INTEGRITY=PASS');
      } else {
        throw ArgumentError('Unknown stage: $stage');
      }
    } finally {
      await database.close();
    }
  });
}
''', flush: true);

    Future<void> runFreshProcess(String stage) async {
      final result = await Process.run(
        'flutter',
        <String>['test', '--no-pub', helper.path],
        workingDirectory: Directory.current.path,
        environment: <String, String>{
          ...Platform.environment,
          'ARVIN_HIERARCHY_DATABASE': file.path,
          'ARVIN_HIERARCHY_STAGE': stage,
        },
      );
      expect(
        result.exitCode,
        0,
        reason: 'Fresh Flutter process stage $stage failed. stdout: ${result.stdout} stderr: ${result.stderr}',
      );
    }

    try {
      await runFreshProcess('recover-and-save');
      await runFreshProcess('verify-second-save');
      await runFreshProcess('verify-third-process-reopen');

      database = NativeDatabase(file);
      await G1DriftSchema.install(database);
      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      final foreignKeys = await database.runSelect('PRAGMA foreign_key_check', const []);
      final count = await database.runSelect('SELECT COUNT(*) AS count FROM tasks', const []);
      expect(integrity.single.values.first, 'ok');
      expect(foreignKeys, isEmpty);
      expect((count.single['count'] as num).toInt(), 9);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
