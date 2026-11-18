import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'automatic_follow_up_notification_service.dart';
import 'services/automatic_follow_up_service.dart';
import 'services/task_store.dart';

/// Executes automatic FollowUp delivery without depending on Flutter UI state.
///
/// Canonical Task/FollowUp data remains in [TaskStore]. This runner stores only
/// notification-delivery markers so the same latest FollowUp schedule is not
/// announced repeatedly by future background invocations.
class AutomaticFollowUpBackgroundRunner {
  const AutomaticFollowUpBackgroundRunner({
    TaskStore? taskStore,
    AutomaticFollowUpService? service,
    AutomaticFollowUpNotificationSink? notificationSink,
    DateTime Function()? now,
  })  : _taskStore = taskStore,
        _service = service,
        _notificationSink = notificationSink,
        _now = now;

  final TaskStore? _taskStore;
  final AutomaticFollowUpService? _service;
  final AutomaticFollowUpNotificationSink? _notificationSink;
  final DateTime Function()? _now;

  static const String notificationStateKey =
      'arvin.followup.notificationState';

  static Map<String, String> decodeDeliveryState(String? raw) {
    if (raw == null || raw.isEmpty) return <String, String>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<int> run() async {
    final store = _taskStore ?? TaskStore();
    final tasks = await store.load();
    final service = _service ?? const AutomaticFollowUpService();
    final candidates = service.dueCandidates(
      tasks,
      now: (_now ?? DateTime.now).call(),
    );

    final prefs = await SharedPreferences.getInstance();
    final state = decodeDeliveryState(prefs.getString(notificationStateKey));
    final liveTaskIds = tasks.map((task) => task.id).toSet();
    state.removeWhere((taskId, _) => !liveTaskIds.contains(taskId));

    final notifications =
        _notificationSink ?? AutomaticFollowUpNotificationService();
    var delivered = 0;

    for (final candidate in candidates) {
      if (state[candidate.taskId] == candidate.deliveryIdentity) continue;

      try {
        await notifications.showDue(candidate);
        state[candidate.taskId] = candidate.deliveryIdentity;
        delivered += 1;
      } catch (_) {
        // Delivery is retryable. Do not mark the candidate as notified when
        // the platform notification call fails.
      }
    }

    await prefs.setString(notificationStateKey, jsonEncode(state));
    return delivered;
  }
}
