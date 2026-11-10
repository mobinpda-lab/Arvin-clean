import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/home/home_filter_ui.dart';
import 'package:arvin/widgets/arvin_roll_box.dart';

void main() {
  test('interactive domain tokens retain semantic accents independently of the blue brand', () {
    expect(ArvinColors.primary, const Color(0xFF4169A1));
    expect(ArvinColors.time, const Color(0xFF008080));
    expect(ArvinColors.reminder, const Color(0xFFD97706));
    expect(ArvinColors.project, const Color(0xFF7C3AED));
    expect(ArvinColors.category, const Color(0xFF2563EB));
    expect(ArvinColors.tag, const Color(0xFF16A34A));
    expect(ArvinColors.timeDark, const Color(0xFF008B8B));
    expect(ArvinColors.reminderDark, const Color(0xFFB45309));
    expect(ArvinColors.projectDark, const Color(0xFF6D28D9));
    expect(ArvinColors.categoryDark, const Color(0xFF1D4ED8));
    expect(ArvinColors.tagDark, const Color(0xFF15803D));
    expect(ArvinColors.timeSoft, const Color(0xFFD9F0EE));
    expect(ArvinColors.reminderSoft, const Color(0xFFFEF3C7));
    expect(ArvinColors.projectSoft, const Color(0xFFEDE9FE));
    expect(ArvinColors.categorySoft, const Color(0xFFDBEAFE));
    expect(ArvinColors.tagSoft, const Color(0xFFDCFCE7));
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

    // ArvinTagRollBox renders a HomeFilterPill. Its label is generated from
    // selectedTags.length using Dart's default (ASCII) integer formatting.
    // Find the concrete trigger widget instead of depending on a semantics
    // tree being enabled by the test binding.
    final tagSelector = find.byType(HomeFilterPill);
    expect(tagSelector, findsOneWidget);
    expect(find.text('1 برچسب'), findsOneWidget);
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

    final tagSelectorAgain = find.byType(HomeFilterPill);
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
