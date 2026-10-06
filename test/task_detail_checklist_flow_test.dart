import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('task detail displays checklist and toggles an item', (tester) async {
    var task = Task(
      id: 'checklist-detail-1',
      title: 'آماده‌سازی مدرسه',
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

    final progress = find.byKey(const ValueKey('task-detail-checklist-progress'));
    expect(find.byKey(const ValueKey('task-detail-checklist')), findsOneWidget);
    expect(progress, findsOneWidget);
    expect(tester.widget<Text>(progress).data, isNotEmpty);
    expect(find.text('کیف'), findsOneWidget);
    expect(find.text('خوراکی'), findsOneWidget);
    expect(find.text('لباس'), findsOneWidget);

    final item = find.byKey(const ValueKey('task-detail-checklist-item-0'));
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(task.checklist, contains('[x] کیف'));
    expect(tester.widget<Text>(progress).data, isNotEmpty);
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
