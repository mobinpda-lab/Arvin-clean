import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:arvin/services/follow_up_single_alarm_arbiter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const arbiter = FollowUpSingleAlarmArbiter();
  const reminderDelivery = FollowUpReminderDeliveryService();
  final now = DateTime(2026, 8, 28, 10);

  Task task({
    required String id,
    DateTime? nextFollowUp,
    DateTime? reminderDate,
    bool completed = false,
    bool archived = false,
    bool trashed = false,
  }) {
    return Task(
      id: id,
      title: 'Task $id',
      completed: completed,
      archived: archived,
      trashed: trashed,
      followUps: [
        FollowUp(
          id: 'fu-$id',
          dateTime: DateTime(2026, 8, 28, 9),
          nextFollowUp: nextFollowUp,
          reminderDate: reminderDate,
        ),
      ],
    );
  }

  test('chooses reminder when it is earlier than automatic follow-up', () {
    final decision = arbiter.next(
      [
        task(
          id: 'one',
          nextFollowUp: DateTime(2026, 8, 28, 12),
          reminderDate: DateTime(2026, 8, 28, 11),
        ),
      ],
      automaticDeliveredState: const {},
      reminderDeliveredIdentities: const {},
      now: now,
    );

    expect(decision, isNotNull);
    expect(decision!.source, FollowUpAlarmSource.reminder);
    expect(decision.alarmAt, DateTime(2026, 8, 28, 11));
  });

  test('chooses automatic follow-up when it is earlier', () {
    final decision = arbiter.next(
      [
        task(
          id: 'one',
          nextFollowUp: DateTime(2026, 8, 28, 10, 30),
          reminderDate: DateTime(2026, 8, 28, 11),
        ),
      ],
      automaticDeliveredState: const {},
      reminderDeliveredIdentities: const {},
      now: now,
    );

    expect(decision, isNotNull);
    expect(decision!.source, FollowUpAlarmSource.automaticFollowUp);
    expect(decision.alarmAt, DateTime(2026, 8, 28, 10, 30));
  });

  test('overdue undelivered reminder retries after minimum delay', () {
    final decision = arbiter.next(
      [
        task(
          id: 'one',
          reminderDate: DateTime(2026, 8, 28, 9, 59),
        ),
      ],
      automaticDeliveredState: const {},
      reminderDeliveredIdentities: const {},
      now: now,
    );

    expect(decision, isNotNull);
    expect(decision!.source, FollowUpAlarmSource.reminder);
    expect(decision.alarmAt, DateTime(2026, 8, 28, 10, 5));
  });

  test('delivered overdue reminder does not create retry work', () {
    final source = task(
      id: 'one',
      reminderDate: DateTime(2026, 8, 28, 9, 59),
    );
    final candidate = reminderDelivery.due([source], now: now).single;

    final decision = arbiter.next(
      [source],
      automaticDeliveredState: const {},
      reminderDeliveredIdentities: {
        reminderDelivery.deliveryIdentity(candidate),
      },
      now: now,
    );

    expect(decision, isNull);
  });

  test('completed archived and trashed reminders never win the alarm', () {
    final future = DateTime(2026, 8, 28, 11);
    final decision = arbiter.next(
      [
        task(id: 'done', reminderDate: future, completed: true),
        task(id: 'archive', reminderDate: future, archived: true),
        task(id: 'trash', reminderDate: future, trashed: true),
      ],
      automaticDeliveredState: const {},
      reminderDeliveredIdentities: const {},
      now: now,
    );

    expect(decision, isNull);
  });

  test('delivered automatic work yields to pending reminder', () {
    final source = task(
      id: 'one',
      nextFollowUp: DateTime(2026, 8, 28, 10, 30),
      reminderDate: DateTime(2026, 8, 28, 11),
    );
    final followUp = source.followUps.single;
    final automaticIdentity =
        '${followUp.id}@${followUp.nextFollowUp!.toIso8601String()}';

    final decision = arbiter.next(
      [source],
      automaticDeliveredState: {'one': automaticIdentity},
      reminderDeliveredIdentities: const {},
      now: now,
    );

    expect(decision, isNotNull);
    expect(decision!.source, FollowUpAlarmSource.reminder);
    expect(decision.alarmAt, DateTime(2026, 8, 28, 11));
  });

  test('equal alarm times deterministically keep automatic follow-up first', () {
    final same = DateTime(2026, 8, 28, 11);
    final decision = arbiter.next(
      [task(id: 'one', nextFollowUp: same, reminderDate: same)],
      automaticDeliveredState: const {},
      reminderDeliveredIdentities: const {},
      now: now,
    );

    expect(decision, isNotNull);
    expect(decision!.source, FollowUpAlarmSource.automaticFollowUp);
    expect(decision.alarmAt, same);
  });
}
