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
        {'id': 'task-1', 'title': 'مشتری', 'followUps': <Object>[]},
      ]),
    });
  });

  test('adding historical Follow-up persists without scheduling legacy dates', () async {
    const coordinator = FollowUpWriteCoordinator(repository: repository);
    final followUp = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
      note: 'تماس ثبت شد',
      nextFollowUp: DateTime(2026, 8, 27, 9),
      reminderDate: DateTime(2026, 8, 27, 10),
    );
    await coordinator.add('task-1', followUp);
    final saved = await repository.loadForTask('task-1');
    expect(saved, hasLength(1));
    expect(saved.single.id, 'follow-1');
    expect(saved.single.note, 'تماس ثبت شد');
    expect(saved.single.nextFollowUp, followUp.nextFollowUp);
    expect(saved.single.reminderDate, followUp.reminderDate);
  });

  test('updating historical Follow-up does not depend on a scheduler', () async {
    const coordinator = FollowUpWriteCoordinator(repository: repository);
    final original = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 26, 12),
      note: 'تماس اولیه',
    );
    await repository.add('task-1', original);
    await coordinator.update(
      'task-1',
      FollowUp(
        id: original.id,
        dateTime: original.dateTime,
        title: original.title,
        note: 'تماس تکمیل شد',
        result: original.result,
        reminderDate: original.reminderDate,
        nextFollowUp: original.nextFollowUp,
        completed: original.completed,
        waitingForResponse: original.waitingForResponse,
        personIds: original.personIds,
      ),
    );
    final saved = await repository.loadForTask('task-1');
    expect(saved.single.id, 'follow-1');
    expect(saved.single.note, 'تماس تکمیل شد');
  });

  test('persistence failure is surfaced without scheduler side effects', () async {
    const coordinator = FollowUpWriteCoordinator(repository: repository);
    expect(
      () => coordinator.add(
        'missing-task',
        FollowUp(id: 'follow-x', dateTime: DateTime(2026, 8, 26, 12)),
      ),
      throwsStateError,
    );
  });
}
