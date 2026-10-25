import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:arvin/services/follow_up_reminder_delivery_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stateService = FollowUpReminderDeliveryState();
  const deliveryService = FollowUpReminderDeliveryService();
  Task task(String id, {List<TaskReminder> reminders = const [], bool completed = false}) =>
      Task(id: id, title: 'Task $id', completed: completed, taskReminders: reminders);

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
      'b:r1': 'b:r1@2026-08-28T12:00:00.000',
      'a:r1': 'a:r1@2026-08-28T11:00:00.000',
    });
    expect(raw, '{"a:r1":"a:r1@2026-08-28T11:00:00.000","b:r1":"b:r1@2026-08-28T12:00:00.000"}');
    expect(stateService.decode(raw), {
      'a:r1': 'a:r1@2026-08-28T11:00:00.000',
      'b:r1': 'b:r1@2026-08-28T12:00:00.000',
    });
  });

  test('markDelivered records exact timestamp and replaces old schedule', () {
    final oldAt = DateTime(2026, 8, 28, 11);
    final oldCandidate = deliveryService.due([
      task('one', reminders: [TaskReminder(id: 'r1', title: 'x', date: oldAt, sequence: 1)]),
    ], now: DateTime(2026, 8, 28, 12)).single;
    final first = stateService.markDelivered({}, oldCandidate);
    final changedAt = DateTime(2026, 8, 28, 11, 30);
    final changedCandidate = deliveryService.due([
      task('one', reminders: [TaskReminder(id: 'r1', title: 'x', date: changedAt, sequence: 1)]),
    ], now: DateTime(2026, 8, 28, 12)).single;
    final second = stateService.markDelivered(first, changedCandidate);
    expect(second, hasLength(1));
    expect(second[changedCandidate.stableKey], deliveryService.deliveryIdentity(changedCandidate));
    expect(stateService.deliveredIdentities(second), {deliveryService.deliveryIdentity(changedCandidate)});
  });

  test('reconcile removes deleted Reminder keys but retains completed Task keys', () {
    final keep = task('keep', completed: true, reminders: [
      TaskReminder(id: 'r1', title: 'x', date: DateTime(2026, 8, 28, 11), sequence: 1),
    ]);
    final cleared = task('cleared');
    final state = {
      'task:keep:reminder:r1': 'task:keep:reminder:r1@2026-08-28T11:00:00.000',
      'task:cleared:reminder:r2': 'task:cleared:reminder:r2@2026-08-28T11:00:00.000',
      'task:deleted:reminder:r3': 'task:deleted:reminder:r3@2026-08-28T11:00:00.000',
    };
    final result = stateService.reconcile(state, [keep, cleared]);
    expect(result, {'task:keep:reminder:r1': 'task:keep:reminder:r1@2026-08-28T11:00:00.000'});
    expect(state, hasLength(3));
  });
}
