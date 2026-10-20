import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FollowUp reminder is optional and survives canonical JSON round-trip', () {
    final followUp = FollowUp(
      id: 'f-reminder',
      dateTime: DateTime(2026, 8, 28, 15, 30),
      title: 'پیگیری اختصاصی',
      note: 'یادداشت تماس با مشتری',
      result: 'منتظر پاسخ',
      reminderDate: DateTime(2026, 8, 28, 15, 15),
      nextFollowUp: DateTime(2026, 8, 30, 10),
    );

    final restored = FollowUp.fromJson(followUp.toJson());

    expect(restored.id, followUp.id);
    expect(restored.dateTime, followUp.dateTime);
    expect(restored.title, followUp.title);
    expect(restored.note, followUp.note);
    expect(restored.result, followUp.result);
    expect(restored.reminderDate, followUp.reminderDate);
    expect(restored.nextFollowUp, followUp.nextFollowUp);
  });

  test('legacy FollowUp JSON without reminder remains valid', () {
    final restored = FollowUp.fromJson({
      'id': 'legacy',
      'dateTime': '2026-08-28T10:00:00.000',
      'note': 'پیگیری قبلی',
      'result': null,
      'nextFollowUp': null,
    });

    expect(restored.title, isNull);
    expect(restored.reminderDate, isNull);
    expect(restored.note, 'پیگیری قبلی');
  });

  test('Task envelope preserves FollowUp reminder without a second store', () {
    final task = Task(
      id: 't1',
      title: 'قرارداد',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 28, 12),
          reminderDate: DateTime(2026, 8, 28, 11, 45),
        ),
      ],
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.followUps, hasLength(1));
    expect(
      restored.followUps.single.reminderDate,
      DateTime(2026, 8, 28, 11, 45),
    );
  });

  test('multiple independent Task reminders and monotonic sequence survive JSON round-trip', () {
    final task = Task(
      id: 'multi-reminder',
      title: 'خرید فرش',
      reminderDate: DateTime(2026, 10, 20, 9),
      taskReminders: [
        TaskReminder(
          id: 'reminder-a',
          title: 'خرید فرش — یادآور 1',
          date: DateTime(2026, 10, 20, 10),
          sequence: 1,
        ),
        TaskReminder(
          id: 'reminder-c',
          title: 'خرید فرش — یادآور 3',
          date: DateTime(2026, 10, 22),
          isAllDay: true,
          sequence: 3,
        ),
      ],
      nextReminderSequence: 4,
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.reminderDate, task.reminderDate,
        reason: 'legacy singular reminder must remain unchanged');
    expect(restored.taskReminders, hasLength(3));
    expect(restored.taskReminders.map((item) => item.id),
        ['reminder-a', 'reminder-c', 'legacy-task-reminder']);
    final independentAllDay = restored.taskReminders.singleWhere(
      (item) => item.id == 'reminder-c',
    );
    expect(independentAllDay.isAllDay, isTrue);
    expect(independentAllDay.date, DateTime(2026, 10, 22));
    expect(restored.taskReminders.last.isLegacyTaskReminder, isTrue);
    expect(restored.taskReminders.last.date, task.reminderDate);
    expect(restored.nextReminderSequence, 5);
  });

  test('legacy Task reminder migrates once and preserves its timestamp', () {
    final restored = Task.fromJson({
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'reminderDate': '2026-10-20T09:30:00.000',
    });

    expect(restored.reminderDate, DateTime(2026, 10, 20, 9, 30));
    expect(restored.taskReminders, hasLength(1));
    expect(restored.taskReminders.single.id, 'legacy-task-reminder');
    expect(restored.taskReminders.single.isLegacyTaskReminder, isTrue);
    expect(restored.taskReminders.single.date, restored.reminderDate);
    expect(restored.taskReminders.single.isAllDay, isFalse,
        reason: 'legacy reminders default to timed semantics without explicit all-day metadata');
    expect(restored.legacyTaskReminderMigrationVersion, 1);
    expect(restored.nextReminderSequence, 2);

    final restoredAgain = Task.fromJson(restored.toJson());
    expect(restoredAgain.taskReminders, hasLength(1),
        reason: 'reloading a migrated Task must not create a duplicate');
    expect(restoredAgain.taskReminders.single.id, 'legacy-task-reminder');
    expect(restoredAgain.legacyTaskReminderMigrationVersion, 1);
  });

  test('legacy migration appends after existing reminders without overwriting them', () {
    final restored = Task.fromJson({
      'id': 'legacy-with-new',
      'title': 'کار ترکیبی',
      'reminderDate': '2026-10-20T09:30:00.000',
      'taskReminders': [
        {
          'id': 'new-reminder',
          'title': 'یادآور مستقل',
          'date': '2026-10-21T11:00:00.000',
          'isAllDay': false,
          'sequence': 1,
        }
      ],
      'nextReminderSequence': 7,
    });

    expect(restored.taskReminders, hasLength(2));
    expect(restored.taskReminders.first.id, 'new-reminder');
    expect(restored.taskReminders.last.id, 'legacy-task-reminder');
    expect(restored.taskReminders.last.sequence, 7,
        reason: 'migration must not recycle previously used sequence numbers');
    expect(restored.nextReminderSequence, 8);

    final restoredAgain = Task.fromJson(restored.toJson());
    expect(restoredAgain.taskReminders, hasLength(2));
    expect(restoredAgain.taskReminders.map((item) => item.id).toSet(),
        {'new-reminder', 'legacy-task-reminder'});
  });

  test('Task without a legacy reminder does not prematurely mark migration complete', () {
    final restored = Task.fromJson({
      'id': 'no-legacy-reminder',
      'title': 'کار جدید',
    });

    expect(restored.taskReminders, isEmpty);
    expect(restored.legacyTaskReminderMigrationVersion, 0);
  });

  test('deleted migrated reminder does not reappear from the retained legacy field', () {
    final migrated = Task.fromJson({
      'id': 'deleted-legacy',
      'title': 'کار قدیمی',
      'reminderDate': '2026-10-20T09:30:00.000',
    });
    migrated.taskReminders.clear();

    final restored = Task.fromJson(migrated.toJson());

    expect(restored.taskReminders, isEmpty);
    expect(restored.legacyTaskReminderMigrationVersion, 1);
    expect(restored.reminderDate, DateTime(2026, 10, 20, 9, 30));
  });

  test('legacy midnight reminder is not inferred to be all-day', () {
    final restored = Task.fromJson({
      'id': 'legacy-midnight',
      'title': 'کار نیمه‌شب',
      'reminderDate': '2026-10-20T00:00:00.000',
    });

    expect(restored.taskReminders, hasLength(1));
    expect(restored.taskReminders.single.date, DateTime(2026, 10, 20));
    expect(restored.taskReminders.single.isAllDay, isFalse);
  });



  test('TaskReminder preserves stable FollowUp identity through JSON round-trip', () {
    final reminder = TaskReminder(
      id: 'reminder-follow-up-1',
      title: 'خرید موکت',
      date: DateTime(2026, 10, 22, 14, 30),
      sequence: 2,
      followUpId: 'follow-up-1',
    );

    final restored = TaskReminder.fromJson(reminder.toJson());

    expect(restored.id, reminder.id);
    expect(restored.followUpId, 'follow-up-1');
    expect(restored.date, reminder.date);
    expect(restored.title, 'خرید موکت');
  });

  test('legacy TaskReminder JSON without FollowUp identity remains compatible', () {
    final restored = TaskReminder.fromJson({
      'id': 'legacy-task-reminder',
      'title': 'یادآور کار',
      'date': '2026-10-22T14:30:00.000',
      'sequence': 1,
    });

    expect(restored.followUpId, isNull);
    expect(restored.id, 'legacy-task-reminder');
  });

}
