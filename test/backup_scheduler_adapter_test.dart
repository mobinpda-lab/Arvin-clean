import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/backup_schedule.dart';
import 'package:arvin/backup_scheduler_adapter.dart';

void main() {
  test('noop scheduler accepts a schedule without changing backup data', () async {
    final scheduler = NoopBackupSchedulerAdapter();
    final schedule = BackupSchedule(
      enabled: true,
      hour: 3,
      minute: 15,
    );

    await scheduler.schedule(schedule);
    await scheduler.cancel();

    expect(schedule.enabled, isTrue);
    expect(schedule.hour, 3);
    expect(schedule.minute, 15);
  });
}
