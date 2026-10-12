import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FollowUp reminder is optional and survives canonical JSON round-trip', () {
    final followUp = FollowUp(
      id: 'f-reminder',
      dateTime: DateTime(2026, 8, 28, 15, 30),
      note: 'تماس با مشتری',
      result: 'منتظر پاسخ',
      reminderDate: DateTime(2026, 8, 28, 15, 15),
      nextFollowUp: DateTime(2026, 8, 30, 10),
    );

    final restored = FollowUp.fromJson(followUp.toJson());

    expect(restored.id, followUp.id);
    expect(restored.dateTime, followUp.dateTime);
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
          date: DateTime(2026, 10, 22, 11),
          isAllDay: true,
          sequence: 3,
        ),
      ],
      nextReminderSequence: 4,
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.reminderDate, task.reminderDate,
        reason: 'legacy singular reminder must remain unchanged');
    expect(restored.taskReminders, hasLength(2));
    expect(restored.taskReminders.map((item) => item.id),
        ['reminder-a', 'reminder-c']);
    expect(restored.taskReminders.last.isAllDay, isTrue);
    expect(restored.taskReminders.last.date, DateTime(2026, 10, 22, 11));
    expect(restored.nextReminderSequence, 4);
  });

  test('legacy Task JSON without a reminder collection remains valid', () {
    final restored = Task.fromJson({
      'id': 'legacy-task',
      'title': 'کار قدیمی',
      'reminderDate': '2026-10-20T09:30:00.000',
    });

    expect(restored.taskReminders, isEmpty);
    expect(restored.reminderDate, DateTime(2026, 10, 20, 9, 30));
    expect(restored.nextReminderSequence, 1);
  });
}
