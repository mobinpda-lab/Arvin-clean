import 'package:arvin/main.dart';
import 'package:arvin/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates a task with trimmed text and a unique tag', (tester) async {
    Task? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<Task>(
                  context: context,
                  builder: (_) => const TaskDialog(),
                );
              },
              child: const Text('باز کردن'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      '  تماس با مشتری  ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('task-editor-description')),
      '  توضیح پیگیری  ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('task-editor-tag')),
      'مهم',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-add-tag')));
    await tester.pump();

    final save = find.byKey(const ValueKey('task-editor-save'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.title, 'تماس با مشتری');
    expect(result!.description, 'توضیح پیگیری');
    expect(result!.tags, ['مهم']);
  });

  testWidgets('editing keeps the existing id and prefilled values', (tester) async {
    final existing = Task(
      id: 'existing-id',
      title: 'کار موجود',
      description: 'توضیح موجود',
      tags: ['پیگیری'],
    );
    Task? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<Task>(
                  context: context,
                  builder: (_) => TaskDialog(task: existing),
                );
              },
              child: const Text('باز کردن'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();

    expect(find.text('ویرایش کار'), findsOneWidget);
    expect(find.text('کار موجود'), findsOneWidget);
    expect(find.text('توضیح موجود'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(InputChip),
        matching: find.text('پیگیری'),
      ),
      findsOneWidget,
    );

    final save = find.byKey(const ValueKey('task-editor-save'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'existing-id');
    expect(result!.title, 'کار موجود');
    expect(result!.description, 'توضیح موجود');
    expect(result!.tags, ['پیگیری']);
  });

  testWidgets('cancel closes the dialog without returning a task', (tester) async {
    Task? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<Task>(
                  context: context,
                  builder: (_) => const TaskDialog(),
                );
              },
              child: const Text('باز کردن'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();

    final cancel = find.byKey(const ValueKey('task-editor-cancel'));
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    await tester.tap(cancel);
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
