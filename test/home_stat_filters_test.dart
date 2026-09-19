import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[\n'
          '{"id":"active","title":"کار فعال","category":"اداری","tags":["مهم"],"completed":false},\n'
          '{"id":"done","title":"کار انجام شده","category":"شخصی","completed":true},\n'
          '{"id":"late","title":"کار عقب افتاده","completed":false,"dueDate":"2020-01-01T08:00:00.000"},\n'
          '{"id":"archived","title":"کار بایگانی","archived":true}\n'
          ']',
    });
  });

  testWidgets('Home exposes four live summary cards and filters tasks',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-four-summary-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-summary-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-summary-active')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-summary-completed')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-summary-overdue')), findsOneWidget);

    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار انجام شده'), findsOneWidget);
    expect(find.text('کار عقب افتاده'), findsOneWidget);
    expect(find.text('کار بایگانی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-summary-completed')));
    await tester.pumpAndSettle();
    expect(find.text('کار انجام شده'), findsOneWidget);
    expect(find.text('کار فعال'), findsNothing);
    expect(find.text('کار عقب افتاده'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-summary-overdue')));
    await tester.pumpAndSettle();
    expect(find.text('کار عقب افتاده'), findsOneWidget);
    expect(find.text('کار انجام شده'), findsNothing);
    expect(find.text('کار فعال'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-summary-active')));
    await tester.pumpAndSettle();
    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار انجام شده'), findsNothing);
    expect(find.text('کار عقب افتاده'), findsNothing);
  });

  testWidgets('Home keeps notification physically left and menu physically right in RTL',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final notificationCenter = tester.getCenter(
      find.byKey(const ValueKey('home-notifications')),
    );
    final menuCenter = tester.getCenter(find.byKey(const ValueKey('home-menu')));

    expect(notificationCenter.dx, lessThan(menuCenter.dx));
  });

  testWidgets('Home keeps core controls reachable on a short Android viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-bismillah')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-title-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-four-summary-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-sort-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Home keeps canonical controls reachable on a normal Android phone viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-bismillah')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-title-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-four-summary-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-sort-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('grouping selector remains available without mutating task storage',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString('arvin.tasks');

    await tester.tap(find.byKey(const ValueKey('home-group-mode-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دسته‌ها').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-group-mode-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('برچسب‌ها').last);
    await tester.pumpAndSettle();

    expect(prefs.getString('arvin.tasks'), before);
  });
}
