import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android system calendar bridge uses insert UI without write permission', () {
    final activity = File(
      'android/app/src/main/kotlin/com/example/arvin/MainActivity.kt',
    ).readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(activity, contains('CalendarContract.Events.CONTENT_URI'));
    expect(activity, contains('Intent.ACTION_INSERT'));
    expect(activity, contains('arvin/system_calendar'));
    expect(activity, contains('insertSystemCalendarEvent'));
    expect(manifest, isNot(contains('android.permission.WRITE_CALENDAR')));
  });
}
