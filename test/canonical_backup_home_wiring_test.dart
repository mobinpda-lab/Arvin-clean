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
    expect(source, isNot(contains('ArvinTask.fromJson(')));
  });
}
