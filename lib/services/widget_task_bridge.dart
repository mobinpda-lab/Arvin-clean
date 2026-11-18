import 'package:flutter/services.dart';

typedef WidgetTaskSelectionHandler = Future<void> Function(String taskId);

/// Flutter side of the Android Widget navigation boundary.
///
/// Only a canonical Task id crosses this channel. The Task itself is always
/// reloaded from Arvin's existing canonical storage.
class WidgetTaskBridge {
  WidgetTaskBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'arvin/widget_task';
  static const consumeMethod = 'consumeWidgetTaskId';
  static const selectedMethod = 'widgetTaskSelected';

  final MethodChannel _channel;

  Future<String?> consumeInitialTaskId() async {
    try {
      final taskId = await _channel.invokeMethod<String>(consumeMethod);
      final normalized = taskId?.trim();
      return normalized == null || normalized.isEmpty ? null : normalized;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  void listen(WidgetTaskSelectionHandler onSelected) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != selectedMethod || call.arguments is! String) return;
      final taskId = (call.arguments as String).trim();
      if (taskId.isNotEmpty) await onSelected(taskId);
    });
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
