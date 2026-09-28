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
      MaterialApp(
        home: Scaffold(
          body: ArvinTagRollBox(
            tags: const <String>['مهم', 'مشتری'],
            selectedTags: selected,
            onChanged: (value) => selected = List<String>.of(value),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('برچسب'));
    await tester.pumpAndSettle();

    expect(find.text('مهم'), findsOneWidget);
    expect(find.text('مشتری'), findsOneWidget);

    await tester.tap(find.text('مهم'));
    await tester.pumpAndSettle();
    expect(selected, <String>['مهم']);

    await tester.tap(find.byTooltip('برچسب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مشتری'));
    await tester.pumpAndSettle();

    expect(selected, containsAll(<String>['مهم', 'مشتری']));
  });
}
