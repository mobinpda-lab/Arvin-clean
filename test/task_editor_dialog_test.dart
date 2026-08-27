import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpEditor(
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

  testWidgets('editor matches Home visual contract and exposes date plus time',
      (tester) async {
    final task = Task(
      id: '1',
      title: 'تماس با علی',
      description: 'پیگیری مشتری',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 27, 10, 30),
      tags: const ['مشتری'],
    );

    await pumpEditor(tester, task: task);

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-time')), findsOneWidget);
    expect(find.text('۱۴۰۵/۰۶/۰۵'), findsOneWidget);
    expect(find.text('۱۰:۳۰'), findsOneWidget);
    expect(find.text('مشتری'), findsOneWidget);

    final save = tester.widget<FilledButton>(
      find.byKey(const ValueKey('task-editor-save')),
    );
    expect(save.style?.backgroundColor?.resolve({}), const Color(0xFF4A4CAB));
  });

  testWidgets('editing and saving preserves the exact existing follow-up time',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'edit',
      title: 'جلسه',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 27, 10, 30),
    );

    await pumpEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpDate, DateTime(2026, 8, 27, 10, 30));
  });

  testWidgets('changing Jalali date preserves the selected hour and minute',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'date-change',
      title: 'جلسه',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 27, 10, 30),
    );

    await pumpEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byKey(const ValueKey('task-editor-date')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('persian-date-day-6')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'تأیید'));
    await tester.pumpAndSettle();

    expect(find.text('۱۰:۳۰'), findsOneWidget);
    expect(find.text('۱۴۰۵/۰۶/۰۶'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpDate, DateTime(2026, 8, 28, 10, 30));
  });

  testWidgets('new editor allows follow-up to stay optional', (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    expect(find.text('انتخاب تاریخ'), findsOneWidget);
    expect(find.text('انتخاب ساعت'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'کار بدون پیگیری',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpEnabled, isFalse);
    expect(result!.followUpDate, isNull);
  });
}
