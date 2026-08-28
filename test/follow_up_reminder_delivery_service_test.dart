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
  }) =>
      Task(
        id: id,
        title: 'Task $id',
        completed: completed,
        archived: archived,
        trashed: trashed,
        reminderDate: taskReminder,
        followUps: followUps,
      );

  FollowUp followUp(
    String id,
    DateTime? reminder, {
    String note = '',
  }) =>
      FollowUp(
        id: id,
        dateTime: DateTime(2026, 8, 28, 10),
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
            followUp('now', now, note: 'تماس'),
            followUp('future', now.add(const Duration(minutes: 1))),
          ],
        ),
      ],
      now: now,
    );

    expect(result.map((item) => item.followUpId), ['past', 'now']);
    expect(result.last.label, 'تماس');
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

  test('Task-level reminder stays independent from FollowUp reminder delivery', () {
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

    expect(result, isEmpty);
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
    expect(result.first.label, 'پیگیری');
  });
}
