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
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('quick-capture-sheet')), findsOneWidget);
        expect(find.text('کار ثبت شد'), findsOneWidget);
        final current = await reader.load();
        expect(
          current.map((task) => task.title),
          contains(title),
          reason: 'Quick Capture must persist "$title" before accepting the next sequential entry.',
        );
      }

      expect(find.text('کار اول'), findsOneWidget);
      expect(find.text('کار دوم'), findsOneWidget);
      expect(find.text('کار سوم'), findsOneWidget);
      expect(find.text('پرونده موجود'), findsOneWidget);

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
      expect(find.text('کار اول'), findsOneWidget);
      expect(find.text('کار دوم'), findsOneWidget);
      expect(find.text('کار سوم'), findsOneWidget);
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
