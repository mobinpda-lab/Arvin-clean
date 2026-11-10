import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const reminders = FollowUpCalendarProjection();

  test('legacy Follow-up nextFollowUp does not create a calendar event', () {
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
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
    expect(task.toJson()['followUps'].single.containsKey('nextFollowUp'), isFalse);
  });

  test('independent TaskReminder creates calendar event without Follow-up scheduling', () {
    final reminderDate = DateTime(2026, 10, 20, 9, 55);
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      taskReminders: [
        TaskReminder(
          id: 'reminder-independent',
          title: 'یادآور مستقل',
          date: reminderDate,
          sequence: 1,
        ),
      ],
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

    expect(reminderItems, hasLength(1));
    expect(reminderItems.single.date, reminderDate);
    expect(reminderItems.single.id, contains('reminder-independent'));
    expect(task.toJson(), before);
    expect(task.toJson()['followUps'].single.containsKey('nextFollowUp'), isFalse);
  });

  test('Reminder precedence is scoped to its own Task', () {
    final withReminder = Task(
      id: 'task-with-reminder',
      title: 'دارای یادآور',
      taskReminders: [
        TaskReminder(
          id: 'reminder-one',
          title: 'یادآور',
          date: DateTime(2026, 10, 20, 9),
          sequence: 1,
        ),
      ],
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

  test('editing a historical Follow-up does not mutate its independent TaskReminder', () {
    final reminderDate = DateTime(2026, 10, 20, 9, 55);
    final task = Task(
      id: 'customer-call',
      title: 'تماس با مشتری',
      taskReminders: [
        TaskReminder(
          id: 'reminder-stable',
          title: 'یادآور مستقل',
          date: reminderDate,
          sequence: 1,
        ),
      ],
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 10, 13, 8),
        ),
      ],
    );

    final original = task.toJson();
    task.followUps = [
      FollowUp(
        id: 'follow-1',
        dateTime: DateTime(2026, 10, 14, 10),
        note: 'ویرایش سابقه',
      ),
    ];

    expect(task.taskReminders.single.date, reminderDate);
    expect(task.taskReminders.single.id, 'reminder-stable');
    expect(reminders.project([task]).single.date, reminderDate);
    expect(original['taskReminders'], task.toJson()['taskReminders']);
  });
}
