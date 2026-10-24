import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const projection = FollowUpCalendarProjection();

  test('projects a date-only Task due date as all-day', () {
    final task = Task(id: 'date-only', title: 'کار روزانه', dueDate: DateTime(2026, 10, 8));
    final items = projection.project([task]);
    expect(items, hasLength(1));
    expect(items.single.id, 'task-due:date-only');
    expect(items.single.isAllDay, isTrue);
  });

  test('legacy FollowUp scheduling fields never create active Calendar events', () {
    final task = Task(
      id: 'history-only',
      title: 'تماس با مشتری',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 10, 20, 10),
      reminderDate: DateTime(2026, 10, 20, 9),
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: DateTime(2026, 10, 13, 8),
          nextFollowUp: DateTime(2026, 10, 20, 10),
          reminderDate: DateTime(2026, 10, 20, 9),
          note: 'سابقه باید باقی بماند',
        ),
      ],
    );
    final before = task.toJson();
    expect(projection.project([task]), isEmpty);
    expect(task.toJson(), before);
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.nextFollowUp, DateTime(2026, 10, 20, 10));
    expect(task.followUps.single.reminderDate, DateTime(2026, 10, 20, 9));
  });

  test('Task due date and canonical Reminder remain independent at the same time', () {
    final at = DateTime(2026, 12, 1, 10);
    final task = Task(
      id: 'independent',
      title: 'جلسه',
      dueDate: at,
      taskReminders: [TaskReminder(id: 'r1', title: 'یادآور جلسه', date: at, sequence: 1)],
    );
    final items = projection.project([task]);
    expect(items, hasLength(2));
    expect(items.map((item) => item.id).toSet(), {
      'task-due:independent',
      'task-reminder-item:independent:r1',
    });
  });

  test('projects multiple stable-ID reminders at the same instant without collapsing them', () {
    final at = DateTime(2026, 12, 5, 9);
    final task = Task(
      id: 'multi',
      title: 'خرید فرش',
      taskReminders: [
        TaskReminder(id: 'r1', title: 'یادآور ۱', date: at, sequence: 1),
        TaskReminder(id: 'r2', title: 'یادآور ۲', date: at, sequence: 2),
        TaskReminder(id: 'r3', title: 'تمام‌روز', date: DateTime(2026, 12, 5), isAllDay: true, sequence: 3),
      ],
    );
    final items = projection.project([task]);
    expect(items, hasLength(3));
    expect(items.map((item) => item.id).toSet(), {
      'task-reminder-item:multi:r1',
      'task-reminder-item:multi:r2',
      'task-reminder-item:multi:r3',
    });
    expect(items.map((item) => item.isAllDay).toSet(), {false, true});
  });

  test('encodes Task and Reminder IDs as a stable identity', () {
    final at = DateTime(2026, 12, 8, 9);
    final task = Task(
      id: 'task:with:colons',
      title: 'خرید فرش',
      taskReminders: [
        TaskReminder(id: 'reminder:one', title: 'یادآور', date: at, sequence: 1),
      ],
    );
    final items = projection.project([task]);
    expect(items.single.id, 'task-reminder-item:task%3Awith%3Acolons:reminder%3Aone');
  });

  test('legacy Task.reminderDate alone is not an active Reminder source', () {
    final task = Task(
      id: 'legacy',
      title: 'کار قدیمی',
      reminderDate: DateTime(2026, 12, 5, 9, 30),
    );
    expect(projection.project([task]), isEmpty);
  });

  test('projects Task recurrence in the visible range without creating Tasks', () {
    final task = Task(
      id: 'daily-task',
      title: 'کار روزانه',
      dueDate: DateTime(2026, 10, 1, 14),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );
    final items = projection.project(
      [task],
      visibleFrom: DateTime(2026, 10, 5),
      visibleTo: DateTime(2026, 10, 8),
    );
    expect(items.map((item) => item.date), [
      DateTime(2026, 10, 5, 14),
      DateTime(2026, 10, 6, 14),
      DateTime(2026, 10, 7, 14),
    ]);
    expect(items.map((item) => item.id).toSet(), hasLength(items.length));
  });
}
