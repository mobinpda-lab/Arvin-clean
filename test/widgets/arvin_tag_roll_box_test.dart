import 'package:arvin/widgets/arvin_roll_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('new tag appears and is selected in the open tag selector', (tester) async {
    var selectedTags = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: ArvinTagRollBox(
            tags: const ['قبلی'],
            selectedTags: selectedTags,
            onChanged: (value) => setState(() => selectedTags = value),
            onCreate: () async => 'جدید',
          ),
        ),
      ),
    ));

    await tester.tap(find.byType(ArvinTagRollBox));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب برچسب'), findsOneWidget);

    await tester.tap(find.text('افزودن برچسب'));
    await tester.pumpAndSettle();

    expect(find.text('جدید'), findsOneWidget);
    final checkbox = tester.widget<CheckboxListTile>(
      find.ancestor(
        of: find.text('جدید'),
        matching: find.byType(CheckboxListTile),
      ),
    );
    expect(checkbox.value, isTrue);

    await tester.tap(find.text('اعمال'));
    await tester.pumpAndSettle();
    expect(selectedTags, contains('جدید'));
  });
}
