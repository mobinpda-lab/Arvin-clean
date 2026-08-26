import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_recurrence_page.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('UI enables recurrence and persists interval on canonical Task', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore();
    await store.save([
      Task(
        id: 'ui-task',
        title: 'تمرین روزانه',
        reminderDate: DateTime(2026, 8, 20, 9),
      ),
    ]);
    final repository = TaskRecurrenceRepository(
      store: store,
      now: () => DateTime(2026, 8, 26, 8),
    );

    await tester.pumpWidget(
      MaterialApp(home: TaskRecurrencePage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('تمرین روزانه'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('recurrence-enabled')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('recurrence-interval')),
      '2',
    );
    await tester.tap(find.byKey(const ValueKey('recurrence-save')));
    await tester.pumpAndSettle();

    final task = (await store.load()).single;
    expect(task.recurrence?.frequency, RecurrenceFrequency.daily);
    expect(task.recurrence?.interval, 2);
    expect(find.text('تکرار ذخیره شد'), findsOneWidget);
  });

  testWidgets('Resume From Today advances reminder and keeps canonical recurrence', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore();
    await store.save([
      Task(
        id: 'resume-task',
        title: 'پیگیری تکراری',
        reminderDate: DateTime(2026, 8, 20, 9),
        recurrence: const RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 2,
        ),
      ),
    ]);
    final repository = TaskRecurrenceRepository(
      store: store,
      now: () => DateTime(2026, 8, 26, 8),
    );

    await tester.pumpWidget(
      MaterialApp(home: TaskRecurrencePage(repository: repository)),
    );
    await tester.pumpAndSettle();

    final resume = find.byKey(const ValueKey('recurrence-resume-today'));
    expect(resume, findsOneWidget);
    await tester.tap(resume);
    await tester.pumpAndSettle();

    final task = (await store.load()).single;
    expect(task.reminderDate, DateTime(2026, 8, 26, 9));
    expect(task.recurrence?.interval, 2);
    expect(find.text('برنامه تکرار از امروز ادامه پیدا کرد'), findsOneWidget);
  });

  testWidgets('Timeline opens recurrence UI on the same canonical Task', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = TaskStore();
    final first = Task(id: 'first', title: 'کار اول', createdAt: DateTime(2026, 8, 1));
    final second = Task(id: 'second', title: 'کار دوم', createdAt: DateTime(2026, 8, 2));
    await store.save([first, second]);

    await tester.pumpWidget(MaterialApp(home: TaskTimelinePage(task: second)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('timeline-open-recurrence')));
    await tester.pumpAndSettle();

    expect(find.text('تکرار کارها'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recurrence-task-picker-second')),
      findsOneWidget,
    );
  });
}
