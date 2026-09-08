import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'automatic_follow_up_platform_stub.dart'
    if (dart.library.io) 'automatic_follow_up_platform_io.dart';
import 'follow_up_reminder_background_runner.dart';
import 'services/follow_up_reminder_alarm_planner.dart';
import 'services/follow_up_reminder_delivery_state.dart';
import 'services/task_store.dart';

const int followUpReminderAlarmId = 42002;

@pragma('vm:entry-point')
Future<void> arvinFollowUpReminderAlarmCallback() async {
  await const FollowUpReminderBackgroundRunner().run();
  await AndroidFollowUpReminderScheduler().reschedule();
}

class AndroidFollowUpReminderScheduler {
  AndroidFollowUpReminderScheduler({
    TaskStore? taskStore,
    FollowUpReminderAlarmPlanner? planner,
    DateTime Function()? now,
  })  : _taskStore = taskStore,
        _planner = planner,
        _now = now;

  final TaskStore? _taskStore;
  final FollowUpReminderAlarmPlanner? _planner;
  final DateTime Function()? _now;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final initialized = await AndroidAlarmManager.initialize();
    if (!initialized) {
      throw StateError('Android Alarm Manager could not be initialized');
    }
    _initialized = true;
  }

  Future<void> reschedule() async {
    if (!supportsAutomaticFollowUpScheduling) return;
    await _ensureInitialized();
    await AndroidAlarmManager.cancel(followUpReminderAlarmId);

    final tasks = await (_taskStore ?? TaskStore()).load();
    final prefs = await SharedPreferences.getInstance();
    final stateService = const FollowUpReminderDeliveryState();
    final state = stateService.decode(
      prefs.getString(FollowUpReminderDeliveryState.storageKey),
    );
    final next = (_planner ?? const FollowUpReminderAlarmPlanner()).nextAlarmAt(
      tasks,
      deliveredState: state,
      now: (_now ?? DateTime.now).call(),
    );
    if (next == null) return;

    await AndroidAlarmManager.oneShotAt(
      next,
      followUpReminderAlarmId,
      arvinFollowUpReminderAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> cancel() async {
    if (!supportsAutomaticFollowUpScheduling) return;
    await _ensureInitialized();
    await AndroidAlarmManager.cancel(followUpReminderAlarmId);
  }
}
