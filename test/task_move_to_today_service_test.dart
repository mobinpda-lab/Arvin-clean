import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_move_to_today_service.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Move to Today changes due day only and preserves canonical envelope',
      () async {
    final store = TaskStore();
    final original = Task(
      id: 'task-1',
      title: 'پیگیری مشتری',
      description: 'شرح',
      dueDate: DateTime(2026, 8, 20, 14, 35),
      reminderDate: DateTime(2026, 8, 19, 9, 15),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 21, 10),
      category: 'مشتریان',
      checklist: <String>['تماس', 'ارسال'],
      tags: <String>['مهم'],
      followUps: <FollowUp>[
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 8, 18, 11),
          note: 'تماس اول',
          result: 'منتظر پاسخ',
          nextFollowUp: DateTime(2026, 8, 21, 10),
        ),
      ],
      createdAt: DateTime(2026, 8, 10, 8),
      updatedAt: DateTime(2026, 8, 18, 11),
    );
    await store.save(<Task>[original]);

    final now = DateTime(2026, 8, 28, 10, 7);
    final moved = await TaskMoveToTodayService(store: store).move(
      original.id,
      now: now,
    );
    final reloaded = (await store.load()).single;

    expect(moved.id, original.id);
    expect(reloaded.id, original.id);
    expect(reloaded.dueDate, DateTime(2026, 8, 28, 14, 35));
    expect(reloaded.updatedAt, now);
    expect(reloaded.reminderDate, DateTime(2026, 8, 19, 9, 15));
    expect(reloaded.followUpDate, DateTime(2026, 8, 21, 10));
    expect(reloaded.followUps.single.id, 'follow-1');
    expect(reloaded.followUps.single.note, 'تماس اول');
    expect(reloaded.category, 'مشتریان');
    expect(reloaded.checklist, <String>['تماس', 'ارسال']);
    expect(reloaded.tags, <String>['مهم']);
    expect(reloaded.title, original.title);
    expect(reloaded.description, original.description);
  });

  test('undated task gets today with the current local hour and minute', () async {
    final store = TaskStore();
    await store.save(<Task>[Task(id: 'task-2', title: 'بدون تاریخ')]);
    final now = DateTime(2026, 8, 28, 16, 42, 30);

    await TaskMoveToTodayService(store: store).move('task-2', now: now);

    final reloaded = (await store.load()).single;
    expect(reloaded.dueDate, DateTime(2026, 8, 28, 16, 42));
  });

  test('missing archived and trashed tasks fail without changing storage',
      () async {
    final store = TaskStore();
    final archived = Task(id: 'archived', title: 'بایگانی', archived: true);
    final trashed = Task(id: 'trashed', title: 'سطل', trashed: true);
    await store.save(<Task>[archived, trashed]);
    final before = (await store.load()).map((task) => task.toJson()).toList();
    final service = TaskMoveToTodayService(store: store);

    await expectLater(
      service.move('missing', now: DateTime(2026, 8, 28)),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      service.move('archived', now: DateTime(2026, 8, 28)),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      service.move('trashed', now: DateTime(2026, 8, 28)),
      throwsA(isA<StateError>()),
    );

    final after = (await store.load()).map((task) => task.toJson()).toList();
    expect(after, before);
  });
}
