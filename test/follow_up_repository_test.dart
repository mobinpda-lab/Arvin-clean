import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('reads legacy followUpDate without rewriting it', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUpDate":"2026-08-14T09:30:00.000"}]',
    });

    const repository = FollowUpRepository();
    final followUps = await repository.loadForTask('t1');

    expect(followUps, hasLength(1));
    expect(followUps.single.dateTime, DateTime(2026, 8, 14, 9, 30));
    expect(followUps.single.note, 'مهاجرت خودکار از تاریخ پیگیری قبلی');
  });

  test('appends a FollowUp while preserving the task envelope', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUpDate":"2026-08-14T09:30:00.000"}]',
    });

    const repository = FollowUpRepository();
    final followUp = FollowUp(
      id: 'f2',
      dateTime: DateTime(2026, 8, 15, 10, 15),
      note: 'تماس مجدد',
      result: 'پاسخ دریافت شد',
      nextFollowUp: DateTime(2026, 8, 20, 10, 15),
    );

    await repository.add('t1', followUp);
    final followUps = await repository.loadForTask('t1');

    expect(followUps, hasLength(2));
    expect(followUps.last.id, 'f2');
    expect(followUps.last.result, 'پاسخ دریافت شد');
  });

  test('updates one FollowUp without changing siblings or task envelope',
      () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'کار',
          'category': 'فروش',
          'followUps': [
            {
              'id': 'f1',
              'dateTime': '2026-08-15T10:15:00.000',
              'note': 'تماس اول',
              'result': null,
              'nextFollowUp': null,
            },
            {
              'id': 'f2',
              'dateTime': '2026-08-20T11:00:00.000',
              'note': 'تماس دوم',
              'result': 'منتظر پاسخ',
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    const repository = FollowUpRepository();
    final edited = FollowUp(
      id: 'f1',
      dateTime: DateTime(2026, 8, 16, 9, 45),
      note: 'تماس اول ویرایش شد',
      result: 'پاسخ دریافت شد',
      nextFollowUp: DateTime(2026, 8, 18, 9, 45),
    );

    await repository.update('t1', edited);

    final followUps = await repository.loadForTask('t1');
    expect(followUps, hasLength(2));
    expect(followUps.first.id, 'f1');
    expect(followUps.first.note, 'تماس اول ویرایش شد');
    expect(followUps.first.result, 'پاسخ دریافت شد');
    expect(followUps.last.id, 'f2');
    expect(followUps.last.note, 'تماس دوم');

    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final task = Map<String, dynamic>.from(stored.single as Map);
    expect(task['title'], 'کار');
    expect(task['category'], 'فروش');
  });

  test('completion preserves Follow-up title, person links, waiting and reminder state', () async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't-complete',
          'title': 'تماس',
          'followUps': [
            {
              'id': 'f-complete',
              'dateTime': '2026-10-15T10:00:00.000',
              'title': 'تماس با آنا',
              'note': 'جزئیات تماس',
              'result': 'منتظر پاسخ',
              'reminderDate': '2026-10-15T18:00:00.000',
              'nextFollowUp': '2026-10-16T10:00:00.000',
              'completed': false,
              'waitingForResponse': true,
              'personIds': ['ana', 'reza'],
            },
          ],
        },
      ]),
    });

    const repository = FollowUpRepository();
    await repository.setCompleted('t-complete', 'f-complete', true);

    final updated = (await repository.loadForTask('t-complete')).single;
    expect(updated.id, 'f-complete');
    expect(updated.title, 'تماس با آنا');
    expect(updated.note, 'جزئیات تماس');
    expect(updated.completed, isTrue);
    expect(updated.waitingForResponse, isTrue);
    expect(updated.personIds, ['ana', 'reza']);
    expect(updated.reminderDate, DateTime(2026, 10, 15, 18));
    expect(updated.nextFollowUp, DateTime(2026, 10, 16, 10));
  });

  test('update fails when the FollowUp id does not exist', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'کار',
          'followUps': [
            {
              'id': 'f1',
              'dateTime': '2026-08-15T10:15:00.000',
              'note': 'تماس',
              'result': null,
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    const repository = FollowUpRepository();
    final missing = FollowUp(
      id: 'missing',
      dateTime: DateTime(2026, 8, 16, 9),
    );

    expect(
      () => repository.update('t1', missing),
      throwsA(isA<StateError>()),
    );
  });

  test('FollowUp reminder mirrors to stable TaskReminder and clearing is scoped', () async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't-reminder',
          'title': 'قرارداد فروش',
          'taskReminders': [
            {
              'id': 'unrelated-reminder',
              'title': 'یادآور مستقل',
              'date': '2026-10-21T09:00:00.000',
              'isAllDay': false,
              'sequence': 1,
            },
          ],
          'nextReminderSequence': 2,
        },
      ]),
    });

    const repository = FollowUpRepository();
    final original = FollowUp(
      id: 'f-reminder',
      dateTime: DateTime(2026, 10, 20, 10),
      title: 'بازبینی قرارداد',
      note: 'یادداشت باید حفظ شود',
      result: 'منتظر پاسخ',
      reminderDate: DateTime(2026, 10, 22, 14, 30),
      nextFollowUp: DateTime(2026, 10, 24, 10),
      waitingForResponse: true,
      personIds: const ['person-1'],
    );

    await repository.add('t-reminder', original);
    var stored = (await TaskStore().load()).single;
    var linked = stored.taskReminders
        .where((item) => item.followUpId == 'f-reminder')
        .single;
    expect(linked.id, 'follow-up-reminder-f-reminder');
    expect(linked.title, 'بازبینی قرارداد');
    expect(linked.date, DateTime(2026, 10, 22, 14, 30));
    expect(stored.taskReminders.any((item) => item.id == 'unrelated-reminder'), isTrue);

    final edited = FollowUp(
      id: original.id,
      dateTime: original.dateTime,
      title: 'بازبینی نهایی قرارداد',
      note: original.note,
      result: original.result,
      reminderDate: DateTime(2026, 10, 23, 16),
      nextFollowUp: original.nextFollowUp,
      waitingForResponse: original.waitingForResponse,
      personIds: original.personIds,
    );
    await repository.update('t-reminder', edited);
    stored = (await TaskStore().load()).single;
    linked = stored.taskReminders
        .where((item) => item.followUpId == 'f-reminder')
        .single;
    expect(linked.id, 'follow-up-reminder-f-reminder');
    expect(linked.title, 'بازبینی نهایی قرارداد');
    expect(linked.date, DateTime(2026, 10, 23, 16));

    final cleared = FollowUp(
      id: edited.id,
      dateTime: edited.dateTime,
      title: edited.title,
      note: edited.note,
      result: edited.result,
      reminderDate: null,
      nextFollowUp: edited.nextFollowUp,
      waitingForResponse: edited.waitingForResponse,
      personIds: edited.personIds,
    );
    await repository.update('t-reminder', cleared);
    stored = (await TaskStore().load()).single;
    expect(stored.followUps.single.id, 'f-reminder');
    expect(stored.followUps.single.result, 'منتظر پاسخ');
    expect(stored.followUps.single.waitingForResponse, isTrue);
    expect(stored.followUps.single.personIds, ['person-1']);
    expect(stored.followUps.single.nextFollowUp, DateTime(2026, 10, 24, 10));
    expect(stored.taskReminders.any((item) => item.followUpId == 'f-reminder'), isFalse);
    expect(stored.taskReminders.single.id, 'unrelated-reminder');
  });

  test('nextFollowUp alone does not create an independent TaskReminder', () async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {'id': 't-next-only', 'title': 'کار مادر'},
      ]),
    });

    const repository = FollowUpRepository();
    await repository.add(
      't-next-only',
      FollowUp(
        id: 'f-next-only',
        dateTime: DateTime(2026, 10, 20, 10),
        nextFollowUp: DateTime(2026, 10, 22, 10),
      ),
    );

    final stored = (await TaskStore().load()).single;
    expect(stored.followUps.single.nextFollowUp, DateTime(2026, 10, 22, 10));
    expect(stored.taskReminders, isEmpty);
  });


  test('re-saving the same FollowUp identity does not duplicate its reminder', () async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {'id': 't-idempotent', 'title': 'کار'},
      ]),
    });

    const repository = FollowUpRepository();
    final followUp = FollowUp(
      id: 'f-idempotent',
      dateTime: DateTime(2026, 10, 20, 10),
      title: 'پیگیری تکرارپذیر',
      reminderDate: DateTime(2026, 10, 22, 10),
    );

    await repository.add('t-idempotent', followUp);
    await repository.add('t-idempotent', followUp);

    final stored = (await TaskStore().load()).single;
    expect(stored.followUps, hasLength(1));
    expect(stored.taskReminders.where((item) => item.followUpId == 'f-idempotent'),
        hasLength(1));
  });


  test('FollowUp title fallback and title-only edit preserve linked reminder identity and time', () async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't-title-fallback',
          'title': '  قرارداد مادر  ',
          'taskReminders': [],
          'nextReminderSequence': 1,
        },
      ]),
    });

    const repository = FollowUpRepository();
    await repository.add(
      't-title-fallback',
      FollowUp(
        id: 'f-parent-fallback',
        dateTime: DateTime(2026, 10, 20, 10),
        title: '   ',
        reminderDate: DateTime(2026, 10, 22, 14, 30),
        personIds: const ['person-1'],
      ),
    );
    await repository.add(
      't-title-fallback',
      FollowUp(
        id: 'f-empty-fallback',
        dateTime: DateTime(2026, 10, 20, 11),
        title: '',
        reminderDate: DateTime(2026, 10, 23, 14, 30),
      ),
    );
    var stored = (await TaskStore().load()).single;
    var parentFallback = stored.taskReminders
        .singleWhere((item) => item.followUpId == 'f-parent-fallback');
    final stableId = parentFallback.id;
    final stableTime = parentFallback.date;

    expect(parentFallback.title, 'پیگیری — قرارداد مادر');
    expect(
      stored.taskReminders
          .singleWhere((item) => item.followUpId == 'f-empty-fallback')
          .title,
      'پیگیری — قرارداد مادر',
    );

    final edited = FollowUp(
      id: 'f-parent-fallback',
      dateTime: DateTime(2026, 10, 20, 10),
      title: 'عنوان تازه',
      reminderDate: stableTime,
      personIds: const ['person-1'],
    );
    await repository.update('t-title-fallback', edited);
    await repository.update('t-title-fallback', edited);

    stored = (await TaskStore().load()).single;
    parentFallback = stored.taskReminders
        .singleWhere((item) => item.followUpId == 'f-parent-fallback');
    expect(parentFallback.id, stableId);
    expect(parentFallback.title, 'عنوان تازه');
    expect(parentFallback.date, stableTime);
    expect(
      stored.taskReminders.where((item) => item.followUpId == 'f-parent-fallback'),
      hasLength(1),
    );
    expect(stored.followUps.singleWhere((item) => item.id == 'f-parent-fallback').personIds,
        ['person-1']);
  });

  test('empty FollowUp and parent titles use generic reminder title', () async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't-empty-titles',
          'title': '   ',
        },
      ]),
    });

    const repository = FollowUpRepository();
    await repository.add(
      't-empty-titles',
      FollowUp(
        id: 'f-empty-titles',
        dateTime: DateTime(2026, 10, 20, 10),
        title: '  ',
        reminderDate: DateTime(2026, 10, 22, 14, 30),
      ),
    );
    final stored = (await TaskStore().load()).single;
    expect(
      stored.taskReminders.singleWhere((item) => item.followUpId == 'f-empty-titles').title,
      'پیگیری',
    );
  });

}
