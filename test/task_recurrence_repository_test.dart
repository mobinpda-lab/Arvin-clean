import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('set and clear recurrence persist only through canonical TaskStore', () async {
    final store = TaskStore();
    await store.save([
      Task(
        id: 'task-1',
        title: 'کار تکرارشونده',
        reminderDate: DateTime(2026, 8, 20, 9),
      ),
    ]);
    final repository = TaskRecurrenceRepository(
      store: store,
      now: () => DateTime(2026, 8, 26, 8),
    );

    await repository.setRule(
      'task-1',
      const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
      ),
    );

    var loaded = await store.load();
    expect(loaded.single.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(loaded.single.recurrence?.interval, 2);

    final stored = (await TaskStore().load()).single;
    expect(stored.recurrence, isNotNull);

    await repository.setRule('task-1', null);
    loaded = await store.load();
    expect(loaded.single.recurrence, isNull);
  });

  test('resume from today updates reminder without rewriting follow-up history', () async {
    final originalFollowUp = FollowUp(
      id: 'fu-1',
      dateTime: DateTime(2026, 8, 10, 12),
      note: 'تاریخچه باید حفظ شود',
      result: 'منتظر پاسخ',
    );
    final store = TaskStore();
    await store.save([
      Task(
        id: 'task-2',
        title: 'کار روزانه',
        reminderDate: DateTime(2026, 8, 20, 9),
        recurrence: const RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 2,
        ),
        followUpEnabled: true,
        followUps: [originalFollowUp],
      ),
    ]);
    final repository = TaskRecurrenceRepository(
      store: store,
      now: () => DateTime(2026, 8, 26, 8),
    );

    await repository.resumeFromToday(
      'task-2',
      target: DateTime(2026, 8, 26, 8),
    );

    final task = (await store.load()).single;
    expect(task.reminderDate, DateTime(2026, 8, 26, 9));
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, originalFollowUp.id);
    expect(task.followUps.single.note, originalFollowUp.note);
    expect(task.followUps.single.result, originalFollowUp.result);
  });

  test('recurring checklist occurrences keep independent tick state', () async {
    final store = TaskStore();
    await store.save([
      Task(
        id: 'checklist-recurring',
        title: 'آماده‌سازی مدرسه',
        checklist: const ['[ ] کیف', '[ ] خوراکی', '[ ] لباس'],
        reminderDate: DateTime(2026, 10, 3, 6),
        recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      ),
    ]);
    final repository = TaskRecurrenceRepository(store: store);
    final saturday = DateTime(2026, 10, 3, 6);
    final sunday = DateTime(2026, 10, 4, 6);

    expect(
      await repository.checklistForOccurrence('checklist-recurring', saturday),
      const ['[ ] کیف', '[ ] خوراکی', '[ ] لباس'],
    );
    await repository.setChecklistForOccurrence(
      'checklist-recurring',
      saturday,
      const ['[x] کیف', '[x] خوراکی', '[ ] لباس'],
    );

    expect(
      await repository.checklistForOccurrence('checklist-recurring', saturday),
      const ['[x] کیف', '[x] خوراکی', '[ ] لباس'],
    );
    expect(
      await repository.checklistForOccurrence('checklist-recurring', sunday),
      const ['[ ] کیف', '[ ] خوراکی', '[ ] لباس'],
    );

    final reloaded = (await TaskStore().load()).single;
    expect(reloaded.checklistOccurrences, {
      saturday.toIso8601String(): const ['[x] کیف', '[x] خوراکی', '[ ] لباس'],
    });
  });

  test('resume requires both recurrence and reminder schedule', () async {
    final store = TaskStore();
    await store.save([
      Task(id: 'no-rule', title: 'بدون تکرار', reminderDate: DateTime(2026, 8, 20)),
      Task(
        id: 'no-reminder',
        title: 'بدون یادآوری',
        recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      ),
    ]);
    final repository = TaskRecurrenceRepository(store: store);

    await expectLater(
      repository.resumeFromToday('no-rule'),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.resumeFromToday('no-reminder'),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.setRule('missing', null),
      throwsA(isA<StateError>()),
    );
  });
  test('complete occurrence updates history without completing canonical Task', () async {
    final store = TaskStore();
    final occurrence = DateTime(2026, 10, 8, 9);
    await store.save([
      Task(
        id: 'complete-occurrence',
        title: 'Recurring',
        reminderDate: occurrence,
        recurrence: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
        ),
      ),
    ]);

    final repository = TaskRecurrenceRepository(
      store: store,
      now: () => DateTime(2026, 10, 8, 9, 30),
    );
    await repository.completeOccurrence('complete-occurrence', occurrence);

    final task = (await store.load()).single;
    expect(task.completed, isFalse);
    expect(
      task.occurrenceHistory[occurrence.toIso8601String()]?['status'],
      RecurrenceOccurrenceStatus.completed.name,
    );
    expect(
      (await repository.occurrenceState('complete-occurrence', occurrence))['status'],
      RecurrenceOccurrenceStatus.completed.name,
    );
  });

  test('turning Repeat off keeps Task and occurrence history', () async {
    final store = TaskStore();
    final occurrence = DateTime(2026, 10, 8, 9);
    await store.save([
      Task(
        id: 'disable-repeat',
        title: 'Recurring',
        reminderDate: occurrence,
        recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        occurrenceHistory: {
          occurrence.toIso8601String(): {
            'scheduledDate': occurrence.toIso8601String(),
            'status': RecurrenceOccurrenceStatus.completed.name,
          },
        },
      ),
    ]);

    final repository = TaskRecurrenceRepository(store: store);
    await repository.setRule('disable-repeat', null);

    final task = (await store.load()).single;
    expect(task.id, 'disable-repeat');
    expect(task.recurrence, isNull);
    expect(
      task.occurrenceHistory[occurrence.toIso8601String()]?['status'],
      RecurrenceOccurrenceStatus.completed.name,
    );
  });

}
