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
  }) =>
      Task(
        id: taskId,
        title: 'Task $taskId',
        completed: completed,
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

  test('markDelivered records exact timestamp and replaces old schedule', () {
    final oldTask = task(
      'one',
      reminderDate: DateTime(2026, 8, 28, 11),
    );
    final oldCandidate = deliveryService
        .due([oldTask], now: DateTime(2026, 8, 28, 12))
        .single;
    final first = stateService.markDelivered({}, oldCandidate);

    final changedTask = task(
      'one',
      reminderDate: DateTime(2026, 8, 28, 11, 30),
    );
    final changedCandidate = deliveryService
        .due([changedTask], now: DateTime(2026, 8, 28, 12))
        .single;
    final second = stateService.markDelivered(first, changedCandidate);

    expect(second, hasLength(1));
    expect(
      second[changedCandidate.stableKey],
      deliveryService.deliveryIdentity(changedCandidate),
    );
    expect(
      stateService.deliveredIdentities(second),
      {deliveryService.deliveryIdentity(changedCandidate)},
    );
  });

  test('reconcile removes deleted or cleared reminders only', () {
    final keep = task(
      'keep',
      reminderDate: DateTime(2026, 8, 28, 11),
      completed: true,
    );
    final cleared = task('cleared', reminderDate: null);
    final state = {
      'keep:fu-1': 'keep:fu-1@2026-08-28T11:00:00.000',
      'cleared:fu-1': 'cleared:fu-1@2026-08-28T11:00:00.000',
      'deleted:fu-1': 'deleted:fu-1@2026-08-28T11:00:00.000',
    };

    final result = stateService.reconcile(state, [keep, cleared]);

    expect(result, {
      'keep:fu-1': 'keep:fu-1@2026-08-28T11:00:00.000',
    });
    expect(state, hasLength(3));
  });
}
