import 'package:arvin/main.dart' as app;
import 'package:arvin/services/task_store.dart';
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

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    final titleField = find.byKey(const ValueKey('task-editor-title'));
    final descriptionField =
        find.byKey(const ValueKey('task-editor-description'));
    final saveTask = find.byKey(const ValueKey('task-editor-save'));

    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(saveTask, findsOneWidget);

    await tester.enterText(titleField, 'تست افراد اندروید');
    await tester.enterText(descriptionField, 'توضیح باید محفوظ بماند');
    await tester.ensureVisible(saveTask);
    await tester.pumpAndSettle();
    await tester.tap(saveTask);
    await tester.pumpAndSettle();

    expect(find.text('تست افراد اندروید'), findsOneWidget);

    await tester.tap(find.text('تقویم'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('بیشتر'));
    await tester.pumpAndSettle();
    final timelineAction = find.text('خط زمانی');
    await tester.ensureVisible(timelineAction);
    await tester.pumpAndSettle();
    await tester.tap(timelineAction);
    await tester.pumpAndSettle();

    final timelineChooser = find.text('انتخاب کار برای خط زمانی');
    if (timelineChooser.evaluate().isNotEmpty) {
      await tester.tap(find.text('تست افراد اندروید').last);
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const ValueKey('timeline-open-people')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('timeline-open-people')));
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

    expect(find.text('علی رضایی اندروید'), findsOneWidget);

    persisted = (await store.load())
        .singleWhere((task) => task.title == 'تست افراد اندروید');
    expect(persisted.people.single.displayName, 'علی رضایی اندروید');
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

    expect(find.byKey(const ValueKey('people-empty')), findsOneWidget);
    persisted = (await store.load())
        .singleWhere((task) => task.title == 'تست افراد اندروید');
    expect(persisted.people, isEmpty);
    expect(persisted.description, 'توضیح باید محفوظ بماند');
  });
}
