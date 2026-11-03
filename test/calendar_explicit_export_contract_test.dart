import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only Calendar Task swipe and Task Details expose export UI', () {
    final launcher = File('lib/widgets/canonical_calendar_launcher.dart').readAsStringSync();
    final calendar = File('lib/calendar_page.dart').readAsStringSync();
    final detail = File('lib/task_detail_page.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final settings = File('lib/calendar_integration_settings_page.dart').readAsStringSync();
    expect(calendar, contains('case CalendarSwipeAction.sync:'));
    expect(calendar, contains('_isTaskRecord'));
    expect(calendar, isNot(contains('task-due-device-calendar-')));
    expect(launcher, isNot(contains('_exportToSystemCalendar')));
    expect(launcher, isNot(contains('_CalendarMoreAction.systemCalendar')));
    expect(launcher, isNot(contains('_CalendarMoreAction.retrySync')));
    expect(launcher, contains('_CalendarMoreAction.nextAction'));
    expect(detail, contains('task-detail-send-device-calendar'));
    expect(settings, contains('calendar-explicit-export-policy'));
    expect(settings, isNot(contains('calendar-auto-sync')));
    expect(settings, isNot(contains('calendar-sync-followups')));
    expect(settings, isNot(contains('calendar-sync-followup-reminders')));
    expect(settings, isNot(contains('calendar-delete-linked')));
    expect(main, contains('onRegisterTaskToDeviceCalendar: _registerTaskInDeviceCalendar'));
    expect(main, contains('onRegisterTaskToDeviceCalendar: _registerTaskFromDetails'));
  });
  test('normal Task save, capture, edit and completion contain no outbound sync', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, isNot(contains('CalendarOutboundSyncService')));
    expect(main, isNot(contains('calendarOutboundSyncService')));
    expect(main, isNot(contains('_syncCalendarAfterQuickCapture')));
    expect(main, isNot(contains('_syncCalendarAfterDetailTaskUpdate')));
    expect(main, isNot(contains('_syncLinkedCalendarAfterTaskEdit')));
    expect(main, isNot(contains('_retryCalendarSync')));
  });
  test('one-item plan receives only the selected reminder link', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('where((link) => link.reminderId == reminder.id)'));
    expect(main, contains('links: selectedLinks'));
    expect(main, contains('final alreadyLinked = selectedLinks.isNotEmpty;'));
  });
  test('inbound mirror reconciliation is non-mutating and imports remain local', () {
    final inbound = File('lib/services/calendar_inbound_sync_service.dart').readAsStringSync();
    final official = File('lib/official_calendar_page.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    expect(inbound, contains('Deliberate no-op'));
    expect(inbound, isNot(contains('TaskStore')));
    expect(inbound, isNot(contains('listDeviceCalendarEvents')));
    expect(official, contains('listDeviceCalendarEvents'));
    expect(main, contains('registerImportedEvent('));
    expect(main, contains('taskStore.save'));
  });
  test('Android validates selected Task identity at every write boundary', () {
    final native = File('android/app/src/main/kotlin/com/example/arvin/MainActivity.kt').readAsStringSync();
    expect(native, contains('private fun isExportableTaskReminderId'));
    expect(native, contains('"task-due:"'));
    expect(native, contains('"task-reminder-item:"'));
    expect(native, contains('"task-reminder:"'));
    expect(native, contains('"task-recurrence:"'));
    expect(native, contains('"invalid_reminder_id"'));
    expect('isExportableTaskReminderId(reminderId)'.allMatches(native).length, greaterThanOrEqualTo(4));
  });
}
