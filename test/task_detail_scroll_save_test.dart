import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('Task Details preserves scroll offset while inline fields autosave', (tester) async {
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
    final list = tester.widget<ListView>(listFinder);
    final controller = list.controller!;
    await tester.drag(listFinder, const Offset(0, -420));
    await tester.pumpAndSettle();
    final before = controller.offset;
    expect(before, greaterThan(0));

    final title = find.byKey(const ValueKey('task-detail-title'));
    await tester.ensureVisible(title);
    await tester.enterText(title, 'عنوان ذخیره‌شده بدون حالت ویرایش');
    await tester.pumpAndSettle();

    expect(persisted?.title, 'عنوان ذخیره‌شده بدون حالت ویرایش');
    expect(controller.offset, before);
    expect(find.byKey(const ValueKey('task-detail-inline-edit-toggle')), findsNothing);
  });
}
