import 'dart:convert';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    var reminderRescheduleCalls = 0;
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      reminderReschedule: () async {
        reminderRescheduleCalls++;
      },
    );
    final followUp = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
      nextFollowUp: DateTime(2026, 8, 27, 9),
    );

    await coordinator.add('task-1', followUp);

    expect(reminderRescheduleCalls, 1);
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.id, 'follow-1');
  });

  test('successful update requests reschedule', () async {
    var reminderRescheduleCalls = 0;
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      reminderReschedule: () async {
        reminderRescheduleCalls++;
      },
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

    expect(reminderRescheduleCalls, 1);
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.nextFollowUp, DateTime(2026, 8, 28, 10));
  });

  test('reminder scheduling failure never rolls back a successful user write', () async {
    var reminderRescheduleCalls = 0;
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      reminderReschedule: () async {
        reminderRescheduleCalls++;
        throw StateError('platform unavailable');
      },
    );
    final followUp = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
      nextFollowUp: DateTime(2026, 8, 27, 9),
    );

    await coordinator.add('task-1', followUp);

    expect(reminderRescheduleCalls, 1);
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.id, 'follow-1');
  });

  test('persistence failure does not call reminder rescheduling', () async {
    var reminderRescheduleCalls = 0;
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      reminderReschedule: () async {
        reminderRescheduleCalls++;
      },
    );

    expect(
      () => coordinator.add(
        'missing-task',
        FollowUp(id: 'follow-x', dateTime: DateTime(2026, 8, 26, 12)),
      ),
      throwsStateError,
    );
    expect(reminderRescheduleCalls, 0);
  });
}
