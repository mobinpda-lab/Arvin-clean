import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openEditor(
    WidgetTester tester, {
    Task? task,
    Size logicalSize = const Size(540, 960),
    ValueChanged<Task?>? onResult,
  }) async {
    tester.view.physicalSize = logicalSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showDialog<Task>(
                    context: context,
                    builder: (_) => ArvinTaskEditorDialog(task: task),
                  );
                  onResult?.call(result);
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
  }

  testWidgets('same canonical editor preserves full-entry Task fields',
      (tester) async {
    Task? result;
    final due = DateTime(2026, 9, 20, 14, 30);
    final reminder = DateTime(2026, 9, 20, 13, 45);
    final task = Task(
      id: 'full-entry',
      title: 'کار کامل',
      dueDate: due,
      reminderDate: reminder,
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
      ),
      priority: TaskPriority.high,
      completed: true,
    );

    await openEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    expect(find.byKey(const ValueKey('task-editor-more-details')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-due-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-reminder-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-recurrence')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-priority')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-completed')), findsOneWidget);

    final save = find.byKey(const ValueKey('task-editor-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'full-entry');
    expect(result!.dueDate, due);
    expect(result!.reminderDate, reminder);
    expect(result!.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(result!.recurrence?.interval, 2);
    expect(result!.priority, TaskPriority.high);
    expect(result!.completed, isTrue);
  });

  testWidgets('full-entry controls remain scroll-accessible on short RTL viewport',
      (tester) async {
    await openEditor(
      tester,
      logicalSize: const Size(360, 560),
    );

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-title')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-more-details')));
    await tester.pumpAndSettle();

    final priority = find.byKey(const ValueKey('task-editor-priority'));
    await tester.ensureVisible(priority);
    await tester.pumpAndSettle();
    expect(priority, findsOneWidget);

    final save = find.byKey(const ValueKey('task-editor-save'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    expect(save, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hiding keyboard keeps draft and one save returns one Task',
      (tester) async {
    final results = <Task?>[];
    await openEditor(
      tester,
      onResult: results.add,
    );

    final title = find.byKey(const ValueKey('task-editor-title'));
    await tester.enterText(title, 'پیش‌نویس حفظ شود');
    await tester.pump();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    expect(find.text('پیش‌نویس حفظ شود'), findsOneWidget);
    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);

    final save = find.byKey(const ValueKey('task-editor-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(results, hasLength(1));
    expect(results.single, isNotNull);
    expect(results.single!.title, 'پیش‌نویس حفظ شود');
  });
}
