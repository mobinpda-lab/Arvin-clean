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
    'checklist add, inline edit and delete preserve legacy follow-up timestamps',
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

      Future<Task?> persistChecklist(Task task, List<String> checklist) async {
        task.checklist = List<String>.of(checklist);
        await store.save([task]);
        return (await store.load()).single;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: TaskDetailPage(
            task: (await store.load()).single,
            onChecklistChanged: persistChecklist,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ADD
      await tester.enterText(
        find.byKey(const ValueKey('task-detail-checklist-add-input')),
        'تماس با مشتری',
      );
      await tester.tap(find.byKey(const ValueKey('task-detail-checklist-add')));
      await tester.pumpAndSettle();

      var saved = (await store.load()).single;
      expect(saved.checklist, ['[ ] تماس با مشتری']);
      expect(saved.followUpDate, legacyFollowUpDate);
      expect(saved.followUps.single.nextFollowUp, legacyNextFollowUp);

      // INLINE EDIT via the pencil icon.
      await tester.tap(find.byKey(const ValueKey('task-detail-checklist-edit-0')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('task-detail-checklist-edit-input-0')),
        'تماس با مشتری (اصلاح‌شده)',
      );
      await tester.tap(find.byKey(const ValueKey('task-detail-checklist-save-0')));
      await tester.pumpAndSettle();

      saved = (await store.load()).single;
      expect(saved.checklist, ['[ ] تماس با مشتری (اصلاح‌شده)']);
      expect(saved.followUpDate, legacyFollowUpDate);
      expect(saved.followUps.single.nextFollowUp, legacyNextFollowUp);

      // DELETE
      await tester.tap(find.byKey(const ValueKey('task-detail-checklist-delete-0')));
      await tester.pumpAndSettle();

      saved = (await store.load()).single;
      expect(saved.checklist, isEmpty);
      expect(saved.followUpDate, legacyFollowUpDate);
      expect(saved.followUps.single.nextFollowUp, legacyNextFollowUp);
    },
  );
}
