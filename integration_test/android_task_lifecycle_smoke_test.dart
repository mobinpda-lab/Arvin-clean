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
      final captureDialog = find.byKey(
        const ValueKey('quick-capture-dialog'),
      );
      // Full-form save can return to the still-open Quick Capture sheet.
      // Close visible capture routes until the real card tap target is exposed;
      // do not let a TextField/overlay intercept the subsequent hit test.
      for (var attempt = 0;
          attempt < 10 && captureDialog.evaluate().isNotEmpty;
          attempt++) {
        final closeQuickCapture = find.byKey(
          const ValueKey('quick-capture-cancel'),
        );
        if (closeQuickCapture.evaluate().isEmpty) break;
        await tester.ensureVisible(closeQuickCapture);
        await tester.tap(closeQuickCapture);
        await tester.pumpAndSettle();
      }
      expect(
        captureDialog,
        findsNothing,
        reason: 'Quick Capture must be dismissed before opening the created Task.',
      );

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

      // Tap the keyed card surface, not the title Text itself: the title's
      // glyph bounds can miss the enclosing InkWell hit target on compact API 35.
      final createdCard = find.byKey(ValueKey(created.id));
      await waitForFinder(createdCard);
      expect(createdCard, findsOneWidget);
      final createdCardTapTarget = find.byKey(
        ValueKey('task-card-open-${created.id}'),
      );
      expect(createdCardTapTarget, findsOneWidget);
      await tester.ensureVisible(createdCardTapTarget);
      await tester.tap(createdCardTapTarget);
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

      // Persistence and rendered detail state are separate acceptance checks.
      final refreshStartedAt = DateTime.now();
      await waitForFinder(find.text(editedTitle), attempts: 25);
      final refreshMilliseconds =
          DateTime.now().difference(refreshStartedAt).inMilliseconds;
      final detailTitleFinder = find.byKey(
        const ValueKey('task-detail-title'),
      );
      final renderedTitle = detailTitleFinder.evaluate().isEmpty
          ? '<task-detail-title-not-rendered>'
          : tester.widget<Text>(detailTitleFinder).data ?? '<null>';
      debugPrint(
        'ARVIN_LIFECYCLE_UI_REFRESH ms=$refreshMilliseconds renderedTitle=$renderedTitle',
      );
      expect(
        find.text(editedTitle),
        findsOneWidget,
        reason: 'The detail UI must display the saved title after edit.',
      );
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
