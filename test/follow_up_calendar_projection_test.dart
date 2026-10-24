import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';

void main() {
  const projection = FollowUpCalendarProjection();

  test('projects all-day Task due date only when the explicit flag is set', () {
    final task = Task(id: 'date-only', title: 'کار روزانه', dueDate: DateTime(2026, 10, 8), allDay: true);
    final items = projection.project([task]);
    expect(items, hasLength(1));
    expect(items.single.id, 'task-due:date-only');
    expect(items.single.isAllDay, isTrue);
  });


  test('midnight timed due date is not inferred to be all-day', () {
    final task = Task(
      id: 'timed-midnight',
      title: 'موعد ساعت‌دار',
      dueDate: DateTime(2026, 10, 8, 0, 0),
      allDay: false,
    );
    final item = projection.project([task]).single;
    expect(item.isAllDay, isFalse);
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

  test('all four alarm/calendar-sync combinations remain independent', () {
    final at = DateTime(2026, 12, 9, 9);
    final task = Task(
      id: 'four-modes',
      title: 'چهار حالت',
      taskReminders: [
        TaskReminder(id: '00', title: 'خاموش/خاموش', date: at, alarmEnabled: false, calendarSyncEnabled: false, sequence: 1),
        TaskReminder(id: '01', title: 'خاموش/روشن', date: at, alarmEnabled: false, calendarSyncEnabled: true, sequence: 2),
        TaskReminder(id: '10', title: 'روشن/خاموش', date: at, alarmEnabled: true, calendarSyncEnabled: false, sequence: 3),
        TaskReminder(id: '11', title: 'روشن/روشن', date: at, alarmEnabled: true, calendarSyncEnabled: true, sequence: 4),
      ],
    );
    final rows = projection.project([task]);
    expect(rows, hasLength(4));
    expect({for (final row in rows) row.id: row.syncToDevice}, {
      'task-reminder-item:four-modes:00': false,
      'task-reminder-item:four-modes:01': true,
      'task-reminder-item:four-modes:10': false,
      'task-reminder-item:four-modes:11': true,
    });
    expect(task.taskReminders.map((item) => [item.alarmEnabled, item.calendarSyncEnabled]).toList(), [
      [false, false], [false, true], [true, false], [true, true],
    ]);
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
