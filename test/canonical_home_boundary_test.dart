import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home owns canonical Task state without legacy ArvinTask projection', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, isNot(contains('class ArvinTask')));
    expect(source, isNot(contains('_legacyViewOf')));
    expect(source, isNot(contains('_canonicalSnapshotOf')));
    expect(source, contains('List<Task> tasks = [];'));
    expect(source, contains('migrationWriter.save(List<Task>.of(tasks))'));
  });

  test('Home edit mutates the existing canonical Task instead of replacing it', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'services/task_edit_apply_service.dart';"));
    expect(
      source,
      contains('final TaskEditApplyService taskEditApplyService = TaskEditApplyService();'),
    );
    expect(source, contains('Future<void> _edit(Task old)'));
    expect(source, contains('taskEditApplyService.apply(old, edited)'));
    expect(source, contains('await _save();'));
    expect(source, isNot(contains('tasks.map(_canonicalSnapshotOf)')));
    expect(source, isNot(contains('tasks[tasks.indexOf(old)] = edited')));
    expect(source, isNot(contains('tasks[index] = edited')));
  });
}
