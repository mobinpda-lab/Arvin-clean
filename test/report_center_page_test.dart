import 'package:arvin/models/task.dart';
import 'package:arvin/report_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

      await tester.drag(find.byType(ListView).last, const Offset(0, -700));
      await tester.pumpAndSettle();

      final categoryField = find.byType(DropdownButtonFormField<String?>).at(1);
      await tester.tap(categoryField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('کار').last);
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
}
