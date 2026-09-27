import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin_clean/models/task.dart';
import 'package:arvin_clean/task_detail_page.dart';

void main() {
  testWidgets('task detail completion toggles back to undone on second tap', (tester) async {
    var task = Task(id: 'toggle-1', title: 'کار تستی');
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onComplete: (current) async {
          current.completed = !current.completed;
          task = current;
          return current;
        },
      ),
    ));

    final button = find.byKey(const ValueKey('task-detail-complete'));
    expect(find.text('انجام کار'), findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(task.completed, isTrue);
    expect(find.text('بازگشت به انجام‌نشده'), findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(task.completed, isFalse);
    expect(find.text('انجام کار'), findsOneWidget);
  });
}