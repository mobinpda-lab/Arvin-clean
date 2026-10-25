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
      expect(persisted, isNotNull);
      expect(persisted.taskReminders, hasLength(1));
      expect(persisted.taskReminders.single.id, reminderId);
      expect(persisted.taskReminders.single.date.hour, 23);
      expect(persisted.taskReminders.single.date.minute, 47);
      expect(persisted.dueDate, now.add(const Duration(hours: 2)));
      expect(persisted.followUps.single.dateTime, now);
      expect(persisted.followUps.single.note, 'این سابقه نباید با ویرایش یادآور تغییر کند');
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-card-independent-reminder-edit');
      debugPrint('CALENDAR_SMOKE: independent Reminder edited and saved without changing Task due date or Follow-up history');
    },
  );
}
