import 'dart:convert';

import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), contains(TaskStore.key));
    expect(preferences.getKeys(), hasLength(1));
    final raw = jsonDecode(preferences.getString(TaskStore.key)!) as List;
    expect((raw.single as Map)['recurrence'], isNotNull);

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
}
