import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
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
      await TaskStore().save(<Task>[seed]);

      app.main();
      await tester.pumpAndSettle();

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quick-capture-sheet')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-input')),
        'تست واقعی اندروید',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-capture-full-form')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
      final titleField = find.byKey(const ValueKey('task-editor-title'));
      final descriptionField = find.byKey(const ValueKey('task-editor-description'));
      await tester.enterText(titleField, 'تست واقعی اندروید');
      await tester.enterText(descriptionField, 'ثبت از مسیر Home روی Emulator');
      final homeSaveButton = find.byKey(const ValueKey('task-editor-save'));
      await tester.ensureVisible(homeSaveButton);
      await tester.tap(homeSaveButton);
      await tester.pumpAndSettle();
      expect(find.text('تست واقعی اندروید'), findsOneWidget);

      final quickCaptureClose = find.byKey(
        const ValueKey('quick-capture-close'),
      );
      if (quickCaptureClose.evaluate().isNotEmpty) {
        await tester.tap(quickCaptureClose);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
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
        // Re-acquire the input hit target before every repeated entry. Android
        // can restore focus to the sheet after the previous async save.
        await tester.tap(input);
        await tester.pump();
        await tester.enterText(input, title);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(submit);
        await tester.pump();
        await tester.tap(submit);
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          find.byKey(const ValueKey('quick-capture-sheet')),
          findsOneWidget,
        );
        for (var attempt = 0; attempt < 30; attempt += 1) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find.text('ثبت کار').evaluate().isNotEmpty &&
              find.text('در حال ثبت…').evaluate().isEmpty) {
            break;
          }
        }
        expect(find.text('ثبت کار'), findsOneWidget);
        expect(find.text('در حال ثبت…'), findsNothing);

        final inputField = tester.widget<TextField>(input);
        expect(inputField.controller?.text, isEmpty);
        expect(inputField.autofocus, isTrue);
        expect(FocusManager.instance.primaryFocus, isNotNull);

        final persisted = await TaskStore().load();
        // ignore: avoid_print
        print(
          'G1 Quick Capture canonical titles after $title: '
          '${persisted.map((task) => '${task.title} [${task.id}]').join(' | ')}',
        );
        expect(
          persisted.any((task) => task.title == title),
          isTrue,
          reason: 'Canonical TaskStore did not persist: $title',
        );

        await tester.pumpAndSettle();
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
      for (final title in <String>['کار اول', 'کار دوم', 'کار سوم']) {
        var visible = false;
        for (var attempt = 0; attempt < 50; attempt += 1) {
          if (find.text(title, skipOffstage: false).evaluate().isNotEmpty) {
            visible = true;
            break;
          }
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(visible, isTrue, reason: 'Home did not render persisted task: $title');
      }
      expect(find.text('پرونده موجود', skipOffstage: false), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('quick-capture-sheet')),
        findsOneWidget,
      );
    },
  );
}
