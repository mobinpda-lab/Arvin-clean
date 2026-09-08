import 'package:shared_preferences/shared_preferences.dart';

import 'follow_up_reminder_notification_service.dart';
import 'services/follow_up_reminder_delivery_service.dart';
import 'services/follow_up_reminder_delivery_state.dart';
import 'services/task_store.dart';

class FollowUpReminderBackgroundRunner {
  const FollowUpReminderBackgroundRunner({
    TaskStore? taskStore,
    FollowUpReminderDeliveryService? deliveryService,
    FollowUpReminderDeliveryState? deliveryState,
    FollowUpReminderNotificationSink? notificationSink,
    DateTime Function()? now,
  })  : _taskStore = taskStore,
        _deliveryService = deliveryService,
        _deliveryState = deliveryState,
        _notificationSink = notificationSink,
        _now = now;

  final TaskStore? _taskStore;
  final FollowUpReminderDeliveryService? _deliveryService;
  final FollowUpReminderDeliveryState? _deliveryState;
  final FollowUpReminderNotificationSink? _notificationSink;
  final DateTime Function()? _now;

  Future<int> run() async {
    final store = _taskStore ?? TaskStore();
    final tasks = await store.load();
    final stateService =
        _deliveryState ?? const FollowUpReminderDeliveryState();
    final service =
        _deliveryService ?? const FollowUpReminderDeliveryService();
    final prefs = await SharedPreferences.getInstance();

    var state = stateService.decode(
      prefs.getString(FollowUpReminderDeliveryState.storageKey),
    );
    state = stateService.reconcile(state, tasks);

    final due = service.due(
      tasks,
      now: (_now ?? DateTime.now).call(),
      deliveredIdentities: stateService.deliveredIdentities(state),
    );
    final notifications =
        _notificationSink ?? FollowUpReminderNotificationService();

    var delivered = 0;
    for (final candidate in due) {
      try {
        await notifications.showDue(candidate);
        state = stateService.markDelivered(state, candidate);
        await prefs.setString(
          FollowUpReminderDeliveryState.storageKey,
          stateService.encode(state),
        );
        delivered++;
      } catch (_) {
        // Keep this reminder retryable. Never record delivery after failure.
      }
    }

    await prefs.setString(
      FollowUpReminderDeliveryState.storageKey,
      stateService.encode(state),
    );
    return delivered;
  }
}
