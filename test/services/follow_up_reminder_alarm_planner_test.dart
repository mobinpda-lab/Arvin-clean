import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = FollowUpReminderAlarmPlanner();

  Task task(
    String id, {
    required DateTime reminder,
    bool taskCompleted = false,
    bool followUpCompleted = false,
  }) {
    return Task(
      id: id,
      title: 'Task $id',
      completed: taskCompleted,
      followUps: [
        FollowUp(
          id: 'fu-$id',
          dateTime: DateTime(2026, 9, 8, 10),
          reminderDate: reminder,
          completed: followUpCompleted,
        ),
      ],
    );
  }

  test('uses the configured local time for all-day Task reminders', () {
    final createdAt = DateTime(2026, 9, 1, 10);
    final reminder = TaskReminder(id: 'all-day-custom', taskId: 'all-day-custom', title: 'یادآور', date: DateTime(2026, 9, 8), createdAt: createdAt, updatedAt: createdAt, isAllDay: true, sequence: 1);
    final customPlanner = FollowUpReminderAlarmPlanner(allDayReminderNotificationMinutes: 7 * 60 + 35);
    expect(customPlanner.nextAlarmAt([Task(id: 'all-day-custom', title: 'کار', taskReminders: [reminder], nextReminderSequence: 2)], deliveredState: const {}, now: DateTime(2026, 9, 8, 7)), DateTime(2026, 9, 8, 7, 35));
  });

  test('selects nearest undelivered independent FollowUp reminder', () {
    final now = DateTime(2026, 9, 8, 12);
    final next = planner.nextAlarmAt(
      [
        task('later', reminder: DateTime(2026, 9, 8, 15)),
        task('next', reminder: DateTime(2026, 9, 8, 13)),
      ],
      deliveredState: const {},
      now: now,
    );

    expect(next, DateTime(2026, 9, 8, 13));
  });

  test('overdue undelivered reminder is retried after bounded floor', () {
    final now = DateTime(2026, 9, 8, 12);
    final next = planner.nextAlarmAt(
      [task('overdue', reminder: DateTime(2026, 9, 8, 11))],
      deliveredState: const {},
      now: now,
    );

    expect(next, DateTime(2026, 9, 8, 12, 1));
  });

  test('delivered exact timestamp is skipped but rescheduled timestamp returns', () {
    final now = DateTime(2026, 9, 8, 12);
    final old = DateTime(2026, 9, 8, 13);
    final delivered = {
      'one:fu-one': 'one:fu-one@${old.toIso8601String()}',
    };

    expect(
      planner.nextAlarmAt(
        [task('one', reminder: old)],
        deliveredState: delivered,
        now: now,
      ),
      isNull,
    );

    expect(
      planner.nextAlarmAt(
        [task('one', reminder: DateTime(2026, 9, 8, 14))],
        deliveredState: delivered,
        now: now,
      ),
      DateTime(2026, 9, 8, 14),
    );
  });
}
