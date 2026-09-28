import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/widgets/arvin_roll_box.dart';

void main() {
  test('issue 1891 semantic palette exposes distinct domain tokens', () {
    expect(ArvinColors.time, isNot(ArvinColors.reminder));
    expect(ArvinColors.reminder, isNot(ArvinColors.project));
    expect(ArvinColors.project, isNot(ArvinColors.category));
    expect(ArvinColors.category, isNot(ArvinColors.tag));
    expect(ArvinColors.error, isNot(ArvinColors.neutral));
    expect(ArvinColors.primary, isNot(ArvinColors.background));
  });

  testWidgets('issue 1891 tag roll box keeps existing tags multi-selectable',
      (tester) async {
    List<String> selected = <String>[];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: ArvinTagRollBox(
              tags: const <String>['مهم', 'مشتری'],
              selectedTags: selected,
              onChanged: (value) =>
                  setState(() => selected = List<String>.of(value)),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('برچسب'));
    await tester.pumpAndSettle();

    final important = find.widgetWithText(CheckedPopupMenuItem<String>, 'مهم');
    final customer = find.widgetWithText(CheckedPopupMenuItem<String>, 'مشتری');
    expect(important, findsOneWidget);
    expect(customer, findsOneWidget);

    await tester.tap(important);
    await tester.pumpAndSettle();
    expect(selected, <String>['مهم']);

    await tester.tap(find.byTooltip('برچسب'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<String>, 'مشتری'),
    );
    await tester.pumpAndSettle();

    expect(selected, containsAll(<String>['مهم', 'مشتری']));
  });
}
