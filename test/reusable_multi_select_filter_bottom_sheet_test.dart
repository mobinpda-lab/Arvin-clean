import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/widgets/reusable_multi_select_filter_bottom_sheet.dart';

void main() {
  testWidgets('multi-select sheet persists inline-created option and auto-selects it', (tester) async {
    Set<String>? result;
    var savedName = '';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            key: const ValueKey('open-filter'),
            onPressed: () async {
              result = await ReusableMultiSelectFilterBottomSheet.showMultiSelect<String>(
                context,
                title: 'انتخاب دسته',
                options: const [
                  ReusableFilterOption(value: 'work', label: 'کاری'),
                ],
                selectedValues: const {},
                createLabel: 'افزودن',
                onCreate: (name) async {
                  savedName = name;
                  return ReusableFilterOption(value: 'new-$name', label: name);
                },
              );
            },
            child: const Text('بازکردن'),
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('open-filter')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'شخصی');
    await tester.tap(find.text('افزودن'));
    await tester.pumpAndSettle();

    expect(savedName, 'شخصی');
    final createdTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'شخصی'),
    );
    expect(createdTile.value, isTrue);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'کاری'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    expect(result, {'new-شخصی', 'work'});
  });

  testWidgets('single-select sheet distinguishes clearing from cancellation', (tester) async {
    ReusableSingleSelectResult<String>? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            key: const ValueKey('open-single-filter'),
            onPressed: () async {
              result = await ReusableMultiSelectFilterBottomSheet.showSingleSelect<String>(
                context,
                title: 'انتخاب پروژه',
                options: const [
                  ReusableFilterOption(value: 'p1', label: 'پروژه یک'),
                ],
                selectedValue: 'p1',
                emptyLabel: 'بدون پروژه',
              );
            },
            child: const Text('بازکردن'),
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('open-single-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<Object?>, 'بدون پروژه'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.cleared, isTrue);
    expect(result!.value, isNull);
  });
}
