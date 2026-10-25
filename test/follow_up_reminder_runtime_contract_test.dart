import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
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

  test('canonical Home Task writes reschedule the shared reminder foundation', () {
    final home = File('lib/main.dart').readAsStringSync();

    expect(home, contains('await taskStore.save(snapshot);'));
    // Five canonical save call sites currently exist in main.dart. Keep this
    // contract aligned with the source; the separate reschedule assertion
    // below verifies that all five reschedule paths remain wired.
    expect(home.split('await taskStore.save(').length - 1, 5);
    expect(
      home.split('AndroidFollowUpReminderScheduler().reschedule()').length - 1,
      5,
    );
  });

  test('FollowUp history writes do not schedule; TaskReminder owns delivery', () {
    final coordinator =
        File('lib/services/follow_up_write_coordinator.dart').readAsStringSync();
    final planner =
        File('lib/services/follow_up_reminder_alarm_planner.dart').readAsStringSync();
    final delivery =
        File('lib/services/follow_up_reminder_delivery_service.dart').readAsStringSync();
    final home = File('lib/main.dart').readAsStringSync();

    expect(coordinator, isNot(contains('reminderReschedule')));
    expect(coordinator, isNot(contains('AndroidFollowUpReminderScheduler')));
    expect(planner, contains('for (final reminder in task.taskReminders)'));
    expect(planner, contains('if (!reminder.alarmEnabled) continue;'));
    expect(delivery, contains('if (!reminder.alarmEnabled) continue;'));
    expect(home, contains('await taskStore.save(snapshot);'));
    expect(home, contains('AndroidFollowUpReminderScheduler().reschedule'));
  });
}
