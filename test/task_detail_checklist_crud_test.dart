import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  testWidgets(
    'unified checklist add, inline edit and delete preserve legacy follow-up timestamps',
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
        expect(saved.followUpDate, legacyFollowUpDate);
        expect(
          saved.followUps.map((followUp) => followUp.toJson()).toList(),
          expectedHistoricalFollowUps,
        );
        expect(saved.followUps.single.nextFollowUp, legacyNextFollowUp);
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

      await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
      await tester.pumpAndSettle();

      final detailScrollable = find.descendant(
        of: find.byKey(const ValueKey('task-detail-content-list')),
        matching: find.byWidgetPredicate(
          (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
        ),
      ).first;
      final addInput = find.byKey(const ValueKey('task-detail-checklist-add-input'));
      await tester.scrollUntilVisible(addInput, 240, scrollable: detailScrollable);
      await tester.pumpAndSettle();
      await tester.enterText(addInput, 'تماس با مشتری');
      await tester.tap(find.byKey(const ValueKey('task-detail-checklist-add')));
      await tester.pumpAndSettle();

      // Inline editing stages the new checklist row until the unified form is saved.
      expect((await store.load()).single.checklist, isEmpty);
      final editChecklist = find.byKey(const ValueKey('task-detail-checklist-edit-0'));
      await tester.scrollUntilVisible(editChecklist, 240, scrollable: detailScrollable);
      await tester.pumpAndSettle();
      await tester.tap(editChecklist);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('task-detail-checklist-edit-input-0')),
        'تماس با مشتری (اصلاح‌شده)',
      );
      await tester.tap(find.byKey(const ValueKey('task-detail-checklist-save-0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
      await tester.pumpAndSettle();
      var saved = (await store.load()).single;
      expect(saved.checklist, ['[ ] تماس با مشتری (اصلاح‌شده)']);
      expectFollowUpHistoryUnchanged(saved);

      // Delete through the same unified edit form and persist the empty checklist.
      await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
      await tester.pumpAndSettle();
      final deleteChecklist = find.byKey(const ValueKey('task-detail-checklist-delete-0'));
      await tester.scrollUntilVisible(deleteChecklist, 240, scrollable: detailScrollable);
      await tester.pumpAndSettle();
      await tester.tap(deleteChecklist);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
      await tester.pumpAndSettle();

      saved = (await store.load()).single;
      expect(saved.checklist, isEmpty);
      expectFollowUpHistoryUnchanged(saved);
    },
  );
}
