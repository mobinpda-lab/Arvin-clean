import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/android_backup_scheduler.dart';
import 'package:arvin/backup_schedule.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('backup schedule calculates the next daily run correctly', () {
    final now = DateTime(2026, 8, 12, 10, 30);
    const schedule = BackupSchedule(
      enabled: true,
      hour: 3,
      minute: 0,
    );

    expect(schedule.nextRun(now), DateTime(2026, 8, 13, 3, 0));
  });

  test('backup alarm callback is a valid background entry point', () async {
    // With no saved background configuration the runner should safely return
    // false; the callback itself must still complete without throwing.
    await expectLater(arvinBackupAlarmCallback(), completes);
  });
}
