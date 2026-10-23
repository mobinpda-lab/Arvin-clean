import 'dart:io';

import 'package:arvin/main.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  test('independent FollowUp reminder runtime reuses reboot-safe AlarmManager', () {
    final scheduler =
        File('lib/android_follow_up_reminder_scheduler.dart').readAsStringSync();
    final runner =
        File('lib/follow_up_reminder_background_runner.dart').readAsStringSync();
    final planner =
        File('lib/services/follow_up_reminder_alarm_planner.dart').readAsStringSync();
    final notification = File('lib/follow_up_reminder_notification_service.dart')
        .readAsStringSync();

    expect(scheduler, contains('followUpReminderAlarmId = 42002'));
    expect(scheduler, contains('rescheduleOnReboot: true'));
    expect(scheduler, contains('FollowUpReminderBackgroundRunner().run()'));
    expect(runner, contains('FollowUpReminderDeliveryState.storageKey'));
    expect(runner, contains('await notifications.showDue(candidate)'));
    expect(runner, contains('stateService.markDelivered(state, candidate)'));
    expect(notification, contains('candidate.label'));
    expect(notification, contains('candidate.taskTitle'));
    expect(notification, contains('payload: candidate.taskId'));
    expect(planner, contains("'task:"));
    expect(runner, contains('FollowUpReminderDeliveryService'));
  });

  testWidgets('quick-capture Task persistence requests reminder rescheduling',
      (tester) async {
    final store = TaskStore();
    var rescheduleCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          taskStore: store,
          taskReminderReschedule: () async {
            rescheduleCalls++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار یادآور مصنوعی',
    );
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect((await store.load()).map((task) => task.title), contains('کار یادآور مصنوعی'));
    expect(rescheduleCalls, 1);
  });

  testWidgets('editing a canonical Task reschedules only after persistence',
      (tester) async {
    final store = TaskStore();
    await store.save(<Task>[Task(id: 'edit-synthetic', title: 'کار قبلی')]);
    var rescheduleCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          taskStore: store,
          taskReminderReschedule: () async {
            rescheduleCalls++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('کار قبلی'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-editor-description')),
      'ویرایش مصنوعی',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect((await store.load()).single.description, 'ویرایش مصنوعی');
    expect(rescheduleCalls, 1);
  });

  testWidgets('scheduler failure does not undo a successfully persisted Task',
      (tester) async {
    final store = TaskStore();
    var rescheduleAttempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          taskStore: store,
          taskReminderReschedule: () async {
            rescheduleAttempts++;
            throw StateError('synthetic scheduler failure');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار پس از خطای زمان‌بند',
    );
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect((await store.load()).map((task) => task.title),
        contains('کار پس از خطای زمان‌بند'));
    expect(rescheduleAttempts, 1);
    expect(tester.takeException(), isNull);
  });

  test('canonical FollowUp write paths request reminder rescheduling', () {
    final coordinator =
        File('lib/services/follow_up_write_coordinator.dart').readAsStringSync();
    final detail = File('lib/task_detail_page.dart').readAsStringSync();
    final office = File('lib/follow_up_office_page.dart').readAsStringSync();
    final home = File('lib/main.dart').readAsStringSync();

    expect(coordinator, contains('reminderReschedule'));
    expect(detail, contains('AndroidFollowUpReminderScheduler().reschedule'));
    expect(office, contains('AndroidFollowUpReminderScheduler().reschedule'));
    expect(home, contains('AndroidFollowUpReminderScheduler().reschedule'));
  });
}
