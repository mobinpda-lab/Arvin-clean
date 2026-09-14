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

  testWidgets('Home exposes four canonical grouping modes without stat cards',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-four-view-selector')), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stat-all')), findsNothing);
    expect(find.byKey(const ValueKey('home-stat-active')), findsNothing);
    expect(find.byKey(const ValueKey('home-stat-done')), findsNothing);
    expect(find.byKey(const ValueKey('home-stat-overdue')), findsNothing);

    expect(find.text('کار عقب افتاده'), findsOneWidget);
    expect(find.text('کار بایگانی'), findsNothing);

    await tester.tap(find.text('دسته‌ها'));
    await tester.pumpAndSettle();
    expect(find.text('اداری'), findsOneWidget);
    expect(find.text('شخصی'), findsOneWidget);

    await tester.tap(find.text('برچسب‌ها'));
    await tester.pumpAndSettle();
    expect(find.text('مهم'), findsWidgets);
    expect(find.text('بدون برچسب'), findsOneWidget);
  });

  testWidgets('four-view selector changes grouping without mutating task storage',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString('arvin.tasks');

    await tester.tap(find.text('دسته‌ها'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('برچسب‌ها'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زمان'));
    await tester.pumpAndSettle();

    expect(prefs.getString('arvin.tasks'), before);
  });
}
