import 'package:arvin/main.dart' as app;
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android launches Persian Home and creates a canonical Task',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);

    final skipGuide = find.text('رد کردن');
    if (skipGuide.evaluate().isNotEmpty) {
      await tester.tap(skipGuide);
      await tester.pumpAndSettle();
    }


    await tester.tap(find.byKey(const ValueKey('home-canonical-add')));

    final quickCaptureDialog =
        find.byKey(const ValueKey('quick-capture-dialog'));
    for (var attempt = 0; attempt < 100; attempt++) {
      if (quickCaptureDialog.evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(quickCaptureDialog, findsOneWidget);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'تست واقعی اندروید',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-capture-full-form')));
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const ValueKey('arvin-task-editor-dialog')).evaluate().isNotEmpty) {
        break;
      }
    }

    final titleField = find.byKey(const ValueKey('task-editor-title'));
    final descriptionField =
        find.byKey(const ValueKey('task-editor-description'));
    final tagRollBox = find.byTooltip('برچسب').last;

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(tagRollBox, findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-block')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-editor-followup-enabled')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('task-editor-date')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-time')), findsNothing);

    await tester.enterText(titleField, 'تست واقعی اندروید');

    final checklistToggle = find.byKey(const ValueKey('task-editor-checklist-toggle'));
    expect(checklistToggle, findsOneWidget);
    await tester.scrollUntilVisible(checklistToggle, 300, scrollable: find.ancestor(of: checklistToggle, matching: find.byType(Scrollable)).first);
    await tester.pump();
    await tester.tap(checklistToggle);
    await tester.pump();
    final checklistBlock = find.byKey(const ValueKey('task-editor-checklist-block'));
    expect(checklistBlock, findsOneWidget);
    final checklistInput = find.byKey(const ValueKey('task-editor-checklist-input'));
    await tester.ensureVisible(checklistInput);
    await tester.enterText(checklistInput, 'کیف');
    await tester.tap(find.byKey(const ValueKey('task-editor-checklist-add')));
    await tester.pump();
    expect(find.text('کیف'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-editor-checklist-check-0')));
    await tester.pump();
    await tester.enterText(
      descriptionField,
      'ثبت از مسیر Home روی Emulator',
    );
    await tester.ensureVisible(tagRollBox);
    await tester.tap(tagRollBox);
    await tester.pumpAndSettle();
    expect(find.text('افزودن برچسب'), findsOneWidget);
    await tester.tap(find.text('افزودن برچسب'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'نام'), 'آزمایش');
    await tester.tap(find.text('افزودن').last);
    await tester.pumpAndSettle();
    expect(find.text('آزمایش'), findsOneWidget);
    await tester.tap(find.text('اعمال'));
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final persisted = await TaskStore().load();
    final created = persisted.where((task) => task.title == 'تست واقعی اندروید');
    expect(created, hasLength(1));
    expect(created.single.description, 'ثبت از مسیر Home روی Emulator');

    final quickCaptureCancel =
        find.byKey(const ValueKey('quick-capture-cancel'));
    if (quickCaptureDialog.evaluate().isNotEmpty &&
        quickCaptureCancel.evaluate().isNotEmpty) {
      await tester.tap(quickCaptureCancel);
      await tester.pumpAndSettle();
    }
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('home');

  });
}
