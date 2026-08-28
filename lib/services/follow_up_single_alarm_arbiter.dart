import '../models/task.dart';
import 'automatic_follow_up_alarm_planner.dart';
import 'follow_up_reminder_delivery_service.dart';
import 'follow_up_reminder_projection.dart';

enum FollowUpAlarmSource {
  automaticFollowUp,
  reminder,
}

class FollowUpAlarmDecision {
  const FollowUpAlarmDecision({
    required this.alarmAt,
    required this.source,
  });

  final DateTime alarmAt;
  final FollowUpAlarmSource source;
}

/// Arbitrates all FollowUp-related scheduling through Arvin's single Android
/// alarm foundation. It owns no persistence or platform side effects.
class FollowUpSingleAlarmArbiter {
  const FollowUpSingleAlarmArbiter({
    this.automaticPlanner = const AutomaticFollowUpAlarmPlanner(),
    this.reminderProjection = const FollowUpReminderProjection(),
    this.reminderDelivery = const FollowUpReminderDeliveryService(),
    this.minimumDelay = const Duration(minutes: 5),
  });

  final AutomaticFollowUpAlarmPlanner automaticPlanner;
  final FollowUpReminderProjection reminderProjection;
  final FollowUpReminderDeliveryService reminderDelivery;
  final Duration minimumDelay;

  FollowUpAlarmDecision? next(
    Iterable<Task> tasks, {
    required Map<String, String> automaticDeliveredState,
    required Set<String> reminderDeliveredIdentities,
    required DateTime now,
  }) {
    final canonicalTasks = List<Task>.of(tasks);
    final floor = now.add(minimumDelay);

    final automaticAt = automaticPlanner.nextAlarmAt(
      canonicalTasks,
      deliveredState: automaticDeliveredState,
      now: now,
    );

    DateTime? reminderAt;
    final dueReminders = reminderDelivery.due(
      canonicalTasks,
      now: now,
      deliveredIdentities: reminderDeliveredIdentities,
    );

    if (dueReminders.isNotEmpty) {
      // A missed/failed reminder remains retryable without creating an
      // immediate reschedule loop.
      reminderAt = floor;
    } else {
      final activeTasks = canonicalTasks.where(
        (task) => !task.completed && !task.archived && !task.trashed,
      );
      for (final candidate in reminderProjection.pending(activeTasks, now: now)) {
        final identity = reminderDelivery.deliveryIdentity(candidate);
        if (reminderDeliveredIdentities.contains(identity)) continue;
        reminderAt = candidate.scheduledAt.isAfter(floor)
            ? candidate.scheduledAt
            : floor;
        break;
      }
    }

    if (automaticAt == null && reminderAt == null) return null;
    if (automaticAt == null) {
      return FollowUpAlarmDecision(
        alarmAt: reminderAt!,
        source: FollowUpAlarmSource.reminder,
      );
    }
    if (reminderAt == null || !reminderAt.isBefore(automaticAt)) {
      return FollowUpAlarmDecision(
        alarmAt: automaticAt,
        source: FollowUpAlarmSource.automaticFollowUp,
      );
    }
    return FollowUpAlarmDecision(
      alarmAt: reminderAt,
      source: FollowUpAlarmSource.reminder,
    );
  }
}
