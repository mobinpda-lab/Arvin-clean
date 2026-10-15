import 'dart:convert';

import 'package:arvin/automatic_follow_up_scheduler_adapter.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/calendar_reschedule_apply_service.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:arvin/task_next_action_page.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
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


Future<void> _pumpRouteTransition(WidgetTester tester) async {
  // Calendar keeps an active ticker, so pumpAndSettle can wait forever.
  // Advance the bounded route animation without relying on global settling.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _openMoreMenu(WidgetTester tester) async {
  await tester.tap(find.text('بیشتر'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

class _RecordingCalendarProjection extends FollowUpCalendarProjection {
  final List<String> visibleRanges = <String>[];
  final List<String> visibleIds = <String>[];

  @override
  List<CalendarReminder> project(
    Iterable<Task> tasks, {
    DateTime? visibleFrom,
    DateTime? visibleTo,
    DateTime? now,
  }) {
    final result = super.project(
      tasks,
      visibleFrom: visibleFrom,
      visibleTo: visibleTo,
      now: now,
    );
    if (visibleFrom != null && visibleTo != null) {
      visibleRanges
        ..clear()
        ..add('${visibleFrom.toIso8601String()}..${visibleTo.toIso8601String()}');
      visibleIds
        ..clear()
        ..addAll(result.map((item) => item.id));
    }
    return result;
  }
}

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
  });


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
    expect(find.byType(ArvinPrimaryNavigation), findsOneWidget);
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsNothing);
    expect(find.text('بیشتر'), findsOneWidget);
    expect(find.text('خط زمانی'), findsNothing);
    expect(find.text('تداخل‌ها'), findsNothing);

    // The launcher starts offline official-calendar calculation in the
    // background. Drain its zero-duration batch-yield timers so this UI-only
    // test does not finish with a live fake timer after widget disposal.
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('timeline refreshes canonical tasks before opening People',
      (tester) async {
    final initial = Task(
      id: 'initial-task',
      title: 'کار اولیه',
    );
    final refreshed = Task(
      id: 'refreshed-task',
      title: 'کار تازه',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(
          tasks: <Task>[initial],
          onRefreshTasks: () async => <Task>[refreshed],
        ),
      ),
    );
    await tester.pump();

    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TaskTimelinePage), findsOneWidget);
    expect(find.byKey(const ValueKey('timeline-open-people')), findsOneWidget);
  });

  testWidgets('real calendar conflict button shows safe replacement suggestions',
      (tester) async {
    final when = DateTime(2026, 8, 27, 9);
    final tasks = [
      Task(
        id: 'conflict-a',
        title: 'جلسه مشتری',
        followUps: [
          FollowUp(id: 'follow-a', dateTime: when, reminderDate: when, note: 'پیگیری قرارداد'),
        ],
      ),
      Task(
        id: 'conflict-b',
        title: 'جلسه داخلی',
        followUps: [
          FollowUp(id: 'follow-b', dateTime: when, reminderDate: when, note: 'هماهنگی تیم'),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: CanonicalCalendarLauncher(tasks: tasks)),
    );
    await tester.pump();

    await _openMoreMenu(tester);
    await tester.scrollUntilVisible(
      find.text('تداخل‌ها', skipOffstage: false),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('تداخل‌ها'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

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
            reminderDate: when,
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
          FollowUp(id: 'follow-b', dateTime: when, reminderDate: when, note: 'هماهنگی تیم'),
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

    await _openMoreMenu(tester);
    await tester.scrollUntilVisible(
      find.text('تداخل‌ها', skipOffstage: false),
      300,
      scrollable: find.byType(Scrollable).last,
    );
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
        followUps: [FollowUp(id: 'follow-a', dateTime: when, reminderDate: when)],
      ),
      Task(
        id: 'conflict-b',
        title: 'جلسه داخلی',
        followUps: [FollowUp(id: 'follow-b', dateTime: when, reminderDate: when)],
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

    await _openMoreMenu(tester);
    await tester.scrollUntilVisible(
      find.text('تداخل‌ها'),
      250,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 10,
    );
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
    await tester.pump(const Duration(milliseconds: 300));

    await _openMoreMenu(tester);
    await tester.tap(find.text('اقدام بعدی'));
    await _pumpRouteTransition(tester);

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
    await tester.pump(const Duration(milliseconds: 300));

    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await _pumpRouteTransition(tester);

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
    await tester.pump(const Duration(milliseconds: 300));

    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('انتخاب کار برای خط زمانی'), findsOneWidget);
    await tester.tap(find.text('کار دوم'));
    await _pumpRouteTransition(tester);

    expect(find.byType(TaskTimelinePage), findsOneWidget);
    expect(find.text('ایجاد کار'), findsOneWidget);
  });

  testWidgets('empty task list reports that timeline is unavailable',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CanonicalCalendarLauncher(tasks: [])),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await _openMoreMenu(tester);
    await tester.tap(find.text('خط زمانی'));
    await tester.pump();

    expect(find.text('کاری برای نمایش خط زمانی وجود ندارد'), findsOneWidget);
  });
  testWidgets('calendar more menu exposes manual bidirectional sync retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(
          tasks: const <Task>[],
          onRetryCalendarSync: () async {
            calls++;
          },
        ),
      ),
    );
    await tester.pump();
    await _openMoreMenu(tester);
    expect(find.text('تلاش دوباره برای همگام‌سازی'), findsOneWidget);
    await tester.tap(find.text('تلاش دوباره برای همگام‌سازی'));
    await tester.pump();
    expect(calls, 1);
    expect(
      find.text('همگام‌سازی تقویم دوباره انجام شد. تغییرات آروین و تقویم گوشی نیز بررسی شد.'),
      findsOneWidget,
    );
  });



  testWidgets('repeat occurrence actions resolve back to the canonical Task', (
    tester,
  ) async {
    final now = IranClock.now();
    // Use a stable same-day time so this test remains valid across midnight.
    final anchor = DateTime(now.year, now.month, now.day, 12);
    final task = Task(
      id: 'repeat-task',
      title: 'کار تکرارشونده',
      dueDate: anchor,
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        count: 10,
      ),
    );
    Task? edited;
    Task? deleted;
    CalendarReminder? registered;
    final projection = _RecordingCalendarProjection();

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(
          tasks: <Task>[task],
          projection: projection,
          onEditTask: (value) async => edited = value,
          onDeleteTask: (value) async => deleted = value,
          onRegisterTaskToDeviceCalendar: (value) async => registered = value,
        ),
      ),
    );
    await tester.tap(find.text('تقویم'));
    await tester.pump();
    await _pumpRouteTransition(tester);

    final occurrenceId = 'task-due:repeat-task:${anchor.toIso8601String()}';
    final card = find.byKey(ValueKey('reminder-card-$occurrenceId'));
    // The official-calendar FutureBuilder and inbound calendar reconciliation
    // complete asynchronously. Wait for the actual occurrence row with a
    // bounded pump; keep the assertion strict if the projection never appears.
    for (var i = 0; i < 30 && card.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (card.evaluate().isEmpty) {
      debugPrint(
        'Repeat occurrence diagnostic: expected=$occurrenceId '
        'ranges=${projection.visibleRanges} visibleIds=${projection.visibleIds} '
        'calendarPages=${find.byType(CalendarPage).evaluate().length}',
      );
    }
    expect(card, findsOneWidget);

    final edit = find.byKey(ValueKey('task-due-edit-$occurrenceId'));
    final register = find.byKey(ValueKey('task-due-device-calendar-$occurrenceId'));
    // Verify the full launcher -> projection -> Calendar card path exposes
    // primary actions before the user expands the row.
    expect(edit, findsOneWidget);
    expect(register, findsOneWidget);

    // The occurrence can be below the current viewport after calendar layout.
    // Scroll it fully into view before tapping so the test validates the action,
    // not an off-screen hit-test failure.
    await tester.ensureVisible(card);
    // Avoid pumpAndSettle: the calendar may keep an active ticker running.
    // A bounded frame is enough to apply the scroll/layout before the tap.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(card);
    await tester.pump();
    expect(edit, findsOneWidget);
    expect(register, findsOneWidget);

    await tester.tap(edit);
    await tester.pump();
    expect(identical(edited, task), isTrue);

    await tester.tap(register);
    await tester.pump();
    expect(registered?.id, occurrenceId);
    expect(registered?.date, anchor);

    // Move one full week forward. The occurrence is still a projection of the
    // same canonical Task, not a separately stored Task/Reminder.
    final calendarSurface = find.byKey(const ValueKey('calendar-swipe-surface'));
    await tester.fling(calendarSurface, const Offset(-500, 0), 1000);
    await _pumpRouteTransition(tester);
    final nextWeekDate = anchor.add(const Duration(days: 7));
    final nextWeekId =
        'task-due:repeat-task:${nextWeekDate.toIso8601String()}';
    final nextWeekCard = find.byKey(ValueKey('reminder-card-$nextWeekId'));
    for (var i = 0; i < 30 && nextWeekCard.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(nextWeekCard, findsOneWidget);

    await tester.fling(calendarSurface, const Offset(500, 0), 1000);
    await _pumpRouteTransition(tester);
    for (var i = 0; i < 30 && card.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(card, findsOneWidget);
    // Destructive actions are intentionally revealed by long-press, not tap.
    await tester.longPress(card);
    await _pumpRouteTransition(tester);

    final delete = find.byKey(ValueKey('task-due-delete-$occurrenceId'));
    expect(delete, findsOneWidget);
    await tester.tap(delete);
    await _pumpRouteTransition(tester);
    expect(find.text('انتقال کار به سطل زباله؟'), findsOneWidget);
    await tester.tap(find.text('لغو'));
    await _pumpRouteTransition(tester);
    expect(deleted, isNull);

    await tester.tap(delete);
    await _pumpRouteTransition(tester);
    await tester.tap(find.text('انتقال به سطل زباله'));
    await _pumpRouteTransition(tester);
    expect(identical(deleted, task), isTrue);
  });


  testWidgets('launcher does not render an eighth occurrence when count is seven', (
    tester,
  ) async {
    final now = IranClock.now();
    final anchor = DateTime(now.year, now.month, now.day, 12);
    final task = Task(
      id: 'repeat-count-seven',
      title: 'کار هفت‌نوبتی',
      dueDate: anchor,
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        count: 7,
      ),
    );
    final projection = _RecordingCalendarProjection();

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(
          tasks: <Task>[task],
          projection: projection,
        ),
      ),
    );
    await tester.tap(find.text('تقویم'));
    await tester.pump();
    await _pumpRouteTransition(tester);

    final firstOccurrenceId =
        'task-due:repeat-count-seven:${anchor.toIso8601String()}';
    final firstCard =
        find.byKey(ValueKey('reminder-card-$firstOccurrenceId'));
    for (var i = 0; i < 30 && firstCard.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(firstCard, findsOneWidget);

    // Count is inclusive of the start date: the eighth date must not appear
    // after moving to the following week in the real launcher -> projection ->
    // Calendar path.
    final calendarSurface = find.byKey(
      const ValueKey('calendar-swipe-surface'),
    );
    await tester.fling(calendarSurface, const Offset(-500, 0), 1000);
    await _pumpRouteTransition(tester);

    final eighthDate = anchor.add(const Duration(days: 7));
    final eighthOccurrenceId =
        'task-due:repeat-count-seven:${eighthDate.toIso8601String()}';
    expect(
      find.byKey(ValueKey('reminder-card-$eighthOccurrenceId')),
      findsNothing,
    );
  });

}
