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

  testWidgets('Home exposes the five canonical filter controls', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('زمان'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-compact-filter-scroll')), findsOneWidget);
    expect(find.text('مرکز'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌بندی‌ها'), findsOneWidget);
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

  testWidgets('Home notification remains physically left of menu in RTL',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final notificationCenter = tester.getCenter(
      find.byKey(const ValueKey('home-notifications')),
    );
    

    expect(notificationCenter.dx, lessThan(tester.getCenter(find.byKey(const ValueKey('home-search-button'))).dx));
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
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-search-button')), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('مرکز'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌بندی‌ها'), findsOneWidget);
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

    await tester.tap(find.text('دسته‌بندی‌ها'));
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
    await tester.scrollUntilVisible(find.text('تأیید / اعمال فیلتر'), 300, scrollable: sheetScrollable);
    expect(find.text('تأیید / اعمال فیلتر'), findsOneWidget);
    expect(find.text('تا ساعت'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('اعمال بازه'), 300, scrollable: sheetScrollable);
    expect(find.text('اعمال بازه'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.ancestor(
      of: find.text('اعمال بازه'),
      matching: find.byType(FilledButton),
    ).first).onPressed, isNull);
  });

  testWidgets('category checkbox selection applies OR only after confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"one","title":"اداری","category":"اداری"},{"id":"two","title":"شخصی","category":"شخصی"},{"id":"three","title":"مالی","category":"مالی"}]',
    });
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('دسته‌بندی‌ها'));
    await tester.pumpAndSettle();
    expect(find.text('همه'), findsOneWidget);
    await tester.tap(find.text('اداری'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('شخصی'));
    await tester.pumpAndSettle();
    // Draft choices are not applied before the explicit confirmation.
    expect(find.text('مالی'), findsOneWidget);
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    expect(find.text('دسته‌بندی‌ها (۲)'), findsOneWidget);
    expect(find.text('اداری'), findsWidgets);
    expect(find.text('شخصی'), findsWidgets);
    expect(find.text('مالی'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tag choices are OR within Tags and AND with Category', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"one","title":"اول","category":"اداری","tags":["مهم","فوری"]},{"id":"two","title":"دوم","category":"اداری","tags":["فوری"]},{"id":"three","title":"سوم","category":"شخصی","tags":["مهم"]}]',
    });
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('دسته‌بندی‌ها'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اداری'));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('برچسب‌ها'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مهم'));
    await tester.tap(find.text('فوری'));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    expect(find.text('اول'), findsOneWidget);
    expect(find.text('دوم'), findsOneWidget);
    expect(find.text('سوم'), findsNothing);
    expect(find.text('برچسب‌ها (۲)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
