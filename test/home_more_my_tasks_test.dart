import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('More exposes report center entry', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-more-report')), findsOneWidget);
    expect(find.text('گزارش‌ها'), findsOneWidget);
  });
}
