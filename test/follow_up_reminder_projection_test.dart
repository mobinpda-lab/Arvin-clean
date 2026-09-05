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
      reminderDate: DateTime(2026, 8, 29, 8),
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

    expect(result.single.scheduledAt, DateTime(2026, 8, 28, 18));
    expect(result.single.label, 'پیگیری');
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
}
