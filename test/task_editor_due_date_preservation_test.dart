import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editing preserves canonical due date independently', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Task? result;
    final task = Task(
      id: 'due-safe',
      title: 'تحویل قرارداد',
      dueDate: DateTime(2026, 9, 11, 14, 45),
      reminderDate: DateTime(2026, 9, 10, 9, 30),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 9, 12, 11),
      followUps: <FollowUp>[
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 9, 8, 10),
          note: 'تماس اولیه',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<Task>(
                    context: context,
                    builder: (_) => ArvinTaskEditorDialog(task: task),
                  );
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
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, DateTime(2026, 9, 11, 14, 45));
    expect(result!.reminderDate, DateTime(2026, 9, 10, 9, 30));
    expect(result!.followUpDate, DateTime(2026, 9, 12, 11));
    expect(result!.followUps, hasLength(1));
    expect(result!.followUps.single.note, 'تماس اولیه');
  });
}
