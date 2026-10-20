import 'dart:convert';

import 'package:arvin/main.dart' as app;
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _logOccurrenceSnapshots(String phase, Task task, List<DateTime> dates) {
  for (var index = 0; index < dates.length; index++) {
    final key = dates[index].toIso8601String();
    final snapshot = task.checklistOccurrences[key];
    final lifecycle = task.occurrenceHistory[key]?['status'] ?? 'unset';
    debugPrint(
      'ARVIN_CHECKLIST_OCCURRENCE phase=$phase day=${index + 1} task_id=${task.id} key=$key snapshot=$snapshot lifecycle=$lifecycle task_completed=${task.completed} occurrence_count=${task.checklistOccurrences.length}',
    );
  }
}

const _prefix = 'ARVIN-CHECKLIST-WAVE-5-01-';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'verifies checklist snapshots after a real Android process restart',
    (tester) async {
      final store = TaskStore();
      final acceptancePreferences = await SharedPreferences.getInstance();
      final expectedTaskId =
          acceptancePreferences.getString('arvin-checklist-wave-5-14-task-id');
      final expectedSnapshotJson =
          acceptancePreferences.getString('arvin-checklist-wave-5-14-store-snapshot');
      final expectedStoreCount =
          acceptancePreferences.getInt('arvin-checklist-wave-5-14-store-count');
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
      expect(expectedTaskId, isNotNull,
          reason: 'The UI run must save the accepted Task ID before restart.');
      expect(expectedSnapshotJson, isNotNull,
          reason: 'The UI run must save the full canonical-store snapshot before restart.');
      expect(expectedStoreCount, isNotNull);
      expect(task.id, expectedTaskId,
          reason: 'Restart must recover the same Task ID, not a replacement Task.');
      final expectedTasks = (jsonDecode(expectedSnapshotJson!) as List)
          .map((raw) => Map<String, dynamic>.from(raw as Map))
          .toList(growable: false)
        ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
      final actualTasks = (await store.load())
          .map((item) => item.toJson())
          .toList(growable: false)
        ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
      expect(actualTasks, expectedTasks,
          reason: 'All canonical Task fields, relationships, occurrence snapshots, and history must survive restart.');
      expect(actualTasks.length, expectedStoreCount,
          reason: 'Canonical record count must be unchanged after restart.');
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
      expect(task.completed, isFalse);
      expect(task.checklistOccurrences.values.every((items) => items.toSet().length == items.length), isTrue);

      final recurrence = TaskRecurrenceRepository(store: store);
      final futureNotMaterialized = DateTime.parse(keys.last).add(const Duration(days: 1));
      expect(await recurrence.checklistForOccurrence(task.id, futureNotMaterialized),
          const ['[ ] A', '[ ] B', '[ ] D']);
      expect(await recurrence.checklistForOccurrence(task.id, futureNotMaterialized),
          const ['[ ] A', '[ ] B', '[ ] D']);
      expect((await store.load()).where((item) => item.title.startsWith(_prefix)), hasLength(1));

      _logOccurrenceSnapshots('post-restart', task, keys.map(DateTime.parse).toList(growable: false));
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