import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/alarm_overlay_page.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';

class _FileAlarmNotifications implements AlarmOverlayNotificationController {
  final List<int> cancelled = <int>[];

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
  }
}

void main() {
  testWidgets(
    'Snooze and completion remain isolated after closing and reopening the same SQLite file',
    (tester) async {
      final directory = await Directory.systemTemp.createTemp('arvin-alarm-file-');
      final path = '${directory.path}/arvin.sqlite';
      var executor = NativeDatabase(File(path));
      await G1DriftSchema.install(executor);
      await G1DriftSchema.markLegacyMigrationComplete(executor);
      var store = TaskStore(executor: executor);
      final notifications = _FileAlarmNotifications();

      try {
        await store.save(<Task>[
          Task(
            id: 'alarm-file-task',
            title: 'تماس با مشتری',
            dueDate: DateTime(2026, 11, 5, 16),
            taskReminders: <TaskReminder>[
              TaskReminder(
                id: 'alarm-file-reminder',
                title: 'یادآور تماس',
                date: DateTime(2026, 11, 1, 12),
                sequence: 2,
              ),
              TaskReminder(
                id: 'alarm-file-sibling',
                title: 'یادآور مستقل',
                date: DateTime(2026, 11, 3, 9),
                sequence: 3,
              ),
            ],
            nextReminderSequence: 4,
            followUps: <FollowUp>[
              FollowUp(
                id: 'alarm-file-history',
                dateTime: DateTime(2026, 10, 30, 9),
                note: 'سابقه قبلی',
              ),
            ],
          ),
        ]);

        await tester.pumpWidget(MaterialApp(
          home: AlarmOverlayPage(
            taskId: 'alarm-file-task',
            taskReminderId: 'alarm-file-reminder',
            notificationId: 7210,
            taskStore: store,
            notificationController: notifications,
            now: () => DateTime(2026, 11, 1, 13),
            rescheduleReminders: () async {},
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze')));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('افزایش مدت تعویق'));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze-dialog-confirm')));
        await tester.pumpAndSettle();

        await executor.close();
        executor = NativeDatabase(File(path));
        await G1DriftSchema.install(executor);
        store = TaskStore(executor: executor);
        var task = (await store.load()).single;
        expect(task.completed, isFalse);
        expect(task.dueDate, DateTime(2026, 11, 5, 16));
        expect(task.followUps.map((item) => item.id), <String>['alarm-file-history']);
        expect(task.taskReminders, hasLength(2));
        final snoozed = task.taskReminders.singleWhere((item) => item.id == 'alarm-file-reminder');
        expect(snoozed.date, DateTime(2026, 11, 1, 13, 10));
        expect(snoozed.sequence, 2);
        final sibling = task.taskReminders.singleWhere((item) => item.id == 'alarm-file-sibling');
        expect(sibling.date, DateTime(2026, 11, 3, 9));
        expect(sibling.sequence, 3);

        await tester.pumpWidget(MaterialApp(
          home: AlarmOverlayPage(
            taskId: 'alarm-file-task',
            taskReminderId: 'alarm-file-reminder',
            notificationId: 7211,
            taskStore: store,
            notificationController: notifications,
            now: () => DateTime(2026, 11, 1, 14),
            rescheduleReminders: () async {},
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('alarm-overlay-complete')));
        await tester.pumpAndSettle();

        await executor.close();
        executor = NativeDatabase(File(path));
        await G1DriftSchema.install(executor);
        store = TaskStore(executor: executor);
        task = (await store.load()).single;
        expect(task.completed, isTrue);
        expect(task.completedAt, DateTime(2026, 11, 1, 14));
        expect(task.dueDate, DateTime(2026, 11, 5, 16));
        expect(task.followUps.map((item) => item.id), <String>['alarm-file-history']);
        expect(task.taskReminders.map((item) => item.id).toSet(),
            <String>{'alarm-file-reminder', 'alarm-file-sibling'});
        expect(
          task.taskReminders.singleWhere((item) => item.id == 'alarm-file-reminder').date,
          DateTime(2026, 11, 1, 13, 10),
        );
        expect(
          task.taskReminders.singleWhere((item) => item.id == 'alarm-file-sibling').date,
          DateTime(2026, 11, 3, 9),
        );
      } finally {
        await executor.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
