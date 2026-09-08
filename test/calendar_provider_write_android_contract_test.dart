import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android Calendar Provider write boundary is explicit and bounded', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();

    expect(
      manifest,
      contains('android.permission.WRITE_CALENDAR'),
    );
    expect(activity, contains('calendarWritePermissionGranted'));
    expect(activity, contains('requestCalendarWritePermission'));
    expect(activity, contains('createDeviceCalendarEvent'));
    expect(activity, contains('updateDeviceCalendarEvent'));
    expect(activity, contains('deleteDeviceCalendarEvent'));
    expect(activity, contains('CalendarContract.Events.CALENDAR_ID'));
    expect(activity, contains('ContentUris.withAppendedId'));
    expect(activity, contains('updated == 1'));
    expect(activity, contains('deleted == 1'));
  });
}
