import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/system_calendar_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Dart bridge rejects FollowUp history IDs before any native write', () async {
    const channel = MethodChannel(SystemCalendarBridge.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async { calls.add(call); return 'event-1'; });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    final bridge = SystemCalendarBridge(channel: channel);
    await expectLater(bridge.createProviderEvent(
      reminderId: 'followup:task-1:history-1', calendarId: '7', title: 'History',
      start: DateTime(2026, 11, 3, 10), end: DateTime(2026, 11, 3, 11), allDay: false,
    ), throwsArgumentError);
    await expectLater(bridge.deleteProviderEvent(
      reminderId: 'task-followup:task-1:history-1', calendarId: '7', eventId: '12',
    ), throwsArgumentError);
    expect(calls, isEmpty);
  });

  test('Dart bridge passes selected Task identity through native write calls', () async {
    const channel = MethodChannel(SystemCalendarBridge.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == SystemCalendarBridge.createProviderEventMethod ? 'event-1' : true;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    final bridge = SystemCalendarBridge(channel: channel);
    const id = 'task-reminder-item:task-1:reminder-2';
    await bridge.createProviderEvent(reminderId: id, calendarId: '7', title: 'Task reminder',
      start: DateTime(2026, 11, 3, 10), end: DateTime(2026, 11, 3, 11), allDay: false);
    await bridge.updateProviderEvent(reminderId: id, calendarId: '7', eventId: 'event-1',
      title: 'Updated', start: DateTime(2026, 11, 3, 11), end: DateTime(2026, 11, 3, 12), allDay: false);
    await bridge.deleteProviderEvent(reminderId: id, calendarId: '7', eventId: 'event-1');
    expect(calls, hasLength(3));
    for (final call in calls) { expect((call.arguments as Map)['reminderId'], id); }
  });

  test('history IDs and completed Task reminders are never eligible', () {
    for (final id in ['followup:task-1:history-1','task-followup:task-1:history-1',
      'task-followup-action:task-1:history-1','unknown:task-1']) {
      expect(SystemCalendarBridge.isExportableTaskReminderId(id), isFalse);
    }
    expect(SystemCalendarBridge.isEligible(CalendarReminder(
      id: 'task-due:task-1', title: 'Completed', date: DateTime(2026, 11, 3), completed: true,
    )), isFalse);
  });
}
