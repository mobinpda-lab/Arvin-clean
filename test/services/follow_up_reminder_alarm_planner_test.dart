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

  test('older reminder JSON defaults enabled when the new flag is absent', () {
    final task = Task.fromJson({
      'id': 'pre-enabled-flag',
      'title': 'سازگاری قدیمی',
      'taskReminders': [
        {
          'id': 'old-r1',
          'title': 'یادآور قدیمی',
          'date': '2026-09-08T15:00:00.000',
          'sequence': 1,
        },
      ],
    });
    expect(task.taskReminders.single.isEnabled, isTrue);
  });

  test('disabled independent Task Reminder is persisted and not scheduled', () {
    final at = DateTime(2026, 9, 8, 15);
    final original = Task(
      id: 'disabled-reminder',
      title: 'یادآور غیرفعال',
      taskReminders: [
        TaskReminder(id: 'r-disabled', title: 'تماس', date: at, sequence: 1, isEnabled: false),
      ],
    );
    final restored = Task.fromJson(original.toJson());
    expect(restored.taskReminders.single.isEnabled, isFalse);
    expect(restored.taskReminders.single.toJson()['isEnabled'], isFalse);
    expect(
      planner.nextAlarmAt([restored], deliveredState: const {}, now: DateTime(2026, 9, 8, 12)),
      isNull,
    );
  });

  test('a migrated reminder remains unscheduled when its canonical record is disabled', () {
    final at = DateTime(2026, 9, 8, 15);
    final task = Task.fromJson({
      'id': 'legacy-reminder-disabled',
      'title': 'یادآور قدیمی',
      'reminderDate': at.toIso8601String(),
      'legacyTaskReminderMigrationVersion': 1,
      'taskReminders': [
        {
          'id': migratedTaskReminderId('legacy-reminder-disabled'),
          'title': 'یادآور قدیمی',
          'date': at.toIso8601String(),
          'sequence': 1,
          'isEnabled': false,
        },
      ],
    });
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
