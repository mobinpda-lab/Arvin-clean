import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  group('TaskReminder legacy compatibility', () {
    test('a Due Date alone does not synthesize a reminder', () {
      final dueAt = DateTime.utc(2026, 10, 28, 9, 30);
      final task = Task.fromJson(<String, dynamic>{
        'id': 'due-date-only',
        'title': 'Due Date only',
        'dueDate': dueAt.toIso8601String(),
      });

      expect(task.dueDate, dueAt);
      expect(task.taskReminders, isEmpty);
      expect(task.legacyTaskReminderMigrationVersion, 0);
    });

    test('legacy Task reminder All-Day flag migrates and survives round-trip', () {
      final date = DateTime(2026, 10, 30);
      final task = Task.fromJson({
        'id': 'legacy-all-day',
        'title': 'یادآور تمام‌روز',
        'reminderDate': date.toIso8601String(),
        'reminderAllDay': true,
      });
      expect(task.reminderAllDay, isTrue);
      expect(task.taskReminders.single.isAllDay, isTrue);
      final restored = Task.fromJson(task.toJson());
      expect(restored.reminderAllDay, isTrue);
      expect(restored.taskReminders.single.isAllDay, isTrue);
      expect(restored.taskReminders.single.date, date);
    });

    test('a valid legacy reminder retains identity and date after reload', () {
      final dueAt = DateTime.utc(2026, 10, 29, 12);
      final legacyReminderAt = DateTime.utc(2026, 10, 28, 8, 15);
      final legacyJson = <String, dynamic>{
        'id': 'legacy-reminder-task',
        'title': 'Legacy reminder',
        'dueDate': dueAt.toIso8601String(),
        'reminderDate': legacyReminderAt.toIso8601String(),
      };

      final migrated = Task.fromJson(legacyJson);
      expect(migrated.taskReminders, hasLength(1));
      expect(migrated.taskReminders.single.id, 'legacy-task-reminder-legacy-task');
      expect(migrated.taskReminders.single.date, legacyReminderAt);
      expect(migrated.taskReminders.single.isLegacyTaskReminder, isTrue);
      expect(migrated.dueDate, dueAt);

      final reloaded = Task.fromJson(migrated.toJson());
      expect(reloaded.taskReminders, hasLength(1));
      expect(reloaded.taskReminders.single.id, 'legacy-task-reminder-legacy-task');
      expect(reloaded.taskReminders.single.date, legacyReminderAt);
      expect(reloaded.taskReminders.single.isLegacyTaskReminder, isTrue);
      expect(reloaded.dueDate, dueAt);
    });
  });
}
