import 'dart:convert';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_reschedule_apply_service.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const repository = FollowUpRepository();

  test('confirmed apply preserves metadata and uses canonical writer', () async {
    final original = FollowUp(
      id: 'follow-1',
      dateTime: DateTime(2026, 8, 27, 10),
      note: 'پیگیری قرارداد',
      result: 'در انتظار پاسخ',
      nextFollowUp: DateTime(2026, 8, 29, 9),
    );
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'task-1',
          'title': 'مشتری',
          'followUps': [original.toJson()],
        },
      ]),
    });
    var reminderRescheduleCalls = 0;
    final service = CalendarRescheduleApplyService(
      writer: FollowUpWriteCoordinator(
        repository: repository,
        reminderReschedule: () async {
          reminderRescheduleCalls++;
        },
      ),
    );
    final proposed = DateTime(2026, 8, 27, 14, 30);

    final updated = await service.applyConfirmed(
      target: FollowUpCalendarTarget(
        taskId: 'task-1',
        followUp: original,
      ),
      dateTime: proposed,
    );

    expect(updated, isNot(same(original)));
    expect(original.dateTime, DateTime(2026, 8, 27, 10));
    expect(updated.id, original.id);
    expect(updated.dateTime, proposed);
    expect(updated.note, original.note);
    expect(updated.result, original.result);
    expect(updated.nextFollowUp, original.nextFollowUp);
    expect(reminderRescheduleCalls, 1);

    final saved = await repository.loadForTask('task-1');
    expect(saved.single.id, original.id);
    expect(saved.single.dateTime, proposed);
    expect(saved.single.note, original.note);
    expect(saved.single.result, original.result);
    expect(saved.single.nextFollowUp, original.nextFollowUp);
  });

  test('persistence failure does not request alarm reschedule', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'task-1',
          'title': 'مشتری',
          'followUps': <Object>[],
        },
      ]),
    });
    var reminderRescheduleCalls = 0;
    final service = CalendarRescheduleApplyService(
      writer: FollowUpWriteCoordinator(
        repository: repository,
        reminderReschedule: () async {
          reminderRescheduleCalls++;
        },
      ),
    );

    expect(
      () => service.applyConfirmed(
        target: FollowUpCalendarTarget(
          taskId: 'missing-task',
          followUp: FollowUp(
            id: 'follow-x',
            dateTime: DateTime(2026, 8, 27, 10),
          ),
        ),
        dateTime: DateTime(2026, 8, 27, 12),
      ),
      throwsStateError,
    );
    expect(reminderRescheduleCalls, 0);
  });
}
