import 'package:arvin/services/system_calendar_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(SystemCalendarBridge.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('selected calendar events use bounded existing provider channel', () async {
    MethodCall? captured;
    messenger.setMockMethodCallHandler(channel, (call) async {
      captured = call;
      if (call.method != SystemCalendarBridge.listEventsMethod) return null;
      return <Map<String, Object?>>[
        <String, Object?>{
          'instanceId': '9001',
          'eventId': '501',
          'calendarId': '12',
          'calendarName': 'Personal',
          'title': 'Meeting',
          'description': 'Synthetic test event',
          'startMillis': 1788170400000,
          'endMillis': 1788174000000,
          'allDay': false,
          'eventTimezone': 'Asia/Tehran',
          'recurrenceRule': 'FREQ=WEEKLY',
        },
      ];
    });

    final start = DateTime(2026, 8, 31);
    final end = start.add(const Duration(days: 7));
    final events = await SystemCalendarBridge(channel: channel)
        .listDeviceCalendarEvents(
          calendarIds: const <String>[' 12 ', '12'],
          start: start,
          end: end,
        );

    expect(captured?.method, SystemCalendarBridge.listEventsMethod);
    final arguments = Map<Object?, Object?>.from(captured?.arguments as Map);
    expect(arguments['calendarIds'], <String>['12']);
    expect(arguments['startMillis'], start.millisecondsSinceEpoch);
    expect(arguments['endMillis'], end.millisecondsSinceEpoch);

    expect(events, hasLength(1));
    final event = events.single;
    expect(event.instanceId, '9001');
    expect(event.eventId, '501');
    expect(event.calendarId, '12');
    expect(event.calendarName, 'Personal');
    expect(event.title, 'Meeting');
    expect(event.description, 'Synthetic test event');
    expect(event.allDay, isFalse);
    expect(event.eventTimezone, 'Asia/Tehran');
    expect(event.recurrenceRule, 'FREQ=WEEKLY');
  });

  test('empty calendar selection performs no platform event query', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls += 1;
      return null;
    });

    final events = await SystemCalendarBridge(channel: channel)
        .listDeviceCalendarEvents(
          calendarIds: const <String>[' ', ''],
          start: DateTime(2026, 8, 31),
          end: DateTime(2026, 9, 1),
        );

    expect(events, isEmpty);
    expect(calls, 0);
  });

  test('event query rejects unbounded range before platform access', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls += 1;
      return null;
    });

    expect(
      () => SystemCalendarBridge(channel: channel).listDeviceCalendarEvents(
        calendarIds: const <String>['12'],
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 5, 1),
      ),
      throwsArgumentError,
    );
    expect(calls, 0);
  });

  test('permission denial fails read-only projection closed', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == SystemCalendarBridge.listEventsMethod) {
        throw PlatformException(code: 'calendar_permission_denied');
      }
      return null;
    });

    final events = await SystemCalendarBridge(channel: channel)
        .listDeviceCalendarEvents(
          calendarIds: const <String>['12'],
          start: DateTime(2026, 8, 31),
          end: DateTime(2026, 9, 1),
        );
    expect(events, isEmpty);
  });

  test('malformed provider event rows are ignored safely', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != SystemCalendarBridge.listEventsMethod) return null;
      return <Object?>[
        <String, Object?>{
          'instanceId': '1',
          'eventId': '2',
          'calendarId': '12',
          'title': 'bad dates',
          'startMillis': 2000,
          'endMillis': 1000,
        },
        <String, Object?>{
          'instanceId': '3',
          'eventId': '4',
          'calendarId': '12',
          'title': 'ok',
          'startMillis': 1000,
          'endMillis': 2000,
          'allDay': true,
        },
      ];
    });

    final events = await SystemCalendarBridge(channel: channel)
        .listDeviceCalendarEvents(
          calendarIds: const <String>['12'],
          start: DateTime(2026, 8, 31),
          end: DateTime(2026, 9, 1),
        );

    expect(events, hasLength(1));
    expect(events.single.instanceId, '3');
    expect(events.single.allDay, isTrue);
  });
}
