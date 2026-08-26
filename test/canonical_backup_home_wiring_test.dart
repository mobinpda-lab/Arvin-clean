import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home backup and restore use the canonical Task path', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'services/task_store.dart';"));
    expect(source, contains('final TaskStore taskStore = TaskStore();'));
    expect(
      source,
      contains('backupManager.backupCanonicalTasks(_searchSource)'),
    );
    expect(source, contains('backupManager.restoreCanonicalTasks()'));
    expect(source, contains('await taskStore.save(List<Task>.of(list));'));

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
    expect(restoreSource, isNot(contains('ArvinTask.fromJson(')));
    expect(restoreSource, isNot(contains('migrationWriter.save(')));
  });
}
