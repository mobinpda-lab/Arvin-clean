import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = FollowUpReminderAlarmPlanner();

  test('legacy FollowUp.reminderDate never schedules an alarm', () {
    final task = Task(
      id: 'legacy-followup',
      title: 'تاریخچه',
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 9, 8, 10),
          reminderDate: DateTime(2026, 9, 8, 11),
        ),
      ],
    );
    expect(
      planner.nextAlarmAt([task], deliveredState: const {}, now: DateTime(2026, 9, 8, 12)),
      isNull,
    );
  });

  test('canonical independent Task Reminder still schedules', () {
    final at = DateTime(2026, 9, 8, 15);
    final task = Task(
      id: 'canonical',
      title: 'یادآور مستقل',
      taskReminders: [TaskReminder(id: 'r1', title: 'تماس', date: at, sequence: 1)],
    );
    expect(
      planner.nextAlarmAt([task], deliveredState: const {}, now: DateTime(2026, 9, 8, 12)),
      at,
    );
  });
}
