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
          title: 'پیگیری قرارداد',
          note: 'نتیجه تماس با مشتری',
          reminderDate: DateTime(2026, 8, 28, 17, 30),
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.taskId, 'task-1');
    expect(result.single.taskTitle, 'قرارداد');
    expect(result.single.followUpId, 'fu-1');
    expect(result.single.label, 'پیگیری قرارداد');
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
          title: '   ',
          note: 'نتیجه پیگیری؛ نباید عنوان Reminder شود',
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
    expect(followUpReminder.label, 'پیگیری — کار');
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

  test('projects independent Task reminders with stable delivery keys', () {
    final task = Task(
      id: 'multi',
      title: 'کار',
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'یادآور اول',
          date: DateTime(2026, 8, 28, 17),
          sequence: 1,
        ),
        TaskReminder(
          id: 'r2',
          title: 'یادآور تمام‌روز',
          date: DateTime(2026, 8, 29),
          isAllDay: true,
          sequence: 2,
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result, hasLength(2));
    expect(result.map((item) => item.stableKey), [
      'task:multi:reminder:r1',
      'task:multi:reminder:r2',
    ]);
    expect(result.last.scheduledAt, DateTime(2026, 8, 29, 9));
    expect(result.last.label, 'یادآور تمام‌روز');
  });

  test('migrated legacy reminder keeps its existing scheduler delivery key', () {
    final task = Task.fromJson({
      'id': 'legacy-scheduler-task',
      'title': 'کار قدیمی',
      'reminderDate': '2026-10-20T09:30:00.000',
    });

    final result = projection.pending([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.stableKey, 'task:legacy-scheduler-task');
    expect(result.single.taskReminderId, isNull);
    expect(result.single.scheduledAt, DateTime(2026, 10, 20, 9, 30));
  });

  test('title-only edit preserves FollowUp reminder delivery identity', () {
    Task withTitle(String title) => Task(
          id: 'task-stable',
          title: 'کار مادر',
          followUps: [
            FollowUp(
              id: 'fu-stable',
              dateTime: now,
              title: title,
              note: 'نتیجه نباید عنوان شود',
              reminderDate: now.add(const Duration(hours: 1)),
            ),
          ],
        );

    final before = projection.pending([withTitle('عنوان قبلی')], now: now).single;
    final after = projection.pending([withTitle('عنوان جدید')], now: now).single;

    expect(before.label, 'عنوان قبلی');
    expect(after.label, 'عنوان جدید');
    expect(after.stableKey, before.stableKey);
    expect(after.scheduledAt, before.scheduledAt);
    expect(after.followUpId, before.followUpId);
  });

  test('blank parent Task title uses safe generic Persian fallback', () {
    final task = Task(
      id: 'task-no-title',
      title: '   ',
      followUps: [
        FollowUp(
          id: 'fu-no-title',
          dateTime: now,
          title: '  ',
          note: 'نتیجه پیگیری',
          reminderDate: now.add(const Duration(hours: 1)),
        ),
      ],
    );

    final result = projection.pending([task], now: now);

    expect(result, hasLength(1));
    expect(result.single.label, 'پیگیری');
    expect(result.single.stableKey, 'task-no-title:fu-no-title');
    expect(result.single.scheduledAt, now.add(const Duration(hours: 1)));
  });


  test('projects migrated linked Follow-up Reminder once with persisted title and identity', () {
    final task = Task.fromJson({
      'id': 'migrated-owner',
      'title': 'کار مادر',
      'followUps': [
        {
          'id': 'migrated-followup',
          'dateTime': '2026-10-20T10:00:00.000',
          'title': 'تماس مشتری',
          'reminderDate': '2026-10-21T11:00:00.000',
        }
      ],
    });
    final result = projection.pending([task], now: DateTime(2026, 10, 20));
    expect(result, hasLength(1));
    expect(result.single.followUpId, 'migrated-followup');
    expect(result.single.label, 'تماس مشتری');
    expect(result.single.stableKey, 'migrated-owner:migrated-followup');
    expect(result.single.scheduledAt, DateTime(2026, 10, 21, 11));
  });
}
