import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_migration_writer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android Quick Capture supports sequential canonical task capture and persistence',
    (tester) async {
      final seed = Task(
        id: 'seed-task',
        title: 'پرونده موجود',
        createdAt: DateTime(2026, 9, 1, 8),
        followUpEnabled: true,
        followUps: <FollowUp>[
          FollowUp(
            id: 'seed-followup',
            dateTime: DateTime(2026, 9, 7, 10, 30),
            note: 'سابقه پیگیری',
          ),
        ],
        tags: <String>['قدیمی'],
      );
      final writer = TaskMigrationWriter();
      await writer.save(<Task>[seed]);

      app.main();
      await tester.pumpAndSettle();

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const ValueKey('home-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-more-quick-capture')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quick-capture-sheet')), findsOneWidget);
      final input = find.byKey(const ValueKey('quick-capture-input'));
      final submit = find.byKey(const ValueKey('quick-capture-submit'));
      expect(input, findsOneWidget);
      expect(submit, findsOneWidget);

      for (final title in <String>[
        'کار اول',
        'کار دوم',
        'کار سوم',
      ]) {
        await tester.enterText(input, title);
        await tester.tap(submit);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byKey(const ValueKey('quick-capture-sheet')), findsOneWidget);
        await tester.pumpAndSettle();
        // Validate the same canonical Home surface that the user sees after
        // each successful save. Avoid reading SharedPreferences from the
        // integration-test isolate while the app isolate is writing it.
        final homeList = find.byType(ListView);
        if (homeList.evaluate().isNotEmpty) {
          await tester.scrollUntilVisible(
            find.text(title, skipOffstage: false),
            300,
            scrollable: homeList.last,
          );
          await tester.pumpAndSettle();
        }
        expect(find.text(title), findsOneWidget);
      }

      await tester.tap(find.byKey(const ValueKey('quick-capture-close')));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      app.main();
      await tester.pumpAndSettle();

      final skipGuideAfterReload = find.text('رد کردن');
      if (skipGuideAfterReload.evaluate().isNotEmpty) {
        await tester.tap(skipGuideAfterReload);
        await tester.pumpAndSettle();
      }
      final restartedHomeList = find.byType(ListView);
      for (final title in <String>['کار اول', 'کار دوم', 'کار سوم']) {
        if (restartedHomeList.evaluate().isNotEmpty) {
          await tester.scrollUntilVisible(
            find.text(title, skipOffstage: false),
            300,
            scrollable: restartedHomeList.last,
          );
          await tester.pumpAndSettle();
        }
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('پرونده موجود'), findsOneWidget);

      // Leave the canonical Quick Capture surface open so the Android smoke
      // workflow can capture the real rendered state as an artifact.
      await tester.tap(find.byKey(const ValueKey('home-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-more-quick-capture')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quick-capture-sheet')), findsOneWidget);
    },
  );
}
