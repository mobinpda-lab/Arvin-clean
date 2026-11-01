import 'package:arvin/models/task.dart';
import 'package:arvin/report_center_page.dart';
import 'package:arvin/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Report Center shows genuine Follow-ups, groups by taskId and opens Task Details',
      (tester) async {
    final day = DateTime(2026, 11, 1, 12);
    final tasks = [
      Task(
        id: 'task-a',
        title: 'کار مشترک',
        completedAt: DateTime(2026, 11, 1, 13),
        followUps: [
          FollowUp(
            id: 'a-one',
            dateTime: DateTime(2026, 11, 1, 8, 30),
            note: 'تماس اول',
          ),
          FollowUp(
            id: 'a-two',
            dateTime: DateTime(2026, 11, 1, 10),
            note: 'تماس دوم',
          ),
        ],
      ),
      Task(
        id: 'task-b',
        title: 'کار مشترک',
        followUps: [
          FollowUp(
            id: 'b-one',
            dateTime: DateTime(2026, 11, 1, 9),
            note: 'تماس سوم',
          ),
        ],
      ),
      Task(
        id: 'task-no-history',
        title: 'بدون سابقه',
        dueDate: DateTime(2026, 11, 1, 11),
        completedAt: DateTime(2026, 11, 1, 11),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(tasks: tasks, now: day),
      ),
    );
    await tester.tap(find.byKey(
      const ValueKey('report-center-completed-follow-ups'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('۳ پیگیری برای ۲ کار'), findsOneWidget);
    expect(find.text('تماس اول'), findsOneWidget);
    expect(find.text('تماس دوم'), findsOneWidget);
    expect(find.text('تماس سوم'), findsOneWidget);
    expect(find.text('بدون سابقه'), findsNothing);

    await tester.tap(find.text('بر اساس کار'));
    await tester.pumpAndSettle();
    expect(find.byKey(
      const ValueKey('completed-follow-up-task-group-task-a'),
    ), findsOneWidget);
    expect(find.byKey(
      const ValueKey('completed-follow-up-task-group-task-b'),
    ), findsOneWidget);

    await tester.tap(find.byKey(
      const ValueKey('completed-follow-up-task-group-task-a'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(
      const ValueKey('completed-follow-up-record-task-a-a-one'),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailPage), findsOneWidget);
  });

  testWidgets('Completed Follow-up report shows the exact empty state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          tasks: [Task(id: 'no-history', title: 'کار بدون سابقه')],
          now: DateTime(2026, 11, 1, 12),
        ),
      ),
    );
    await tester.tap(find.byKey(
      const ValueKey('report-center-completed-follow-ups'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('برای این روز پیگیری‌ای ثبت نشده است.'), findsOneWidget);
  });
}
