import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_alarm_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = FollowUpReminderAlarmPlanner();
  final now = DateTime(2026, 8, 28, 18);

  Task task(
    String id,
    DateTime? reminder, {
    String followUpId = 'fu-1',
    bool trashed = false,
  }) =>
      Task(
        id: id,
        title: 'Task $id',
        trashed: trashed,
        followUps: [
          FollowUp(
            id: followUpId,
            dateTime: DateTime(2026, 8, 28, 10),
            note: 'تماس',
            reminderDate: reminder,
          ),
        ],
      );

  test('chooses nearest pending canonical FollowUp reminder', () {
    final plan = planner.next(
      [
        task('later', DateTime(2026, 8, 28, 20)),
        task('first', DateTime(2026, 8, 28, 19)),
      ],
      now: now,
    );

    expect(plan, isNotNull);
    expect(plan!.candidate.taskId, 'first');
    expect(plan.alarmAt, DateTime(2026, 8, 28, 19));
  });

  test('skips exact delivered reminder and chooses the next one', () {
    final first = task('first', DateTime(2026, 8, 28, 19));
    final firstPlan = planner.next([first], now: now)!;

    final next = planner.next(
      [first, task('later', DateTime(2026, 8, 28, 20))],
      now: now,
      deliveredKeys: {firstPlan.deliveryKey},
    );

    expect(next, isNotNull);
    expect(next!.candidate.taskId, 'later');
  });

  test('changing reminder time creates a new delivery identity', () {
    final oldPlan = planner.next(
      [task('1', DateTime(2026, 8, 28, 19))],
      now: now,
    )!;
    final changedPlan = planner.next(
      [task('1', DateTime(2026, 8, 28, 19, 30))],
      now: now,
      deliveredKeys: {oldPlan.deliveryKey},
    );

    expect(changedPlan, isNotNull);
    expect(changedPlan!.deliveryKey, isNot(oldPlan.deliveryKey));
  });

  test('ignores past missing and trashed reminder work', () {
    final plan = planner.next(
      [
        task('past', DateTime(2026, 8, 28, 17, 59)),
        task('missing', null),
        task('trash', DateTime(2026, 8, 28, 19), trashed: true),
      ],
      now: now,
    );

    expect(plan, isNull);
  });

  test('exact-now reminder remains eligible', () {
    final plan = planner.next(
      [task('now', now)],
      now: now,
    );

    expect(plan, isNotNull);
    expect(plan!.alarmAt, now);
  });
}
