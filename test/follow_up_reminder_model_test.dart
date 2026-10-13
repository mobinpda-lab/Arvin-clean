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


  test('legacy Task reminder migrates deterministically and preserves legacy value', () {
    final reminderDate = DateTime(2026, 10, 13, 0);
    final original = Task.fromJson(<String, dynamic>{
      'id': 'legacy-task-reminder-1',
      'title': 'جلسه',
      'reminderDate': reminderDate.toIso8601String(),
    });

    expect(original.reminderDate, reminderDate);
    expect(original.taskReminders, hasLength(1));
    final migrated = original.taskReminders.single;
    expect(migrated.id, 'legacy-task-reminder:legacy-task-reminder-1');
    expect(migrated.taskId, original.id);
    expect(migrated.title, 'جلسه — یادآور ۱');
    expect(migrated.date, reminderDate);
    expect(migrated.status, 'active');
    expect(migrated.isAllDay, isFalse);
    expect(migrated.sequence, 1);
    expect(original.nextReminderSequence, 2);

    final restored = Task.fromJson(original.toJson());
    expect(restored.reminderDate, reminderDate);
    expect(restored.taskReminders, hasLength(1));
    expect(restored.taskReminders.single.id, migrated.id);
    expect(restored.taskReminders.single.createdAt, migrated.createdAt);
    expect(restored.taskReminders.single.updatedAt, migrated.updatedAt);
    expect(restored.nextReminderSequence, 2);
  });

  test('legacy migration allocates above existing sequence without changing it', () {
    final createdAt = DateTime(2026, 10, 1, 9);
    final updatedAt = DateTime(2026, 10, 2, 10);
    final legacyDate = DateTime(2026, 10, 13, 0);
    final original = Task.fromJson(<String, dynamic>{
      'id': 'mixed-reminders',
      'title': 'تماس',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderDate': legacyDate.toIso8601String(),
      'nextReminderSequence': 5,
      'taskReminders': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'new-reminder-4',
          'taskId': 'mixed-reminders',
          'title': 'عنوان قابل ویرایش',
          'date': '2026-10-12T11:30:00.000',
          'status': 'active',
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
          'isAllDay': false,
          'sequence': 4,
        },
      ],
    });

    expect(original.taskReminders, hasLength(2));
    expect(original.taskReminders.first.id, 'new-reminder-4');
    expect(original.taskReminders.first.sequence, 4);
    expect(original.taskReminders.first.title, 'عنوان قابل ویرایش');
    expect(original.taskReminders.last.id, 'legacy-task-reminder:mixed-reminders');
    expect(original.taskReminders.last.sequence, 5);
    expect(original.nextReminderSequence, 6);
    expect(original.reminderDate, legacyDate);
    expect(original.taskReminders.last.isAllDay, isFalse);

    final restored = Task.fromJson(original.toJson());
    expect(restored.taskReminders, hasLength(2));
    expect(restored.taskReminders.map((item) => item.id).toSet(),
        {'new-reminder-4', 'legacy-task-reminder:mixed-reminders'});
    expect(restored.nextReminderSequence, 6);
  });

  test('nextFollowUp alone does not synthesize a Task reminder', () {
    final task = Task.fromJson(<String, dynamic>{
      'id': 'next-action-only',
      'title': 'اقدام بعدی',
      'followUps': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'follow-up-1',
          'dateTime': '2026-10-10T10:00:00.000',
          'note': 'بررسی',
          'nextFollowUp': '2026-10-15T09:00:00.000',
        },
      ],
    });

    expect(task.taskReminders, isEmpty);
    expect(task.reminderDate, isNull);
    expect(task.followUps.single.nextFollowUp, DateTime(2026, 10, 15, 9));
    expect(task.followUps.single.reminderDate, isNull);
  });
}
