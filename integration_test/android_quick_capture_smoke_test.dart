import 'dart:convert';

import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_migration_writer.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const canonicalAndroidOptions = SharedPreferencesAsyncAndroidOptions(
    backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
    originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(),
  );
  final canonicalPlatformStore = SharedPreferencesAsync(options: canonicalAndroidOptions);

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

      // Keep Home and Quick Capture in the same Flutter engine. Running two
      // integration-test entrypoints in one flutter test command still
      // creates separate app/test processes, which can expose SharedPreferences
      // cache boundaries. This combined smoke first proves the canonical Home
      // path, then exercises sequential Quick Capture against the same engine.
      expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(find.text('کل'), findsNothing);
    expect(find.text('فعال'), findsNothing);
    expect(find.text('انجام‌شده'), findsNothing);
    expect(find.text('عقب‌افتاده'), findsNothing);
    expect(find.text('کارهای من'), findsNothing);
    expect(find.byKey(const ValueKey('home-group-mode-selector')), findsNothing);
    expect(find.byKey(const ValueKey('home-main-view-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-projects')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-categories')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-labels')), findsOneWidget);

    await binding.convertFlutterSurfaceToImage();
    await binding.takeScreenshot('arvin-home-time');
    for (final mode in <String>['projects', 'categories', 'labels']) {
      await tester.tap(find.byKey(ValueKey('home-main-view-$mode')));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('arvin-home-$mode');
    }
    await tester.tap(find.byKey(const ValueKey('home-main-view-time')));
    await tester.pumpAndSettle();

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
        await tester.enterText(input, title);
        await tester.tap(submit);
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          find.byKey(const ValueKey('quick-capture-sheet')),
          findsOneWidget,
        );
        // Wait for the canonical persistence callback to finish before the
        // next sequential entry. This avoids a second tap racing the async
        // TaskStore mutation while the button is temporarily disabled.
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

        // Read the same canonical Android SharedPreferences file without a
        // Flutter-engine cache. This keeps the smoke test focused on real
        // persistence rather than a per-engine cache boundary.
        final raw = await canonicalPlatformStore.getString(TaskStore.key);
        expect(raw, isNotNull, reason: 'Canonical task document is missing');
        final decoded = jsonDecode(raw!) as List<dynamic>;
        expect(
          decoded.any(
            (item) => item is Map<String, dynamic> && item['title'] == title,
          ),
          isTrue,
          reason: 'Canonical Android storage did not persist: $title',
        );

        await tester.pumpAndSettle();
      }

      // Quick Capture intentionally remains open across sequential saves.
      // Validate saved tasks after closing the modal, because the modal
      // correctly blocks pointer interaction with the Home list.
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
      // Home reloads canonical storage asynchronously after the app restart.
      // Poll the real Home tree briefly rather than asserting before the reload
      // has completed. A missing task after the bounded wait remains a real
      // persistence/rendering failure.
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
      final persistedAfterRestart = await TaskStore().load();
      expect(
        persistedAfterRestart
            .where((task) => ['کار اول', 'کار دوم', 'کار سوم'].contains(task.title))
            .map((task) => task.title)
            .toSet(),
        {'کار اول', 'کار دوم', 'کار سوم'},
      );


      // Leave the canonical Quick Capture surface open so the Android smoke
      // workflow can capture the real rendered state as an artifact.
      await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('quick-capture-sheet')),
        findsOneWidget,
      );
    },
  );
}
