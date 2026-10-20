import 'package:arvin/services/reminder_notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification payload preserves parent Task and Follow-up identity', () {
    final encoded = ReminderNotificationPayload.encode(
      taskId: 'task-42',
      followUpId: 'follow-up-9',
    );

    final decoded = ReminderNotificationPayload.decode(encoded);

    expect(decoded?.taskId, 'task-42');
    expect(decoded?.followUpId, 'follow-up-9');
  });

  test('Task reminder payload has no Follow-up identity', () {
    final decoded = ReminderNotificationPayload.decode(
      ReminderNotificationPayload.encode(taskId: 'task-42'),
    );

    expect(decoded?.taskId, 'task-42');
    expect(decoded?.followUpId, isNull);
  });

  test('legacy Task-ID-only notification payload remains compatible', () {
    final decoded =
        ReminderNotificationPayload.decode('legacy-task-42');

    expect(decoded?.taskId, 'legacy-task-42');
    expect(decoded?.followUpId, isNull);
  });

  test('empty notification payload is ignored', () {
    expect(ReminderNotificationPayload.decode(null), isNull);
    expect(ReminderNotificationPayload.decode('  '), isNull);
  });
}
