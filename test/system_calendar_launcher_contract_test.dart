import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Calendar export exists only on Task-card swipe and Task Details', () {
    final launcher = File('lib/widgets/canonical_calendar_launcher.dart').readAsStringSync();
    final calendar = File('lib/calendar_page.dart').readAsStringSync();
    final detail = File('lib/task_detail_page.dart').readAsStringSync();
    final navigation = File('lib/widgets/arvin_primary_navigation.dart').readAsStringSync();

    expect(launcher, isNot(contains('SystemCalendarBridge().insert(selected)')));
    expect(launcher, isNot(contains('_exportToSystemCalendar')));
    expect(launcher, isNot(contains('_CalendarMoreAction.systemCalendar')));
    expect(launcher, isNot(contains('_CalendarMoreAction.retrySync')));
    expect(calendar, contains('case CalendarSwipeAction.sync:'));
    expect(calendar, isNot(contains('task-due-device-calendar-')));
    expect(detail, contains('task-detail-send-device-calendar'));
    expect(navigation, contains('ArvinPrimaryDestination.more'));
  });
}
