import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ordinary Task detail is read-only and has Edit without add FollowUp',
      (tester) async {
    final task = Task(
      id: 'ordinary',
      title: 'ارسال قرارداد',
      description: 'نسخه نهایی برای مشتری',
      dueDate: DateTime(2026, 8, 30, 14, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async => value,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
    expect(find.text('ارسال قرارداد'), findsOneWidget);
    expect(find.text('نسخه نهایی برای مشتری'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-edit')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-add-followup')), findsNothing);
  });

  testWidgets('follow-up Task round add opens entry and appends canonical history',
      (tester) async {
    final task = Task(
      id: 'follow-up',
      title: 'پیگیری مشتری',
      followUpEnabled: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async => value,
          onAddFollowUp: (value, followUp) async {
            value.followUps = <FollowUp>[...value.followUps, followUp];
            value.followUpEnabled = true;
            return value;
          },
        ),
      ),
    );

    final add = find.byKey(const ValueKey('task-detail-add-followup'));
    expect(add, findsOneWidget);
    await tester.tap(add);
    await tester.pumpAndSettle();

    expect(find.text('ثبت پیگیری'), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-up-entry-title')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.note, 'پیگیری');
    expect(find.byKey(ValueKey('task-detail-followup-${task.followUps.single.id}')),
        findsOneWidget);
    expect(find.text('پیگیری'), findsWidgets);
  });

  testWidgets('Edit result refreshes the same detail page', (tester) async {
    final task = Task(id: 'same-id', title: 'عنوان قبلی');

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async {
            value.title = 'عنوان جدید';
            return value;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
    await tester.pumpAndSettle();

    expect(task.id, 'same-id');
    expect(find.text('عنوان جدید'), findsOneWidget);
  });
}
