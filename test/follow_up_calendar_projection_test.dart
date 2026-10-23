import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const projection = FollowUpCalendarProjection();

  test('projects a date-only Task due date as an all-day Calendar event', () {
    final task = Task(
      id: 'date-only',
      title: 'کار روزانه',
      dueDate: DateTime(2026, 10, 8),
    );

    final reminders = projection.project([task]);

    expect(reminders, hasLength(1));
    expect(reminders.single.id, 'task-due:date-only');
    expect(reminders.single.isAllDay, isTrue);
  });

  test('does not project Follow-up history or its date, while preserving source data', () {
    final reminderDate = DateTime(2026, 10, 12, 9);
    final followUp = FollowUp(
      id: 'fu-history',
      dateTime: DateTime(2026, 10, 11, 10),
      title: 'تماس بعدی',
      note: 'یادداشت پیگیری',
      reminderDate: reminderDate,
    );
    final task = Task(
      id: 'history-only',
      title: 'پیگیری بدون رویداد تقویم',
      followUpEnabled: true,
      followUpDate: followUp.dateTime,
      followUps: [followUp],
    );

    expect(projection.project([task]), isEmpty);
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single, same(followUp));
    expect(task.followUps.single.dateTime, DateTime(2026, 10, 11, 10));
    expect(task.followUps.single.reminderDate, reminderDate);
    expect(task.followUpDate, followUp.dateTime);
  });

  test('independent Task reminders and due dates remain visible without Follow-ups', () {
    final dueDate = DateTime(2026, 10, 15, 14, 30);
    final reminderDate = DateTime(2026, 10, 15, 16, 30);
    final followUpDate = DateTime(2026, 10, 15, 15);
    final task = Task(
      id: 'task-reminder',
      title: 'ارسال پیش‌فاکتور',
      dueDate: dueDate,
      followUpEnabled: true,
      followUpDate: followUpDate,
      followUps: [
        FollowUp(
          id: 'fu',
          dateTime: followUpDate,
          reminderDate: DateTime(2026, 10, 15, 17),
        ),
      ],
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'یادآور مستقل',
          date: reminderDate,
          sequence: 1,
        ),
      ],
    );

    final reminders = projection.project([task]);

    expect(reminders.map((item) => item.id), contains('task-due:task-reminder'));
    expect(reminders.map((item) => item.id), contains('task-reminder-item:task-reminder:r1'));
    expect(reminders.any((item) => item.id.startsWith('followup:')), isFalse);
    expect(reminders, hasLength(2));
    expect(task.followUps.single.reminderDate, DateTime(2026, 10, 15, 17));
  });

  test('projects past, today, and future recurrence occurrences in visible range', () {
    final task = Task(
      id: 'short-cycle',
      title: 'کار تکرارشونده',
      dueDate: DateTime(2026, 10, 22, 9),
      recurrence: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      ),
      occurrenceHistory: const {},
    );

    final reminders = projection.project(
      [task],
      visibleFrom: DateTime(2026, 10, 21),
      visibleTo: DateTime(2026, 10, 25),
    );

    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 21, 9),
      DateTime(2026, 10, 22, 9),
      DateTime(2026, 10, 23, 9),
      DateTime(2026, 10, 24, 9),
    ]);
    expect(reminders.every((item) => item.id.startsWith('task-due:short-cycle:')), isTrue);
  });

  test('respects recurrence count and end-date boundaries', () {
    final task = Task(
      id: 'bounded',
      title: 'تکرار محدود',
      dueDate: DateTime(2026, 10, 1, 9),
      recurrence: RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        count: 3,
      ),
    );

    final reminders = projection.project(
      [task],
      visibleFrom: DateTime(2026, 10, 1),
      visibleTo: DateTime(2026, 10, 10),
    );

    expect(reminders.map((item) => item.date), <DateTime>[
      DateTime(2026, 10, 1, 9),
      DateTime(2026, 10, 2, 9),
      DateTime(2026, 10, 3, 9),
    ]);
  });

  test('projects every independent Task reminder once with stable identity', () {
    final task = Task(
      id: 'multi',
      title: 'یادآورها',
      taskReminders: [
        TaskReminder(id: 'r1', title: 'اول', date: DateTime(2026, 10, 1, 9), sequence: 1),
        TaskReminder(id: 'r2', title: 'دوم', date: DateTime(2026, 10, 2, 9), sequence: 2),
      ],
    );

    final reminders = projection.project([task]);

    expect(reminders.map((item) => item.id), <String>[
      'task-reminder-item:multi:r1',
      'task-reminder-item:multi:r2',
    ]);
  });
}
