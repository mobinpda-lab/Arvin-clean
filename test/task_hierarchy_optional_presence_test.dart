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
        final missing = cases.singleWhere((task) => task.id == '${field}-missing').toJson();
        final explicitNull = cases.singleWhere((task) => task.id == '${field}-null').toJson();
        final valid = cases.singleWhere((task) => task.id == '${field}-valid').toJson();
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
        final missing = restored.singleWhere((task) => task.id == '${field}-missing').toJson();
        final explicitNull = restored.singleWhere((task) => task.id == '${field}-null').toJson();
        final valid = restored.singleWhere((task) => task.id == '${field}-valid').toJson();
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
}
