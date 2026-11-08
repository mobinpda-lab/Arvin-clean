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
    expect(find.text('انتخاب‌شده: 0'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'شخصی');
    await tester.tap(find.text('افزودن'));
    await tester.pumpAndSettle();

    expect(savedName, 'شخصی');
    final createdTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('multi-select-option-new-شخصی')),
    );
    expect(createdTile.value, isTrue);
    expect(find.text('انتخاب‌شده: 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('multi-select-option-work')));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب‌شده: 2'), findsOneWidget);
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

  testWidgets('multi-select checkbox rows and inline creation keep 48dp targets', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            key: const ValueKey('open-filter-touch-targets'),
            onPressed: () => ReusableMultiSelectFilterBottomSheet.showMultiSelect<String>(
              context,
              title: 'انتخاب برچسب‌ها',
              options: const [
                ReusableFilterOption(value: 'one', label: 'مورد یک'),
              ],
              selectedValues: const {},
              onCreate: (name) async =>
                  ReusableFilterOption(value: name, label: name),
            ),
            child: const Text('بازکردن'),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const ValueKey('open-filter-touch-targets')));
    await tester.pumpAndSettle();

    final checkboxRows = find.byType(CheckboxListTile);
    expect(checkboxRows, findsNWidgets(2));
    for (var index = 0; index < tester.widgetList(checkboxRows).length; index++) {
      expect(tester.getSize(checkboxRows.at(index)).height, greaterThanOrEqualTo(48));
    }
    final createButton = find.widgetWithText(FilledButton, '+ ایجاد مورد جدید');
    expect(tester.getSize(createButton).height, greaterThanOrEqualTo(48));
    final selectedCount = find.byKey(const ValueKey('multi-select-selected-count'));
    expect(selectedCount, findsOneWidget);
    expect(tester.getSize(selectedCount).height, greaterThanOrEqualTo(48));
  });
}
