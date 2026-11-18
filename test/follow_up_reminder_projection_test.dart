import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = FollowUpReminderProjection();
  final now = DateTime(2026, 8, 28, 16);

  test('legacy FollowUp.reminderDate never creates a future candidate', () {
    final task = Task(
      id: 'history-only',
      title: 'تاریخچه',
      followUpEnabled: true,
      followUpDate: now.add(const Duration(hours: 1)),
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: now,
          note: 'تماس واقعی',
          reminderDate: now.add(const Duration(hours: 2)),
          nextFollowUp: now.add(const Duration(hours: 3)),
        ),
      ],
    );
    expect(projection.pending([task], now: now), isEmpty);
  });

  test('only independent TaskReminder records enter the projection', () {
    final task = Task(
      id: 'task-1',
      title: 'کار',
      reminderDate: now.add(const Duration(hours: 1)),
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: now,
          reminderDate: now.add(const Duration(hours: 2)),
        ),
      ],
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'یادآور معتبر',
          date: now.add(const Duration(hours: 3)),
          sequence: 1,
        ),
      ],
    );

    final result = projection.pending([task], now: now);
    expect(result, hasLength(1));
    expect(result.single.stableKey, 'task:task-1:reminder:r1');
    expect(result.single.isTaskReminder, isTrue);
    expect(result.single.scheduledAt, now.add(const Duration(hours: 3)));
  });

  test('legacy Task reminder enters only through the approved decode migration', () {
    final decoded = Task.fromJson({
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'reminderDate': '2026-08-28T17:00:00.000',
    });
    final result = projection.pending([decoded], now: now);
    expect(result, hasLength(1));
    expect(result.single.stableKey, 'task:legacy-task');
    expect(result.single.taskReminderId, isNull);
    expect(result.single.scheduledAt, DateTime(2026, 8, 28, 17));
  });

  test('raw legacy Task reminder, legacy dates, and flags do not schedule', () {
    final raw = Task(
      id: 'raw-legacy',
      title: 'کار قدیمی',
      reminderDate: now.add(const Duration(hours: 1)),
      followUpDate: now.add(const Duration(hours: 2)),
      followUpEnabled: true,
    );
    expect(projection.pending([raw], now: now), isEmpty);
  });

  test('completed archived and trashed Tasks do not schedule independent reminders', () {
    final at = now.add(const Duration(hours: 1));
    final tasks = [
      Task(id: 'done', title: 'انجام‌شده', completed: true, taskReminders: [TaskReminder(id: 'a', title: 'a', date: at, sequence: 1)]),
      Task(id: 'archived', title: 'بایگانی', archived: true, taskReminders: [TaskReminder(id: 'b', title: 'b', date: at, sequence: 1)]),
      Task(id: 'trashed', title: 'حذف‌شده', trashed: true, taskReminders: [TaskReminder(id: 'c', title: 'c', date: at, sequence: 1)]),
    ];
    expect(projection.pending(tasks, now: now), isEmpty);
  });

  test('sorts independent reminders deterministically and uses 9 AM for all-day', () {
    final task = Task(
      id: 'multi',
      title: 'کار',
      taskReminders: [
        TaskReminder(id: 'later', title: 'بعدی', date: now.add(const Duration(hours: 2)), sequence: 2),
        TaskReminder(id: 'earlier', title: 'اولی', date: now.add(const Duration(hours: 1)), sequence: 1),
        TaskReminder(id: 'all-day', title: 'تمام‌روز', date: DateTime(2026, 8, 29), isAllDay: true, sequence: 3),
      ],
    );
    final result = projection.pending([task], now: now);
    expect(result.map((item) => item.stableKey), [
      'task:multi:reminder:earlier',
      'task:multi:reminder:later',
      'task:multi:reminder:all-day',
    ]);
    expect(result.last.scheduledAt, DateTime(2026, 8, 29, 9));
  });
}
