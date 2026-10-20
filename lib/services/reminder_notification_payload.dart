import 'dart:convert';

/// Stable, backwards-compatible identity carried by reminder notification taps.
class ReminderNotificationPayload {
  const ReminderNotificationPayload({
    required this.taskId,
    this.followUpId,
  });

  final String taskId;
  final String? followUpId;

  static String encode({
    required String taskId,
    String? followUpId,
  }) {
    return jsonEncode(<String, Object?>{
      'taskId': taskId,
      'followUpId': followUpId,
    });
  }

  /// Accepts the new structured payload and legacy payloads containing only a
  /// Task ID, so notifications already scheduled by older app versions remain
  /// routable.
  static ReminderNotificationPayload? decode(String? payload) {
    final value = payload?.trim();
    if (value == null || value.isEmpty) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final taskId = decoded['taskId'];
        final followUpId = decoded['followUpId'];
        if (taskId is String && taskId.trim().isNotEmpty) {
          return ReminderNotificationPayload(
            taskId: taskId,
            followUpId: followUpId is String && followUpId.isNotEmpty
                ? followUpId
                : null,
          );
        }
      }
    } catch (_) {
      // Old notification payloads were plain Task IDs, not JSON.
    }

    return ReminderNotificationPayload(taskId: value);
  }
}
