import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android Calendar canonical TaskReminder interaction, editor cancel and Persian time picker',
    (tester) async {
      final store = TaskStore();
      final existing = await store.load();
      expect(existing, isEmpty, reason: 'Calendar smoke expects a fresh emulator database');

      final now = IranClock.now();
      final reminderAt = DateTime(now.year, now.month, now.day, 12, 30);
      final dueAt = DateTime(now.year, now.month, now.day, 17);
      const taskId = 'calendar-smoke-task';
      const reminderId = 'calendar-smoke-reminder';
      const reminderTitle = 'یادآور آزمایشی';
      final seed = Task(
        id: taskId,
        title: 'کار آزمون تعامل تقویم',
        createdAt: now,
        updatedAt: now,
        dueDate: dueAt,
        taskReminders: [
          TaskReminder(
            id: reminderId,
            title: reminderTitle,
            date: reminderAt,
            sequence: 1,
            alarmEnabled: false,
            calendarSyncEnabled: false,
          ),
        ],
        nextReminderSequence: 2,
      );
      await store.save([seed]);

      final seededReadback = await store.load();
      expect(seededReadback, hasLength(1));
      expect(seededReadback.single.id, taskId);
      expect(seededReadback.single.taskReminders, hasLength(1));
      expect(seededReadback.single.taskReminders.single.id, reminderId);
      expect(seededReadback.single.dueDate, dueAt);
      expect(
        seededReadback.single.taskReminders.single.date.toUtc().isAtSameMomentAs(reminderAt.toUtc()),
        isTrue,
      );
      debugPrint(
        'CALENDAR_REMINDER_TRACE: after_seed tasks=${seededReadback.length} '
        'taskIds=${seededReadback.map((task) => task.id).toList()} '
        'reminderIds=${seededReadback.expand((task) => task.taskReminders.map((item) => item.id)).toList()}',
      );

      app.main();
      await tester.pumpAndSettle();

      final startupReadback = await TaskStore().load();
      expect(startupReadback, hasLength(1));
      expect(startupReadback.single.id, taskId);
      expect(startupReadback.single.taskReminders, hasLength(1));
      expect(startupReadback.single.taskReminders.single.id, reminderId);
      expect(startupReadback.single.dueDate, dueAt);
      expect(
        startupReadback.single.taskReminders.single.date.toUtc().isAtSameMomentAs(reminderAt.toUtc()),
        isTrue,
      );
      debugPrint(
        'CALENDAR_REMINDER_TRACE: after_app_start tasks=${startupReadback.length} '
        'reminderIds=${startupReadback.expand((task) => task.taskReminders.map((item) => item.id)).toList()}',
      );

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      expect(find.byType(ArvinPrimaryNavigation), findsOneWidget);
      await tester.tap(find.text('تقویم').last);
      await tester.pumpAndSettle();
      debugPrint(
        'CALENDAR_REMINDER_TRACE: after_calendar_navigation '
        'launcherCount=${find.byType(CanonicalCalendarLauncher).evaluate().length} '
        'selectedDayListCount=${find.byKey(const ValueKey('calendar-selected-day-list')).evaluate().length}',
      );

      const cardKey = ValueKey(
        'reminder-card-task-reminder-item:calendar-smoke-task:calendar-smoke-reminder',
      );
      final card = find.byKey(cardKey);
      for (var attempt = 0; attempt < 80 && card.evaluate().isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      debugPrint(
        'CALENDAR_REMINDER_TRACE: canonicalCardCount=${card.evaluate().length} '
        'matchingTitleCount=${find.text(reminderTitle).evaluate().length}',
      );
      expect(card, findsOneWidget);
      expect(find.text(reminderTitle), findsOneWidget);
      expect(Directionality.of(tester.element(card)), TextDirection.rtl);
      expect(
        Theme.of(tester.element(card)).textTheme.bodyMedium?.fontFamily,
        AppFonts.vazirmatnFamily,
      );
      expect(tester.takeException(), isNull);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-canonical-reminder-card');

      await tester.longPress(card);
      await tester.pumpAndSettle();
      const editTaskActionKey = ValueKey(
        'task-due-edit-task-reminder-item:calendar-smoke-task:calendar-smoke-reminder',
      );
      expect(find.byKey(editTaskActionKey), findsOneWidget);
      await tester.tap(find.byKey(editTaskActionKey));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-editor-multiple-reminders')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('task-editor-reminder-title-calendar-smoke-reminder')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('task-editor-reminder-time-calendar-smoke-reminder')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
      expect(find.byKey(const ValueKey('universal-time-cancel')), findsOneWidget);
      expect(find.byKey(const ValueKey('universal-time-save')), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byKey(const ValueKey('universal-time-selected-value')))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
      await binding.takeScreenshot('calendar-vazirmatn-persian-time-picker');

      await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
      await tester.pumpAndSettle();

      // A cancelled picker must preserve both the Task due date and the
      // independently scheduled TaskReminder.
      final afterPickerCancel = await TaskStore().load();
      expect(afterPickerCancel, hasLength(1));
      expect(afterPickerCancel.single.dueDate, dueAt);
      expect(afterPickerCancel.single.taskReminders, hasLength(1));
      expect(afterPickerCancel.single.taskReminders.single.id, reminderId);
      expect(
        afterPickerCancel.single.taskReminders.single.date.toUtc().isAtSameMomentAs(reminderAt.toUtc()),
        isTrue,
      );

      // A changed editor draft is also discarded without mutating SQLite.
      await tester.enterText(
        find.byKey(const ValueKey('task-editor-title')),
        'عنوانی که نباید ذخیره شود',
      );
      await tester.tap(find.byKey(const ValueKey('task-editor-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-editor-exit-discard')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('task-editor-exit-discard')));
      await tester.pumpAndSettle();

      final finalReadback = await TaskStore().load();
      expect(finalReadback, hasLength(1));
      expect(finalReadback.single.id, taskId);
      expect(finalReadback.single.title, 'کار آزمون تعامل تقویم');
      expect(finalReadback.single.dueDate, dueAt);
      expect(finalReadback.single.taskReminders, hasLength(1));
      expect(finalReadback.single.taskReminders.single.id, reminderId);
      expect(
        finalReadback.single.taskReminders.single.date.toUtc().isAtSameMomentAs(reminderAt.toUtc()),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      debugPrint(
        'CALENDAR_REMINDER_TRACE: after_cancel dueAt=${finalReadback.single.dueDate} '
        'reminderIds=${finalReadback.single.taskReminders.map((item) => item.id).toList()}',
      );
      await binding.takeScreenshot('calendar-canonical-reminder-after-cancel');
    },
  );
}
