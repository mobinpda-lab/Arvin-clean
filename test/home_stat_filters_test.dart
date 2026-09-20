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

  testWidgets('Home exposes the four owner main views and switches grouping',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-four-main-views')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-projects')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-categories')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-labels')), findsOneWidget);

    expect(find.byKey(const ValueKey('home-summary-all')), findsNothing);
    expect(find.byKey(const ValueKey('home-summary-active')), findsNothing);
    expect(find.byKey(const ValueKey('home-summary-completed')), findsNothing);
    expect(find.byKey(const ValueKey('home-summary-overdue')), findsNothing);
    expect(find.text('کارهای من'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-main-view-categories')));
    await tester.pumpAndSettle();
    expect(find.text('دسته‌ها'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('home-main-view-labels')));
    await tester.pumpAndSettle();
    expect(find.text('برچسب‌ها'), findsWidgets);
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
    expect(find.byKey(const ValueKey('home-four-main-views')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-sort-selector')), findsNothing);
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

}
