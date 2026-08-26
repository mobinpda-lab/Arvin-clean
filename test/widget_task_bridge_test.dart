import 'package:arvin/services/widget_task_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(WidgetTaskBridge.channelName);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('consumes canonical Task id from Android intent bridge', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, WidgetTaskBridge.consumeMethod);
      return 'task-42';
    });

    final bridge = WidgetTaskBridge(channel: channel);
    expect(await bridge.consumeInitialTaskId(), 'task-42');
  });

  test('empty or unavailable native task id is ignored safely', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => '   ');
    final bridge = WidgetTaskBridge(channel: channel);
    expect(await bridge.consumeInitialTaskId(), isNull);
  });
}
