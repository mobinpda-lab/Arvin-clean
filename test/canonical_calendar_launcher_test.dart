import 'package:arvin/models/task.dart';
import 'package:arvin/task_next_action_page.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launcher accepts canonical follow-ups without parallel storage',
      (tester) async {
    final task = Task(
      id: 'task-1',
      title: 'تماس با مشتری',
      followUps: <FollowUp>[
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 8, 26, 9),
          note: 'پیگیری قرارداد',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(tasks: <Task>[task]),
      ),
    );

    expect(find.byType(CanonicalCalendarLauncher), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsOneWidget);
    expect(find.text('خط زمانی'), findsOneWidget);
  });

  testWidgets('next action opens canonical ranked suggestion page',
      (tester) async {
    final tasks = [
      Task(
        id: 'next-1',
        title: 'تماس فوری',
        reminderDate: DateTime(2020, 1, 1, 9),
      ),
      Task(id: 'next-2', title: 'کار آزاد'),
    ];

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: tasks)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('اقدام بعدی'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskNextActionPage), findsOneWidget);
    expect(find.text('تماس فوری'), findsOneWidget);
    expect(find.text('کار آزاد'), findsOneWidget);
  });

  testWidgets('single task opens its canonical timeline directly',
      (tester) async {
    final task = Task(
      id: 'timeline-task',
      title: 'قرارداد مشتری',
      createdAt: DateTime(2026, 8, 26, 8),
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 8, 26, 10),
          note: 'تماس با مشتری',
          result: 'پاسخ مثبت',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: [task])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('خط زمانی'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskTimelinePage), findsOneWidget);
    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('نتیجه: پاسخ مثبت'), findsOneWidget);
  });

  testWidgets('multiple tasks require explicit timeline selection',
      (tester) async {
    final tasks = [
      Task(id: 'one', title: 'کار اول', createdAt: DateTime(2026, 8, 26, 8)),
      Task(id: 'two', title: 'کار دوم', createdAt: DateTime(2026, 8, 26, 9)),
    ];

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: tasks)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('خط زمانی'));
    await tester.pumpAndSettle();

    expect(find.text('انتخاب کار برای خط زمانی'), findsOneWidget);
    await tester.tap(find.text('کار دوم'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskTimelinePage), findsOneWidget);
    expect(find.text('ایجاد کار'), findsOneWidget);
  });

  testWidgets('empty task list reports that timeline is unavailable',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CanonicalCalendarLauncher(tasks: [])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('خط زمانی'));
    await tester.pump();

    expect(find.text('کاری برای نمایش خط زمانی وجود ندارد'), findsOneWidget);
  });
}
