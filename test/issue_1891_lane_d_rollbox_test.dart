import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/widgets/arvin_roll_box.dart';

void main() {
  test('issue 1891 interactive domain tokens use the approved turquoise palette', () {
    expect(ArvinColors.time, ArvinColors.primary);
    expect(ArvinColors.reminder, ArvinColors.primary);
    expect(ArvinColors.project, ArvinColors.primary);
    expect(ArvinColors.category, ArvinColors.primary);
    expect(ArvinColors.tag, ArvinColors.primary);
    expect(ArvinColors.timeDark, ArvinColors.primaryDark);
    expect(ArvinColors.reminderDark, ArvinColors.primaryDark);
    expect(ArvinColors.projectDark, ArvinColors.primaryDark);
    expect(ArvinColors.categoryDark, ArvinColors.primaryDark);
    expect(ArvinColors.tagDark, ArvinColors.primaryDark);
    expect(ArvinColors.timeSoft, ArvinColors.primarySoft);
    expect(ArvinColors.reminderSoft, ArvinColors.primarySoft);
    expect(ArvinColors.projectSoft, ArvinColors.primarySoft);
    expect(ArvinColors.categorySoft, ArvinColors.primarySoft);
    expect(ArvinColors.tagSoft, ArvinColors.primarySoft);
    expect(ArvinColors.error, isNot(ArvinColors.neutral));
    expect(ArvinColors.primary, isNot(ArvinColors.background));
  });

  testWidgets('issue 1891 tag roll box supports multi-select with apply/cancel', (tester) async {
    List<String> selected = <String>['مهم'];
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: ArvinTagRollBox(
              tags: const <String>['مهم', 'مشتری'],
              selectedTags: selected,
              onChanged: (value) => setState(() => selected = List<String>.of(value)),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final tagSelector = find.bySemanticsLabel('1 برچسب');
    expect(tagSelector, findsOneWidget);
    await tester.tap(tagSelector);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب برچسب'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));

    final targetTag = find.widgetWithText(CheckboxListTile, 'مشتری');
    expect(targetTag, findsOneWidget);
    await tester.ensureVisible(targetTag);
    await tester.pumpAndSettle();
    await tester.tap(targetTag);
    await tester.pump();
    expect(selected, <String>['مهم']);

    await tester.tap(find.text('لغو'));
    await tester.pumpAndSettle();
    expect(selected, <String>['مهم']);

    final tagSelectorAgain = find.bySemanticsLabel('1 برچسب');
    expect(tagSelectorAgain, findsOneWidget);
    await tester.tap(tagSelectorAgain);
    await tester.pumpAndSettle();
    final targetTagAgain = find.widgetWithText(CheckboxListTile, 'مشتری');
    expect(targetTagAgain, findsOneWidget);
    await tester.ensureVisible(targetTagAgain);
    await tester.pumpAndSettle();
    await tester.tap(targetTagAgain);
    await tester.pump();
    await tester.tap(find.text('اعمال'));
    await tester.pumpAndSettle();
    expect(selected, containsAll(<String>['مهم', 'مشتری']));
  });
}
