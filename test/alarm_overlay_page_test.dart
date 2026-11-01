import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/alarm_overlay_page.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/models/goal_project.dart';

class _FakeAlarmNotifications implements AlarmOverlayNotificationController {
  final List<int> cancelled = <int>[];

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  Future<Task> seedTask(TaskStore store, {bool allDay = false}) async {
    final task = Task(
      id: 'alarm-task-1',
      title: 'تماس با مشتری',
      taskReminders: [
        TaskReminder(
          id: 'reminder-stable-1',
          title: 'یادآور تماس',
          date: DateTime(2026, 11, 1, 12),
          isAllDay: allDay,
          sequence: 4,
        ),
      ],
      nextReminderSequence: 5,
      followUps: [
        FollowUp(
          id: 'existing-follow-up',
          dateTime: DateTime(2026, 10, 30, 9),
          note: 'سابقه قبلی',
        ),
      ],
    );
    await store.save([task]);
    return task;
  }

  Future<void> scrollToFollowUp(WidgetTester tester) async {
    final followUp = find.byKey(const ValueKey('alarm-overlay-follow-up'));
    expect(followUp, findsOneWidget);
    await tester.scrollUntilVisible(
      followUp,
      100,
      scrollable: find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(followUp.hitTestable(), findsOneWidget);
  }

  testWidgets('compact card resolves the actual Project membership title', (tester) async {
    final store = TaskStore();
    await seedTask(store);
    final projectDatabase = NativeDatabase.memory();
    addTearDown(projectDatabase.close);
    await G1DriftSchema.install(projectDatabase);
    final projectStore = ProjectStore(executor: projectDatabase);
    await projectStore.save(<ProjectPlan>[
      ProjectPlan(
        id: 'project-marketing',
        title: 'پروژه بازاریابی',
        itemIds: const <String>['alarm-task-1'],
      ),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7012,
        taskStore: store,
        projectStore: projectStore,
        notificationController: _FakeAlarmNotifications(),
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('پروژه بازاریابی'), findsOneWidget);
  });

  testWidgets('complete uses Task.setCompleted and leaves Reminder and Follow-up history untouched', (tester) async {
    final store = TaskStore();
    await seedTask(store);
    final notifications = _FakeAlarmNotifications();
    var rescheduled = false;

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7010,
        taskStore: store,
        notificationController: notifications,
        rescheduleReminders: () async { rescheduled = true; },
        now: () => DateTime(2026, 11, 1, 14),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('alarm-overlay-complete')));
    await tester.pumpAndSettle();

    final stored = (await store.load()).single;
    expect(stored.completed, isTrue);
    expect(stored.completedAt, DateTime(2026, 11, 1, 14));
    expect(stored.followUps, hasLength(1));
    expect(stored.taskReminders.single.id, 'reminder-stable-1');
    expect(stored.taskReminders.single.date, DateTime(2026, 11, 1, 12));
    expect(rescheduled, isTrue);
    expect(notifications.cancelled, [7010]);
  });

  testWidgets('compact card exposes four distinct accessible actions', (tester) async {
    final store = TaskStore();
    final task = await seedTask(store);
    task.category = 'پروژه بازاریابی';
    await store.save([task]);

    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
      child: MaterialApp(
        home: AlarmOverlayPage(
          taskId: 'alarm-task-1',
          taskReminderId: 'reminder-stable-1',
          notificationId: 7011,
          taskStore: store,
          notificationController: _FakeAlarmNotifications(),
          rescheduleReminders: () async {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('پروژه بازاریابی'), findsOneWidget);
    for (final key in [
      'alarm-overlay-complete',
      'alarm-overlay-snooze',
      'alarm-overlay-follow-up',
      'alarm-overlay-stop',
    ]) {
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('alarm-overlay-volume-info')), findsNothing);
  });

  testWidgets('stop dismisses only the notification and leaves Task data intact',
      (tester) async {
    final store = TaskStore();
    await seedTask(store);
    final notifications = _FakeAlarmNotifications();

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7001,
        taskStore: store,
        notificationController: notifications,
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.byKey(const ValueKey('alarm-overlay-reminder-time')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('alarm-overlay-stop')));
    await tester.pumpAndSettle();

    expect(notifications.cancelled, [7001]);
    final stored = (await store.load()).single;
    expect(stored.taskReminders.single.id, 'reminder-stable-1');
    expect(stored.taskReminders.single.date, DateTime(2026, 11, 1, 12));
    expect(stored.followUps, hasLength(1));
    expect(stored.completed, isFalse);
  });

