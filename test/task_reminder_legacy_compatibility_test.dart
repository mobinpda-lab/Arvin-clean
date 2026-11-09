import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  group('TaskReminder canonical compatibility', () {
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
      expect(task.taskReminders.single.isAllDay, isTrue);
      final restored = Task.fromJson(task.toJson());
      expect(restored.taskReminders.single.isAllDay, isTrue);
      expect(restored.taskReminders.single.date, date);
    });

 
    test('an explicitly configured independent reminder is exposed by the computed getter', () {
      final first = DateTime(2026, 11, 2, 8, 15);
      final second = DateTime(2026, 11, 3, 9, 30);
      final task = Task(
        id: 'independent-reminder-fallback',
        title: 'Independent reminder',
        dueDate: DateTime(2026, 11, 4, 10),
        taskReminders: [
          TaskReminder(
            id: 'disabled-reminder',
            title: 'Disabled',
            date: first,
            sequence: 1,
            isEnabled: false,
          ),
          TaskReminder(
            id: 'active-reminder-2',
            title: 'Active second',
            date: second,
            sequence: 2,
          ),
        ],
      );

      expect(task.reminderDate, second);
      expect(task.dueDate, DateTime(2026, 11, 4, 10));
      expect(task.taskReminders, hasLength(2));

      final restored = Task.fromJson(task.toJson());
      expect(restored.reminderDate, second);
      expect(restored.taskReminders, hasLength(2));
    });

    test('computed getter returns the earliest enabled reminder regardless of origin', () {
      final legacyAt = DateTime(2026, 11, 2, 8);
      final independentAt = DateTime(2026, 11, 1, 7);
      final task = Task(
        id: 'legacy-precedence',
        title: 'Legacy precedence',
        reminderDate: legacyAt,
        taskReminders: [
          TaskReminder(
            id: 'independent',
            title: 'Independent',
            date: independentAt,
            sequence: 2,
          ),
        ],
      );

      expect(task.reminderDate, independentAt);
    });

    test('computed getter chooses the earliest enabled datetime, not sequence order', () {
      final task = Task(
        id: 'earliest-reminder',
        title: 'Earliest reminder',
        taskReminders: [
          TaskReminder(
            id: 'later-sequence-first',
            title: 'Later',
            date: DateTime(2026, 11, 3, 11),
            sequence: 1,
          ),
          TaskReminder(
            id: 'earlier-sequence-second',
            title: 'Earlier',
            date: DateTime(2026, 11, 3, 8),
            sequence: 2,
          ),
          TaskReminder(
            id: 'disabled-earliest',
            title: 'Disabled',
            date: DateTime(2026, 11, 3, 7),
            sequence: 3,
            isEnabled: false,
          ),
        ],
      );

      expect(task.reminderDate, DateTime(2026, 11, 3, 8));
    });

    test('old per-reminder legacy metadata is ignored and never re-serialized', () {
      final task = Task.fromJson({
        'id': 'legacy-flag-input',
        'title': 'Old reminder metadata',
        'legacyTaskReminderMigrationVersion': 1,
        'taskReminders': [
          {
            'id': 'legacy-task-reminder-legacy-flag-input',
            'title': 'یادآوری قدیمی',
            'date': '2026-11-03T08:00:00.000',
            'sequence': 1,
            'isLegacyTaskReminder': true,
          },
        ],
      });

      expect(task.reminderDate, DateTime(2026, 11, 3, 8));
      final serializedReminder =
          (task.toJson()['taskReminders'] as List).single as Map;
      expect(serializedReminder.containsKey('isLegacyTaskReminder'), isFalse);
    });

    test('computed getter is null when every reminder is disabled', () {
      final task = Task(
        id: 'disabled-reminders',
        title: 'Disabled reminders',
        taskReminders: [
          TaskReminder(
            id: 'disabled-only',
            title: 'Disabled',
            date: DateTime(2026, 11, 3, 8),
            sequence: 1,
            isEnabled: false,
          ),
        ],
      );

      expect(task.reminderDate, isNull);
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
      expect(migrated.taskReminders.single.id, 'legacy-task-reminder-legacy-reminder-task');
      expect(migrated.taskReminders.single.date, legacyReminderAt);
      expect(migrated.dueDate, dueAt);

      final reloaded = Task.fromJson(migrated.toJson());
      expect(reloaded.taskReminders, hasLength(1));
      expect(reloaded.taskReminders.single.id, 'legacy-task-reminder-legacy-reminder-task');
      expect(reloaded.taskReminders.single.date, legacyReminderAt);
      expect(reloaded.dueDate, dueAt);
    });
  });
}
