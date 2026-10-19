import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Wave 4.44 creates, edits and completes one canonical Task through Arvin UI',
    (tester) async {
      final runId = DateTime.now().microsecondsSinceEpoch.toString();
      final prefix = 'ARVIN-LIFECYCLE-WAVE-4-44-$runId';
      final initialTitle = '$prefix — کار آزمایشی';
      final editedTitle = '$prefix — کار آزمایشی ویرایش‌شده';
      const editedDescription = 'توضیحات فارسی برای آزمون چرخهٔ عمر و ماندگاری داده';
      final store = TaskStore();

      Future<void> waitForFinder(Finder finder, {int attempts = 100}) async {
        for (var attempt = 0; attempt < attempts; attempt++) {
          if (finder.evaluate().isNotEmpty) return;
          await tester.pump(const Duration(milliseconds: 100));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      Future<List<Task>> matchingTasks() async => (await store.load())
          .where((task) => task.title.startsWith(prefix))
          .toList(growable: false);

      app.main();
      await tester.pumpAndSettle();

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      final homeMenu = find.byKey(const ValueKey('home-menu'));
      await tester.ensureVisible(homeMenu);
      await tester.tap(homeMenu);
      await tester.pumpAndSettle();

      final quickCapture = find.byKey(
        const ValueKey('home-more-quick-capture'),
      );
      await waitForFinder(quickCapture);
      expect(quickCapture, findsOneWidget);
      await tester.ensureVisible(quickCapture);
      await tester.tap(quickCapture);
      await tester.pumpAndSettle();

      final dialog = find.byKey(const ValueKey('quick-capture-dialog'));
      await waitForFinder(dialog);
      expect(dialog, findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-input')),
        initialTitle,
      );
      final submit = find.byKey(const ValueKey('quick-capture-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      // Quick Capture intentionally stays open after a successful submission;
      // close only that sheet before opening the newly created Task.
      final closeQuickCapture = find.byKey(
        const ValueKey('quick-capture-cancel'),
      );
      await tester.ensureVisible(closeQuickCapture);
      await tester.tap(closeQuickCapture);
      await tester.pumpAndSettle();

      var matching = await matchingTasks();
      for (var attempt = 0; attempt < 50 && matching.isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        matching = await matchingTasks();
      }
      expect(matching, hasLength(1),
          reason: 'Quick Capture must create exactly one uniquely identified Task.');
      final created = matching.single;
      expect(created.id.trim(), isNotEmpty);
      expect(created.title, initialTitle);
      debugPrint(
        'ARVIN_LIFECYCLE_CREATED id=${created.id} title=${created.title} count=${matching.length}',
      );

      final initialTitleFinder = find.text(initialTitle);
      await tester.ensureVisible(initialTitleFinder);
      await tester.tap(initialTitleFinder);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('task-lifecycle-created');

      await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
      await tester.pumpAndSettle();
      final titleField = find.byKey(const ValueKey('task-editor-title'));
      final descriptionField = find.byKey(
        const ValueKey('task-editor-description'),
      );
      await waitForFinder(titleField);
      await waitForFinder(descriptionField);
      expect(titleField, findsOneWidget);
      expect(descriptionField, findsOneWidget);
      await tester.enterText(titleField, editedTitle);
      await tester.enterText(descriptionField, editedDescription);
      final save = find.byKey(const ValueKey('task-editor-header-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      matching = await matchingTasks();
      expect(matching, hasLength(1));
      var edited = matching.single;
      expect(edited.id, created.id);
      expect(edited.title, editedTitle);
      expect(edited.description, editedDescription);
      expect(edited.completed, isFalse);
      expect(find.text(editedTitle), findsOneWidget);
      await binding.takeScreenshot('task-lifecycle-edited');

      final complete = find.byKey(const ValueKey('task-detail-complete'));
      expect(complete, findsOneWidget);
      await tester.tap(complete);
      await tester.pumpAndSettle();
      await waitForFinder(find.text('بازگشت به انجام‌نشده'));
      expect(find.text('بازگشت به انجام‌نشده'), findsOneWidget);

      matching = await matchingTasks();
      expect(matching, hasLength(1));
      edited = matching.single;
      expect(edited.id, created.id);
      expect(edited.title, editedTitle);
      expect(edited.description, editedDescription);
      expect(edited.completed, isTrue);
      debugPrint(
        'ARVIN_LIFECYCLE_PRE_RESTART id=${edited.id} title=${edited.title} completed=${edited.completed} count=${matching.length}',
      );

      await tester.pumpAndSettle();
      await binding.takeScreenshot('task-lifecycle');
    },
  );
}
