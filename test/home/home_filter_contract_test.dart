import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/main.dart';
import 'package:arvin/home/home_filter_ui.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  testWidgets('Home renders five collapsible time groups and hides empty filtered groups', (tester) async {
    await TaskStore.resetTestDatabase();
    addTearDown(() => TaskStore.resetTestDatabase());
    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final tomorrow = today.add(const Duration(days: 1));
    final future = today.add(const Duration(days: 4));
    final past = today.subtract(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arvin.tasks',
      '[{"id":"past","title":"گذشته","dueDate":"${past.toIso8601String()}"},{"id":"completed-past","title":"گذشته تکمیل‌شده","dueDate":"${past.toIso8601String()}","completed":true},{"id":"today","title":"امروز","dueDate":"${today.toIso8601String()}"},{"id":"tomorrow","title":"کار فردا","dueDate":"${tomorrow.toIso8601String()}"},{"id":"future","title":"آینده","dueDate":"${future.toIso8601String()}"},{"id":"none","title":"بی‌زمان"}]');

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تاریخ‌گذشته'), findsOneWidget);
    expect(find.text('گذشته تکمیل‌شده'), findsOneWidget);
    expect(find.text('امروز'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-tags')), findsOneWidget);

    final scrollable = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('home-group-tomorrow')), 400, scrollable: scrollable);
    expect(find.byKey(const ValueKey('home-group-tomorrow')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('home-group-future')), 400, scrollable: scrollable);
    expect(find.byKey(const ValueKey('home-group-future')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('home-group-no_date')), 400, scrollable: scrollable);
    expect(find.byKey(const ValueKey('home-group-no_date')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-group-today')), findsOneWidget);
    expect(find.text('تاریخ‌گذشته'), findsNothing);
    expect(find.byKey(const ValueKey('home-group-tomorrow')), findsNothing);
    expect(find.text('آینده'), findsNothing);
    expect(find.text('فاقد زمان'), findsNothing);
  });

  testWidgets('Home filter cards reduce vertical density on compact screens', (tester) async {
    Widget buildFilter(Size size) => MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            HomeFilterCard(
              dimension: HomeFilterDimension.time,
              title: 'زمان',
              value: 'امروز',
              accent: const Color(0xFF4A4CAB),
              soft: const Color(0xFFE9EAFF),
              icon: Icons.schedule_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(buildFilter(const Size(320, 640)));
    expect(
      tester.getSize(find.byKey(const ValueKey('home-filter-card-time'))).height,
      72,
    );

    await tester.pumpWidget(buildFilter(const Size(320, 800)));
    // The same AnimatedContainer transitions from 72 px to 88 px.
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getSize(find.byKey(const ValueKey('home-filter-card-time'))).height,
      88,
    );
  });

  testWidgets('Home multi-tag selection is OR within Tags and excludes unmatched tasks', (tester) async {
    await TaskStore.resetTestDatabase();
    addTearDown(() => TaskStore.resetTestDatabase());
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'arvin.tasks',
      '[{"id":"tag-first","title":"فقط برچسب اول","tags":["برچسب اول"]},'
      '{"id":"tag-second","title":"فقط برچسب دوم","tags":["برچسب دوم"]},'
      '{"id":"tag-both","title":"هر دو برچسب","tags":["برچسب اول","برچسب دوم"]},'
      '{"id":"tag-other","title":"برچسب نامرتبط","tags":["برچسب دیگر"]}]',
    );

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-filter-card-tags')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('برچسب اول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('برچسب دوم'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('بستن'), findsOneWidget);
    await tester.tap(find.byTooltip('بستن'));
    await tester.pumpAndSettle();

    expect(find.text('فقط برچسب اول'), findsOneWidget);
    expect(find.text('فقط برچسب دوم'), findsOneWidget);
    expect(find.text('هر دو برچسب'), findsOneWidget);
    expect(find.text('برچسب نامرتبط'), findsNothing);
  });
}
