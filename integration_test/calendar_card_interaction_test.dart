import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/persian_date_formatter.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android calendar card tap, long press, SQLite completion and Persian time picker',
    (tester) async {
      final store = TaskStore();
      final existing = await store.load();
      // Each GitHub Actions job receives a fresh emulator. Refuse to overwrite
      // unexpected data rather than clearing a possibly non-empty database.
      expect(existing, isEmpty, reason: 'Calendar smoke expects a fresh emulator database');

      final now = IranClock.now();
      // Anchor all test data to the same calendar day selected by CalendarPage.
      // A relative +10 minute timestamp can cross midnight and leave the
      // initially selected day empty, which unmounts calendar-selected-day-list.
      final testDay = DateTime(now.year, now.month, now.day);
      final reminderAt = DateTime(testDay.year, testDay.month, testDay.day, 12, 10);
      final secondReminderAt = DateTime(testDay.year, testDay.month, testDay.day, 13);
      final legacyFollowUpDate = DateTime(testDay.year, testDay.month, testDay.day, 15);
      final legacyNextFollowUp = DateTime(testDay.year, testDay.month, testDay.day, 16);
      const taskId = 'calendar-smoke-task';
      const reminderId = 'calendar-smoke-reminder';
      const secondReminderId = 'calendar-smoke-reminder-2';
      final seed = Task(
        id: taskId,
        title: 'کار آزمون تعامل تقویم',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(testDay.year, testDay.month, testDay.day, 14),
        followUpEnabled: true,
        followUpDate: legacyFollowUpDate,
        followUps: [
          FollowUp(
            id: 'calendar-smoke-history',
            dateTime: now,
            title: 'سابقه تاریخی',
            note: 'این سابقه نباید با ویرایش یادآور تغییر کند',
            nextFollowUp: legacyNextFollowUp,
          ),
        ],
        taskReminders: [
          TaskReminder(
            id: reminderId,
            title: 'یادآور آزمایشی',
            date: reminderAt,
            sequence: 1,
          ),
          TaskReminder(
            id: secondReminderId,
            title: 'یادآور مستقل دوم',
            date: secondReminderAt,
            sequence: 2,
          ),
        ],
      );
      await store.save([seed]);
      debugPrint('CALENDAR_SMOKE: seeded one canonical record in SQLite');

      // Wave 7.96 diagnostic A: verify the persisted record through a fresh
      // TaskStore.load() read, without changing any acceptance assertions.
      final reloadedTasks = await TaskStore().load();
      expect(reloadedTasks, hasLength(1));
      expect(reloadedTasks.single.id, taskId);
      expect(reloadedTasks.single.taskReminders, hasLength(2));
      expect(
        reloadedTasks.single.taskReminders.every(
          (item) => !item.isLegacyTaskReminder,
        ),
        isTrue,
        reason: 'Due Date must not turn independent reminders into legacy reminders',
      );
      debugPrint(
        'CALENDAR_DIAG_A: requestedTaskId=$taskId '
        'reloadedTaskIds=${reloadedTasks.map((task) => task.id).toList()} '
        'reloadedTaskCount=${reloadedTasks.length}',
      );
      for (final task in reloadedTasks.where((task) => task.id == taskId)) {
        debugPrint(
          'CALENDAR_DIAG_A: taskId=${task.id} '
          'reminderCount=${task.taskReminders.length}',
        );
        for (final reminder in task.taskReminders) {
          debugPrint(
            'CALENDAR_DIAG_A: taskId=${task.id} '
            'reminderId=${reminder.id} '
            'type=${reminder.isLegacyTaskReminder ? 'legacy' : 'independent'} '
            'date=${reminder.date.toIso8601String()}',
          );
        }
      }
      if (!reloadedTasks.any((task) => task.id == taskId)) {
        debugPrint('CALENDAR_DIAG_A: RESULT=TASK_NOT_FOUND_AFTER_LOAD');
      }

      app.main();
      await tester.pumpAndSettle();

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      expect(find.byType(ArvinPrimaryNavigation), findsOneWidget);
      await tester.tap(find.text('تقویم').last);
      await tester.pumpAndSettle();

      final cardKey = const ValueKey(
        'reminder-card-task-reminder-item:calendar-smoke-task:calendar-smoke-reminder',
      );
      final card = find.byKey(cardKey);
      final calendarList = find.byKey(
        const ValueKey('calendar-selected-day-list'),
      );
      final calendarScrollable = find.descendant(
        of: calendarList,
        matching: find.byType(Scrollable),
      );
      final targetDayCell = find.byKey(
        ValueKey('calendar-week-day-${testDay.year}-${testDay.month}-${testDay.day}'),
      );
      expect(targetDayCell, findsOneWidget,
          reason: 'The seeded reminder day must be visible before selecting it.');
      await tester.tap(targetDayCell);
      await tester.pumpAndSettle();

      // Wait for the canonical Task projection to reach the Calendar UI.
      // Do not attempt to scroll a selected-day list while Empty State is mounted.
      for (var attempt = 0; attempt < 50; attempt++) {
        if (card.evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(card, findsOneWidget,
          reason: 'The selected test day must show the seeded independent reminder.');
      expect(calendarList, findsOneWidget,
          reason: 'A selected day containing a reminder must mount calendar-selected-day-list.');
      expect(calendarScrollable, findsOneWidget);
      await tester.scrollUntilVisible(
        card,
        200,
        scrollable: calendarScrollable,
      );
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
      expect(find.text('یادآور آزمایشی'), findsOneWidget);
      expect(Directionality.of(tester.element(card)), TextDirection.rtl);
      expect(
        Theme.of(tester.element(card)).textTheme.bodyMedium?.fontFamily,
        AppFonts.vazirmatnFamily,
      );
      expect(tester.takeException(), isNull);

      await binding.convertFlutterSurfaceToImage();

      // The independent Reminder opens the canonical Task editor, never a
      // Follow-up editor. Canceling the time picker must not alter its time.
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      // Calendar editing awaits canonical editor preparation (storage and
      // project metadata). pumpAndSettle alone can return before that Future
      // completes when no frame is scheduled, so use the same bounded wait
      // pattern as the Android home smoke test. Keep the assertion strict.
      for (var attempt = 0; attempt < 30; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byKey(const ValueKey('arvin-task-editor-dialog')).evaluate().isNotEmpty) {
          break;
        }
      }
      expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
      final timeButton = find.byKey(const ValueKey('task-editor-reminder-time-calendar-smoke-reminder'));
      await tester.ensureVisible(timeButton);
      await tester.tap(timeButton);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
      expect(find.byKey(const ValueKey('universal-time-cancel')), findsOneWidget);
      expect(find.byKey(const ValueKey('universal-time-save')), findsOneWidget);
      expect(Directionality.of(tester.element(find.byKey(const ValueKey('universal-time-selected-value')))), TextDirection.rtl);
      await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
      await tester.pumpAndSettle();

      // Cancel must leave the canonical persisted reminder and sibling data untouched.
      final afterCancel = (await store.load()).single;
      expect(afterCancel.taskReminders.singleWhere((item) => item.id == reminderId).date, reminderAt);
      expect(afterCancel.taskReminders.singleWhere((item) => item.id == secondReminderId).date, secondReminderAt);
      expect(afterCancel.dueDate, DateTime(testDay.year, testDay.month, testDay.day, 14));
      expect(afterCancel.followUpEnabled, isTrue);
      expect(afterCancel.followUpDate, legacyFollowUpDate);
      expect(afterCancel.followUps.single.dateTime, now);
      expect(afterCancel.followUps.single.nextFollowUp, legacyNextFollowUp);
      expect(afterCancel.followUps.single.note, 'این سابقه نباید با ویرایش یادآور تغییر کند');

      // Change the date through the actual Jalali date picker.
      final dateButton = find.byKey(const ValueKey('task-editor-reminder-date-calendar-smoke-reminder'));
      await tester.ensureVisible(dateButton);
      await tester.tap(dateButton);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
      final formatter = const PersianDateFormatter();
      final targetDate = DateTime(reminderAt.year, reminderAt.month, reminderAt.day + 1);
      final initialJalali = formatter.toJalali(reminderAt);
      final targetJalali = formatter.toJalali(targetDate);
      if (targetJalali.year != initialJalali.year || targetJalali.month != initialJalali.month) {
        await tester.tap(find.byTooltip('ماه بعد'));
        await tester.pumpAndSettle();
      }
      final targetDay = find.byKey(ValueKey('persian-date-day-${targetJalali.day}'));
      await tester.ensureVisible(targetDay);
      await tester.tap(targetDay);
      await tester.tap(find.text('تأیید'));
      await tester.pumpAndSettle();

      // Make a real time change through the existing universal picker.
      await tester.tap(timeButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('universal-time-manual-toggle')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('universal-time-manual-input')), '۲۳:۴۷');
      await tester.tap(find.byKey(const ValueKey('universal-time-save')));
      await tester.pumpAndSettle();
      final saveEditor = find.byKey(const ValueKey('task-editor-header-save'));
      await tester.ensureVisible(saveEditor);
      await tester.tap(saveEditor);
      await tester.pumpAndSettle();

      Task? persisted;
      for (var attempt = 0; attempt < 50; attempt++) {
        final current = await store.load();
        if (current.isNotEmpty) {
          final matching = current.single.taskReminders
              .where((item) => item.id == reminderId)
              .toList(growable: false);
          if (matching.length == 1 &&
              matching.single.date.year == targetDate.year &&
              matching.single.date.month == targetDate.month &&
              matching.single.date.day == targetDate.day &&
              matching.single.date.hour == 23 &&
              matching.single.date.minute == 47) {
            persisted = current.single;
            break;
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
      if (persisted == null) fail('The independent TaskReminder edit was not persisted.');
      final savedTask = persisted;
      expect(savedTask.taskReminders, hasLength(2));
      final savedReminder = savedTask.taskReminders.singleWhere((item) => item.id == reminderId);
      expect(savedReminder.date.year, targetDate.year);
      expect(savedReminder.date.month, targetDate.month);
      expect(savedReminder.date.day, targetDate.day);
      expect(savedReminder.date.hour, 23);
      expect(savedReminder.date.minute, 47);
      expect(savedTask.taskReminders.singleWhere((item) => item.id == secondReminderId).date, secondReminderAt);
      expect(savedTask.dueDate, DateTime(testDay.year, testDay.month, testDay.day, 14));
      expect(savedTask.followUpEnabled, isTrue);
      expect(savedTask.followUpDate, legacyFollowUpDate);
      expect(savedTask.followUps.single.dateTime, now);
      expect(savedTask.followUps.single.nextFollowUp, legacyNextFollowUp);
      expect(savedTask.followUps.single.note, 'این سابقه نباید با ویرایش یادآور تغییر کند');
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-card-independent-reminder-edit');
      debugPrint('CALENDAR_SMOKE: independent Reminder edited and saved without changing Task due date or Follow-up history');
    },
  );
}
