import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/main.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';
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
      '[{"id":"past","title":"گذشته","dueDate":"${past.toIso8601String()}","category":"شخصی","tags":["خانه"]},{"id":"today","title":"امروز","dueDate":"${today.toIso8601String()}","category":"کاری","tags":["اداری"]},{"id":"tomorrow","title":"کار فردا","dueDate":"${tomorrow.toIso8601String()}","category":"شخصی"},{"id":"future","title":"آینده","dueDate":"${future.toIso8601String()}","category":"کاری"},{"id":"none","title":"بی‌زمان","category":"کاری"}]');

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تاریخ گذشته'), findsOneWidget);
    expect(find.text('امروز'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-center')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-tags')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-all')), findsNothing);
    expect(find.byKey(const ValueKey('home-compact-filter-scroll')), findsOneWidget);
    expect(find.byType(ActionChip), findsNWidgets(5));

    // Each filter keeps its own internal unrestricted choice.
    final timeFilter = find.byKey(const ValueKey('home-filter-card-time'));
    await tester.ensureVisible(timeFilter);
    await tester.pumpAndSettle();
    await tester.tap(timeFilter);
    await tester.pumpAndSettle();
    expect(find.text('همه'), findsOneWidget);
    final pastTimeOption = find.widgetWithText(RadioListTile<String>, 'گذشته');
    await tester.ensureVisible(pastTimeOption);
    await tester.tap(pastTimeOption);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب زمان'), findsNothing);

    final timeFilter = find.byKey(const ValueKey('home-filter-card-time'));
    await tester.ensureVisible(timeFilter);
    await tester.pumpAndSettle();
    await tester.tap(timeFilter);
    await tester.pumpAndSettle();
    final allTimeOption = find.widgetWithText(RadioListTile<String>, 'همه');
    await tester.ensureVisible(allTimeOption);
    await tester.tap(allTimeOption);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب زمان'), findsNothing);

    await tester.drag(find.byKey(const ValueKey('home-compact-filter-scroll')), const Offset(-180, 0));
    await tester.pumpAndSettle();
    final centerFilter = find.byKey(const ValueKey('home-filter-card-center'));
    await tester.ensureVisible(centerFilter);
    await tester.pumpAndSettle();
    await tester.tap(centerFilter);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب مرکز'), findsOneWidget);
    expect(find.text('همه مراکز'), findsOneWidget);
    await tester.tap(find.text('همه مراکز'));
    await tester.pumpAndSettle();

    final projectFilter = find.byKey(const ValueKey('home-filter-card-project'));
    await tester.ensureVisible(projectFilter);
    await tester.pumpAndSettle();
    await tester.tap(projectFilter);
    await tester.pumpAndSettle();
    expect(find.text('همه پروژه‌ها'), findsOneWidget);
    await tester.tap(find.text('همه پروژه‌ها'));
    await tester.pumpAndSettle();

    final categoryFilter = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryFilter);
    await tester.pumpAndSettle();
    await tester.tap(categoryFilter);
    await tester.pumpAndSettle();
    expect(find.text('همه دسته‌ها'), findsOneWidget);
    await tester.tap(find.text('همه دسته‌ها'));
    await tester.pumpAndSettle();

    final tagsFilter = find.byKey(const ValueKey('home-filter-card-tags'));
    await tester.ensureVisible(tagsFilter);
    await tester.pumpAndSettle();
    await tester.tap(tagsFilter);
    await tester.pumpAndSettle();
    expect(find.text('همه برچسب‌ها'), findsOneWidget);
    await tester.tap(find.text('همه برچسب‌ها'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-group-tomorrow')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-future')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-no_date')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز').last);
    await tester.pumpAndSettle();

    // A category restriction can be cleared independently while time stays active.
    final categoryFilter = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryFilter);
    await tester.pumpAndSettle();
    await tester.tap(categoryFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('کاری'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.text('امروز'), findsAtLeastNWidgets(1));
    expect(find.text('کار فردا'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-filter-card-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('همه دسته‌ها'));
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

    final legacyOnlyTitle = find.text('بدون سابقه واقعی');
    await tester.ensureVisible(legacyOnlyTitle);
    await tester.pumpAndSettle();
    expect(legacyOnlyTitle, findsOneWidget);
    await tester.tap(legacyOnlyTitle);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-card-follow-up-legacy-only')), findsNothing);
    final legacyOnlyDetails = find.byKey(const ValueKey('task-card-details-legacy-only'));
    await tester.ensureVisible(legacyOnlyDetails);
    await tester.pumpAndSettle();
    expect(legacyOnlyDetails, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home hides bottom navigation on downward scroll and restores it upward while FAB stays available', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tasks = List.generate(
      14,
      (index) => {
        'id': 'scroll-task-$index',
        'title': 'کار پیمایش $index',
        'dueDate': DateTime(2030, 11, 2, 9 + index).toIso8601String(),
      },
    );
    SharedPreferences.setMockInitialValues({'arvin.tasks': jsonEncode(tasks)});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(ArvinPrimaryNavigation), findsOneWidget);
    final add = find.byKey(const ValueKey('home-canonical-add'));
    expect(add, findsOneWidget);

    await tester.drag(find.byKey(const ValueKey('home-task-list-viewport')), const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-bottom-navigation-hidden')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);

    await tester.drag(find.byKey(const ValueKey('home-task-list-viewport')), const Offset(0, 420));
    await tester.pumpAndSettle();

    expect(find.byType(ArvinPrimaryNavigation), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
