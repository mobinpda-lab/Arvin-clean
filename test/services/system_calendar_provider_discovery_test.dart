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

  test('permission and provider discovery use the existing calendar channel',
      () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case SystemCalendarBridge.permissionStatusMethod:
          return true;
        case SystemCalendarBridge.requestPermissionMethod:
          return true;
        case SystemCalendarBridge.listCalendarsMethod:
          return <Map<String, Object?>>[
            <String, Object?>{
              'id': '12',
              'displayName': 'Personal',
              'accountName': 'user@example.com',
              'accountType': 'com.google',
              'ownerAccount': 'user@example.com',
              'accessLevel': 700,
              'visible': true,
              'syncEvents': true,
              'isPrimary': true,
            },
            <String, Object?>{
              'id': '21',
              'displayName': 'Samsung Calendar',
              'accountName': 'phone',
              'accountType': 'com.osp.app.signin',
              'accessLevel': 500,
              'visible': true,
              'syncEvents': true,
              'isPrimary': false,
            },
          ];
      }
      return null;
    });

    final bridge = SystemCalendarBridge(channel: channel);

    expect(await bridge.hasReadPermission(), isTrue);
    expect(await bridge.requestReadPermission(), isTrue);

    final calendars = await bridge.listDeviceCalendars();
    expect(calendars, hasLength(2));
    expect(calendars.first.id, '12');
    expect(calendars.first.displayName, 'Personal');
    expect(calendars.first.accountType, 'com.google');
    expect(calendars.first.isPrimary, isTrue);
    expect(calendars.last.displayName, 'Samsung Calendar');
    expect(calendars.last.isPrimary, isFalse);

    expect(
      calls,
      <String>[
        SystemCalendarBridge.permissionStatusMethod,
        SystemCalendarBridge.requestPermissionMethod,
        SystemCalendarBridge.listCalendarsMethod,
      ],
    );
  });

  test('permission denial returns an empty provider list without mutation',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == SystemCalendarBridge.permissionStatusMethod) {
        return false;
      }
      if (call.method == SystemCalendarBridge.requestPermissionMethod) {
        return false;
      }
      if (call.method == SystemCalendarBridge.listCalendarsMethod) {
        throw PlatformException(code: 'calendar_permission_denied');
      }
      return null;
    });

    final bridge = SystemCalendarBridge(channel: channel);
    expect(await bridge.hasReadPermission(), isFalse);
    expect(await bridge.requestReadPermission(), isFalse);
    expect(await bridge.listDeviceCalendars(), isEmpty);
  });

  test('provider parsing normalizes optional metadata and ignores blank ids',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != SystemCalendarBridge.listCalendarsMethod) return null;
      return <Object?>[
        <String, Object?>{
          'id': ' 44 ',
          'displayName': ' Work ',
          'accountName': ' ',
          'accessLevel': 200.0,
          'visible': true,
        },
        <String, Object?>{
          'id': ' ',
          'displayName': 'invalid',
        },
        'unexpected',
      ];
    });

    final calendars =
        await SystemCalendarBridge(channel: channel).listDeviceCalendars();
    expect(calendars, hasLength(1));
    expect(calendars.single.id, '44');
    expect(calendars.single.displayName, 'Work');
    expect(calendars.single.accountName, isNull);
    expect(calendars.single.accessLevel, 200);
    expect(calendars.single.visible, isTrue);
    expect(calendars.single.syncEvents, isFalse);
  });
}
