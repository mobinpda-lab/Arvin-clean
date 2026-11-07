import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('task detail displays checklist and toggles an item', (tester) async {
    var task = Task(
      id: 'checklist-detail-1',
      title: 'آماده‌سازی مدرسه',
      checklistEnabled: true,
      checklist: const ['[ ] کیف', '[x] خوراکی', '[ ] لباس'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onChecklistChanged: (current, checklist) async {
            current.checklist = List<String>.of(checklist);
            task = current;
            return current;
          },
        ),
      ),
    );

    final detailScrollable = find.descendant(
      of: find.byKey(const ValueKey('task-detail-page')),
      matching: find.byType(Scrollable),
    ).first;
    final checklistCard = find.byKey(const ValueKey('task-detail-checklist'));
    await tester.scrollUntilVisible(checklistCard, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    final progress = find.byKey(const ValueKey('task-detail-checklist-progress'));
    expect(checklistCard, findsOneWidget);
    expect(progress, findsOneWidget);
    expect(tester.widget<Text>(progress).data, isNotEmpty);
    expect(find.text('کیف'), findsOneWidget);
    expect(find.text('خوراکی'), findsOneWidget);
    expect(find.text('لباس'), findsOneWidget);

    final item = find.byKey(const ValueKey('task-detail-checklist-item-0'));
    final checkbox = find.descendant(of: item, matching: find.byType(Checkbox));
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(task.checklist, contains('[x] کیف'));
    expect(tester.widget<Text>(progress).data, isNotEmpty);
  });

  testWidgets('task detail hides disabled checklist while retaining its rows', (tester) async {
    final task = Task(
      id: 'disabled-checklist-detail',
      title: 'کار با چک‌لیست خاموش',
      checklist: const ['[ ] کیف'],
      checklistEnabled: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(task: task),
      ),
    );

    expect(find.byKey(const ValueKey('task-detail-checklist')), findsNothing);
    expect(task.checklist, const ['[ ] کیف']);
  });

  testWidgets('task detail hides checklist section when task has no checklist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: Task(id: 'no-checklist', title: 'کار ساده'),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('task-detail-checklist')), findsNothing);
  });
}
