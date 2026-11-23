import 'backup_schedule.dart';

/// Platform-agnostic scheduling contract for automatic backups.
///
/// The Android implementation can be connected later without coupling the
/// backup format or storage code to a specific scheduler package.
abstract interface class BackupSchedulerAdapter {
  Future<void> schedule(BackupSchedule schedule);
  Future<void> cancel();
}

class NoopBackupSchedulerAdapter implements BackupSchedulerAdapter {
  @override
  Future<void> schedule(BackupSchedule schedule) async {}

  @override
  Future<void> cancel() async {}
}
