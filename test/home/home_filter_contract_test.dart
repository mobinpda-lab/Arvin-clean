import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/main.dart';
import 'package:arvin/home/home_filter_ui.dart';
import 'package:arvin/services/iran_clock.dart';

void main() {
  testWidgets('Home renders five collapsible time groups and hides empty filtered groups', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final tomorrow = today.add(const Duration(days: 1));
    final future = today.add(const Duration(days: 4));
    final past = today.subtract(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arvin.tasks',
      '[{"id":"past","title":"گذشته","dueDate":"${past.toIso8601String()}"},{"id":"today","title":"امروز","dueDate":"${today.toIso8601String()}"},{"id":"tomorrow","title":"کار فردا","dueDate":"${tomorrow.toIso8601String()}"},{"id":"future","title":"آینده","dueDate":"${future.toIso8601String()}"},{"id":"none","title":"بی‌زمان"}]');

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تاریخ گذشته'), findsOneWidget);
    expect(find.text('امروز'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-tags')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-compact-filter-scroll')), findsOneWidget);
    expect(find.byType(ActionChip), findsNWidgets(5));

    expect(find.byKey(const ValueKey('home-group-tomorrow')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-future')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-no_date')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-group-today')), findsOneWidget);
    expect(find.text('تاریخ گذشته'), findsNothing);
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
  testWidgets('Home task card expands in place with real FollowUp history and preserves details route', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final actualFollowUpAt = DateTime.now().subtract(const Duration(hours: 2));
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"accordion-real","title":"کار آکاردئونی","description":"شرح دقیق کار","dueDate":"2026-11-02T12:30:00.000","followUps":[{"id":"follow-up-real","dateTime":"${actualFollowUpAt.toIso8601String()}","note":"تماس واقعی","completed":true}]},{"id":"legacy-only","title":"بدون سابقه واقعی","followUpDate":"2026-11-02T09:00:00.000"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('task-card-details-accordion-real')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-card-accordion-accordion-real')), findsOneWidget);
    expect(find.text('شرح دقیق کار'), findsNothing);

    await tester.tap(find.text('کار آکاردئونی'));
    await tester.pumpAndSettle();

    expect(find.text('شرح دقیق کار'), findsOneWidget);
    expect(find.textContaining('تاریخ و ساعت دقیق:'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-card-follow-up-accordion-real')), findsOneWidget);
    expect(find.text('آخرین پیگیری: تماس واقعی'), findsOneWidget);

    await tester.tap(find.text('بدون سابقه واقعی'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-card-follow-up-legacy-only')), findsNothing);
    expect(find.byKey(const ValueKey('task-card-details-legacy-only')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
