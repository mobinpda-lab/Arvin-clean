import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/alarm_overlay_page.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/task_storage_lock.dart';

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
      final diagnosticClock = Stopwatch()..start();
      void stage(String message) => debugPrint(
            '[ARVIN_TIMEOUT_DIAG][TEST][${diagnosticClock.elapsedMilliseconds}ms] $message',
          );
      TaskStorageLock.diagnosticLoggingEnabled = true;
      stage('T00 START: file-backed persistence scenario');
      // ProjectStore's one-time legacy migration and CalendarOutboundSyncService
      // both read SharedPreferences. Seed the plugin before either path runs so
      // this file-backed test never waits on an unregistered platform channel.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      stage('T00a SharedPreferences mock initialized');
      // Use the checked-out workspace rather than resolving the OS temp
      // directory: the CI runner's systemTemp lookup stalled before returning.
      // The workspace is writable in Actions and the directory is deleted below.
      final testWorkspace = Directory.current;
      stage('T00b before workspace.createTemp: ${testWorkspace.path}');
      final directory = await testWorkspace.createTemp('arvin-alarm-file-');
      stage('T00c temporary directory created: ${directory.path}');
      final path = '${directory.path}/arvin.sqlite';
      stage('T00d before NativeDatabase constructor');
      var executor = NativeDatabase(File(path));
      stage('T00e NativeDatabase constructor returned');
      stage('T01 before first Schema install');
      await G1DriftSchema.install(executor);
      stage('T02 first Schema install completed');
      await G1DriftSchema.markLegacyMigrationComplete(executor);
      var store = TaskStore(executor: executor);
      final notifications = _FileAlarmNotifications();

      try {
        stage('T03 before initial Task + Reminder + FollowUp save');
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

        stage('T04 initial Task + Reminder + FollowUp save completed');
        await tester.pumpWidget(MaterialApp(
          home: AlarmOverlayPage(
            taskId: 'alarm-file-task',
            taskReminderId: 'alarm-file-reminder',
            notificationId: 7210,
            taskStore: store,
            projectStore: ProjectStore(executor: executor),
            notificationController: notifications,
            now: () => DateTime(2026, 11, 1, 13),
            rescheduleReminders: () async {},
          ),
        ));
        await tester.pumpAndSettle();
        stage('T05 before Snooze action');
        await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze')));
        await tester.pumpAndSettle();
        stage('T06 Snooze overlay rendered; choosing duration');
        await tester.tap(find.byTooltip('افزایش مدت تعویق'));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('alarm-overlay-snooze-dialog-confirm')));
        await tester.pumpAndSettle();
        stage('T07 Snooze completed; Reminder persistence path returned');

        stage('T08 before closing first SQLite executor');
        await executor.close();
        stage('T09 first SQLite executor closed');
        executor = NativeDatabase(File(path));
        stage('T10 before second-connection Schema install');
        await G1DriftSchema.install(executor);
        stage('T11 second-connection Schema install completed');
        store = TaskStore(executor: executor);
        stage('T12 before reloading Task after reopen');
        var task = (await store.load()).single;
        stage('T13 Task reload after reopen completed');
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
            projectStore: ProjectStore(executor: executor),
            notificationController: notifications,
            now: () => DateTime(2026, 11, 1, 14),
            rescheduleReminders: () async {},
          ),
        ));
        await tester.pumpAndSettle();
        stage('T14 before Complete action; awaiting full completion + Calendar sync path');
        await tester.tap(find.byKey(const ValueKey('alarm-overlay-complete')));
        await tester.pumpAndSettle();
        stage('T15 Complete action returned to widget test');

        stage('T16 before closing executor after Complete');
        await executor.close();
        stage('T17 executor after Complete closed');
        executor = NativeDatabase(File(path));
        stage('T18 before final Schema install');
        await G1DriftSchema.install(executor);
        stage('T19 final Schema install completed');
        store = TaskStore(executor: executor);
        stage('T20 before final Task reload');
        task = (await store.load()).single;
        stage('T21 final Task reload completed');
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
        stage('T22 finally: closing current SQLite executor');
        await executor.close();
        TaskStorageLock.diagnosticLoggingEnabled = false;
        stage('T23 END: diagnostics disabled');
        await directory.delete(recursive: true);
      }
    },
  );
}
