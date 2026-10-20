import 'package:arvin/main.dart' as app;
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _prefix = 'ARVIN-CHECKLIST-WAVE-5-00-';

List<List<String>> _initialSnapshots() => <List<String>>[
  const ['[x] A', '[ ] B', '[x] C'],
  const ['[ ] A', '[x] B', '[ ] C'],
  const ['[x] A', '[x] B', '[ ] C'],
  const ['[ ] A', '[ ] B', '[x] C'],
  const ['[x] A', '[x] B', '[x] C'],
  const ['[ ] A', '[x] B', '[ ] C'],
  const ['[x] A', '[ ] B', '[ ] C'],
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'creates a real Task, edits its recurring checklist through UI and persists seven occurrences',
    (tester) async {
      final store = TaskStore();
      // The emulator is disposable CI state. Remove only this test's own
      // namespaced fixtures so retries cannot create ambiguous evidence.
      await store.mutate<void>((tasks) {
        tasks.removeWhere((task) => task.title.startsWith(_prefix));
      });

      Future<void> waitForFinder(Finder finder, {int attempts = 100}) async {
        for (var attempt = 0; attempt < attempts; attempt++) {
          if (finder.evaluate().isNotEmpty) return;
          await tester.pump(const Duration(milliseconds: 100));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      Future<List<Task>> matchingTasks() async => (await store.load())
          .where((task) => task.title.startsWith(_prefix))
          .toList(growable: false);

      app.main();
      await tester.pumpAndSettle();
      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
      await tester.pumpAndSettle();
      final quickCapture = find.byKey(const ValueKey('quick-capture-dialog'));
      await waitForFinder(quickCapture);
      expect(quickCapture, findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-input')),
        '$_prefix مدرسه',
      );
      await tester.tap(find.byKey(const ValueKey('quick-capture-full-form')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);

      final checklistToggle = find.byKey(const ValueKey('task-editor-checklist-toggle'));
      await tester.ensureVisible(checklistToggle);
      await tester.tap(checklistToggle);
      await tester.pumpAndSettle();
      final checklistInput = find.byKey(const ValueKey('task-editor-checklist-input'));
      final checklistAdd = find.byKey(const ValueKey('task-editor-checklist-add'));
      for (final item in const ['A', 'B', 'C']) {
        await tester.ensureVisible(checklistInput);
        await tester.enterText(checklistInput, item);
        await tester.tap(checklistAdd);
        await tester.pump();
      }

      // Configure Repeat through the same UI control used by the product.
      final recurrenceControl = find.byKey(const ValueKey('task-editor-recurrence'));
      await tester.ensureVisible(recurrenceControl);
      await tester.tap(recurrenceControl);
      await tester.pumpAndSettle();
      await tester.tap(find.text('روزانه').last);
      await tester.pumpAndSettle();
      final save = find.byKey(const ValueKey('task-editor-header-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      final cancelCapture = find.byKey(const ValueKey('quick-capture-cancel'));
      if (cancelCapture.evaluate().isNotEmpty) {
        await tester.tap(cancelCapture);
        await tester.pumpAndSettle();
      }

      var matches = await matchingTasks();
      expect(matches, hasLength(1),
          reason: 'The Task must be created through the actual Arvin UI exactly once.');
      final createdId = matches.single.id;
      expect(createdId, isNotEmpty);
      expect(matches.single.checklist, const ['[ ] A', '[ ] B', '[ ] C']);

      final today = DateTime.now();
      final localToday = DateTime(today.year, today.month, today.day);
      final beforeRule = (await store.load()).singleWhere((task) => task.id == createdId);
      expect(beforeRule.recurrence, isNotNull);
      expect(beforeRule.recurrence!.frequency, RecurrenceFrequency.daily);
      expect(beforeRule.recurrence!.active, isTrue);

      // Generate the seven scheduled dates with the canonical recurrence
      // rule, not with hand-created occurrence records.
      final anchor = DateTime(localToday.year, localToday.month, localToday.day - 4, 6);
      final rule = beforeRule.recurrence!;
      final dates = rule.occurrencesBetween(
        anchor: anchor,
        from: anchor,
        to: anchor.add(const Duration(days: 7)),
      );
      expect(dates, hasLength(7));
      expect(
        rule.occurrencesBetween(
          anchor: anchor,
          from: anchor,
          to: anchor.add(const Duration(days: 7)),
        ),
        dates,
        reason: 'Repeat generation must be idempotent.',
      );

      final initial = _initialSnapshots();
      final recurrence = TaskRecurrenceRepository(store: store, now: () => today);

      // Use the existing canonical repository API to record pre-existing
      // execution snapshots and lifecycle states, without a parallel store.
      for (var index = 0; index < dates.length; index++) {
        await recurrence.setChecklistForOccurrence(createdId, dates[index], initial[index]);
      }
      await recurrence.setOccurrenceStatus(
        createdId,
        dates[4],
        RecurrenceOccurrenceStatus.completed,
        completedAt: dates[4].add(const Duration(hours: 1)),
      );
      await recurrence.setOccurrenceStatus(
        createdId,
        dates[5],
        RecurrenceOccurrenceStatus.cancelled,
        result: 'Wave 5.00 lifecycle fixture',
      );

      final before = (await store.load()).singleWhere((task) => task.id == createdId);
      final occurrenceHistory = <String, Map<String, dynamic>>{
        for (final entry in before.occurrenceHistory.entries)
          entry.key: Map<String, dynamic>.from(entry.value),
      };
      expect(before.checklistOccurrences, hasLength(7));
      debugPrint(
        'ARVIN_CHECKLIST_PRE_EDIT task_id=${before.id} occurrence_keys=${before.checklistOccurrences.keys.toList()..sort()}',
      );

      // Rebuild Home from canonical storage so the real editor receives the
      // persisted Repeat state rather than a stale in-memory Task copy.
      await tester.pumpWidget(const SizedBox.shrink());
      await app.main();
      await tester.pumpAndSettle();
      final secondSkipGuide = find.text('رد کردن');
      if (secondSkipGuide.evaluate().isNotEmpty) {
        await tester.tap(secondSkipGuide);
        await tester.pumpAndSettle();
      }

      final card = find.byKey(ValueKey(createdId));
      await waitForFinder(card);
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
      await tester.pumpAndSettle();

      final deleteC = find.byKey(const ValueKey('task-editor-checklist-delete-2'));
      await tester.ensureVisible(deleteC);
      await tester.tap(deleteC);
      await tester.pump();
      await tester.enterText(checklistInput, 'D');
      await tester.tap(checklistAdd);
      await tester.pump();
      expect(find.text('C'), findsNothing);
      expect(find.text('D'), findsOneWidget);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      matches = await matchingTasks();
      expect(matches, hasLength(1));
      final after = matches.single;
      expect(after.id, createdId);
      expect(after.checklist, const ['[ ] A', '[ ] B', '[ ] D']);
      expect(after.checklistOccurrences.keys.toSet(),
          dates.map((date) => date.toIso8601String()).toSet());
      for (var index = 0; index < 4; index++) {
        expect(after.checklistOccurrences[dates[index].toIso8601String()], initial[index]);
      }
      for (var index = 4; index < 7; index++) {
        expect(after.checklistOccurrences[dates[index].toIso8601String()],
            const ['[ ] A', '[ ] B', '[ ] D']);
      }
      expect(after.occurrenceHistory, occurrenceHistory);
      debugPrint(
        'ARVIN_CHECKLIST_POST_EDIT task_id=${after.id} occurrence_keys=${after.checklistOccurrences.keys.toList()..sort()} count=${matches.length}',
      );
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('checklist-evolution-after-edit');
    },
  );
}