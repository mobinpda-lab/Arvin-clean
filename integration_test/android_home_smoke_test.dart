import 'package:arvin/main.dart' as app;
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quick-capture-dialog')), findsOneWidget);
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
    final tagField = find.byKey(const ValueKey('task-editor-tag'));

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(tagField, findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-block')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-editor-followup-enabled')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('task-editor-date')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-time')), findsNothing);

    await tester.enterText(titleField, 'تست واقعی اندروید');
    await tester.enterText(
      descriptionField,
      'ثبت از مسیر Home روی Emulator',
    );
    await tester.ensureVisible(tagField);
    await tester.enterText(tagField, 'آزمایش');
    final addTagButton =
        find.byKey(const ValueKey('task-editor-add-tag'));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(addTagButton);
    await tester.pumpAndSettle();
    await tester.tap(addTagButton);
    await tester.pumpAndSettle();
    expect(find.text('آزمایش'), findsOneWidget);

    final saveButton = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final persisted = await TaskStore().load();
    final created = persisted.where((task) => task.title == 'تست واقعی اندروید');
    expect(created, hasLength(1));
    expect(created.single.description, 'ثبت از مسیر Home روی Emulator');
  });
}
