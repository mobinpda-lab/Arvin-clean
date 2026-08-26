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

    expect(source, contains('Future<void> _edit(Task old)'));
    expect(source, contains('old.title = edited.title'));
    expect(source, contains('old.followUpEnabled = edited.followUpEnabled'));
    expect(source, contains('old.followUpDate = edited.followUpDate'));
    expect(source, contains('old.updatedAt = DateTime.now()'));
    expect(source, isNot(contains('tasks.map(_canonicalSnapshotOf)')));
  });
}
