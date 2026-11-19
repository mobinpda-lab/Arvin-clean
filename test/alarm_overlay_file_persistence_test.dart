import 'dart:async';
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
      // Use the runner-provided system temporary directory directly. The
      // previous workspace Directory.exists/stat probe stalled before SQLite
      // setup, so avoid probing the checkout filesystem in this persistence test.
      final systemTemp = Directory.systemTemp;
      stage('T00b before synchronous systemTemp.createTempSync: ${systemTemp.path}');
      // The async createTemp Future did not complete in the CI test isolate.
      // createTempSync uses Dart's native filesystem path and avoids waiting
      // on that unresolved async operation; it does not bypass SQLite setup.
      late final Directory directory;
      try {
        directory = systemTemp.createTempSync('arvin-alarm-file-');
        stage('T00c temporary directory created synchronously: ${directory.path}');
      } catch (error, stackTrace) {
        stage('T00b CREATE_TEMP_SYNC_EXCEPTION: $error');
        debugPrint('[ARVIN_TIMEOUT_DIAG][STACK] $stackTrace');
        rethrow;
      }
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

        stage('T07a before disposing first Alarm Overlay');
        await tester.pumpWidget(const SizedBox.shrink());
        stage('T07b first Alarm Overlay disposed before closing SQLite');

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

        final completeActionKey = GlobalKey(debugLabel: 'alarm-file-complete-action');
        final loadCompleted = Completer<String?>();
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
            completeActionKey: completeActionKey,
            onLoadComplete: (error) {
              if (!loadCompleted.isCompleted) loadCompleted.complete(error);
            },
          ),
        ));
        stage('T13.5 waiting for asynchronous Alarm Overlay load completion');
        stage('T13.5a before awaiting onLoadComplete callback signal');
        final loadError = await tester.runAsync(() => loadCompleted.future);
        stage('T13.5b onLoadComplete callback signal returned; error=$loadError');
        expect(
          loadError,
          isNull,
          reason: loadError ?? 'Alarm Overlay must finish loading before Complete interaction.',
        );
        stage('T13.5c before settling the loaded Overlay frame');
        await tester.pumpAndSettle();
        stage('T13.6 asynchronous Alarm Overlay load completed');
        stage('T14 before Complete action; verifying real control visibility');
        stage('T14.01 before reading the real Complete GlobalKey context');
        final completeContext = completeActionKey.currentContext;
        if (completeContext == null) {
          throw TestFailure('The real Complete control is not mounted.');
        }
        stage('T14.02 real Complete control context resolved');

        final completeRenderObject = completeContext.findRenderObject();
        if (completeRenderObject is! RenderBox) {
          throw TestFailure('The real Complete control has no RenderBox.');
        }
        stage('T14.03 real Complete RenderBox resolved');

        final scrollableState = Scrollable.maybeOf(completeContext);
        if (scrollableState == null) {
          throw TestFailure('The real Complete control is not inside its overlay Scrollable.');
        }
        final scrollPosition = scrollableState.position;
        stage('T14.04 real overlay ScrollPosition resolved');

        final viewport = Offset.zero &
            (tester.view.physicalSize / tester.view.devicePixelRatio);
        Rect currentCompleteRect() {
          final renderObject = completeContext.findRenderObject();
          if (renderObject is! RenderBox) {
            throw TestFailure('The real Complete control lost its RenderBox.');
          }
          return renderObject.localToGlobal(Offset.zero) & renderObject.size;
        }
        stage('T14.05 viewport and real Complete geometry access resolved');

        // Move the actual scroll position in bounded, non-animated increments.
        // The GlobalKey supplies the real button context directly, avoiding a
        // full-tree Finder cardinality traversal that stalled this test after T14.
        for (var attempt = 0; attempt < 8; attempt++) {
          stage('T14.2 scroll attempt $attempt: before Complete bounds');
          final buttonRect = currentCompleteRect();
          if (buttonRect.top >= viewport.top &&
              buttonRect.bottom <= viewport.bottom) {
            stage('T14.3 Complete bounds are inside viewport');
            break;
          }

          var delta = 0.0;
          if (buttonRect.bottom > viewport.bottom) {
            final distance = buttonRect.bottom - viewport.bottom;
            delta = distance > 220.0 ? 220.0 : distance;
          } else if (buttonRect.top < viewport.top) {
            final distance = viewport.top - buttonRect.top;
            delta = -(distance > 220.0 ? 220.0 : distance);
          }
          if (delta == 0.0) {
            break;
          }
          final nextOffset = (scrollPosition.pixels + delta)
              .clamp(scrollPosition.minScrollExtent, scrollPosition.maxScrollExtent)
              .toDouble();
          if (nextOffset == scrollPosition.pixels) {
            break;
          }
          stage('T14.4 jumpTo offset $nextOffset');
          scrollPosition.jumpTo(nextOffset);
          await tester.pump(const Duration(milliseconds: 100));
          stage('T14.5 bounded viewport frame pumped');
        }

        final completeRect = currentCompleteRect();
        expect(
          completeRect.top,
          greaterThanOrEqualTo(viewport.top),
          reason: 'The real Complete control must be visible in the overlay viewport.',
        );
        expect(
          completeRect.bottom,
          lessThanOrEqualTo(viewport.bottom),
          reason: 'The real Complete control must be fully visible before tapping.',
        );
        stage('T14a Complete control is fully inside the real test viewport');
        await tester.tapAt(currentCompleteRect().center);
        stage('T14b actual Complete button tap dispatched');
        stage('T14c awaiting real completion handler, SQLite mutation, Calendar path and notification cancellation');
        // Do not use pumpAndSettle here: the overlay owns repeating animations
        // unrelated to the asynchronous Complete handler. Pump bounded frames
        // until the handler's final notification-cancel callback is observed.
        for (var frame = 0;
            frame < 50 && !notifications.cancelled.contains(7211);
            frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(notifications.cancelled, contains(7211));
        stage('T14d Complete handler finished; notification cancellation observed');
        stage('T15 completion handler returned without global animation settling');

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
        await tester.pumpWidget(const SizedBox.shrink());
        stage('T22.1 finally: Alarm Overlay disposed before SQLite close');
        stage('T22 finally: closing current SQLite executor');
        await executor.close();
        stage('T22.2 current SQLite executor closed');
        TaskStorageLock.diagnosticLoggingEnabled = false;
        stage('T23 END: diagnostics disabled');
        stage('T23a before synchronous temporary directory cleanup');
        directory.deleteSync(recursive: true);
        stage('T24 temporary directory cleanup completed');
      }
    },
  );
}

