import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/backup_schedule.dart';

void main() {
  group('BackupSchedule', () {
    test('calculates the next run today when the configured time is ahead', () {
      const schedule = BackupSchedule(enabled: true, hour: 14, minute: 30);
      final next = schedule.nextRun(DateTime(2026, 8, 12, 10, 17));
      expect(next, DateTime(2026, 8, 12, 14, 30));
    });

    test('moves to tomorrow when the configured time has passed', () {
      const schedule = BackupSchedule(enabled: true, hour: 3, minute: 4);
      final next = schedule.nextRun(DateTime(2026, 8, 12, 10, 17));
      expect(next, DateTime(2026, 8, 13, 3, 4));
    });

    test('uses safe defaults for a disabled schedule', () {
      final schedule = BackupSchedule.disabled();
      expect(schedule.enabled, isFalse);
      expect(schedule.hour, 3);
      expect(schedule.minute, 0);
    });
  });
}
