import 'package:arvin/widgets/task_category_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supports new category, known category and explicit clear',
      (tester) async {
    String? value;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: TaskCategoryField(
              value: value,
              knownCategories: const ['اداری', 'شخصی', 'اداری', '  '],
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    expect(find.text('دسته‌بندی'), findsOneWidget);
    expect(find.text('اداری'), findsOneWidget);
    expect(find.text('شخصی'), findsOneWidget);
    expect(find.byType(InputChip), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('task-category-input')),
      '  مشتری  ',
    );
    await tester.tap(find.byKey(const ValueKey('task-category-apply')));
    await tester.pump();
    expect(value, 'مشتری');

    await tester.tap(find.byKey(const ValueKey('task-category-option-اداری')));
    await tester.pump();
    expect(value, 'اداری');

    await tester.tap(find.byKey(const ValueKey('task-category-clear')));
    await tester.pump();
    expect(value, isNull);
  });
}
