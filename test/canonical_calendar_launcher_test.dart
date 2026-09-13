import 'package:arvin/models/task.dart';
import 'package:arvin/task_next_action_page.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openMoreMenu(WidgetTester tester) async {
  await tester.tap(find.text('بیشتر'));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('launcher keeps the canonical navigation and follow-up path',
      (tester) async {
    final task = Task(
      id: 'task-1',
      title: 'تماس با مشتری',
      followUps: [
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 8, 26, 9),
          note: 'پیگیری قرارداد',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: [task])),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(CanonicalCalendarLauncher), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsOneWidget);
    expect(find.text('بیشتر'), findsOneWidget);
    expect(find.text('خط زمانی'), findsNothing);
    expect(find.text('تداخل‌ها'), findsNothing);
  });

  testWidgets('real calendar conflict button shows replacement suggestions',
      (tester) async {
    final when = DateTime(2026, 8, 27, 9);
    final tasks = [
      Task(
        id: 'conflict-a',
        title: 'جلسه مشتری',
        followUps: [
          FollowUp(id: 'follow-a', dateTime: when, note: 'پیگیری قرارداد'),
        ],
      ),
      Task(
        id: 'conflict-b',
        title: 'جلسه داخلی',
        followUps: [
          FollowUp(id: 'follow-b', dateTime: when, note: 'هماهنگی تیم'),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: tasks)),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await _openMoreMenu(tester);

    expect(find.text('تداخل‌ها'), findsOneWidget);
    await tester.tap(find.text('تداخل‌ها'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('تداخل‌های زمانی'), findsOneWidget);
    expect(find.text('جلسه مشتری — پیگیری قرارداد'), findsWidgets);
    expect(find.text('جلسه داخلی — هماهنگی تیم'), findsWidgets);
    expect(find.textContaining('اعمال ۰۹:۳۰'), findsWidgets);
    expect(
      find.textContaining('هیچ زمانی بدون تأیید شما تغییر نمی‌کند'),
      findsOneWidget,
    );
  });

  testWidgets('timeline opens directly for one task', (tester) async {
    final task = Task(
      id: 'timeline-task',
      title: 'قرارداد مشتری',
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
    await tester.pump(const Duration(milliseconds: 250));
    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(TaskTimelinePage), findsOneWidget);
    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('نتیجه: پاسخ مثبت'), findsOneWidget);
  });

  testWidgets('timeline requires explicit selection for multiple tasks',
      (tester) async {
    final tasks = [
      Task(id: 'one', title: 'کار اول'),
      Task(id: 'two', title: 'کار دوم'),
    ];

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: tasks)),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('انتخاب کار برای خط زمانی'), findsOneWidget);
    await tester.tap(find.text('کار دوم'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TaskTimelinePage), findsOneWidget);
  });

  testWidgets('empty task list reports unavailable timeline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CanonicalCalendarLauncher(tasks: [])),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('کاری برای نمایش خط زمانی وجود ندارد'), findsOneWidget);
  });

  testWidgets('next action opens the canonical ranked suggestion page',
      (tester) async {
    final tasks = [
      Task(id: 'next-1', title: 'تماس فوری', reminderDate: DateTime(2020, 1, 1, 9)),
      Task(id: 'next-2', title: 'کار آزاد'),
    ];

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: tasks)),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('اقدام بعدی'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(TaskNextActionPage), findsOneWidget);
    expect(find.text('تماس فوری'), findsOneWidget);
    expect(find.text('کار آزاد'), findsOneWidget);
  });
}
