import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[\n'
          '{"id":"active","title":"کار فعال","completed":false},\n'
          '{"id":"done","title":"کار انجام شده","completed":true},\n'
          '{"id":"late","title":"کار عقب افتاده","completed":false,"followUpEnabled":true,"followUpDate":"2020-01-01T08:00:00.000"},\n'
          '{"id":"archived","title":"کار بایگانی","archived":true}\n'
          ']',
    });
  });

  testWidgets('Home stat cards are tappable filters', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-stat-all')));
    await tester.pumpAndSettle();
    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار انجام شده'), findsOneWidget);
    expect(find.text('کار عقب افتاده'), findsOneWidget);
    expect(find.text('کار بایگانی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-stat-active')));
    await tester.pumpAndSettle();
    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار عقب افتاده'), findsOneWidget);
    expect(find.text('کار انجام شده'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-stat-done')));
    await tester.pumpAndSettle();
    expect(find.text('کار انجام شده'), findsOneWidget);
    expect(find.text('کار فعال'), findsNothing);
    expect(find.text('کار عقب افتاده'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-stat-overdue')));
    await tester.pumpAndSettle();
    expect(find.text('کار عقب افتاده'), findsOneWidget);
    expect(find.text('کار فعال'), findsNothing);
    expect(find.text('کار انجام شده'), findsNothing);
  });

  testWidgets('selected stat card exposes selected semantics', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-stat-done')));
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(
      find.byKey(const ValueKey('home-stat-done')),
    );
    expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
  });
}
