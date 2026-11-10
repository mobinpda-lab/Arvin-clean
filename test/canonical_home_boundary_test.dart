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
    final save = source.substring(
      source.indexOf('Future<void> _save()'),
      source.indexOf('DateTime? _homeLastFollowUpDate'),
    );
    expect(save, isNot(contains('CalendarOutboundSyncService')));
    expect(save, isNot(contains('syncTaskLifecycle')));
    expect(source, isNot(contains('TaskMigrationWriter')));
    expect(source, isNot(contains('migrationWriter.save(')));
  });
  test('normal save, Quick Capture, edit and completion never export automatically', () {
    final source = File('lib/main.dart').readAsStringSync();
    final save = source.substring(
      source.indexOf('Future<void> _save()'),
      source.indexOf('DateTime? _homeLastFollowUpDate'),
    );
    expect(save, isNot(contains('CalendarOutboundSyncService')));
    expect(save, isNot(contains('calendarOutboundSyncService')));
    expect(source, isNot(contains('_syncCalendarAfterTaskMutation')));
    expect(source, isNot(contains('_syncCalendarAfterQuickCapture')));
    expect(source, isNot(contains('_syncCalendarAfterDetailTaskUpdate')));
    expect(source, isNot(contains('_syncLinkedCalendarAfterTaskEdit')));
    expect(source, isNot(contains('_retryCalendarSync')));
    expect(source, contains('await taskStore.save(snapshot);'));
    expect(source, contains("onCaptured: (captured) async"));
    expect(source, contains("onFullForm: (draft) async"));
    expect(source, contains('Future<Task?> _completeFromDetail(Task task)'));
    expect(source, contains('task.setCompleted(!task.completed);'));
  });
  test('Home edit mutates the existing canonical Task instead of replacing it', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("import 'services/task_edit_apply_service.dart';"));
    expect(source, contains('Future<void> _edit(Task old)'));
    expect(source, contains('taskEditApplyService.apply(old, edited)'));
    expect(source, contains('await _save();'));
    expect(source, isNot(contains('tasks.map(_canonicalSnapshotOf)')));
    expect(source, isNot(contains('tasks[tasks.indexOf(old)] = edited')));
    expect(source, isNot(contains('tasks[index] = edited')));
  });
  test('only explicit Calendar swipe and Task Details callbacks are wired for export', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('onRegisterTaskToDeviceCalendar: _registerTaskInDeviceCalendar'));
    expect(main, contains('onRegisterTaskToDeviceCalendar: _registerTaskFromDetails'));
    expect(main, contains('linkedOnly: true'));
    final outbound = File('lib/services/calendar_outbound_sync_service.dart').readAsStringSync();
    expect(outbound, contains('if (linkedOnly && !linkedReminderIds.contains(reminder.id)) continue;'));
    expect(outbound, contains('final managedLinks = linkedOnly'));
  });
}
