import 'backup_schedule.dart';

/// Platform-agnostic scheduling contract for automatic backups.
///
/// This layer deliberately does not start a background worker yet. It keeps
/// scheduling decisions separate from [ArvinBackupService] so Android's
/// eventual background implementation can be swapped without changing the
/// backup format or persistence logic.
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
