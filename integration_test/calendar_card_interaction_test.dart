import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'canonical TaskReminder card opens Task editor and cancels without mutation',
    (tester) async {
      final store = TaskStore();
      final existing = await store.load();
      expect(existing, isEmpty, reason: 'Calendar smoke expects a fresh emulator database');

      final now = IranClock.now();
      final reminderAt = DateTime(now.year, now.month, now.day, 12, 30);
      const taskId = 'calendar-smoke-task';
      const reminderId = 'calendar-smoke-reminder';
      const reminderTitle = 'یادآوری استاندارد آزمون';
      final seed = Task(
        id: taskId,
        title: 'کار آزمون تعامل تقویم',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(now.year, now.month, now.day, 17),
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
      final persistedBeforeLaunch = await store.load();
      expect(persistedBeforeLaunch, hasLength(1));
      expect(persistedBeforeLaunch.single.taskReminders, hasLength(1));
      expect(persistedBeforeLaunch.single.taskReminders.single.id, reminderId);
      expect(persistedBeforeLaunch.single.dueDate, seed.dueDate);

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

      final card = find.byKey(const ValueKey(
        'reminder-card-task-reminder-item:calendar-smoke-task:calendar-smoke-reminder',
      ));
      final selectedDayList = find.byKey(
        const ValueKey('calendar-selected-day-list'),
      );
      expect(selectedDayList, findsOneWidget);
      await tester.scrollUntilVisible(
        card,
        240,
        scrollable: selectedDayList,
        maxScrolls: 12,
      );
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
      expect(find.text(reminderTitle), findsOneWidget);
      expect(Directionality.of(tester.element(card)), TextDirection.rtl);
      expect(
        Theme.of(tester.element(card)).textTheme.bodyMedium?.fontFamily,
        AppFonts.vazirmatnFamily,
      );
      expect(tester.takeException(), isNull);

      await binding.convertFlutterSurfaceToImage();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-editor-title')), findsOneWidget);
      await binding.takeScreenshot('calendar-canonical-task-editor');

      await tester.enterText(
        find.byKey(const ValueKey('task-editor-title')),
        'عنوانی که نباید ذخیره شود',
      );
      await tester.tap(find.byKey(const ValueKey('task-editor-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-editor-exit-discard')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('task-editor-exit-discard')));
      await tester.pumpAndSettle();

      final persistedAfterCancel = await store.load();
      expect(persistedAfterCancel, hasLength(1));
      expect(persistedAfterCancel.single.title, 'کار آزمون تعامل تقویم');
      expect(persistedAfterCancel.single.dueDate, seed.dueDate);
      expect(persistedAfterCancel.single.taskReminders, hasLength(1));
      expect(persistedAfterCancel.single.taskReminders.single.id, reminderId);
      expect(persistedAfterCancel.single.taskReminders.single.date, reminderAt);
      expect(find.text(reminderTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
      await binding.takeScreenshot('calendar-canonical-reminder-after-cancel');
    },
  );
}
