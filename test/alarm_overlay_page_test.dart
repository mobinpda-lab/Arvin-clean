import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/alarm_overlay_page.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

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

    await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze-plus')));
    await tester.pump();
    expect(find.text('۱۰ دقیقه'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze-confirm')));
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


  testWidgets('overlay hierarchy has a prominent Stop, volume speaker, and bottom Follow-up shortcut',
      (tester) async {
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

    final stop = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byKey(const ValueKey('alarm-overlay-stop')),
        matching: find.byType(SizedBox),
      ).first,
    );
    expect(stop.height, 64);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.byKey(const ValueKey('alarm-overlay-volume-row')), findsOneWidget);

    final volumeY = tester.getTopLeft(
      find.byKey(const ValueKey('alarm-overlay-volume-row')),
    ).dy;
    final snoozeY = tester.getTopLeft(
      find.byKey(const ValueKey('alarm-overlay-snooze-confirm')),
    ).dy;
    final followUpY = tester.getTopLeft(
      find.byKey(const ValueKey('alarm-overlay-follow-up')),
    ).dy;
    expect(followUpY, greaterThan(volumeY));
    expect(followUpY, greaterThan(snoozeY));
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
    expect(followUp.hitTestable(), findsNothing);

    await scrollToFollowUp(tester);
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

    expect(find.byKey(const ValueKey('alarm-overlay-snooze-confirm')), findsNothing);
    expect(find.text('برای یادآور تمام‌روز، تعویق زمانی در دسترس نیست.'), findsOneWidget);
    final displayedTime = tester.widget<Text>(
      find.byKey(const ValueKey('alarm-overlay-reminder-time')),
    );
    expect(displayedTime.data, contains('تمام‌روز'));
  });
}
