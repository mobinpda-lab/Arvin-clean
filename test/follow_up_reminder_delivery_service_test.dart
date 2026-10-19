import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FollowUpReminderDeliveryService();
  final now = DateTime(2026, 8, 28, 18, 15);

  Task task(
    String id, {
    bool completed = false,
    bool archived = false,
    bool trashed = false,
    DateTime? taskReminder,
    List<FollowUp> followUps = const <FollowUp>[],
    List<TaskReminder> taskReminders = const <TaskReminder>[],
  }) =>
      Task(
        id: id,
        title: 'Task $id',
        completed: completed,
        archived: archived,
        trashed: trashed,
        reminderDate: taskReminder,
        taskReminders: taskReminders,
        followUps: followUps,
      );

  FollowUp followUp(
    String id,
    DateTime? reminder, {
    String note = '',
    String? title,
  }) =>
      FollowUp(
        id: id,
        dateTime: DateTime(2026, 8, 28, 10),
        title: title,
        note: note,
        reminderDate: reminder,
      );

  test('returns overdue and exact-now FollowUp reminders but not future work', () {
    final result = service.due(
      [
        task(
          'one',
          followUps: [
            followUp('past', now.subtract(const Duration(minutes: 5))),
            followUp('now', now, title: 'پیگیری تماس', note: 'نتیجه تماس'),
            followUp('future', now.add(const Duration(minutes: 1))),
          ],
        ),
      ],
      now: now,
    );

    expect(result.map((item) => item.followUpId), ['past', 'now']);
    expect(result.last.label, 'پیگیری تماس');
  });

  test('exact delivered identity is skipped while a changed time is new work', () {
    final original = followUp('fu', now.subtract(const Duration(minutes: 10)));
    final tasks = [task('one', followUps: [original])];
    final first = service.due(tasks, now: now).single;
    final delivered = service.deliveryIdentity(first);

    expect(
      service.due(tasks, now: now, deliveredIdentities: {delivered}),
      isEmpty,
    );

    final changed = task(
      'one',
      followUps: [
        followUp('fu', now.subtract(const Duration(minutes: 2))),
      ],
    );
    final changedResult = service.due(
      [changed],
      now: now,
      deliveredIdentities: {delivered},
    );

    expect(changedResult, hasLength(1));
    expect(service.deliveryIdentity(changedResult.single), isNot(delivered));
  });

  test('inactive Tasks never produce FollowUp reminder delivery', () {
    final reminder = now.subtract(const Duration(minutes: 1));
    final result = service.due(
      [
        task('done', completed: true, followUps: [followUp('a', reminder)]),
        task('archive', archived: true, followUps: [followUp('b', reminder)]),
        task('trash', trashed: true, followUps: [followUp('c', reminder)]),
      ],
      now: now,
    );

    expect(result, isEmpty);
  });

  test('Task-level reminder is delivered by the canonical reminder service', () {
    final result = service.due(
      [
        task(
          'one',
          taskReminder: now.subtract(const Duration(minutes: 1)),
          followUps: [followUp('no-reminder', null)],
        ),
      ],
      now: now,
    );

    expect(result, hasLength(1));
    expect(result.single.isTaskReminder, isTrue);
    expect(result.single.stableKey, 'task:one');
    expect(result.single.followUpId, isNull);
    expect(result.single.scheduledAt, now.subtract(const Duration(minutes: 1)));
  });

  test('Task-level reminder and FollowUp reminder can coexist without duplicate identity', () {
    final result = service.due(
      [
        task(
          'one',
          taskReminder: now.subtract(const Duration(minutes: 2)),
          followUps: [followUp('fu', now.subtract(const Duration(minutes: 1)))],
        ),
      ],
      now: now,
    );

    expect(result.map((item) => item.stableKey), ['task:one', 'one:fu']);
  });

  test('blank note uses canonical label and ordering is deterministic', () {
    final sameTime = now.subtract(const Duration(minutes: 1));
    final result = service.due(
      [
        task('b', followUps: [followUp('z', sameTime)]),
        task('a', followUps: [followUp('y', sameTime)]),
        task(
          'early',
          followUps: [
            followUp('x', sameTime.subtract(const Duration(minutes: 1))),
          ],
        ),
      ],
      now: now,
    );

    expect(result.map((item) => item.stableKey), [
      'early:x',
      'a:y',
      'b:z',
    ]);
    expect(result.first.label, 'پیگیری — Task early');
  });

  test('delivers multiple Task reminders with distinct stable identities', () {
    final at = now.subtract(const Duration(minutes: 2));
    final result = service.due(
      [
        task(
          'multi',
          taskReminders: [
            TaskReminder(id: 'r1', title: 'یادآور اول', date: at, sequence: 1),
            TaskReminder(id: 'r2', title: 'یادآور دوم', date: at, sequence: 2),
          ],
        ),
      ],
      now: now,
    );

    expect(result, hasLength(2));
    expect(result.map((item) => item.stableKey).toSet(), {
      'task:multi:reminder:r1',
      'task:multi:reminder:r2',
    });
    expect(result.map((item) => item.label), ['یادآور اول', 'یادآور دوم']);
  });

  test('date-only reminder notification uses 9 AM, not an inferred midnight time', () {
    final result = service.due(
      [
        task(
          'all-day',
          taskReminders: [
            TaskReminder(
              id: 'r-all-day',
              title: 'یادآور تمام‌روز',
              date: DateTime(2026, 8, 28),
              isAllDay: true,
              sequence: 1,
            ),
          ],
        ),
      ],
      now: DateTime(2026, 8, 28, 9),
    );

    expect(result, hasLength(1));
    expect(result.single.scheduledAt, DateTime(2026, 8, 28, 9));
  });
  test('linked Follow-up Reminder delivers once under the existing Follow-up identity', () {
    final at = DateTime(2026, 10, 21, 11, 30);
    final linkedTask = Task.fromJson({
      'id': 'linked-delivery',
      'title': 'کار مادر',
      'followUps': [
        {
          'id': 'linked-fu',
          'dateTime': '2026-10-20T10:00:00.000',
          'title': 'تماس مشتری',
          'reminderDate': at.toIso8601String(),
        }
      ],
    });
    final result = service.due([linkedTask], now: at);
    expect(result, hasLength(1));
    expect(result.single.stableKey, 'linked-delivery:linked-fu');
    expect(result.single.label, 'تماس مشتری');
    expect(
      service.due(
        [linkedTask],
        now: at,
        deliveredIdentities: {service.deliveryIdentity(result.single)},
      ),
      isEmpty,
    );
  });

}
