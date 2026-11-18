import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[\n        {"id":"active","title":"کار فعال","category":"اداری","tags":["مهم"],"completed":false},\n        {"id":"done","title":"کار انجام شده","category":"شخصی","completed":true},\n        {"id":"late","title":"کار عقب افتاده","completed":false,"dueDate":"2020-01-01T08:00:00.000"},\n        {"id":"archived","title":"کار بایگانی","archived":true}\n      ]',
    });
  });

  testWidgets('Home exposes four implemented filters while the REV10 Center filter is pending', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);

    final scrollable = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('active')), 400, scrollable: scrollable);
    expect(find.text('کار فعال'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('done')), 400, scrollable: scrollable);
    expect(find.text('کار انجام شده'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('late')), 400, scrollable: scrollable);
    expect(find.text('کار عقب افتاده'), findsOneWidget);

    expect(find.text('کار بایگانی'), findsNothing);
  });

  testWidgets('Home general filter is physically left of menu in RTL',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final filterCenter = tester.getCenter(
      find.byKey(const ValueKey('home-global-filter')),
    );
    final menuCenter = tester.getCenter(find.byKey(const ValueKey('home-menu')));

    expect(filterCenter.dx, lessThan(menuCenter.dx));
  });

  testWidgets('Home general filter exposes Today, Timeless, Archive and Trash views', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-global-filter')));
    await tester.pumpAndSettle();

    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('کارهای فاقد زمان'), findsOneWidget);
    expect(find.text('بایگانی'), findsOneWidget);
    expect(find.text('سطل زباله'), findsOneWidget);
  });

  testWidgets('Home sort defaults to Follow-up Date and exposes all approved sort keys', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final filterScroll = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('home-filter-sort-scroll')),
    );
    expect(filterScroll.scrollDirection, Axis.horizontal);
    expect(find.byKey(const ValueKey('home-sort')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-sort')));
    await tester.pumpAndSettle();

    expect(find.text('تاریخ پیگیری'), findsOneWidget);
    expect(find.text('موعد کار'), findsOneWidget);
    expect(find.text('آخرین تغییرات'), findsOneWidget);
    expect(find.text('عنوان'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-sort-selected-lastFollowUp')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-sort-option-date')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-sort-selected-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-sort-selected-lastFollowUp')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-sort-descending')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('home-sort-descending')),
      ).value,
      isTrue,
    );

    await tester.tap(find.text('بستن'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home keeps core controls reachable on a short Android viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.text('آروین'), findsOneWidget);
    expect(find.text('مدیریت کارها، یادداشت‌ها و پیگیری‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-global-filter')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home grouping does not mutate canonical task storage',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString('arvin.tasks');

    await tester.tap(find.text('دسته‌ها'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('برچسب‌ها'));
    await tester.pumpAndSettle();

    expect(prefs.getString('arvin.tasks'), before);
  });
  testWidgets('Home time filter exposes precise date and time range controls',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('زمان'));
    await tester.pumpAndSettle();

    final sheetScrollable = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.text('از تاریخ'), 300, scrollable: sheetScrollable);
    expect(find.text('از تاریخ'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('تا تاریخ'), 300, scrollable: sheetScrollable);
    expect(find.text('تا تاریخ'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('از ساعت'), 300, scrollable: sheetScrollable);
    expect(find.text('از ساعت'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('تا ساعت'), 300, scrollable: sheetScrollable);
    expect(find.text('تا ساعت'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('اعمال بازه'), 300, scrollable: sheetScrollable);
    expect(find.text('اعمال بازه'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.ancestor(
      of: find.text('اعمال بازه'),
      matching: find.byType(FilledButton),
    ).first).onPressed, isNull);
  });

}
