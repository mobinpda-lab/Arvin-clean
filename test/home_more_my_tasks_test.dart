import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('More exposes report center entry', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    final moreSheet = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-more-report')),
      300,
      scrollable: moreSheet,
    );
    expect(find.byKey(const ValueKey('home-more-report')), findsOneWidget);
    expect(find.text('گزارش‌ها'), findsOneWidget);
  });
  testWidgets('More exposes and opens the Follow-up Office waiting list',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    final moreSheet = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-more-follow-up-office')),
      250,
      scrollable: moreSheet,
    );
    expect(find.text('دفتر پیگیری'), findsOneWidget);
    expect(find.text('پیگیری‌ها و موارد منتظر پاسخ دیگران'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-more-follow-up-office')));
    await tester.pumpAndSettle();

    expect(find.byTooltip('فقط منتظر پاسخ'), findsOneWidget);
    expect(find.byTooltip('بازخوانی'), findsOneWidget);
  });

}
