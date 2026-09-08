import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('independent FollowUp reminder runtime reuses reboot-safe AlarmManager', () {
    final scheduler =
        File('lib/android_follow_up_reminder_scheduler.dart').readAsStringSync();
    final runner =
        File('lib/follow_up_reminder_background_runner.dart').readAsStringSync();
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
