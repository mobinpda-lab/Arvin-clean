import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'android_automatic_follow_up_scheduler.dart';
import 'services/automatic_follow_up_delivery_state.dart';
import 'services/automatic_follow_up_service.dart';
import 'models/task.dart';
import 'services/task_store.dart';

const String arvinActionDone = 'arvin_action_done';
const String arvinActionSnooze15 = 'arvin_action_snooze_15';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse details) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final taskId = details.payload?.trim();
  if (taskId == null || taskId.isEmpty) return;
  if (details.actionId != arvinActionDone &&
      details.actionId != arvinActionSnooze15) {
    return;
  }

  final store = TaskStore();
  final tasks = await store.load();
  final index = tasks.indexWhere((task) => task.id == taskId);
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  if (index < 0) {
    if (details.id != null) await notifications.cancel(id: details.id!);
    await _clearAutomaticFollowUpDeliveryMarker(taskId);
    await AndroidAutomaticFollowUpScheduler().reschedule();
    return;
  }

  final task = tasks[index];
  if (details.actionId == arvinActionDone) {
    task.completed = true;
    task.updatedAt = DateTime.now();
    await store.save(tasks);
    if (details.id != null) await notifications.cancel(id: details.id!);
    await _clearAutomaticFollowUpDeliveryMarker(taskId);
    await AndroidAutomaticFollowUpScheduler().reschedule();
    return;
  }

  if (task.completed || task.archived || task.trashed) {
    if (details.id != null) await notifications.cancel(id: details.id!);
    await _clearAutomaticFollowUpDeliveryMarker(taskId);
    await AndroidAutomaticFollowUpScheduler().reschedule();
    return;
  }

  final latest = task.lastFollowUp;
  if (latest == null) {
    if (details.id != null) await notifications.cancel(id: details.id!);
    await _clearAutomaticFollowUpDeliveryMarker(taskId);
    await AndroidAutomaticFollowUpScheduler().reschedule();
    return;
  }

  final nextFollowUp = DateTime.now().add(const Duration(minutes: 15));
  task.followUps = task.followUps.map((followUp) {
    if (followUp.id != latest.id) return followUp;
    return FollowUp(
      id: followUp.id,
      dateTime: followUp.dateTime,
      title: followUp.title,
      note: followUp.note,
      result: followUp.result,
      reminderDate: followUp.reminderDate,
      nextFollowUp: nextFollowUp,
      completed: followUp.completed,
      waitingForResponse: followUp.waitingForResponse,
      personIds: followUp.personIds,
    );
  }).toList(growable: false);
  task.updatedAt = DateTime.now();
  await store.save(tasks);
  if (details.id != null) await notifications.cancel(id: details.id!);
  await _clearAutomaticFollowUpDeliveryMarker(taskId);
  await AndroidAutomaticFollowUpScheduler().reschedule();
}

Future<void> _clearAutomaticFollowUpDeliveryMarker(String taskId) async {
  final preferences = await SharedPreferences.getInstance();
  final raw = preferences.getString(
    automaticFollowUpNotificationStateKey,
  );
  if (raw == null || raw.isEmpty) return;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    final state = decoded.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    state.remove(taskId);
    await preferences.setString(
      automaticFollowUpNotificationStateKey,
      jsonEncode(state),
    );
  } catch (_) {
    await preferences.remove(
      automaticFollowUpNotificationStateKey,
    );
  }
}

abstract interface class AutomaticFollowUpNotificationSink {
  Future<void> showDue(AutomaticFollowUpCandidate candidate);
}

class AutomaticFollowUpNotificationService
    implements AutomaticFollowUpNotificationSink {
  AutomaticFollowUpNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'arvin_followup',
    'پیگیری‌های آروین',
    description: 'هشدار پیگیری‌های موعدرسیده آروین',
    importance: Importance.high,
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const settings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: settings),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    _initialized = true;
  }

  int notificationIdFor(AutomaticFollowUpCandidate candidate) {
    final value = '${candidate.taskId}:${candidate.followUpId}';
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 42001 : hash;
  }

  @override
  Future<void> showDue(AutomaticFollowUpCandidate candidate) async {
    await _ensureInitialized();
    await _plugin.show(
      id: notificationIdFor(candidate),
      title: 'پیگیری موعدرسیده',
      body: candidate.taskTitle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'arvin_followup',
          'پیگیری‌های آروین',
          channelDescription: 'هشدار پیگیری‌های موعدرسیده آروین',
          importance: Importance.high,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              arvinActionDone,
              'تأیید / انجام شد',
              showsUserInterface: false,
            ),
            AndroidNotificationAction(
              arvinActionSnooze15,
              'تعویق ۱۵ دقیقه',
              showsUserInterface: false,
            ),
          ],
        ),
      ),
      payload: candidate.taskId,
    );
  }
}
