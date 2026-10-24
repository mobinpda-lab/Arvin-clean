import 'package:arvin/main.dart' as app;
import 'package:arvin/services/follow_up_calendar_projection.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
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
      debugPrint('CALENDAR_DIAG_INPUT taskId=$taskId followUpId=$followUpId followUpDateTime=${seed.followUps.single.dateTime.toIso8601String()} reminderDate=${seed.followUps.single.reminderDate?.toIso8601String()} nextFollowUp=${seed.followUps.single.nextFollowUp?.toIso8601String()}');
      await store.save([seed]);
      final persistedSeed = (await store.load()).single;
      debugPrint('CALENDAR_DIAG_SQL taskCount=1 taskId=${persistedSeed.id} followUpCount=${persistedSeed.followUps.length} followUpId=${persistedSeed.followUps.single.id} reminderDate=${persistedSeed.followUps.single.reminderDate?.toIso8601String()} nextFollowUp=${persistedSeed.followUps.single.nextFollowUp?.toIso8601String()}');
      final projected = const FollowUpCalendarProjection().project([persistedSeed]);
      debugPrint('CALENDAR_DIAG_PROJECTION count=${projected.length} items=${projected.map((item) => '${item.id}@${item.date.toIso8601String()}').join(',')}');

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

      final launcherFinder = find.byType(CanonicalCalendarLauncher);
      if (launcherFinder.evaluate().isNotEmpty) {
        final launcher = tester.widget<CanonicalCalendarLauncher>(launcherFinder);
        debugPrint('CALENDAR_DIAG_SNAPSHOT taskCount=${launcher.tasks.length} tasks=${launcher.tasks.map((task) => '${task.id}[followUps=${task.followUps.length}]').join(',')}');
      } else {
        debugPrint('CALENDAR_DIAG_SNAPSHOT launcherCount=0');
      }
      debugPrint('CALENDAR_DIAG_EXPECTED_DAY=${DateTime(now.year, now.month, now.day).toIso8601String()}')

      final cardKey = const ValueKey(
        'reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up',
      );
      final card = find.byKey(cardKey);
      for (var attempt = 0; attempt < 80 && card.evaluate().isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      debugPrint('CALENDAR_DIAG_UI expectedCard=${cardKey.value} foundCount=${card.evaluate().length} iranNow=${IranClock.now().toIso8601String()}');
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
      expect(
        find.byKey(const ValueKey('follow-up-exit-discard')),
        findsNothing,
        reason: 'Cancelling the time picker must not leave the Follow-up form dirty',
      );
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
