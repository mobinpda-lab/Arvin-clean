import 'package:arvin/models/task.dart';
import 'package:arvin/models/person_reference.dart';
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
  testWidgets('Report Center shows separate person-specific active waiting rows', (tester) async {
    final ana = PersonReference(id: 'ana', displayName: 'آنا');
    final reza = PersonReference(id: 'reza', displayName: 'رضا');
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 15, 10),
          people: [ana, reza],
          tasks: [
            Task(
              id: 'task-waiting',
              title: 'پرونده مشتری',
              followUps: [
                FollowUp(
                  id: 'waiting-ana',
                  dateTime: DateTime(2026, 10, 15, 9),
                  note: 'پاسخ آنا',
                  personIds: ['ana'],
                  waitingForResponse: true,
                  nextFollowUp: DateTime(2026, 10, 16, 9),
                  reminderDate: DateTime(2026, 10, 15, 18),
                ),
                FollowUp(
                  id: 'waiting-reza',
                  dateTime: DateTime(2026, 10, 15, 9),
                  note: 'پاسخ رضا',
                  personIds: ['reza'],
                  waitingForResponse: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('پیگیری‌های منتظر پاسخ'));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 2 پیگیری'), findsOneWidget);
    expect(find.textContaining('پاسخ آنا'), findsOneWidget);
    expect(find.textContaining('پاسخ رضا'), findsOneWidget);
    expect(find.textContaining('اقدام بعدی:'), findsOneWidget);
    expect(find.textContaining('یادآور:'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('آنا').last);
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 1 پیگیری'), findsOneWidget);
    expect(find.textContaining('پاسخ آنا'), findsOneWidget);
    expect(find.textContaining('پاسخ رضا'), findsNothing);
  });

}

