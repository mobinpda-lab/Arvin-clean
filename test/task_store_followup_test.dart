import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('adds and reloads a real follow-up while preserving legacy scheduling date', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUpDate":"2026-08-14T09:30:00.000"}]',
    });

    final store = TaskStore();
    final followUp = FollowUp(
      id: 'f2',
      dateTime: DateTime(2026, 8, 15, 10, 15),
      note: 'تماس مجدد',
      result: 'پاسخ دریافت شد',
    );

    await store.addFollowUp('t1', followUp);
    final loaded = await store.loadFollowUps('t1');
    final task = (await store.load()).single;

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'f2');
    expect(loaded.single.result, 'پاسخ دریافت شد');
    expect(task.followUpDate, DateTime(2026, 8, 14, 9, 30));
    expect(task.followUpEnabled, isTrue);
    expect(task.updatedAt, isNotNull);
  });

  test('legacy followUpEnabled serialization mirrors records and legacy date', () {
    final recorded = Task(
      id: 'recorded',
      title: 'رکورد واقعی',
      followUps: [
        FollowUp(id: 'fu-recorded', dateTime: DateTime(2026, 10, 15, 10)),
      ],
    );
    final legacyDate = Task(
      id: 'legacy-date',
      title: 'تاریخ قدیمی',
      followUpDate: DateTime(2026, 10, 15, 10),
    );

    expect(recorded.toJson()['followUpEnabled'], isTrue);
    expect(legacyDate.toJson()['followUpEnabled'], isTrue);
  });

  test('converts a normal Task to FollowUp without changing identity', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t-convert","title":"کار معمولی","description":"متن","category":"مشتریان","tags":["فوری"]}]',
    });
    final store = TaskStore();
    await store.convertToFollowUp('t-convert');
    final task = (await store.load()).single;
    expect(task.id, 't-convert');
    expect(task.title, 'کار معمولی');
    expect(task.description, 'متن');
    expect(task.category, 'مشتریان');
    expect(task.tags, ['فوری']);
    expect(task.followUpEnabled, isTrue);
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, startsWith('follow-up-conversion:t-convert:'));
    expect(task.followUps.single.note, isEmpty);
  });

  test('legacy enablement flag alone does not block canonical conversion', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t-legacy-flag","title":"پرچم قدیمی","followUpEnabled":true}]',
    });
    final store = TaskStore();

    await store.convertToFollowUp('t-legacy-flag');
    final task = (await store.load()).single;

    expect(task.followUpEnabled, isTrue);
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, startsWith('follow-up-conversion:t-legacy-flag:'));
  });

  test('converting an existing FollowUp task is idempotent', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t-existing","title":"پیگیری","followUpEnabled":true,"followUps":[{"id":"f1","dateTime":"2026-08-15T10:15:00.000"}]}]',
    });
    final store = TaskStore();
    await store.convertToFollowUp('t-existing');
    final task = (await store.load()).single;
    expect(task.id, 't-existing');
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, 'f1');
  });

  test('throws when adding a follow-up to an unknown task', () async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});

    final store = TaskStore();
    final followUp = FollowUp(
      id: 'f1',
      dateTime: DateTime(2026, 8, 15, 10, 15),
    );

    expect(
      () => store.addFollowUp('missing', followUp),
      throwsA(isA<StateError>()),
    );
  });
  test('persists structured waiting-for-response state through canonical SQL storage', () async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      final task = Task(
        id: 'waiting-sql',
        title: 'منتظر پاسخ',
        followUps: [
          FollowUp(
            id: 'waiting-sql-fu',
            dateTime: DateTime(2026, 10, 15, 10),
            personIds: const ['person-1'],
            waitingForResponse: true,
            nextFollowUp: DateTime(2026, 10, 16, 10),
            reminderDate: DateTime(2026, 10, 15, 18),
          ),
        ],
      );

      await store.save([task]);
      final loaded = (await store.load()).single.followUps.single;

      expect(loaded.waitingForResponse, isTrue);
      expect(loaded.personIds, ['person-1']);
      expect(loaded.nextFollowUp, DateTime(2026, 10, 16, 10));
      expect(loaded.reminderDate, DateTime(2026, 10, 15, 18));
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

  test('linked Follow-up Reminder persists through canonical SQL reload and can be cleared independently', () async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      final scheduledAt = DateTime(2026, 10, 21, 11, 30);
      final task = Task(
        id: 'followup-reminder-sql',
        title: 'ارسال قرارداد',
        taskReminders: [
          TaskReminder(
            id: 'unrelated-reminder-sql',
            title: 'یادآور دیگر',
            date: DateTime(2026, 10, 22, 9),
            sequence: 1,
          ),
        ],
        nextReminderSequence: 2,
        followUps: [
          FollowUp(
            id: 'followup-reminder-sql-id',
            dateTime: DateTime(2026, 10, 20, 10),
            title: 'تماس با مشتری',
            result: 'در انتظار پاسخ',
            waitingForResponse: true,
            personIds: const ['person-sql'],
            nextFollowUp: DateTime(2026, 10, 23, 10),
            reminderDate: scheduledAt,
          ),
        ],
      );

      await store.save([task]);
      var restored = (await store.load()).single;
      expect(restored.taskReminders.where((item) => item.followUpId != null), hasLength(1));
      final linkedBefore = restored.taskReminders.singleWhere(
        (item) => item.followUpId == 'followup-reminder-sql-id',
      );
      expect(linkedBefore.title, 'تماس با مشتری');
      expect(linkedBefore.date, scheduledAt);
      expect(restored.followUps.single.personIds, ['person-sql']);
      expect(restored.followUps.single.waitingForResponse, isTrue);
      expect(restored.followUps.single.result, 'در انتظار پاسخ');
      expect(restored.followUps.single.nextFollowUp, DateTime(2026, 10, 23, 10));

      final originalFollowUp = restored.followUps.single;
      final titleEdited = FollowUp(
        id: originalFollowUp.id,
        dateTime: originalFollowUp.dateTime,
        title: 'عنوان اصلاح‌شده',
        note: originalFollowUp.note,
        result: originalFollowUp.result,
        reminderDate: originalFollowUp.reminderDate,
        nextFollowUp: originalFollowUp.nextFollowUp,
        completed: originalFollowUp.completed,
        waitingForResponse: originalFollowUp.waitingForResponse,
        personIds: originalFollowUp.personIds,
      );
      restored.syncFollowUpReminder(titleEdited);
      restored.followUps = [titleEdited];
      await store.save([restored]);
      restored = (await store.load()).single;
      final linkedAfter = restored.taskReminders.singleWhere(
        (item) => item.followUpId == 'followup-reminder-sql-id',
      );
      expect(linkedAfter.id, linkedBefore.id);
      expect(linkedAfter.date, scheduledAt);
      expect(linkedAfter.title, 'عنوان اصلاح‌شده');

      final current = restored.followUps.single;
      final cleared = FollowUp(
        id: current.id,
        dateTime: current.dateTime,
        title: current.title,
        note: current.note,
        result: current.result,
        reminderDate: null,
        nextFollowUp: current.nextFollowUp,
        completed: current.completed,
        waitingForResponse: current.waitingForResponse,
        personIds: current.personIds,
      );
      restored.syncFollowUpReminder(cleared);
      restored.followUps = [cleared];
      await store.save([restored]);
      restored = (await store.load()).single;
      expect(restored.followUps, hasLength(1));
      expect(restored.followUps.single.id, 'followup-reminder-sql-id');
      expect(restored.followUps.single.reminderDate, isNull);
      expect(restored.taskReminders.map((item) => item.id), ['unrelated-reminder-sql']);
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

}
