import 'dart:convert';

import '../models/task.dart';
import 'follow_up_reminder_delivery_service.dart';
import 'follow_up_reminder_projection.dart';

/// Metadata-only delivery state for independent FollowUp reminders.
///
/// Canonical reminder data always remains on Task/FollowUp in TaskStore. This
/// state only remembers which exact reminder timestamp was successfully shown
/// so retries remain idempotent without introducing a second domain store.
class FollowUpReminderDeliveryState {
  const FollowUpReminderDeliveryState({
    this.deliveryService = const FollowUpReminderDeliveryService(),
  });

  final FollowUpReminderDeliveryService deliveryService;

  static const String storageKey =
      'arvin.followup.reminderNotificationState';

  Map<String, String> decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <String, String>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};

      final result = <String, String>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! String) {
          return <String, String>{};
        }
        if (key.trim().isEmpty || value.trim().isEmpty) {
          return <String, String>{};
        }
        result[key] = value;
      }
      return result;
    } catch (_) {
      return <String, String>{};
    }
  }

  String encode(Map<String, String> state) {
    final keys = state.keys.toList()..sort();
    final ordered = <String, String>{};
    for (final key in keys) {
      final value = state[key];
      if (key.trim().isEmpty || value == null || value.trim().isEmpty) continue;
      ordered[key] = value;
    }
    return jsonEncode(ordered);
  }

  Set<String> deliveredIdentities(Map<String, String> state) =>
      Set<String>.unmodifiable(state.values);

  Map<String, String> markDelivered(
    Map<String, String> state,
    FollowUpReminderCandidate candidate,
  ) {
    final next = Map<String, String>.of(state);
    next[candidate.stableKey] = deliveryService.deliveryIdentity(candidate);
    return next;
  }

  /// Removes metadata only when its canonical FollowUp reminder no longer
  /// exists. Completed/archived Tasks intentionally keep their marker so a
  /// reversible lifecycle change cannot cause a duplicate old notification.
  Map<String, String> reconcile(
    Map<String, String> state,
    Iterable<Task> tasks,
  ) {
    final liveKeys = <String>{};
    for (final task in tasks) {
      for (final followUp in task.followUps) {
        if (followUp.reminderDate != null) {
          liveKeys.add('${task.id}:${followUp.id}');
        }
      }
    }

    final next = Map<String, String>.of(state);
    next.removeWhere((key, _) => !liveKeys.contains(key));
    return next;
  }
}
