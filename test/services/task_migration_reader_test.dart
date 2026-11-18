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

  test('preserves legacy followUpDate through read boundary without fake history', () async {
    SharedPreferences.setMockInitialValues({
      legacyKey:
          '[{"id":"reader-followup","title":"پیگیری","followUpDate":"2026-08-25T08:00:00.000Z"}]',
    });
    final prefs = await SharedPreferences.getInstance();

    final task = TaskMigrationReader().loadFrom(prefs).single;

    expect(task.followUpDate, DateTime.parse('2026-08-25T08:00:00.000Z'));
    expect(task.followUpEnabled, isTrue);
    expect(task.followUps, isEmpty);
    expect(task.lastFollowUp, isNull);
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
}
