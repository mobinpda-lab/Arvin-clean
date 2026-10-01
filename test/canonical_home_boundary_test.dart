import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home owns canonical Task state without legacy ArvinTask projection', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, isNot(contains('class ArvinTask')));
    expect(source, isNot(contains('_legacyViewOf')));
    expect(source, isNot(contains('_canonicalSnapshotOf')));
    expect(source, contains('List<Task> tasks = [];'));
    expect(source, contains('final TaskStore taskStore = TaskStore();'));
    expect(source, contains('await taskStore.save(snapshot);'));
    expect(source, contains('calendarOutboundSyncService.sync('));
    expect(source, isNot(contains('TaskMigrationWriter')));
    expect(source, isNot(contains('migrationWriter.save(')));
  });

  test('Home exposes a user-visible calendar sync recovery action', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('همگام‌سازی کار با تقویم مقصد انجام نشد.'));
    expect(source, contains('تلاش دوباره'));
    expect(source, contains('Future<void> _retryCalendarSync'));
    expect(source, contains('همگام‌سازی با تقویم مقصد انجام شد.'));
    expect(
      source,
      contains('همگام‌سازی انجام نشد؛ تنظیمات و دسترسی تقویم را بررسی کنید.'),
    );
    expect(
      source,
      isNot(contains('external side effect and is retried on the next canonical save')),
    );
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
