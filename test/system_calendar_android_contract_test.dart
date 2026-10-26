import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification settings bridge opens Android app notification settings', () {
    final activity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();
    final settings = File('lib/settings_page.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    expect(activity, contains('arvin/app_settings'));
    expect(activity, contains('openNotificationSettings'));
    expect(activity, contains('Settings.ACTION_APP_NOTIFICATION_SETTINGS'));
    expect(activity, contains('Settings.ACTION_APPLICATION_DETAILS_SETTINGS'));
    expect(settings, contains('notification-settings-title'));
    expect(settings, contains('areNotificationsEnabled'));
    expect(settings, contains('requestNotificationsPermission'));
    expect(main, contains('onPressed: _openPrimarySettings'));
  });

  test('manual system calendar export remains user-approved insert UI', () {
    final activity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();

    expect(activity, contains('Intent.ACTION_INSERT'));
    expect(activity, contains('arvin/system_calendar'));
    expect(activity, contains('insertSystemCalendarEvent'));
  });

  test('provider sync write access is explicit and separate from manual export', () {
    final activity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android.permission.WRITE_CALENDAR'));
    expect(activity, contains('requestCalendarWritePermission'));
    expect(activity, contains('createDeviceCalendarEvent'));
    expect(activity, contains('updateDeviceCalendarEvent'));
    expect(activity, contains('deleteDeviceCalendarEvent'));
    expect(activity, contains('CalendarContract.Events.CALENDAR_ID'));
  });
  test('startup calendar permission contract is wired to the native boundary', () {
    final activity = File('android/app/src/main/kotlin/com/example/arvin/MainActivity.kt').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final service = File('lib/services/startup_permission_service.dart').readAsStringSync();
    expect(activity, contains('requestCalendarAccessPermissions'));
    expect(activity, contains('CALENDAR_ACCESS_PERMISSION_REQUEST_CODE'));
    expect(activity, contains('READ_CALENDAR'));
    expect(activity, contains('WRITE_CALENDAR'));
    expect(main, contains('StartupPermissionService().requestOnStartup()'));
    expect(service, contains('requestCalendarAccessPermissions'));
    expect(service, contains('MethodChannel'));
  });
}
