import 'package:arvin/main.dart' as app;
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _prefix = 'ARVIN-CHECKLIST-WAVE-5-00-';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'verifies checklist snapshots after a real Android process restart',
    (tester) async {
      final store = TaskStore();
      app.main();
      await tester.pumpAndSettle();

      Future<List<Task>> matchingTasks() async => (await store.load())
          .where((task) => task.title.startsWith(_prefix))
          .toList(growable: false);

      Future<void> waitForFinder(Finder finder, {int attempts = 100}) async {
        for (var attempt = 0; attempt < attempts; attempt++) {
          if (finder.evaluate().isNotEmpty) return;
          await tester.pump(const Duration(milliseconds: 100));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      var matches = await matchingTasks();
      for (var attempt = 0; attempt < 50 && matches.isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        matches = await matchingTasks();
      }
      expect(matches, hasLength(1),
          reason: 'Exactly one UI-created Checklist Task must survive process restart.');
      final task = matches.single;
      expect(task.id, isNotEmpty);
      expect(task.recurrence, isNotNull);
      expect(task.recurrence!.frequency, RecurrenceFrequency.daily);
      expect(task.recurrence!.active, isTrue);
      expect(task.checklist, const ['[ ] A', '[ ] B', '[ ] D']);
      expect(task.checklistOccurrences, hasLength(7));
      final keys = task.checklistOccurrences.keys.toList()..sort();
      const oldSnapshots = <List<String>>[
        ['[x] A', '[ ] B', '[x] C'],
        ['[ ] A', '[x] B', '[ ] C'],
        ['[x] A', '[x] B', '[ ] C'],
        ['[ ] A', '[ ] B', '[x] C'],
      ];
      for (var index = 0; index < 4; index++) {
        expect(task.checklistOccurrences[keys[index]], oldSnapshots[index]);
      }
      for (var index = 4; index < 7; index++) {
        expect(task.checklistOccurrences[keys[index]], const ['[ ] A', '[ ] B', '[ ] D']);
      }
      expect(task.occurrenceHistory[keys[4]]?['status'], 'completed');
      expect(task.occurrenceHistory[keys[5]]?['status'], 'cancelled');
      expect(keys.toSet(), hasLength(7));
      expect(task.checklistOccurrences.values.every((items) => items.toSet().length == items.length), isTrue);

      final recurrence = TaskRecurrenceRepository(store: store);
      final futureNotMaterialized = DateTime.parse(keys.last).add(const Duration(days: 1));
      expect(await recurrence.checklistForOccurrence(task.id, futureNotMaterialized),
          const ['[ ] A', '[ ] B', '[ ] D']);
      expect(await recurrence.checklistForOccurrence(task.id, futureNotMaterialized),
          const ['[ ] A', '[ ] B', '[ ] D']);
      expect((await store.load()).where((item) => item.title.startsWith(_prefix)), hasLength(1));

      debugPrint(
        'ARVIN_CHECKLIST_POST_RESTART task_id=${task.id} occurrence_keys=$keys count=${matches.length}',
      );
      final card = find.byKey(ValueKey(task.id));
      await waitForFinder(card);
      expect(card, findsOneWidget);
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('checklist-evolution-restarted');
    },
  );
}