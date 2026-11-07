import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('Task Details preserves scroll offset across inline edit entry and successful save', (tester) async {
    Task? persisted;
    final task = Task(
      id: 'scroll-save-contract',
      title: 'کار با محتوای بلند',
      checklistEnabled: true,
      checklist: List<String>.generate(
        24,
        (index) => '[ ] مرحله شماره ${index + 1}',
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onTaskChanged: (candidate) async {
          persisted = candidate;
          return candidate;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final listFinder = find.byKey(const ValueKey('task-detail-content-list'));
    final initialList = tester.widget<ListView>(listFinder);
    final controller = initialList.controller!;
    await tester.drag(listFinder, const Offset(0, -420));
    await tester.pumpAndSettle();
    final before = controller.offset;
    expect(before, greaterThan(0));

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(controller.offset, before);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(persisted?.id, task.id);
    expect(controller.offset, before);
    expect(find.byKey(const ValueKey('task-detail-inline-edit-cancel')), findsNothing);
  });
}
