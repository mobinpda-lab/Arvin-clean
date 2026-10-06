import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('More exposes category and tag management', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-more-taxonomy'), skipOffstage: false),
      300,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.byKey(const ValueKey('home-more-taxonomy')), findsOneWidget);
    expect(find.text('دسته‌ها و برچسب‌ها'), findsOneWidget);
  });
}
