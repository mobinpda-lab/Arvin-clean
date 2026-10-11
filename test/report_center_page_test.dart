import 'package:arvin/arvin_colors.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/report_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Report Center uses pastel colors for task status cards', (tester) async {
    final now = DateTime(2026, 10, 7, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: now,
          tasks: [
            Task(id: 'done', title: 'انجام‌شده', completed: true),
            Task(id: 'late', title: 'عقب‌افتاده', dueDate: DateTime(2026, 10, 6, 9)),
            Task(id: 'planned', title: 'برنامه‌ریزی‌شده', dueDate: DateTime(2026, 10, 8, 9)),
          ],
        ),
      ),
    );

    expect(
      tester.widget<Card>(find.byKey(const ValueKey('report-task-card-done'))).color,
      ArvinColors.timeSoft,
    );
    expect(
      tester.widget<Card>(find.byKey(const ValueKey('report-task-card-late'))).color,
      ArvinColors.errorSoft,
    );
    expect(
      tester.widget<Card>(find.byKey(const ValueKey('report-task-card-planned'))).color,
      ArvinColors.projectSoft,
    );
  });

  testWidgets('Report Center opens an Arvin bottom-sheet filter panel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [
            Task(id: 'one', title: 'اول', dueDate: DateTime(2026, 10, 7, 15)),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();

    expect(find.text('فیلتر گزارش‌ها'), findsOneWidget);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('بازه دقیق'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('report-filter-apply')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-clear')), findsOneWidget);
  });

  testWidgets(
    'Report Center combines time and category filters and opens that exact report scope',
    (tester) async {
      final now = DateTime(2026, 10, 7, 10);
      await tester.pumpWidget(
        MaterialApp(
          home: ReportCenterPage(
            now: now,
            tasks: [
              Task(
                id: 'match',
                title: 'جلسه امروز',
                category: 'کار',
                tags: ['مهم'],
                dueDate: DateTime(2026, 10, 7, 15),
              ),
              Task(
                id: 'wrong-time',
                title: 'جلسه فردا',
                category: 'کار',
                tags: ['مهم'],
                dueDate: DateTime(2026, 10, 8, 15),
              ),
              Task(
                id: 'wrong-category',
                title: 'خرید امروز',
                category: 'خرید',
                tags: ['مهم'],
                dueDate: DateTime(2026, 10, 7, 15),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('report-center-filters')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'امروز'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const ValueKey('report-filter-section-دسته')));
      await tester.tap(find.byKey(const ValueKey('report-filter-section-دسته')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('report-filter-category-کار')));
      await tester.tap(find.byKey(const ValueKey('report-filter-category-کار')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
      await tester.pumpAndSettle();

      expect(find.text('نتیجه: 1 کار'), findsOneWidget);
      expect(find.text('جلسه امروز'), findsOneWidget);
      expect(find.text('خرید امروز'), findsNothing);
      expect(find.text('جلسه فردا'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('report-center-open-report')));
      await tester.pumpAndSettle();

      expect(find.text('گزارش و اشتراک‌گذاری'), findsOneWidget);
      expect(find.byKey(const ValueKey('report-task-match')), findsOneWidget);
      expect(find.byKey(const ValueKey('report-task-wrong-time')), findsNothing);
      expect(find.byKey(const ValueKey('report-task-wrong-category')), findsNothing);
    },
  );

  testWidgets('Report date range opens the Jalali picker rather than Gregorian calendar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [Task(id: 'one', title: 'اول')],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final rangeSection = find.byKey(const ValueKey('report-filter-section-بازه دقیق'));
    await tester.ensureVisible(rangeSection);
    await tester.tap(rangeSection);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('از تاریخ'));
    await tester.tap(find.text('از تاریخ'));
    await tester.pumpAndSettle();

    expect(find.text('انتخاب تاریخ شروع گزارش'), findsOneWidget);
    expect(find.byKey(const ValueKey('persian-date-month-name')), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsNothing);
  });

  testWidgets('report filter sections collapse and expand without losing selections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [Task(id: 'one', title: 'اول', category: 'کار')],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final categorySection = find.byKey(const ValueKey('report-filter-section-دسته'));
    await tester.ensureVisible(categorySection);
    await tester.tap(categorySection);
    await tester.pumpAndSettle();
    final categoryChip = find.byKey(const ValueKey('report-filter-category-کار'));
    await tester.ensureVisible(categoryChip);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: categorySection,
      matching: find.text('دسته'),
    ));
    await tester.pumpAndSettle();
    // ExpansionTile keeps its child subtree alive while collapsed; the selected
    // value must remain intact when the section is reopened.
    expect(tester.widget<FilterChip>(categoryChip).selected, isTrue);
    await tester.tap(find.descendant(
      of: categorySection,
      matching: find.text('دسته'),
    ));
    await tester.pumpAndSettle();
    expect(categoryChip, findsOneWidget);
    expect(tester.widget<FilterChip>(categoryChip).selected, isTrue);
    expect(find.text('1'), findsOneWidget);
  });

}

