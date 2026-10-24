import 'package:arvin/models/task.dart';
import 'package:arvin/services/follow_up_reminder_delivery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FollowUpReminderDeliveryService();
  final now = DateTime(2026, 8, 28, 18, 15);

  Task task(String id, {bool completed = false, bool archived = false, bool trashed = false, List<TaskReminder> reminders = const []}) =>
      Task(id: id, title: 'Task $id', completed: completed, archived: archived, trashed: trashed, taskReminders: reminders);

  test('delivers overdue and exact-now canonical Reminders but not future ones', () {
    final result = service.due([
      task('one', reminders: [
        TaskReminder(id: 'past', title: 'گذشته', date: now.subtract(const Duration(minutes: 5)), sequence: 1),
        TaskReminder(id: 'now', title: 'تماس', date: now, sequence: 2),
        TaskReminder(id: 'future', title: 'آینده', date: now.add(const Duration(minutes: 1)), sequence: 3),
      ]),
    ], now: now);
    expect(result.map((item) => item.taskReminderId), ['past', 'now']);
    expect(result.last.label, 'تماس');
  });

  test('exact delivered identity is skipped while changed time is new work', () {
    final originalAt = now.subtract(const Duration(minutes: 10));
    final tasks = [task('one', reminders: [TaskReminder(id: 'r1', title: 'یادآوری', date: originalAt, sequence: 1)])];
    final first = service.due(tasks, now: now).single;
    final delivered = service.deliveryIdentity(first);
    expect(service.due(tasks, now: now, deliveredIdentities: {delivered}), isEmpty);
    final changed = task('one', reminders: [
      TaskReminder(id: 'r1', title: 'یادآوری', date: now.subtract(const Duration(minutes: 2)), sequence: 1),
    ]);
    final changedResult = service.due([changed], now: now, deliveredIdentities: {delivered});
    expect(changedResult, hasLength(1));
    expect(service.deliveryIdentity(changedResult.single), isNot(delivered));
  });

  test('completed archived and trashed Tasks never produce notifications', () {
    final at = now.subtract(const Duration(minutes: 1));
    final result = service.due([
      task('done', completed: true, reminders: [TaskReminder(id: 'a', title: 'x', date: at, sequence: 1)]),
      task('archive', archived: true, reminders: [TaskReminder(id: 'b', title: 'x', date: at, sequence: 1)]),
      task('trash', trashed: true, reminders: [TaskReminder(id: 'c', title: 'x', date: at, sequence: 1)]),
    ], now: now);
    expect(result, isEmpty);
  });

  test('same-time Reminder siblings keep independent delivery identities', () {
    final at = now.subtract(const Duration(minutes: 1));
    final result = service.due([
      task('one', reminders: [
        TaskReminder(id: 'r1', title: 'اول', date: at, sequence: 1),
        TaskReminder(id: 'r2', title: 'دوم', date: at, sequence: 2),
      ]),
    ], now: now);
    expect(result.map((item) => item.stableKey), ['task:one:reminder:r1', 'task:one:reminder:r2']);
  });

  test('migrated legacy Task Reminder retains its single stable delivery key', () {
    final at = DateTime(2026, 8, 28, 18);
    final migrated = Task.fromJson({'id': 'one', 'title': 'قدیمی', 'reminderDate': at.toIso8601String()});
    final result = service.due([migrated], now: now);
    expect(result, hasLength(1));
    expect(result.single.stableKey, 'task:one');
  });
}
