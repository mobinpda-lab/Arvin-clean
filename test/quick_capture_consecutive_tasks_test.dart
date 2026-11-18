import 'package:arvin/quick_capture_dialog.dart';
import 'package:arvin/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Quick Capture keeps the sheet open for consecutive title-only tasks',
    (tester) async {
      final captured = <Task>[];
      var nextId = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'quick-${nextId++}',
              now: () => DateTime(2026, 9, 25, 10, 30),
              onCaptured: (task) async {
                captured.add(task);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byKey(const ValueKey('quick-capture-input'));
      final submit = find.byKey(const ValueKey('quick-capture-submit'));

      await tester.enterText(input, 'کار اول');
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsOneWidget);
      expect(captured, hasLength(1));
      expect(captured.single.title, 'کار اول');
      expect(captured.single.dueDate, isNull);
      expect(captured.single.reminderDate, isNull);
      expect(captured.single.priority, TaskPriority.none);

      await tester.enterText(input, 'کار دوم');
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsOneWidget);
      expect(captured, hasLength(2));
      expect(captured[1].title, 'کار دوم');
      expect(captured[1].dueDate, isNull);
      expect(captured[1].reminderDate, isNull);
      expect(captured[1].priority, TaskPriority.none);
    },
  );
  testWidgets(
    'Quick Capture Enter submits one task and keeps the sheet open',
    (tester) async {
      final captured = <Task>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'enter-1',
              now: () => DateTime(2026, 9, 27, 10, 0),
              onCaptured: (task) async => captured.add(task),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byKey(const ValueKey('quick-capture-input'));
      await tester.enterText(input, 'ثبت با اینتر');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(captured, hasLength(1));
      expect(captured.single.title, 'ثبت با اینتر');
      expect(find.byKey(const ValueKey('quick-capture-dialog')), findsOneWidget);
      expect(tester.widget<TextField>(input).controller!.text, isEmpty);
    },
  );

}
