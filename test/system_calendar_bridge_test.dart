import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/system_calendar_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only active canonical Task and TaskReminder items are export eligible', () {
    final due = CalendarReminder(id: 'task-due:task-1', title: 'موعد کار', date: DateTime(2026, 8, 26, 10));
    final followUpHistory = CalendarReminder(id: 'followup:task-1:fu-1', title: 'تاریخچه', date: DateTime(2026, 8, 26, 10));
    final taskFollowUpHistory = CalendarReminder(id: 'task-followup:task-1:fu-2', title: 'تاریخچه', date: DateTime(2026, 8, 26, 11));
    final official = CalendarReminder(id: 'prayer:tehran:2026-08-26:fajr', title: 'اذان صبح', date: DateTime(2026, 8, 26, 4));
    final completed = CalendarReminder(id: 'task-due:task-2', title: 'انجام شده', date: DateTime(2026, 8, 26, 11), completed: true);
    expect(SystemCalendarBridge.isEligible(due), isTrue);
    expect(SystemCalendarBridge.isEligible(followUpHistory), isFalse);
    expect(SystemCalendarBridge.isEligible(taskFollowUpHistory), isFalse);
    expect(SystemCalendarBridge.isEligible(official), isFalse);
    expect(SystemCalendarBridge.isEligible(completed), isFalse);
  });

  test('linked provider identity verification uses the native bridge and fails closed', () async {
    const channel = MethodChannel(SystemCalendarBridge.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == SystemCalendarBridge.verifyProviderEventIdentityMethod) {
        return true;
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final bridge = SystemCalendarBridge();
    expect(
      await bridge.verifyProviderEventIdentity(calendarId: '42', eventId: '7'),
      isTrue,
    );
    expect(calls.single.method, SystemCalendarBridge.verifyProviderEventIdentityMethod);
    expect(calls.single.arguments, {'calendarId': '42', 'eventId': '7'});
    expect(
      await bridge.verifyProviderEventIdentity(calendarId: '', eventId: '7'),
      isFalse,
    );
  });

  test('eligible reminder is sent through the existing platform boundary', () async {
    const channel = MethodChannel(SystemCalendarBridge.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final reminder = CalendarReminder(
      id: 'task-due:task-1',
      title: 'موعد کار',
      date: DateTime(2026, 8, 26, 10, 15),
    );

    expect(await SystemCalendarBridge(channel: channel).insert(reminder), isTrue);
    expect(calls, hasLength(1));
    expect(calls.single.method, SystemCalendarBridge.insertMethod);
    expect(calls.single.arguments, isA<Map<Object?, Object?>>());
    expect((calls.single.arguments as Map<Object?, Object?>)['reminderId'], 'task-due:task-1');
  });

  test('opens the selected phone-owned event in its native calendar editor', () async {
    const channel = MethodChannel(SystemCalendarBridge.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    expect(
      await SystemCalendarBridge(channel: channel).openDeviceCalendarEvent(
        calendarId: 'calendar-7',
        eventId: 'event-1',
      ),
      isTrue,
    );
    expect(calls, hasLength(1));
    expect(calls.single.method, SystemCalendarBridge.openProviderEventMethod);
    expect(calls.single.arguments, <String, Object?>{
      'calendarId': 'calendar-7',
      'eventId': 'event-1',
    });
  });

  test('ineligible reminder never crosses the native boundary', () async {
    const channel = MethodChannel(SystemCalendarBridge.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final official = CalendarReminder(
      id: 'holiday:1405:01:01',
      title: 'تعطیلی رسمی',
      date: DateTime(2026, 3, 21),
      isAllDay: true,
    );

    expect(await SystemCalendarBridge(channel: channel).insert(official), isFalse);
    expect(calls, isEmpty);
  });
}
