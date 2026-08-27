import 'dart:convert';

import 'package:arvin/automatic_follow_up_scheduler_adapter.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_reschedule_apply_service.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:arvin/task_next_action_page.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduler implements AutomaticFollowUpSchedulerAdapter {
  int rescheduleCalls = 0;

  @override
  Future<void> cancel() async {}

  @override
  Future<void> reschedule() async {
    rescheduleCalls += 1;
  }
}

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
    expect(find.text('تداخل‌ها'), findsOneWidget);
  });

  testWidgets('real calendar conflict button shows safe replacement suggestions',
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
    await tester.pump();

    await tester.tap(find.text('تداخل‌ها'));
    await tester.pumpAndSettle();

    expect(find.text('تداخل‌های زمانی'), findsOneWidget);
    expect(find.text('جلسه مشتری — پیگیری قرارداد'), findsWidgets);
    expect(find.text('جلسه داخلی — هماهنگی تیم'), findsWidgets);
    expect(find.textContaining('اعمال ۰۹:۳۰'), findsWidgets);
    expect(
      find.textContaining('هیچ زمانی بدون تأیید شما تغییر نمی‌کند'),
      findsOneWidget,
    );
  });

  testWidgets('suggested reschedule requires confirmation before canonical write',
      (tester) async {
    const repository = FollowUpRepository();
    final when = DateTime(2026, 8, 27, 9);
    final tasks = [
      Task(
        id: 'conflict-a',
        title: 'جلسه مشتری',
        followUps: [
          FollowUp(
            id: 'follow-a',
            dateTime: when,
            note: 'پیگیری قرارداد',
            result: 'منتظر تأیید',
            nextFollowUp: DateTime(2026, 8, 29, 9),
          ),
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
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode(tasks.map((task) => task.toJson()).toList()),
    });
    final scheduler = _FakeScheduler();
    final service = CalendarRescheduleApplyService(
      writer: FollowUpWriteCoordinator(
        repository: repository,
        scheduler: scheduler,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(
          tasks: tasks,
          rescheduleApplyService: service,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('تداخل‌ها'));
    await tester.pumpAndSettle();
    final apply = find.textContaining('اعمال ۰۹:۳۰').first;
    await tester.tap(apply);
    await tester.pumpAndSettle();

    expect(find.text('تأیید تغییر زمان'), findsOneWidget);
    expect(find.text('زمان فعلی: ۰۹:۰۰'), findsOneWidget);
    expect(find.text('زمان پیشنهادی: ۰۹:۳۰'), findsOneWidget);

    await tester.tap(find.text('لغو'));
    await tester.pumpAndSettle();
    expect(scheduler.rescheduleCalls, 0);
    final afterCancelA = await repository.loadForTask('conflict-a');
    final afterCancelB = await repository.loadForTask('conflict-b');
    expect(afterCancelA.single.dateTime, when);
    expect(afterCancelB.single.dateTime, when);

    await tester.tap(find.textContaining('اعمال ۰۹:۳۰').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعمال زمان پیشنهادی'));
    await tester.pumpAndSettle();

    expect(scheduler.rescheduleCalls, 1);
    expect(find.text('زمان پیگیری با موفقیت تغییر کرد'), findsOneWidget);
    final savedA = await repository.loadForTask('conflict-a');
    final savedB = await repository.loadForTask('conflict-b');
    final moved = [savedA.single, savedB.single]
        .where((item) => item.dateTime == DateTime(2026, 8, 27, 9, 30))
        .toList();
    expect(moved, hasLength(1));
  });

  testWidgets('failed confirmed write is surfaced without scheduler request',
      (tester) async {
    const repository = FollowUpRepository();
    final when = DateTime(2026, 8, 27, 9);
    final tasks = [
      Task(
        id: 'conflict-a',
        title: 'جلسه مشتری',
        followUps: [FollowUp(id: 'follow-a', dateTime: when)],
      ),
      Task(
        id: 'conflict-b',
        title: 'جلسه داخلی',
        followUps: [FollowUp(id: 'follow-b', dateTime: when)],
      ),
    ];
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});
    final scheduler = _FakeScheduler();

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(
          tasks: tasks,
          rescheduleApplyService: CalendarRescheduleApplyService(
            writer: FollowUpWriteCoordinator(
              repository: repository,
              scheduler: scheduler,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('تداخل‌ها'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('اعمال ۰۹:۳۰').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعمال زمان پیشنهادی'));
    await tester.pumpAndSettle();

    expect(find.text('تغییر زمان انجام نشد؛ دوباره تلاش کنید'), findsOneWidget);
    expect(scheduler.rescheduleCalls, 0);
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
