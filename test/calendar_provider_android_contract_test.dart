import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar discovery remains read-only at Android permission boundary', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(
      manifest,
      contains('android.permission.READ_CALENDAR'),
    );
    expect(
      manifest,
      isNot(contains('android.permission.WRITE_CALENDAR')),
    );
  });

  test('native bridge exposes permission request and provider enumeration', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();

    expect(mainActivity, contains('calendarReadPermissionGranted'));
    expect(mainActivity, contains('requestCalendarReadPermission'));
    expect(mainActivity, contains('listDeviceCalendars'));
    expect(mainActivity, contains('Manifest.permission.READ_CALENDAR'));
    expect(mainActivity, contains('CalendarContract.Calendars.CONTENT_URI'));
    expect(mainActivity, contains('CalendarContract.Calendars.ACCOUNT_TYPE'));
    expect(mainActivity, contains('CalendarContract.Calendars.IS_PRIMARY'));
    expect(mainActivity, contains('onRequestPermissionsResult'));
    expect(mainActivity, isNot(contains('Manifest.permission.WRITE_CALENDAR')));
  });
}
