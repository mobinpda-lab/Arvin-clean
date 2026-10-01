import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
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
    final activity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final service =
        File('lib/services/startup_permission_service.dart').readAsStringSync();

    expect(activity, contains('requestCalendarAccessPermissions'));
    expect(activity, contains('CALENDAR_ACCESS_PERMISSION_REQUEST_CODE'));
    expect(activity, contains('READ_CALENDAR'));
    expect(activity, contains('WRITE_CALENDAR'));
    expect(main, contains('StartupPermissionService().requestOnStartup()'));
    expect(service, contains('requestCalendarAccessPermissions'));
    expect(service, contains('MethodChannel'));
  });
}
