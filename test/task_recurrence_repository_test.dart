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

  test('Repeat Case 2: end date bounds schedule and remaining occurrences', () {
    final start = DateTime(2026, 10, 8, 9);
    final end = DateTime(2026, 10, 11, 9);
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: DateTime(2026, 10, 8, 9),
      endDate: DateTime(2026, 10, 11, 9),
    );

    final occurrences = rule.occurrencesBetween(
      anchor: start,
      from: start,
      to: DateTime(2026, 10, 12, 9),
    );

    expect(occurrences, [
      DateTime(2026, 10, 8, 9),
      DateTime(2026, 10, 9, 9),
      DateTime(2026, 10, 10, 9),
    ]);
    expect(occurrences.last.isBefore(end), isTrue);

    final completed = {occurrences.first.toIso8601String()};
    final remaining = occurrences
        .where((value) => !completed.contains(value.toIso8601String()))
        .length;
    expect(remaining, 2);
  });

  test('Repeat Case 3: count bounds total completed and remaining', () {
    final start = DateTime(2026, 10, 8, 9);
    const rule = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: DateTime(2026, 10, 8, 9),
      count: 4,
    );

    final occurrences = rule.occurrencesBetween(
      anchor: start,
      from: start,
      to: DateTime(2026, 10, 20, 9),
    );

    expect(occurrences, [
      DateTime(2026, 10, 8, 9),
      DateTime(2026, 10, 9, 9),
      DateTime(2026, 10, 10, 9),
      DateTime(2026, 10, 11, 9),
    ]);

    final completed = {
      occurrences[0].toIso8601String(),
      occurrences[1].toIso8601String(),
    };
    expect(occurrences.length, 4);
    expect(completed.length, 2);
    expect(occurrences.length - completed.length, 2);
  });

  test('Repeat Case 4: completed history remains immutable while future schedule is adjustable', () async {
    final past = DateTime(2026, 10, 8, 9);
    final future = DateTime(2026, 10, 9, 9);
    final store = TaskStore();
    await store.save([
      Task(
        id: 'history-adjustment',
        title: 'تکرار با تاریخچه',
        reminderDate: past,
        recurrence: const RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 1,
        ),
        occurrenceHistory: {
          past.toIso8601String(): {
            'scheduledDate': past.toIso8601String(),
            'status': RecurrenceOccurrenceStatus.completed.name,
            'completionDate': DateTime(2026, 10, 8, 9, 30).toIso8601String(),
          },
        },
      ),
    ]);

    final repository = TaskRecurrenceRepository(store: store);
    await repository.setRule(
      'history-adjustment',
      const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      ),
    );

    final updated = (await store.load()).single;
    expect(updated.occurrenceHistory[past.toIso8601String()]?['scheduledDate'], past.toIso8601String());
    expect(updated.occurrenceHistory[past.toIso8601String()]?['status'], RecurrenceOccurrenceStatus.completed.name);
    expect(updated.occurrenceHistory[past.toIso8601String()]?['completionDate'], DateTime(2026, 10, 8, 9, 30).toIso8601String());
    expect(updated.recurrence?.interval, 2);
    expect(updated.recurrence?.nextOccurrence(future), DateTime(2026, 10, 11, 9));
  });

  test('Repeat Case 5: checklist state is independent per occurrence after reload', () async {
    final start = DateTime(2026, 10, 8, 9);
    final next = DateTime(2026, 10, 9, 9);
    final store = TaskStore();
    await store.save([
      Task(
        id: 'checklist-evidence',
        title: 'تکرار با چک‌لیست',
        checklist: const ['[ ] اول', '[ ] دوم'],
        reminderDate: start,
        recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      ),
    ]);

    final repository = TaskRecurrenceRepository(store: store);
    await repository.setChecklistForOccurrence(
      'checklist-evidence',
      start,
      const ['[x] اول', '[ ] دوم'],
    );

    expect(
      await repository.checklistForOccurrence('checklist-evidence', start),
      const ['[x] اول', '[ ] دوم'],
    );
    expect(
      await repository.checklistForOccurrence('checklist-evidence', next),
      const ['[ ] اول', '[ ] دوم'],
    );

    final reloaded = (await TaskStore().load()).single;
    expect(reloaded.checklistOccurrences[start.toIso8601String()], const ['[x] اول', '[ ] دوم']);
    expect(reloaded.checklistOccurrences.containsKey(next.toIso8601String()), isFalse);
  });
}