  testWidgets('snooze updates only the exact Reminder and preserves its identity',
      (tester) async {
    final store = TaskStore();
    await seedTask(store);
    final notifications = _FakeAlarmNotifications();
    var rescheduled = false;

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7002,
        taskStore: store,
        notificationController: notifications,
        now: () => DateTime(2026, 11, 1, 13),
        rescheduleReminders: () async { rescheduled = true; },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('افزایش مدت تعویق'));
    await tester.pump();
    expect(find.text('۱۰ دقیقه'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze-dialog-confirm')));
    await tester.pumpAndSettle();

    final stored = (await store.load()).single;
    expect(stored.taskReminders, hasLength(1));
    expect(stored.taskReminders.single.id, 'reminder-stable-1');
    expect(stored.taskReminders.single.title, 'یادآور تماس');
    expect(stored.taskReminders.single.sequence, 4);
    expect(stored.taskReminders.single.date, DateTime(2026, 11, 1, 13, 10));
    expect(stored.followUps, hasLength(1));
    expect(stored.completed, isFalse);
    expect(rescheduled, isTrue);
    expect(notifications.cancelled, [7002]);
  });

  testWidgets('Follow-up shortcut reuses the canonical form without Reminder option',
      (tester) async {
    final store = TaskStore();
    await seedTask(store);
    final notifications = _FakeAlarmNotifications();

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7003,
        taskStore: store,
        notificationController: notifications,
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    await scrollToFollowUp(tester);
    await tester.tap(find.byKey(const ValueKey('alarm-overlay-follow-up')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('follow-up-entry-add-reminder')), findsNothing);
    expect((await store.load()).single.followUps, hasLength(1));

    await tester.tap(find.byKey(const ValueKey('follow-up-entry-back')));
    await tester.pumpAndSettle();
    expect((await store.load()).single.followUps, hasLength(1));
    expect((await store.load()).single.taskReminders.single.id, 'reminder-stable-1');
  });


  testWidgets('explicit Follow-up Save persists history without adding a future Reminder',
      (tester) async {
    final store = TaskStore();
    await seedTask(store);
    final notifications = _FakeAlarmNotifications();

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7005,
        taskStore: store,
        notificationController: notifications,
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    await scrollToFollowUp(tester);
    await tester.tap(find.byKey(const ValueKey('alarm-overlay-follow-up')));
    await tester.pumpAndSettle();
    final note = find.byKey(const ValueKey('follow-up-entry-note'));
    await tester.enterText(note, 'گفت‌وگو انجام شد');
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    final stored = (await store.load()).single;
    expect(stored.followUps, hasLength(2));
    expect(stored.followUps.last.note, 'گفت‌وگو انجام شد');
    expect(stored.taskReminders, hasLength(1));
    expect(stored.taskReminders.single.id, 'reminder-stable-1');
    expect(stored.completed, isFalse);
  });


  testWidgets('compact card keeps all four actions available without decorative volume control', (tester) async {
    final store = TaskStore();
    await seedTask(store);

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7006,
        taskStore: store,
        notificationController: _FakeAlarmNotifications(),
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    for (final key in [
      'alarm-overlay-complete',
      'alarm-overlay-snooze',
      'alarm-overlay-follow-up',
      'alarm-overlay-stop',
    ]) {
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('alarm-overlay-volume-info')), findsNothing);
    expect(find.text('تکمیل'), findsOneWidget);
    expect(find.text('تعویق'), findsOneWidget);
    expect(find.text('پیگیری'), findsOneWidget);
    expect(find.text('توقف زنگ'), findsOneWidget);
  });

  testWidgets('bottom Follow-up shortcut is reachable and tappable by scrolling on a short viewport',
      (tester) async {
    tester.view.physicalSize = const Size(360, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = TaskStore();
    await seedTask(store);

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7007,
        taskStore: store,
        notificationController: _FakeAlarmNotifications(),
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    final followUp = find.byKey(const ValueKey('alarm-overlay-follow-up'));
    expect(followUp, findsOneWidget);
    await scrollToFollowUp(tester);
    expect(followUp.hitTestable(), findsOneWidget);
    await tester.tap(followUp);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('follow-up-entry-note')), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-up-entry-add-reminder')), findsNothing);
    expect((await store.load()).single.followUps, hasLength(1));
  });

  testWidgets('all-day Reminder does not expose a time-changing Snooze control',
      (tester) async {
    final store = TaskStore();
    await seedTask(store, allDay: true);

    await tester.pumpWidget(MaterialApp(
      home: AlarmOverlayPage(
        taskId: 'alarm-task-1',
        taskReminderId: 'reminder-stable-1',
        notificationId: 7004,
        taskStore: store,
        notificationController: _FakeAlarmNotifications(),
        rescheduleReminders: () async {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alarm-overlay-snooze')), findsOneWidget);
    expect(tester.widget<OutlinedButton>(find.byKey(const ValueKey('alarm-overlay-stop'))).onPressed, isNotNull);
    expect(find.text('این یادآور تمام‌روز است و تعویق زمانی ندارد.'), findsOneWidget);
    final displayedTime = tester.widget<Text>(
      find.byKey(const ValueKey('alarm-overlay-reminder-time')),
    );
    expect(displayedTime.data, contains('تمام‌روز'));
  });
}
