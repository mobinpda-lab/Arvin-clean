import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('All-Day due dates serialize as floating calendar dates', () {
    final task = Task(
      id: 'all-day-due',
      title: 'کار بدون ساعت',
      dueDate: DateTime(2026, 11, 8),
      allDay: true,
    );

    expect(task.toJson()['dueDate'], '2026-11-08');
    expect(task.toJson()['allDay'], isTrue);
  });

  test('an ordinary task without follow-ups is not a Notebook note', () {
    final task = Task(id: 'task-1', title: 'کار عادی');

    expect(task.isSimpleNote, isFalse);
    expect(task.isNotebookItem, isFalse);
    expect(task.followUpEnabled, isFalse);
  });

  test('an explicit Notebook note remains a note after follow-up is enabled', () {
    final task = Task(
      id: 'note-1',
      title: 'یادداشت پیگیری‌دار',
      notebookKind: NotebookItemKind.note,
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 9, 19, 11),
          note: 'پیگیری ثبت شد',
        ),
      ],
    );

    expect(task.isSimpleNote, isTrue);
    expect(task.isNotebookItem, isTrue);
  });

  test('enabling follow-up keeps the same item and exposes follow-up state', () {
    final task = Task(
      id: '1',
      title: 'کار',
      followUpEnabled: true,
    );

    expect(task.isSimpleNote, isFalse);
    expect(task.id, '1');
  });

  test('new unified fields survive serialization without breaking legacy fields', () {
    final created = DateTime(2026, 8, 14, 10, 30);
    final reminder = DateTime(2026, 8, 15, 9);
    final task = Task(
      id: '1',
      title: 'کار',
      description: 'توضیح',
      createdAt: created,
      category: 'پیگیری مشتری',
      followUpEnabled: true,
      checklist: const ['تماس', 'ثبت نتیجه'],
      taskReminders: [TaskReminder(id: 'roundtrip-reminder', title: 'یادآوری', date: reminder, sequence: 1)],
      followUps: [
        FollowUp(id: 'f1', dateTime: created, note: 'تماس انجام شد'),
      ],
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.id, '1');
    expect(restored.createdAt, created);
    expect(restored.category, 'پیگیری مشتری');
    expect(restored.followUpEnabled, isTrue);
    expect(restored.checklist, ['تماس', 'ثبت نتیجه']);
    expect(restored.reminderDate, reminder);
    expect(restored.followUps.single.note, 'تماس انجام شد');
  });

  test('legacy followUpDate migrates to an independent Reminder, not Follow-up history', () {
    final legacyDate = DateTime(2026, 8, 13, 12);
    final task = Task.fromLegacyJson({
      'id': 'legacy',
      'title': 'قدیمی',
      'followUpEnabled': true,
      'followUpDate': legacyDate.toIso8601String(),
    });

    expect(task.followUpEnabled, isFalse);
    expect(task.followUpDate, isNull);
    expect(task.followUps, isEmpty);
    expect(task.lastFollowUp, isNull);
    expect(task.taskReminders, hasLength(1));
    expect(task.taskReminders.single.id, 'legacy-task-follow-up-reminder-legacy');
    expect(task.taskReminders.single.date, legacyDate);
    expect(task.taskReminders.single.isEnabled, isTrue);
    expect(task.legacyTaskReminderMigrationVersion, 2);

    final reopened = Task.fromJson(task.toJson());
    expect(reopened.taskReminders, hasLength(1));
    expect(reopened.taskReminders.single.date, legacyDate);
  });

  test('legacy disabled followUpDate remains a disabled independent Reminder', () {
    final legacyDate = DateTime(2026, 8, 14, 9);
    final task = Task.fromLegacyJson({
      'id': 'legacy-disabled',
      'title': 'پیگیری غیرفعال',
      'followUpEnabled': false,
      'followUpDate': legacyDate.toIso8601String(),
    });

    expect(task.taskReminders, hasLength(1));
    expect(task.taskReminders.single.date, legacyDate);
    expect(task.taskReminders.single.isEnabled, isFalse);
    expect(task.followUpDate, isNull);
  });

  test('legacy Follow-up next action dates become independent TaskReminders', () {
    final task = Task.fromLegacyJson({
      'id': 'legacy-follow-up',
      'title': 'پیگیری مشتری',
      'followUps': [
        {
          'id': 'follow-up-1',
          'dateTime': '2026-08-13T12:00:00.000',
          'reminderDate': '2026-08-14T09:00:00.000',
          'nextFollowUp': '2026-08-15T10:30:00.000',
        },
      ],
    });

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.nextFollowUp, isNull);
    expect(task.taskReminders, hasLength(2));
    expect(
      task.taskReminders.map((reminder) => reminder.id),
      containsAll([
        'follow-up-reminder-legacy-follow-up-follow-up-1',
        'follow-up-next-reminder-legacy-follow-up-follow-up-1',
      ]),
    );
    expect(
      task.taskReminders.map((reminder) => reminder.date),
      containsAll([
        DateTime(2026, 8, 14, 9),
        DateTime(2026, 8, 15, 10, 30),
      ]),
    );
  });

  test('missing category remains backward-compatible with legacy data', () {
    final task = Task.fromJson({
      'id': 'legacy',
      'title': 'قدیمی',
    });

    expect(task.category, isNull);
    expect(task.toJson()['category'], isNull);
  });
}
