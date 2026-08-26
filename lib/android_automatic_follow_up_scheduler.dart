import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'automatic_follow_up_background_runner.dart';
import 'automatic_follow_up_scheduler_adapter.dart';
import 'services/automatic_follow_up_alarm_planner.dart';
import 'services/task_store.dart';

const int automaticFollowUpAlarmId = 42001;

@pragma('vm:entry-point')
Future<void> arvinAutomaticFollowUpAlarmCallback() async {
  await const AutomaticFollowUpBackgroundRunner().run();
  await AndroidAutomaticFollowUpScheduler().reschedule();
}

/// Reuses Arvin's existing Android AlarmManager foundation and keeps exactly
/// one alarm: the nearest not-yet-delivered canonical FollowUp schedule.
///
/// Calls are intentionally no-op off Android. This keeps the shared widget/test
/// composition platform-safe while production Android still uses AlarmManager.
class AndroidAutomaticFollowUpScheduler
    implements AutomaticFollowUpSchedulerAdapter {
  AndroidAutomaticFollowUpScheduler({
    TaskStore? taskStore,
    AutomaticFollowUpAlarmPlanner? planner,
    DateTime Function()? now,
  })  : _taskStore = taskStore,
        _planner = planner,
        _now = now;

  final TaskStore? _taskStore;
  final AutomaticFollowUpAlarmPlanner? _planner;
  final DateTime Function()? _now;
  bool _initialized = false;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final initialized = await AndroidAlarmManager.initialize();
    if (!initialized) {
      throw StateError('Android Alarm Manager could not be initialized');
    }
    _initialized = true;
  }

  @override
  Future<void> reschedule() async {
    if (!_isAndroid) return;

    await _ensureInitialized();
    await AndroidAlarmManager.cancel(automaticFollowUpAlarmId);

    final tasks = await (_taskStore ?? TaskStore()).load();
    final prefs = await SharedPreferences.getInstance();
    final deliveredState = AutomaticFollowUpBackgroundRunner.decodeDeliveryState(
      prefs.getString(AutomaticFollowUpBackgroundRunner.notificationStateKey),
    );
    final next = (_planner ?? const AutomaticFollowUpAlarmPlanner()).nextAlarmAt(
      tasks,
      deliveredState: deliveredState,
      now: (_now ?? DateTime.now).call(),
    );
    if (next == null) return;

    await AndroidAlarmManager.oneShotAt(
      next,
      automaticFollowUpAlarmId,
      arvinAutomaticFollowUpAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  @override
  Future<void> cancel() async {
    if (!_isAndroid) return;

    await _ensureInitialized();
    await AndroidAlarmManager.cancel(automaticFollowUpAlarmId);
  }
}
