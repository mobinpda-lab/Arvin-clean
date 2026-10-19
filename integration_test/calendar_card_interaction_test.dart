import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() ready, {
  Duration step = const Duration(milliseconds: 100),
  Duration limit = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(limit);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (ready()) return;
  }
  await tester.pump();
}

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

      // These production-owned anchors are present once the Calendar route
      // has built its month header and view selector. Poll with a hard bound
      // instead of relying on a single settle after navigation.
      final calendarReady = find.byKey(
        const ValueKey('calendar-month-year-header'),
      );
      final calendarViewMode = find.byKey(
        const ValueKey('calendar-view-mode-control'),
      );
      for (var attempt = 0;
          attempt < 75 &&
              (calendarReady.evaluate().isEmpty ||
                  calendarViewMode.evaluate().isEmpty);
          attempt++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(calendarReady, findsOneWidget,
          reason: 'Calendar month header did not become ready within 15 seconds');
      expect(calendarViewMode, findsOneWidget,
          reason: 'Calendar view selector did not become ready within 15 seconds');

      // Production contract: _ReminderCard uses ValueKey('reminder-card-${item.id}')
      // and FollowUpCalendarProjection.reminderIdFor() returns
      // 'followup:<taskId>:<followUpId>'. Keep this exact semantic identity.
      const cardKey = ValueKey(
        'reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up',
      );
      final card = find.byKey(cardKey);

      // The selected-day ListView can lazily build children outside the
      // viewport. Scroll only within that list and cap the number of attempts.
      final selectedDayList = find.byKey(
        const ValueKey('calendar-selected-day-list'),
      );
      expect(selectedDayList, findsOneWidget,
          reason: 'Seeded reminder should create the selected-day calendar list');
      await tester.scrollUntilVisible(
        card,
        240,
        scrollable: selectedDayList,
        maxScrolls: 20,
      );
      await _pumpUntil(
        tester,
        () => tester.any(card),
        limit: const Duration(seconds: 3),
      );
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
}
