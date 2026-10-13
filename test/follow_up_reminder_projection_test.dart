import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = FollowUpReminderProjection();
  final now = DateTime(2026, 8, 28, 16);

  test('projects future FollowUp reminders with parent identity and label', () {
    final task = Task(
      id: 'task-1',
      title: 'قرارداد',
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: DateTime(2026, 8, 28, 12),
          note: 'تماس با مشتری',
          reminderDate: DateTime(2026, 8, 28, 17, 30),
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.taskId, 'task-1');
    expect(result.single.taskTitle, 'قرارداد');
    expect(result.single.followUpId, 'fu-1');
    expect(result.single.label, 'تماس با مشتری');
    expect(result.single.scheduledAt, DateTime(2026, 8, 28, 17, 30));
    expect(result.single.stableKey, 'task-1:fu-1');
  });

  test('projects canonical Task reminder alongside FollowUp reminders', () {
    final task = Task(
      id: 'task-1',
      title: 'کار',
      reminderDate: DateTime(2026, 8, 28, 17),
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: DateTime(2026, 8, 28, 15),
          reminderDate: DateTime(2026, 8, 28, 18),
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result, hasLength(2));
    expect(result.map((item) => item.stableKey), ['task:task-1', 'task-1:fu-1']);
    expect(result.first.isTaskReminder, isTrue);
    expect(result.first.label, 'یادآوری');
  });

  test('FollowUp reminder remains independent from Task reminder', () {
    final task = Task(
      id: 'task-1',
      title: 'کار',
      reminderDate: DateTime(2026, 8, 28, 16, 15),
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: DateTime(2026, 8, 28, 15),
          reminderDate: DateTime(2026, 8, 28, 18),
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result, hasLength(2));
    final followUpReminder = result.singleWhere((item) => item.isTaskReminder == false);
    expect(followUpReminder.scheduledAt, DateTime(2026, 8, 28, 18));
    expect(followUpReminder.label, 'پیگیری');
  });

  test('ignores disabled, expired, completed, archived, and trashed work', () {
    FollowUp future(String id) => FollowUp(
          id: id,
          dateTime: now,
          reminderDate: now.add(const Duration(hours: 1)),
        );

    final tasks = [
      Task(
        id: 'active',
        title: 'فعال',
        followUps: [
          FollowUp(id: 'no-reminder', dateTime: now),
          FollowUp(
            id: 'expired',
            dateTime: now,
            reminderDate: now.subtract(const Duration(minutes: 1)),
          ),
          FollowUp(id: 'completed-future', dateTime: now, reminderDate: now.add(const Duration(hours: 2)), completed: true),
          FollowUp(id: 'due-now', dateTime: now, reminderDate: now),
        ],
      ),
      Task(
        id: 'completed',
        title: 'انجام‌شده',
        completed: true,
        followUps: [future('completed-task-future')],
      ),
      Task(
        id: 'archived',
        title: 'بایگانی',
        archived: true,
        followUps: [future('archived-future')],
      ),
      Task(
        id: 'trashed',
        title: 'حذف‌شده',
        trashed: true,
        followUps: [future('trashed-future')],
      ),
    ];

    final result = projection.pending(tasks, now: now);

    expect(result.map((item) => item.followUpId), ['due-now']);
  });

  test('sorts deterministically by reminder time then stable identity', () {
    final task = Task(
      id: 't',
      title: 'کار',
      followUps: [
        FollowUp(
          id: 'b',
          dateTime: now,
          reminderDate: now.add(const Duration(hours: 2)),
        ),
        FollowUp(
          id: 'c',
          dateTime: now,
          reminderDate: now.add(const Duration(hours: 1)),
        ),
        FollowUp(
          id: 'a',
          dateTime: now,
          reminderDate: now.add(const Duration(hours: 2)),
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result.map((item) => item.followUpId), ['c', 'a', 'b']);
  });

  test('projects multiple independent Task reminders with stable keys', () {
    final createdAt = DateTime(2026, 8, 1, 10);
    final task = Task(
      id: 'task-1',
      title: 'کار',
      taskReminders: <TaskReminder>[
        TaskReminder(
          id: 'r1',
          taskId: 'task-1',
          title: 'یادآور اول',
          date: DateTime(2026, 8, 28, 0),
          createdAt: createdAt,
          updatedAt: createdAt,
          isAllDay: true,
          sequence: 1,
        ),
        TaskReminder(
          id: 'r2',
          taskId: 'task-1',
          title: 'یادآور دوم',
          date: DateTime(2026, 8, 28, 0),
          createdAt: createdAt,
          updatedAt: createdAt,
          sequence: 2,
        ),
      ],
      nextReminderSequence: 3,
    );

    final result = projection.pending([task], now: DateTime(2026, 8, 28, 8));

    expect(result, hasLength(2));
    expect(result.map((item) => item.stableKey).toSet(), {
      'task-reminder-item:task-1:r1',
      'task-reminder-item:task-1:r2',
    });
    expect(
      result.singleWhere((item) => item.taskReminderId == 'r1').scheduledAt,
      DateTime(2026, 8, 28, 9),
    );
    expect(
      result.singleWhere((item) => item.taskReminderId == 'r2').scheduledAt,
      DateTime(2026, 8, 28, 0),
    );
  });

  test('migrated legacy reminder uses old delivery identity exactly once', () {
    final task = Task.fromJson(<String, dynamic>{
      'id': 'legacy-task',
      'title': 'تماس',
      'reminderDate': '2026-08-28T17:00:00.000',
    });

    final result = projection.pending([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.stableKey, 'task:legacy-task');
    expect(result.single.taskReminderId, 'legacy-task-reminder:legacy-task');
    expect(result.single.label, 'تماس — یادآور ۱');
  });

  test('deleted migrated legacy reminder is not scheduled from retained legacy value', () {
    final task = Task.fromJson(<String, dynamic>{
      'id': 'deleted-legacy',
      'title': 'تماس',
      'reminderDate': '2026-08-28T17:00:00.000',
    });
    task.taskReminders.clear();

    expect(
      projection.pending([task], now: now),
      isEmpty,
    );
    expect(task.reminderDate, DateTime(2026, 8, 28, 17));
  });

}
