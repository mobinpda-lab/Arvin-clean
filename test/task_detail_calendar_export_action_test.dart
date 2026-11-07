import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('Task Details explicit Send to Device Calendar button sends only its Task',
      (tester) async {
    final task = Task(id: 'detail-export-task', title: 'کار آزمایشی');
    Task? selected;
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onRegisterTaskToDeviceCalendar: (value) async { selected = value; },
      ),
    ));
    final button = find.byKey(const ValueKey('task-detail-send-device-calendar'));
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pump();
    expect(identical(selected, task), isTrue);
  });
}
