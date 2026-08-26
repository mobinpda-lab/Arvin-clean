import 'package:arvin/models/task.dart';
import 'package:arvin/task_next_action_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('orders overdue, scheduled, then unscheduled canonical tasks',
      (tester) async {
    final now = DateTime(2026, 8, 26, 12);
    final tasks = [
      Task(id: 'later', title: 'کار زمان‌دار', reminderDate: DateTime(2026, 8, 27, 9)),
      Task(id: 'free', title: 'کار بدون زمان'),
      Task(id: 'late', title: 'کار عقب‌افتاده', reminderDate: DateTime(2026, 8, 25, 9)),
      Task(id: 'done', title: 'کار تمام‌شده', completed: true),
    ];

    await tester.pumpWidget(
      MaterialApp(home: TaskNextActionPage(tasks: tasks, now: now)),
    );
    await tester.pumpAndSettle();

    expect(find.text('اقدام بعدی'), findsOneWidget);
    expect(find.text('کار تمام‌شده'), findsNothing);

    final overdue = tester.getTopLeft(find.text('کار عقب‌افتاده')).dy;
    final scheduled = tester.getTopLeft(find.text('کار زمان‌دار')).dy;
    final unscheduled = tester.getTopLeft(find.text('کار بدون زمان')).dy;
    expect(overdue, lessThan(scheduled));
    expect(scheduled, lessThan(unscheduled));
    expect(find.text('عقب‌افتاده • 2026/08/25 • 09:00'), findsOneWidget);
    expect(find.text('زمان‌بندی‌شده • 2026/08/27 • 09:00'), findsOneWidget);
    expect(find.text('بدون زمان‌بندی'), findsOneWidget);
  });

  testWidgets('shows an explicit empty state when no open task exists',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TaskNextActionPage(
          tasks: [Task(id: 'done', title: 'تمام', completed: true)],
          now: DateTime(2026, 8, 26, 12),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اقدام بازی برای پیشنهاد وجود ندارد'), findsOneWidget);
  });
}
