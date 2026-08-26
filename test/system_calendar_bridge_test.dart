import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/calendar_page.dart';
import 'package:arvin/services/system_calendar_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only active canonical FollowUp reminders are export eligible', () {
    final followUp = CalendarReminder(
      id: 'followup:task-1:fu-1',
      title: 'پیگیری مشتری',
      date: DateTime(2026, 8, 26, 10),
    );
    final official = CalendarReminder(
      id: 'prayer:tehran:2026-08-26:fajr',
      title: 'اذان صبح',
      date: DateTime(2026, 8, 26, 4),
    );
    final completed = CalendarReminder(
      id: 'followup:task-1:fu-2',
      title: 'انجام شده',
      date: DateTime(2026, 8, 26, 11),
      completed: true,
    );

    expect(SystemCalendarBridge.isEligible(followUp), isTrue);
    expect(SystemCalendarBridge.isEligible(official), isFalse);
    expect(SystemCalendarBridge.isEligible(completed), isFalse);
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
      id: 'followup:task-1:fu-1',
      title: 'پیگیری مشتری',
      date: DateTime(2026, 8, 26, 10, 15),
    );

    expect(await SystemCalendarBridge(channel: channel).insert(reminder), isTrue);
    expect(calls, hasLength(1));
    expect(calls.single.method, SystemCalendarBridge.insertMethod);
    expect(calls.single.arguments, isA<Map<Object?, Object?>>());
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
