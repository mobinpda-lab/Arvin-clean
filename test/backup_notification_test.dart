import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/backup_background_runner.dart';
import 'package:arvin/backup_notification_service.dart';

class _FakeNotificationSink implements BackupNotificationSink {
  int successCount = 0;
  int failureCount = 0;
  String? successFileName;
  String? failureMessage;

  @override
  Future<void> showSuccess(String fileName) async {
    successCount++;
    successFileName = fileName;
  }

  @override
  Future<void> showFailure(String message) async {
    failureCount++;
    failureMessage = message;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('invalid background backup configuration reports failure', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(BackupBackgroundRunner.directoryUriKey, 'content://backup');
    await prefs.setString(BackupBackgroundRunner.payloadKey, '{invalid');

    final notifications = _FakeNotificationSink();
    final result = await BackupBackgroundRunner(
      notificationSink: notifications,
    ).run();

    expect(result, isFalse);
    expect(notifications.failureCount, 1);
    expect(notifications.failureMessage, contains('پشتیبان‌گیری'));
    expect(notifications.successCount, 0);
  });

  test('missing background configuration does not send a notification', () async {
    final notifications = _FakeNotificationSink();

    final result = await BackupBackgroundRunner(
      notificationSink: notifications,
    ).run();

    expect(result, isFalse);
    expect(notifications.successCount, 0);
    expect(notifications.failureCount, 0);
  });
}
