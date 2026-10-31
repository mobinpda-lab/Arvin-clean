import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:arvin/services/follow_up_reminder_delivery_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stateService = FollowUpReminderDeliveryState();
  const deliveryService = FollowUpReminderDeliveryService();

  Task task(
    String taskId, {
    String followUpId = 'fu-1',
    DateTime? reminderDate,
    bool completed = false,
    List<TaskReminder> taskReminders = const <TaskReminder>[],
  }) =>
      Task(
        id: taskId,
        title: 'Task $taskId',
        completed: completed,
        taskReminders: taskReminders,
        followUps: [
          FollowUp(
            id: followUpId,
            dateTime: DateTime(2026, 8, 28, 10),
            reminderDate: reminderDate,
          ),
        ],
      );

  test('malformed metadata fails closed without touching canonical data', () {
    expect(stateService.decode(null), isEmpty);
    expect(stateService.decode(''), isEmpty);
    expect(stateService.decode('not-json'), isEmpty);
    expect(stateService.decode('["x"]'), isEmpty);
    expect(stateService.decode('{"a":1}'), isEmpty);
    expect(stateService.decode('{"":"value"}'), isEmpty);
  });

  test('encoding is deterministic and round-trips exact identities', () {
    final raw = stateService.encode({
      'b:fu': 'b:fu@2026-08-28T12:00:00.000',
      'a:fu': 'a:fu@2026-08-28T11:00:00.000',
    });

    expect(
      raw,
      '{"a:fu":"a:fu@2026-08-28T11:00:00.000","b:fu":"b:fu@2026-08-28T12:00:00.000"}',
    );
    expect(stateService.decode(raw), {
      'a:fu': 'a:fu@2026-08-28T11:00:00.000',
      'b:fu': 'b:fu@2026-08-28T12:00:00.000',
    });
  });

  test('markDelivered records canonical Task Reminder identity', () {
    final reminder = TaskReminder(
      id: 'r1',
      title: 'تماس',
      date: DateTime(2026, 8, 28, 11),
      sequence: 1,
    );
    final candidate = deliveryService.due(
      [task('one', taskReminders: [reminder])],
      now: DateTime(2026, 8, 28, 12),
    ).single;
    final result = stateService.markDelivered({}, candidate);
    expect(result, hasLength(1));
    expect(result[candidate.stableKey], deliveryService.deliveryIdentity(candidate));
  });

  test('reconcile removes legacy FollowUp delivery markers but keeps canonical Reminder markers', () {
    final canonical = task(
      'keep',
      taskReminders: [
        TaskReminder(
          id: 'r1',
          title: 'یادآور',
          date: DateTime(2026, 8, 28, 11),
          sequence: 1,
        ),
      ],
    );
    final state = {
      'task:keep:reminder:r1': 'canonical-id',
      'keep:fu-1': 'legacy-followup-id',
      'deleted:fu-1': 'deleted-id',
    };

    final result = stateService.reconcile(state, [canonical]);
    expect(result, {'task:keep:reminder:r1': 'canonical-id'});
    expect(state, hasLength(3));
  });

}
