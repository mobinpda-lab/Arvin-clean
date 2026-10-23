import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Calendar excludes next-action dates, projects independent Follow-up reminders, and opens the exact Task',
    (tester) async {
      final store = TaskStore();
      final existing = await store.load();
      expect(existing, isEmpty, reason: 'Calendar smoke expects a fresh emulator database');

      final now = IranClock.now();
      final dueAt = now.add(const Duration(minutes: 10));
      final reminderAt = now.add(const Duration(minutes: 20));
      final followUpAt = now.add(const Duration(minutes: 30));
      final followUpReminderAt = now.add(const Duration(minutes: 40));
      final nextFollowUpAt = now.add(const Duration(minutes: 50));
      const taskId = 'calendar-smoke-task';
      const followUpId = 'calendar-smoke-follow-up';
      final seed = Task(
        id: taskId,
        title: 'کار آزمون تعامل تقویم',
        createdAt: now,
        updatedAt: now,
        dueDate: dueAt,
        followUpEnabled: true,
        followUpDate: followUpAt,
        followUps: [
          FollowUp(
            id: followUpId,
            dateTime: followUpAt,
            title: 'پیگیری آزمایشی',
            note: 'این سابقه باید حفظ شود',
            reminderDate: followUpReminderAt,
            nextFollowUp: nextFollowUpAt,
          ),
        ],
        taskReminders: [
          TaskReminder(
            id: 'calendar-smoke-reminder',
            title: 'یادآور مجاز تقویم',
            date: reminderAt,
            sequence: 1,
          ),
        ],
      );
      await store.save([seed]);
      final persistedSeed = (await store.load()).single;
      expect(persistedSeed.followUps, hasLength(1));
      expect(persistedSeed.followUps.single.id, followUpId);
      expect(persistedSeed.followUps.single.reminderDate, followUpReminderAt);
      expect(persistedSeed.followUps.single.nextFollowUp, nextFollowUpAt);
      expect(persistedSeed.taskReminders, hasLength(1));
      debugPrint('CALENDAR_SMOKE: canonical Follow-up and independent Reminder persisted in SQLite');

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

      final dueCard = find.byKey(const ValueKey('reminder-card-task-due:calendar-smoke-task'));
      final independentReminderCard = find.byKey(const ValueKey(
        'reminder-card-task-reminder-item:calendar-smoke-task:calendar-smoke-reminder',
      ));
      final followUpCard = find.byKey(const ValueKey(
        'reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up',
      ));
      for (var attempt = 0; attempt < 80 && dueCard.evaluate().isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(dueCard, findsOneWidget);
      expect(independentReminderCard, findsOneWidget);
      expect(followUpCard, findsOneWidget);
      expect(find.text('پیگیری آزمایشی'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await binding.convertFlutterSurfaceToImage();

      // A permitted Task event opens the exact canonical Task detail in one tap.
      await tester.tap(dueCard);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-detail-title')), findsOneWidget);
      expect(find.text('کار آزمون تعامل تقویم'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-permitted-task-detail');
      debugPrint('CALENDAR_SMOKE: one tap opened the matching Task detail');

      final afterInteraction = (await store.load()).single;
      expect(afterInteraction.followUps, hasLength(1));
      expect(afterInteraction.followUps.single.id, followUpId);
      expect(afterInteraction.followUps.single.dateTime, followUpAt);
      expect(afterInteraction.followUps.single.reminderDate, followUpReminderAt);
      expect(afterInteraction.followUps.single.nextFollowUp, nextFollowUpAt);
      expect(afterInteraction.taskReminders, hasLength(1));
      expect(afterInteraction.taskReminders.single.id, 'calendar-smoke-reminder');
      debugPrint('CALENDAR_SMOKE: Follow-up history and independent Reminder survived Calendar interaction');
    },
  );
}
