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

  testWidgets('Home exposes the four final grouping controls', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);

    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار انجام شده'), findsOneWidget);
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
}
