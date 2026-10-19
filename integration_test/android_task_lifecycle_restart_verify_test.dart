import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Wave 4.44 verifies Task after process restart, reopens and saves unchanged state',
    (tester) async {
      const prefix = 'ARVIN-LIFECYCLE-WAVE-4-44-';
      const editedDescription = 'توضیحات فارسی برای آزمون چرخهٔ عمر و ماندگاری داده';
      final store = TaskStore();

      Future<List<Task>> matchingTasks() async => (await store.load())
          .where((task) => task.title.startsWith(prefix))
          .toList(growable: false);

      Future<void> waitForFinder(Finder finder, {int attempts = 100}) async {
        for (var attempt = 0; attempt < attempts; attempt++) {
          if (finder.evaluate().isNotEmpty) return;
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      app.main();
      await tester.pumpAndSettle();

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      var matching = await matchingTasks();
      for (var attempt = 0; attempt < 50 && matching.isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        matching = await matchingTasks();
      }
      expect(matching, hasLength(1),
          reason: 'Exactly one Wave 4.44 Task must survive the process restart.');

      final restarted = matching.single;
      final stableId = restarted.id;
      final editedTitle = restarted.title;
      expect(stableId.trim(), isNotEmpty);
      expect(editedTitle, contains('ویرایش‌شده'));
      expect(restarted.description, editedDescription);
      expect(restarted.completed, isTrue);
      print(
        'ARVIN_LIFECYCLE_POST_RESTART id=${restarted.id} title=${restarted.title} completed=${restarted.completed} count=${matching.length}',
      );

      final titleFinder = find.text(editedTitle);
      await waitForFinder(titleFinder);
      expect(titleFinder, findsOneWidget);
      await tester.ensureVisible(titleFinder);
      await tester.tap(titleFinder);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
      expect(find.text('بازگشت به انجام‌نشده'), findsOneWidget);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('task-lifecycle-restarted');

      await tester.tap(find.byKey(const ValueKey('task-detail-complete')));
      await tester.pumpAndSettle();
      expect(find.text('انجام کار'), findsOneWidget);

      matching = await matchingTasks();
      expect(matching, hasLength(1));
      var reopened = matching.single;
      expect(reopened.id, stableId);
      expect(reopened.title, editedTitle);
      expect(reopened.description, editedDescription);
      expect(reopened.completed, isFalse);

      // Saving without editing must update the same canonical record, not add one.
      await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-editor-title')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-editor-description')), findsOneWidget);
      final save = find.byKey(const ValueKey('task-editor-header-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      matching = await matchingTasks();
      expect(matching, hasLength(1));
      reopened = matching.single;
      expect(reopened.id, stableId);
      expect(reopened.title, editedTitle);
      expect(reopened.description, editedDescription);
      expect(reopened.completed, isFalse);
      print(
        'ARVIN_LIFECYCLE_REOPENED id=${reopened.id} title=${reopened.title} completed=${reopened.completed} count=${matching.length}',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      final homeTitle = find.text(editedTitle);
      await waitForFinder(homeTitle);
      expect(homeTitle, findsOneWidget);
      await tester.ensureVisible(homeTitle);
      await tester.tap(homeTitle);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
      expect(find.text('انجام کار'), findsOneWidget);

      matching = await matchingTasks();
      expect(matching, hasLength(1));
      expect(matching.single.id, stableId);
      expect(matching.single.completed, isFalse);
      expect(matching.single.title, editedTitle);
      expect(matching.single.description, editedDescription);
    },
  );
}
