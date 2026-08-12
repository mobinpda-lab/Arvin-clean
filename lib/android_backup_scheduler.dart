import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'backup_schedule.dart';
import 'backup_scheduler_adapter.dart';

const int backupAlarmId = 41001;

/// Entry point invoked by Android AlarmManager.
///
/// The actual backup operation is intentionally connected in a later step.
/// Keeping this callback top-level makes it valid for Android's background
/// isolate and lets us verify scheduling independently first.
@pragma('vm:entry-point')
void arvinBackupAlarmCallback() {
  // Intentionally empty for this phase. The next phase will invoke the
  // backup service from this background isolate.
}

class AndroidBackupScheduler implements BackupSchedulerAdapter {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final initialized = await AndroidAlarmManager.initialize();
    if (!initialized) {
      throw StateError('Android Alarm Manager could not be initialized');
    }
    _initialized = true;
  }

  @override
  Future<void> schedule(BackupSchedule schedule) async {
    await _ensureInitialized();
    await AndroidAlarmManager.cancel(backupAlarmId);

    if (!schedule.enabled) return;

    await AndroidAlarmManager.oneShotAt(
      schedule.nextRun(),
      backupAlarmId,
      arvinBackupAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  @override
  Future<void> cancel() async {
    await _ensureInitialized();
    await AndroidAlarmManager.cancel(backupAlarmId);
  }
}
