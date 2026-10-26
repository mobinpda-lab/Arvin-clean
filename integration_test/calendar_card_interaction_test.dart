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
      final reminderAt = now.add(const Duration(minutes: 10));
      const taskId = 'calendar-smoke-task';
      const reminderId = 'calendar-smoke-reminder';
      const secondReminderId = 'calendar-smoke-reminder-2';
      final seed = Task(
        id: taskId,
        title: 'کار آزمون تعامل تقویم',
        createdAt: now,
        updatedAt: now,
        dueDate: now.add(const Duration(hours: 2)),
        followUps: [
          FollowUp(
            id: 'calendar-smoke-history',
            dateTime: now,
            title: 'سابقه تاریخی',
            note: 'این سابقه نباید با ویرایش یادآور تغییر کند',
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
            date: now.add(const Duration(hours: 1)),
            sequence: 2,
          ),
        ],
      );
      await store.save([seed]);
      debugPrint('CALENDAR_SMOKE: seeded one canonical record in SQLite');

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
      for (var attempt = 0; attempt < 80 && card.evaluate().isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(card, findsOneWidget);
      expect(find.text('یادآور آزمایشی'), findsOneWidget);
      expect(Directionality.of(tester.element(card)), TextDirection.rtl);
      expect(
        Theme.of(tester.element(card)).textTheme.bodyMedium?.fontFamily,
        AppFonts.vazirharfFamily,
      );
      expect(tester.takeException(), isNull);

      await binding.convertFlutterSurfaceToImage();

      // The independent Reminder opens the canonical Task editor, never a
      // Follow-up editor. Canceling the time picker must not alter its time.
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
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
      expect(afterCancel.taskReminders.singleWhere((item) => item.id == secondReminderId).date, now.add(const Duration(hours: 1)));
      expect(afterCancel.dueDate, now.add(const Duration(hours: 2)));
      expect(afterCancel.followUps.single.dateTime, now);
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
        if (current.isNotEmpty && current.single.taskReminders.single.date.hour == 23 &&
            current.single.taskReminders.single.date.minute == 47) {
          persisted = current.single;
          break;
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
      expect(savedTask.taskReminders.singleWhere((item) => item.id == secondReminderId).date, now.add(const Duration(hours: 1)));
      expect(savedTask.dueDate, now.add(const Duration(hours: 2)));
      expect(savedTask.followUps.single.dateTime, now);
      expect(savedTask.followUps.single.note, 'این سابقه نباید با ویرایش یادآور تغییر کند');
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-card-independent-reminder-edit');
      debugPrint('CALENDAR_SMOKE: independent Reminder edited and saved without changing Task due date or Follow-up history');
    },
  );
}
