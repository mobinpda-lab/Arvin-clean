import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/task_migration_reader.dart';

void main() {
  const legacyKey = TaskMigrationReader.legacyKey;

  test('returns empty when legacy storage is absent', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final tasks = TaskMigrationReader().loadFrom(prefs);

    expect(tasks, isEmpty);
  });

  test('reads existing arvin.tasks into canonical Task objects', () async {
    SharedPreferences.setMockInitialValues({
      legacyKey: '[{"id":"reader-1","title":"کار خواندنی","completed":true}]',
    });
    final prefs = await SharedPreferences.getInstance();

    final tasks = TaskMigrationReader().loadFrom(prefs);

    expect(tasks, hasLength(1));
    expect(tasks.single.id, 'reader-1');
    expect(tasks.single.title, 'کار خواندنی');
    expect(tasks.single.completed, isTrue);
  });

  test('retains retired legacy followUpDate as inert metadata at the read boundary', () async {
    const legacyDate = '2026-08-25T08:00:00.000Z';
    SharedPreferences.setMockInitialValues({
      legacyKey:
          '[{"id":"reader-followup","title":"پیگیری","followUpDate":"$legacyDate"}]',
    });
    final prefs = await SharedPreferences.getInstance();

    final task = TaskMigrationReader().loadFrom(prefs).single;

    expect(task.followUpDate, isNull);
    expect(task.followUpEnabled, isFalse);
    expect(task.followUps, isEmpty);
    expect(task.lastFollowUp, isNull);
    expect(task.legacyFollowUpMetadata['taskLevel'], {
      'followUpDate': legacyDate,
    });
  });

  test('does not write to storage', () async {
    SharedPreferences.setMockInitialValues({
      legacyKey: '[{"id":"reader-read-only","title":"فقط خواندن"}]',
    });
    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString(legacyKey);

    TaskMigrationReader().loadFrom(prefs);

    expect(prefs.getString(legacyKey), before);
  });

  test('surfaces malformed storage instead of silently discarding it', () async {
    SharedPreferences.setMockInitialValues({legacyKey: 'not-json'});
    final prefs = await SharedPreferences.getInstance();

    expect(
      () => TaskMigrationReader().loadFrom(prefs),
      throwsA(isA<FormatException>()),
    );
  });

  test('preserves followUpEnabled missing, null, false and true distinctly', () async {
    const raw = '''
[
  {"id":"followup-missing","title":"فیلد غایب"},
  {"id":"followup-null","title":"مقدار تهی","followUpEnabled":null},
  {"id":"followup-false","title":"مقدار نادرست","followUpEnabled":false},
  {"id":"followup-true","title":"مقدار درست","followUpEnabled":true}
]
''';
    SharedPreferences.setMockInitialValues({legacyKey: raw});
    final prefs = await SharedPreferences.getInstance();

    final tasks = TaskMigrationReader().loadFrom(prefs);
    expect(tasks, hasLength(4));

    final missing = tasks.singleWhere((task) => task.id == 'followup-missing');
    final explicitNull = tasks.singleWhere((task) => task.id == 'followup-null');
    final explicitFalse = tasks.singleWhere((task) => task.id == 'followup-false');
    final explicitTrue = tasks.singleWhere((task) => task.id == 'followup-true');

    expect(missing.legacyFollowUpMetadata['taskLevel'], isNull);
    expect(
      (explicitNull.legacyFollowUpMetadata['taskLevel'] as Map)
          .containsKey('followUpEnabled'),
      isTrue,
    );
    expect(
      (explicitNull.legacyFollowUpMetadata['taskLevel'] as Map)['followUpEnabled'],
      isNull,
    );
    expect(
      (explicitFalse.legacyFollowUpMetadata['taskLevel'] as Map)['followUpEnabled'],
      isFalse,
    );
    expect(
      (explicitTrue.legacyFollowUpMetadata['taskLevel'] as Map)['followUpEnabled'],
      isTrue,
    );

    for (final task in tasks) {
      final roundTripped = TaskMigrationReader().adapter.decodeLegacyList(
        '[${jsonEncode(task.toJson())}]',
      ).single;
      expect(
        roundTripped.legacyFollowUpMetadata,
        task.legacyFollowUpMetadata,
        reason: 'Legacy metadata changed for ${task.id}',
      );
    }
  });

}
