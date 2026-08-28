import 'package:arvin/widgets/task_bulk_edit_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category selection trims value and blank explicitly clears category', () {
    expect(TaskBulkCategorySelection.fromInput('  فروش  ').category, 'فروش');
    expect(TaskBulkCategorySelection.fromInput('   ').category, isNull);
  });

  test('tag selection trims, de-duplicates and accepts Persian comma', () {
    final selection = TaskBulkTagSelection.fromText(
      'فوری، مشتری, فوری\nپیگیری',
    );

    expect(selection.tags, ['فوری', 'مشتری', 'پیگیری']);
  });

  testWidgets('category dialog returns an explicit normalized selection',
      (tester) async {
    TaskBulkCategorySelection? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showTaskBulkCategoryDialog(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-bulk-category-input')),
      '  قراردادها  ',
    );
    await tester.tap(find.byKey(const ValueKey('task-bulk-category-apply')));
    await tester.pumpAndSettle();

    expect(result?.category, 'قراردادها');
  });

  testWidgets('tags dialog requires at least one tag and returns many',
      (tester) async {
    TaskBulkTagSelection? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showTaskBulkTagsDialog(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('task-bulk-tags-apply')),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const ValueKey('task-bulk-tags-input')),
      'مهم، فردا, مهم',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('task-bulk-tags-apply')));
    await tester.pumpAndSettle();

    expect(result?.tags, ['مهم', 'فردا']);
  });
}
