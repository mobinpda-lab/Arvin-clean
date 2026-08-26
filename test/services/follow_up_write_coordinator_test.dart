import 'dart:convert';

import 'package:arvin/automatic_follow_up_scheduler_adapter.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduler implements AutomaticFollowUpSchedulerAdapter {
  int rescheduleCalls = 0;
  bool throwOnReschedule = false;

  @override
  Future<void> cancel() async {}

  @override
  Future<void> reschedule() async {
    rescheduleCalls += 1;
    if (throwOnReschedule) throw StateError('platform unavailable');
  }
}

void main() {
  const repository = FollowUpRepository();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'task-1',
          'title': 'مشتری',
          'followUps': <Object>[],
        },
      ]),
    });
  });

  test('successful add persists first then requests reschedule', () async {
    final scheduler = _FakeScheduler();
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      scheduler: scheduler,
    );
    final followUp = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
      nextFollowUp: DateTime(2026, 8, 27, 9),
    );

    await coordinator.add('task-1', followUp);

    expect(scheduler.rescheduleCalls, 1);
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.id, 'follow-1');
  });

  test('successful update requests reschedule', () async {
    final scheduler = _FakeScheduler();
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      scheduler: scheduler,
    );
    final original = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
    );
    await repository.add('task-1', original);

    final updated = FollowUp(
      id: 'follow-1',
      dateTime: original.dateTime,
      nextFollowUp: DateTime(2026, 8, 28, 10),
    );
    await coordinator.update('task-1', updated);

    expect(scheduler.rescheduleCalls, 1);
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.nextFollowUp, DateTime(2026, 8, 28, 10));
  });

  test('scheduler failure never rolls back a successful user write', () async {
    final scheduler = _FakeScheduler()..throwOnReschedule = true;
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      scheduler: scheduler,
    );
    final followUp = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
      nextFollowUp: DateTime(2026, 8, 27, 9),
    );

    await coordinator.add('task-1', followUp);

    expect(scheduler.rescheduleCalls, 1);
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.id, 'follow-1');
  });

  test('persistence failure does not call scheduler', () async {
    final scheduler = _FakeScheduler();
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      scheduler: scheduler,
    );

    expect(
      () => coordinator.add(
        'missing-task',
        FollowUp(id: 'follow-x', dateTime: DateTime(2026, 8, 26, 12)),
      ),
      throwsStateError,
    );
    expect(scheduler.rescheduleCalls, 0);
  });
}
