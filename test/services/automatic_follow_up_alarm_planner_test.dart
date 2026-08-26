import 'package:arvin/models/task.dart';
import 'package:arvin/services/automatic_follow_up_alarm_planner.dart';
import 'package:arvin/services/automatic_follow_up_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = AutomaticFollowUpAlarmPlanner();
  final now = DateTime(2026, 8, 26, 12);

  Task taskWithSchedule({
    required String id,
    required DateTime historyAt,
    required DateTime nextAt,
    bool completed = false,
  }) {
    return Task(
      id: id,
      title: id,
      completed: completed,
      followUps: [
        FollowUp(
          id: 'follow-$id',
          dateTime: historyAt,
          nextFollowUp: nextAt,
        ),
      ],
    );
  }

  test('chooses earliest not-delivered canonical schedule', () {
    final earlier = taskWithSchedule(
      id: 'earlier',
      historyAt: now.subtract(const Duration(hours: 1)),
      nextAt: now.add(const Duration(hours: 1)),
    );
    final later = taskWithSchedule(
      id: 'later',
      historyAt: now.subtract(const Duration(minutes: 30)),
      nextAt: now.add(const Duration(hours: 2)),
    );

    expect(
      planner.nextAlarmAt(
        [later, earlier],
        deliveredState: const {},
        now: now,
      ),
      now.add(const Duration(hours: 1)),
    );
  });

  test('skips the already delivered latest schedule', () {
    final earlier = taskWithSchedule(
      id: 'earlier',
      historyAt: now.subtract(const Duration(hours: 1)),
      nextAt: now.add(const Duration(hours: 1)),
    );
    final later = taskWithSchedule(
      id: 'later',
      historyAt: now.subtract(const Duration(minutes: 30)),
      nextAt: now.add(const Duration(hours: 2)),
    );
    final candidate = const AutomaticFollowUpService()
        .scheduledCandidates([earlier])
        .single;

    expect(
      planner.nextAlarmAt(
        [earlier, later],
        deliveredState: {'earlier': candidate.deliveryIdentity},
        now: now,
      ),
      now.add(const Duration(hours: 2)),
    );
  });

  test('clamps overdue retry to a small future delay', () {
    final overdue = taskWithSchedule(
      id: 'overdue',
      historyAt: now.subtract(const Duration(hours: 2)),
      nextAt: now.subtract(const Duration(minutes: 10)),
    );

    expect(
      planner.nextAlarmAt(
        [overdue],
        deliveredState: const {},
        now: now,
      ),
      now.add(const Duration(minutes: 5)),
    );
  });

  test('ignores completed tasks and superseded old schedules', () {
    final completed = taskWithSchedule(
      id: 'completed',
      historyAt: now.subtract(const Duration(hours: 2)),
      nextAt: now.add(const Duration(hours: 1)),
      completed: true,
    );
    final superseded = Task(
      id: 'superseded',
      title: 'superseded',
      followUps: [
        FollowUp(
          id: 'old',
          dateTime: now.subtract(const Duration(days: 2)),
          nextFollowUp: now.add(const Duration(hours: 1)),
        ),
        FollowUp(
          id: 'new',
          dateTime: now.subtract(const Duration(hours: 1)),
        ),
      ],
    );

    expect(
      planner.nextAlarmAt(
        [completed, superseded],
        deliveredState: const {},
        now: now,
      ),
      isNull,
    );
  });
}
