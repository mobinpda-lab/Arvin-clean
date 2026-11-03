import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_move_to_today_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Task Details explicit today action sits below Due Date and persists only the date change',
    (tester) async {
      await TaskStore.resetTestDatabase();
      addTearDown(TaskStore.resetTestDatabase);
      final store = TaskStore();
      final oldDueDate = DateTime(2026, 10, 20, 14, 35, 12);
      final reminderDate = DateTime(2026, 11, 8, 9, 10);
      final followUpDate = DateTime(2026, 10, 18, 11, 20);
      final followUp = FollowUp(
        id: 'due-action-history',
        dateTime: followUpDate,
        note: 'سابقه باید محفوظ بماند',
        nextFollowUp: DateTime(2026, 11, 12, 8),
        completed: true,
      );
      final task = Task(
        id: 'due-action-task',
        title: 'کار دارای موعد',
        description: 'توضیح نباید تغییر کند',
        dueDate: oldDueDate,
        reminderDate: reminderDate,
        allDay: false,
        checklist: const <String>['[ ] مورد اول', '[x] مورد دوم'],
        followUpEnabled: true,
        followUpDate: followUpDate,
        followUps: <FollowUp>[followUp],
      );
      await store.save(<Task>[task]);

      final fixedNow = DateTime(2026, 11, 3, 18, 45);
      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            task: task,
            now: fixedNow,
            onMoveDueDateToToday: (current) =>
                TaskMoveToTodayService(store: store).move(current.id, now: fixedNow),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dueRow = find.byKey(const ValueKey('task-detail-due-date'));
      final todayAction = find.byKey(const ValueKey('task-detail-move-due-date-to-today'));
      expect(dueRow, findsOneWidget);
      expect(todayAction, findsOneWidget);
      expect(
        tester.getTopLeft(todayAction).dy,
        greaterThan(tester.getBottomLeft(dueRow).dy),
      );

      // The Due Date row is display-only; it must not invoke the quick action.
      await tester.tap(dueRow);
      await tester.pump();
      expect((await store.load()).single.dueDate, oldDueDate);

      await tester.ensureVisible(todayAction);
      await tester.tap(todayAction);
      await tester.pumpAndSettle();

      final expectedDueDate = DateTime(2026, 11, 3, 14, 35);
      final persisted = (await store.load()).single;
      expect(persisted.dueDate, expectedDueDate);
      expect(
        tester.widget<Text>(dueRow).data,
        contains('۱۴۰۵/۰۸/۱۲ • ۱۴:۳۵'),
      );
      expect(persisted.title, 'کار دارای موعد');
      expect(persisted.description, 'توضیح نباید تغییر کند');
      expect(persisted.reminderDate, reminderDate);
      expect(persisted.allDay, isFalse);
      expect(persisted.checklist, const <String>['[ ] مورد اول', '[x] مورد دوم']);
      expect(persisted.followUpEnabled, isTrue);
      expect(persisted.followUpDate, followUpDate);
      expect(persisted.followUps, hasLength(1));
      expect(persisted.followUps.single.id, 'due-action-history');
      expect(persisted.followUps.single.dateTime, followUpDate);
      expect(persisted.followUps.single.note, 'سابقه باید محفوظ بماند');
      expect(
        persisted.followUps.single.nextFollowUp,
        DateTime(2026, 11, 12, 8),
      );
    },
  );

  testWidgets('all-day Task due date moves to local today at midnight', (tester) async {
    await TaskStore.resetTestDatabase();
    addTearDown(TaskStore.resetTestDatabase);
    final store = TaskStore();
    final task = Task(
      id: 'all-day-due-action',
      title: 'کار تمام‌روز',
      allDay: true,
      dueDate: DateTime(2026, 10, 20),
    );
    await store.save(<Task>[task]);

    final fixedNow = DateTime(2026, 11, 3, 18, 45);
    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          now: fixedNow,
          onMoveDueDateToToday: (current) =>
              TaskMoveToTodayService(store: store).move(current.id, now: fixedNow),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('task-detail-move-due-date-to-today')),
    );
    await tester.tap(find.byKey(const ValueKey('task-detail-move-due-date-to-today')));
    await tester.pumpAndSettle();

    final persisted = (await store.load()).single;
    expect(persisted.dueDate, DateTime(2026, 11, 3));
    expect(persisted.allDay, isTrue);
  });
}
