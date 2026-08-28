import 'package:arvin/automatic_follow_up_notification_service.dart';
import 'package:arvin/services/follow_up_reminder_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = AutomaticFollowUpNotificationService();

  FollowUpReminderCandidate candidate({
    String taskId = 'task-1',
    String taskTitle = 'مشتری رضایی',
    String followUpId = 'fu-1',
    String label = 'تماس مجدد',
  }) =>
      FollowUpReminderCandidate(
        taskId: taskId,
        taskTitle: taskTitle,
        followUpId: followUpId,
        label: label,
        scheduledAt: DateTime(2026, 8, 28, 19),
      );

  test('FollowUp reminder notification id is stable for canonical identity', () {
    final value = candidate();

    expect(
      service.reminderNotificationIdFor(value),
      service.reminderNotificationIdFor(value),
    );
    expect(service.reminderNotificationIdFor(value), greaterThan(0));
  });

  test('different FollowUp identity gets a different reminder notification id', () {
    expect(
      service.reminderNotificationIdFor(candidate(followUpId: 'fu-1')),
      isNot(service.reminderNotificationIdFor(candidate(followUpId: 'fu-2'))),
    );
  });

  test('reminder notification body identifies parent Task and FollowUp label', () {
    expect(
      service.reminderBodyFor(candidate()),
      'مشتری رضایی • تماس مجدد',
    );
  });

  test('blank display values use safe canonical fallbacks', () {
    expect(
      service.reminderBodyFor(candidate(taskTitle: ' ', label: ' ')),
      'بدون عنوان • پیگیری',
    );
  });
}
