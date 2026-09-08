import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar provider declares separate read and write permission boundaries', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(manifest, contains('android.permission.READ_CALENDAR'));
    expect(manifest, contains('android.permission.WRITE_CALENDAR'));
  });

  test('native bridge keeps read discovery bounded and write sync explicit', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();

    expect(mainActivity, contains('calendarReadPermissionGranted'));
    expect(mainActivity, contains('requestCalendarReadPermission'));
    expect(mainActivity, contains('listDeviceCalendars'));
    expect(mainActivity, contains('listDeviceCalendarEvents'));
    expect(mainActivity, contains('Manifest.permission.READ_CALENDAR'));
    expect(mainActivity, contains('CalendarContract.Calendars.CONTENT_URI'));
    expect(mainActivity, contains('CalendarContract.Instances.CONTENT_URI'));
    expect(mainActivity, contains('MAX_EVENT_QUERY_WINDOW_MILLIS'));
    expect(mainActivity, contains('MAX_EVENT_QUERY_CALENDARS'));

    expect(mainActivity, contains('calendarWritePermissionGranted'));
    expect(mainActivity, contains('requestCalendarWritePermission'));
    expect(mainActivity, contains('Manifest.permission.WRITE_CALENDAR'));
    expect(mainActivity, contains('createDeviceCalendarEvent'));
    expect(mainActivity, contains('updateDeviceCalendarEvent'));
    expect(mainActivity, contains('deleteDeviceCalendarEvent'));
    expect(mainActivity, contains('ContentUris.withAppendedId'));
    expect(mainActivity, contains('CalendarContract.Events.CALENDAR_ID'));
    expect(mainActivity, contains('onRequestPermissionsResult'));
  });
}
