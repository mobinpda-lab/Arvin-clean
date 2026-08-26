import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home backup and restore use the canonical Task and Settings path', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'services/task_store.dart';"));
    expect(source, contains('final TaskStore taskStore = TaskStore();'));
    expect(source, contains('backupManager.backupCanonicalTasks('));
    expect(source, contains('settings: appSettingsService.toPortableJson('));
    expect(source, contains('backupManager.restoreCanonicalBackup()'));
    expect(source, contains('await taskStore.save(List<Task>.of(list));'));
    expect(source, contains('appSettingsService.saveSettings(restoredSettings)'));

    expect(
      source,
      isNot(contains('tasks.map((task) => task.toJson()).toList()')),
    );

    final restoreStart =
        source.indexOf('Future<void> _restoreFromFile() async');
    final restoreEnd = source.indexOf(
      'Future<void> _backupMenu() async',
      restoreStart,
    );
    expect(restoreStart, greaterThanOrEqualTo(0));
    expect(restoreEnd, greaterThan(restoreStart));

    final restoreSource = source.substring(restoreStart, restoreEnd);
    expect(restoreSource, contains('candidate.settings == null'));
    expect(restoreSource, contains('decodePortableJson(candidate.settings!)'));
    expect(restoreSource, isNot(contains('ArvinTask.fromJson(')));
    expect(restoreSource, isNot(contains('migrationWriter.save(')));
  });
}
