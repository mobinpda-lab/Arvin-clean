import 'package:arvin/main.dart' as app;
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android completes canonical Task People add cancel remove flow',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

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
      'تست افراد اندروید',
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
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (titleField.evaluate().isNotEmpty) break;
    }
    final descriptionField =
        find.byKey(const ValueKey('task-editor-description'));
    final saveTask = find.byKey(const ValueKey('task-editor-header-save'));

    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(saveTask, findsOneWidget);

    await tester.enterText(titleField, 'تست افراد اندروید');
    await tester.enterText(descriptionField, 'توضیح باید محفوظ بماند');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveTask);
    await tester.pumpAndSettle();
    await tester.tap(saveTask);
    await tester.pumpAndSettle();

    // Full-form editing returns to the Quick Capture sheet; close that
    // intentional sheet through its visible cancel action before navigation.
    await tester.tap(find.byKey(const ValueKey('quick-capture-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('تست افراد اندروید'), findsOneWidget);

    final homeBar = find.byType(NavigationBar);
    expect(homeBar, findsOneWidget);
    await tester.tap(find.text('تقویم'));
    await tester.pumpAndSettle();

    final calendarBar = find.byType(NavigationBar);
    expect(calendarBar, findsOneWidget);
    await tester.tap(find.text('بیشتر'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final timelineAction = find.text('خط زمانی');
    await tester.ensureVisible(timelineAction);
    await tester.pumpAndSettle();
    await tester.tap(timelineAction);
    await tester.pumpAndSettle();

    final timelineChooser = find.byType(SimpleDialog);
    if (timelineChooser.evaluate().isNotEmpty) {
      final selectedTask = find.descendant(
        of: timelineChooser,
        matching: find.text('تست افراد اندروید'),
      );
      await tester.tap(selectedTask);
      await tester.pumpAndSettle();
    }

    final timelinePage = find.byType(TaskTimelinePage);
    // The timeline route may mount after the dialog/navigation transition on a
    // slower Android emulator. Wait for the canonical destination itself first,
    // then wait for its People action. Both waits are bounded to 10 seconds.
    for (var attempt = 0; attempt < 100; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (timelinePage.evaluate().isNotEmpty) break;
    }
    expect(timelinePage, findsOneWidget);

    final peopleAction =
        find.byKey(const ValueKey('timeline-open-people'));
    for (var attempt = 0; attempt < 100; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (peopleAction.evaluate().isNotEmpty) break;
    }
    expect(peopleAction, findsOneWidget);
    await tester.tap(peopleAction);
    await tester.pumpAndSettle();

    expect(find.text('افراد مرتبط'), findsOneWidget);

    final store = TaskStore();

    await tester.tap(find.byKey(const ValueKey('people-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('people-name-input')),
      'نام لغوشده اندروید',
    );
    await tester.tap(find.byKey(const ValueKey('people-add-cancel')));
    await tester.pumpAndSettle();

    var persisted = (await store.load())
        .singleWhere((task) => task.title == 'تست افراد اندروید');
    expect(persisted.people, isEmpty);
    expect(persisted.description, 'توضیح باید محفوظ بماند');

    await tester.tap(find.byKey(const ValueKey('people-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('people-name-input')),
      'علی رضایی اندروید',
    );
    await tester.tap(find.byKey(const ValueKey('people-add-save')));
    await tester.pumpAndSettle();

    persisted = (await store.load())
        .singleWhere((task) => task.title == 'تست افراد اندروید');
    expect(persisted.people.single.displayName, 'علی رضایی اندروید');
    final personRow =
        find.byKey(ValueKey('people-row-${persisted.people.single.id}'));
    for (var attempt = 0; attempt < 20 && personRow.evaluate().isEmpty; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(personRow, findsOneWidget);
    await tester.ensureVisible(personRow);
    await tester.pumpAndSettle();

    expect(persisted.description, 'توضیح باید محفوظ بماند');

    await tester.tap(find.byTooltip('حذف ارتباط'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('people-remove-cancel')));
    await tester.pumpAndSettle();

    persisted = (await store.load())
        .singleWhere((task) => task.title == 'تست افراد اندروید');
    expect(persisted.people.single.displayName, 'علی رضایی اندروید');

    await tester.tap(find.byTooltip('حذف ارتباط'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('people-remove-confirm')));
    await tester.pumpAndSettle();

    for (var attempt = 0;
        attempt < 20 &&
            find.byKey(const ValueKey('people-empty')).evaluate().isEmpty;
        attempt++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byKey(const ValueKey('people-empty')), findsOneWidget);
    persisted = (await store.load())
        .singleWhere((task) => task.title == 'تست افراد اندروید');
    expect(persisted.people, isEmpty);
    expect(persisted.description, 'توضیح باید محفوظ بماند');
  });
}
