import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openEditor(
    WidgetTester tester, {
    Task? task,
    ValueChanged<Task?>? onResult,
  }) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2;
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

  testWidgets('due controls are independent and visible for a new ordinary task',
      (tester) async {
    await openEditor(tester);

    expect(find.byKey(const ValueKey('task-editor-due-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-due-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-due-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-date')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-time')), findsNothing);
    expect(find.text('مستقل از یادآور و زمان پیگیری'), findsOneWidget);
  });

  testWidgets('editing shows existing due date in Jalali and saves it unchanged',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'due-edit',
      title: 'تحویل',
      dueDate: DateTime(2026, 8, 28, 14, 45),
      reminderDate: DateTime(2026, 8, 28, 13),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 29, 10),
    );

    await openEditor(tester, task: task, onResult: (value) => result = value);

    expect(find.text('۱۴۰۵/۰۶/۰۶'), findsOneWidget);
    expect(find.text('۱۴:۴۵'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(result?.dueDate, DateTime(2026, 8, 28, 14, 45));
    expect(result?.reminderDate, DateTime(2026, 8, 28, 13));
    expect(result?.followUpDate, DateTime(2026, 8, 29, 10));
  });

  testWidgets('due date can be cleared without clearing follow-up', (tester) async {
    Task? result;
    final task = Task(
      id: 'due-clear',
      title: 'پرونده',
      dueDate: DateTime(2026, 8, 30, 12),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 31, 9, 30),
    );

    await openEditor(tester, task: task, onResult: (value) => result = value);
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-clear-due')));
    await tester.tap(find.byKey(const ValueKey('task-editor-clear-due')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(result?.dueDate, isNull);
    expect(result?.followUpDate, DateTime(2026, 8, 31, 9, 30));
    expect(result?.followUpEnabled, isTrue);
  });
}
