import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  test('legacy JSON migrates to SQL with ids, relations, and unknown fields intact',
      () async {
    final legacy = <String, dynamic>{
      'id': 'legacy-1',
      'title': 'کار مهاجرت',
      'description': 'داده قدیمی',
      'tags': <String>['مهم'],
      'category': 'فروش',
      'completed': true,
      'archived': false,
      'trashed': false,
      'followUpEnabled': true,
      'followUps': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'fu-1',
          'dateTime': '2026-09-20T10:00:00.000Z',
          'note': 'پیگیری قدیمی',
          'completed': true,
        },
      ],
      'checklist': <String>['مرحله ۱'],
      'futureField': <String, dynamic>{'keep': true},
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TaskStore.key, jsonEncode(<dynamic>[legacy]));

    final store = TaskStore(executor: NativeDatabase.memory());
    final loaded = await store.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'legacy-1');
    expect(loaded.single.completed, isTrue);
    expect(loaded.single.followUps.single.id, 'fu-1');
    expect(loaded.single.followUps.single.completed, isTrue);
    expect(loaded.single.tags, <String>['مهم']);
    expect(loaded.single.checklist, <String>['مرحله ۱']);

    final db = NativeDatabase.memory();
    await G1DriftSchema.install(db);
    final rows = await db.runSelect(
      'SELECT id, legacy_payload_json FROM tasks WHERE id = ?',
      <Object?>['legacy-1'],
    );
    expect(rows, hasLength(1));
    final envelope = jsonDecode(rows.single['legacy_payload_json'] as String)
        as Map<String, dynamic>;
    expect(envelope['futureField'], <String, dynamic>{'keep': true});
    await db.close();
  });

  test('canonical SQL remains the source after legacy preference changes',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      TaskStore.key,
      jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'canonical-1',
          'title': 'عنوان اولیه',
          'description': '',
          'tags': <String>[],
          'archived': false,
          'trashed': false,
        },
      ]),
    );

    final store = TaskStore(executor: NativeDatabase.memory());
    expect((await store.load()).single.title, 'عنوان اولیه');

    await prefs.setString(
      TaskStore.key,
      jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'canonical-1',
          'title': 'تغییر جعلی قدیمی',
          'description': '',
          'tags': <String>[],
          'archived': false,
          'trashed': false,
        },
      ]),
    );

    final loaded = await store.load();
    expect(loaded.single.title, 'عنوان اولیه');
  });
}
