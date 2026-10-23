import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/follow_up_calendar_projection.dart';
import 'package:arvin/services/follow_up_internal_calendar_projection.dart';
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
      const followUpId = 'calendar-smoke-follow-up';
      final seed = Task(
        id: taskId,
        title: 'کار آزمون تعامل تقویم',
        createdAt: now,
        updatedAt: now,
        followUpEnabled: true,
        followUps: [
          FollowUp(
            id: followUpId,
            dateTime: now,
            title: 'پیگیری آزمایشی',
            note: 'ثبت شواهد تقویم',
            reminderDate: reminderAt,
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
        'reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up',
      );
      final card = find.byKey(cardKey);
      for (var attempt = 0; attempt < 80 && card.evaluate().isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(card, findsOneWidget);
      expect(find.text('پیگیری آزمایشی'), findsOneWidget);
      expect(Directionality.of(tester.element(card)), TextDirection.rtl);
      expect(
        Theme.of(tester.element(card)).textTheme.bodyMedium?.fontFamily,
        AppFonts.vazirharfFamily,
      );
      expect(tester.takeException(), isNull);

      await binding.convertFlutterSurfaceToImage();

      // A short tap must open the Follow-up editor, not expand the card.
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('follow-up-entry-time')), findsOneWidget);
      expect(find.text('ویرایش پیگیری'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-card-interaction');
      debugPrint('CALENDAR_SMOKE: Follow-up editor form captured after it was fully opened');

      // Open the canonical round clock and capture its Persian-digit RTL state.
      await tester.tap(find.byKey(const ValueKey('follow-up-entry-time')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
      expect(find.byKey(const ValueKey('universal-time-cancel')), findsOneWidget);
      expect(find.byKey(const ValueKey('universal-time-save')), findsOneWidget);
      expect(Directionality.of(tester.element(
        find.byKey(const ValueKey('universal-time-selected-value')),
      )), TextDirection.rtl);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-persian-time-picker');
      debugPrint('CALENDAR_SMOKE: Persian time picker rendered without framework exception');

      await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('follow-up-entry-back')));
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);

      // Long press must expose contextual actions. Completing the Follow-up
      // must update the canonical SQLite record, not a parallel UI-only state.
      await tester.longPress(card);
      await tester.pumpAndSettle();
      final completeAction = find.byKey(const ValueKey(
        'reminder-complete-followup:calendar-smoke-task:calendar-smoke-follow-up',
      ));
      expect(completeAction, findsOneWidget);
      expect(find.byKey(const ValueKey(
        'reminder-edit-followup:calendar-smoke-task:calendar-smoke-follow-up',
      )), findsOneWidget);
      await tester.tap(completeAction);
      await tester.pumpAndSettle();

      Task? persisted;
      for (var attempt = 0; attempt < 50; attempt++) {
        final current = await store.load();
        if (current.isNotEmpty && current.single.followUps.single.completed) {
          persisted = current.single;
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(persisted, isNotNull);
      expect(persisted!.followUps.single.completed, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('calendar-card-completed');
      debugPrint('CALENDAR_SMOKE: long press action persisted completed=true in SQLite');
      debugPrint('CALENDAR_SMOKE: no Flutter framework exception observed');
    },
  );

  testWidgets(
    'Follow-up without reminderDate does not project an independent reminder card',
    (tester) async {
      final followUpAt = DateTime(2026, 10, 22, 10);
      final task = Task(
        id: 'calendar-no-reminder-date',
        title: 'پیگیری بدون یادآور',
        followUpEnabled: true,
        followUps: <FollowUp>[
          FollowUp(
            id: 'follow-up-no-reminder-date',
            dateTime: followUpAt,
            title: 'پیگیری بدون زمان یادآور',
          ),
        ],
      );

      final before = task.toJson();
      final reminders = const FollowUpCalendarProjection().project([task]);
      final actions = const FollowUpInternalCalendarProjection().project([task]);

      expect(reminders, isEmpty,
          reason: 'A Follow-up without reminderDate must not become a reminder card');
      expect(
        actions,
        isEmpty,
        reason: 'No nextFollowUp was configured for this Follow-up',
      );
      expect(task.toJson(), equals(before),
          reason: 'Projection must not mutate the canonical Task or Follow-up');
    },
  );

  testWidgets(
    'nextFollowUp alone remains an internal action, not a reminder card',
    (tester) async {
      final nextActionAt = DateTime(2026, 10, 23, 14, 30);
      final task = Task(
        id: 'calendar-next-action-only',
        title: 'پیگیری بعدی بدون یادآور',
        followUpEnabled: true,
        followUps: <FollowUp>[
          FollowUp(
            id: 'follow-up-next-action-only',
            dateTime: DateTime(2026, 10, 20, 9),
            title: 'اقدام بعدی',
            nextFollowUp: nextActionAt,
          ),
        ],
      );

      final before = task.toJson();
      final reminders = const FollowUpCalendarProjection().project([task]);
      final actions = const FollowUpInternalCalendarProjection().project([task]);

      expect(reminders, isEmpty,
          reason: 'nextFollowUp alone must not create a reminder/calendar-sync item');
      expect(actions, hasLength(1),
          reason: 'The planned action remains visible in the internal Calendar projection');
      expect(actions.single.id,
          'task-followup-action:calendar-next-action-only:follow-up-next-action-only');
      expect(actions.single.date, nextActionAt);
      expect(task.followUps.single.reminderDate, isNull);
      expect(task.followUps.single.nextFollowUp, nextActionAt);
      expect(task.toJson(), equals(before),
          reason: 'Projection must preserve the two independent canonical fields');
    },
  );

  testWidgets(
    'Follow-up reminder projection preserves the independent Task date',
    (tester) async {
      final taskDate = DateTime(2026, 11, 5, 8, 15);
      final reminderDate = DateTime(2026, 10, 25, 11, 45);
      final nextActionAt = DateTime(2026, 10, 27, 16);
      final task = Task(
        id: 'calendar-independent-task-date',
        title: 'کار با تاریخ مستقل',
        dueDate: taskDate,
        followUpEnabled: true,
        followUps: <FollowUp>[
          FollowUp(
            id: 'follow-up-independent-date',
            dateTime: DateTime(2026, 10, 21, 9),
            title: 'یادآور پیگیری',
            reminderDate: reminderDate,
            nextFollowUp: nextActionAt,
          ),
        ],
      );

      final before = task.toJson();
      final reminders = const FollowUpCalendarProjection().project([task]);
      final actions = const FollowUpInternalCalendarProjection().project([task]);

      expect(reminders.map((item) => item.id), containsAll(<String>[
        'followup:calendar-independent-task-date:follow-up-independent-date',
        'task-due:calendar-independent-task-date',
      ]));
      expect(reminders, hasLength(2));
      expect(
        reminders.singleWhere((item) => item.id == 'task-due:calendar-independent-task-date').date,
        taskDate,
      );
      expect(actions, hasLength(0),
          reason: 'An explicit Follow-up reminder takes precedence over its internal next-action fallback');
      expect(task.dueDate, taskDate);
      expect(task.followUps.single.reminderDate, reminderDate);
      expect(task.followUps.single.nextFollowUp, nextActionAt);
      expect(task.toJson(), equals(before),
          reason: 'Calendar projections must not replace or clear the independent Task date');
    },
  );

}
