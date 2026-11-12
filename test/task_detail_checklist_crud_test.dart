import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_detail_page.dart';

Future<void> _scrollTaskDetailUntilVisible(
  WidgetTester tester,
  Finder target,
  double delta,
) async {
  final list = tester.widget<ListView>(
    find.byKey(const ValueKey('task-detail-content-list')),
  );
  final controller = list.controller!;
  expect(controller.hasClients, isTrue);

  for (var pass = 0; pass < 2 && target.evaluate().isEmpty; pass++) {
    for (var step = 0; step < 40 && target.evaluate().isEmpty; step++) {
      final max = controller.position.maxScrollExtent;
      if (controller.offset >= max - 0.5) break;
      final next = (controller.offset + delta).clamp(0.0, max).toDouble();
      if (next <= controller.offset) break;
      controller.jumpTo(next);
      await tester.pumpAndSettle();
    }
    if (target.evaluate().isEmpty && pass == 0 && controller.offset > 0) {
      controller.jumpTo(0);
      await tester.pumpAndSettle();
    }
  }

  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  testWidgets(
    'checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps',
    (tester) async {
      final store = TaskStore();
      final legacyFollowUpDate = DateTime(2026, 8, 14, 9, 30);
      final legacyNextFollowUp = DateTime(2026, 8, 16, 11, 45);
      final initialTask = Task(
        id: 'checklist-crud-preservation',
        title: 'کار آزمایشی',
        followUpEnabled: true,
        followUpDate: legacyFollowUpDate,
        checklistEnabled: true,
        checklist: const [],
        followUps: [
          FollowUp(
            id: 'legacy-follow-up',
            dateTime: DateTime(2026, 8, 12, 8),
            nextFollowUp: legacyNextFollowUp,
          ),
        ],
      );
      await store.save([initialTask]);
      final expectedHistoricalFollowUps = initialTask.followUps
          .map((followUp) => followUp.toJson())
          .toList(growable: false);

      void expectFollowUpHistoryUnchanged(Task saved) {
        expect(saved.taskReminders, isEmpty);
        expect(saved.legacyFollowUpMetadata['taskLevel'], {
          'followUpEnabled': true,
          'followUpDate': legacyFollowUpDate.toIso8601String(),
        });
        expect(
          saved.followUps.map((followUp) => followUp.toJson()).toList(),
          expectedHistoricalFollowUps,
        );
        expect(saved.legacyFollowUpMetadata['followUps'], [
          {
            'id': 'legacy-follow-up',
            'nextFollowUp': legacyNextFollowUp.toIso8601String(),
          },
        ]);
        expect(saved.followUps.single.nextFollowUp, isNull);
      }

      Future<Task?> persistTask(Task candidate) async {
        await store.save([candidate]);
        return (await store.load()).single;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            task: (await store.load()).single,
            onTaskChanged: persistTask,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addChecklist = find.byKey(const ValueKey('task-detail-add-checklist'));
      await _scrollTaskDetailUntilVisible(tester, addChecklist, 240);
      await tester.pumpAndSettle();
      await tester.tap(addChecklist);
      await tester.pumpAndSettle();

      final addInput = find.byKey(const ValueKey('task-detail-checklist-add-input'));
      await tester.ensureVisible(addInput);
      await tester.enterText(addInput, 'تماس با مشتری');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      var saved = (await store.load()).single;
      expect(saved.checklist, ['[ ] تماس با مشتری']);
      expectFollowUpHistoryUnchanged(saved);

      final editChecklist = find.byKey(const ValueKey('task-detail-checklist-edit-0'));
      await _scrollTaskDetailUntilVisible(tester, editChecklist, 240);
      await tester.tap(editChecklist);
      await tester.pumpAndSettle();
      final editInput = find.byKey(const ValueKey('task-detail-checklist-edit-input-0'));
      await tester.enterText(editInput, 'تماس با مشتری (اصلاح‌شده)');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      saved = (await store.load()).single;
      expect(saved.checklist, ['[ ] تماس با مشتری (اصلاح‌شده)']);
      expectFollowUpHistoryUnchanged(saved);

      final deleteChecklist = find.byKey(const ValueKey('task-detail-checklist-delete-0'));
      await _scrollTaskDetailUntilVisible(tester, deleteChecklist, 240);
      await tester.tap(deleteChecklist);
      await tester.pumpAndSettle();

      saved = (await store.load()).single;
      expect(saved.checklist, isEmpty);
      expectFollowUpHistoryUnchanged(saved);
    },
  );
}
