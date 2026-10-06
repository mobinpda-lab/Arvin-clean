import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/main.dart';

void main() {
  testWidgets('Home renders five collapsible time groups and hides empty filtered groups', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final tomorrow = today.add(const Duration(days: 1));
    final future = today.add(const Duration(days: 4));
    final past = today.subtract(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arvin.tasks',
      '[{"id":"past","title":"گذشته","dueDate":"${past.toIso8601String()}"},{"id":"today","title":"امروز","dueDate":"${today.toIso8601String()}"},{"id":"tomorrow","title":"فردا","dueDate":"${tomorrow.toIso8601String()}"},{"id":"future","title":"آینده","dueDate":"${future.toIso8601String()}"},{"id":"none","title":"بی‌زمان"}]');

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تاریخ‌گذشته'), findsOneWidget);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('فردا'), findsOneWidget);
    expect(find.text('آینده'), findsOneWidget);
    expect(find.text('فاقد زمان'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-tags')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز').last);
    await tester.pumpAndSettle();

    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('تاریخ‌گذشته'), findsNothing);
    expect(find.text('فردا'), findsNothing);
    expect(find.text('آینده'), findsNothing);
    expect(find.text('فاقد زمان'), findsNothing);
  });
}
