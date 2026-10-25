import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const reminders = FollowUpCalendarProjection();

  test('legacy nextFollowUp does not create a calendar event', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
        ),
      ],
    );

    final before = task.toJson();
    final reminderItems = reminders.project([task]);

    expect(reminderItems, isEmpty);
    expect(task.toJson(), before);
  });

  test('explicit Reminder takes calendar precedence without mutating Follow-up', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      reminderDate: DateTime(2026, 10, 20, 9, 55),
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: DateTime(2026, 10, 20, 9, 55),
        ),
      ],
    );

    final before = task.toJson();
    final reminderItems = reminders.project([task]);

    expect(reminderItems.any((item) => item.date == DateTime(2026, 10, 20, 9, 55)), isTrue);
    expect(task.followUps.single.nextFollowUp, DateTime(2026, 10, 20, 10));
    expect(task.toJson(), before);
  });

  test('Reminder precedence is scoped to its own Task', () {
    final withReminder = Task(
      id: 'task-with-reminder',
      title: 'دارای یادآور',
      reminderDate: DateTime(2026, 10, 20, 9),
      followUps: [
        FollowUp(
          id: 'follow-with-reminder',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
        ),
      ],
    );
    final withoutReminder = Task(
      id: 'task-without-reminder',
      title: 'بدون یادآور',
      followUps: [
        FollowUp(
          id: 'follow-without-reminder',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 21, 10),
        ),
      ],
    );

    final items = reminders.project([withReminder, withoutReminder]);
    expect(items, hasLength(1));
    expect(items.single.id, contains('task-with-reminder'));
  });

  test('changing nextFollowUp does not mutate existing reminderDate', () {
    final originalReminder = DateTime(2026, 10, 20, 9, 55);
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: originalReminder,
        ),
      ],
    );

    final followUp = task.followUps.single;
    final changed = FollowUp(
      id: followUp.id,
      dateTime: followUp.dateTime,
      note: followUp.note,
      result: followUp.result,
      reminderDate: followUp.reminderDate,
      nextFollowUp: DateTime(2026, 10, 21, 10),
      completed: followUp.completed,
    );

    expect(changed.nextFollowUp, DateTime(2026, 10, 21, 10));
    expect(changed.reminderDate, originalReminder);
    expect(reminders.project([task]).single.date, originalReminder);

    expect(reminders.project([task]).single.date, originalReminder);
    final followUpWithoutReminder = FollowUp(
      id: changed.id,
      dateTime: changed.dateTime,
      note: changed.note,
      result: changed.result,
      nextFollowUp: changed.nextFollowUp,
      completed: changed.completed,
    );
    final taskWithoutReminder = Task(
      id: task.id,
      title: task.title,
      followUps: [followUpWithoutReminder],
    );
    expect(reminders.project([taskWithoutReminder]), isEmpty);
  });
}
