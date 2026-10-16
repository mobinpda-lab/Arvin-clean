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
    expect(tester.getSize(find.byKey(const ValueKey('report-filter-header'))).height, 64);

    final applyBeforeScroll = tester.getRect(find.byKey(const ValueKey('report-filter-apply')));
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('report-filter-apply')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-clear')), findsOneWidget);
    expect(tester.getRect(find.byKey(const ValueKey('report-filter-apply'))), applyBeforeScroll);
    expect(find.text('بازنشانی'), findsOneWidget);
    expect(find.text('اعمال فیلتر'), findsOneWidget);
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

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report-filter-section-دسته')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('report-filter-section-دسته')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report-filter-category-کار')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('report-filter-category-کار')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report-filter-apply')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
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
  testWidgets('People and waiting-for-response controls stay inside filter sheet', (tester) async {
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
            Task(
              id: 'task-not-waiting',
              title: 'کار عادی',
              followUps: [
                FollowUp(
                  id: 'not-waiting',
                  dateTime: DateTime(2026, 10, 15, 9),
                  waitingForResponse: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('پیگیری‌های منتظر پاسخ'), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('آنا'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('report-filter-header')), findsOneWidget);

    final peopleSection = find.byKey(const ValueKey('report-filter-section-اشخاص'));
    await tester.ensureVisible(peopleSection);
    await tester.pumpAndSettle();
    await tester.tap(peopleSection);
    await tester.pumpAndSettle();

    final anaOption = find.byKey(const ValueKey('report-filter-person-آنا'));
    await tester.ensureVisible(anaOption);
    await tester.pumpAndSettle();
    expect(anaOption, findsOneWidget);
    await tester.tap(anaOption);
    await tester.pumpAndSettle();

    final featureSection = find.byKey(const ValueKey('report-filter-section-ویژگی‌های کار'));
    await tester.ensureVisible(featureSection);
    await tester.pumpAndSettle();
    await tester.tap(featureSection);
    await tester.pumpAndSettle();

    final waitingOption = find.widgetWithText(ChoiceChip, 'منتظر پاسخ');
    await tester.ensureVisible(waitingOption);
    await tester.pumpAndSettle();
    expect(waitingOption, findsOneWidget);
    await tester.tap(waitingOption);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 1 کار'), findsOneWidget);
    expect(find.text('پرونده مشتری'), findsOneWidget);
    expect(find.text('کار عادی'), findsNothing);
    expect(find.text('شخص: آنا'), findsOneWidget);
    expect(find.text('منتظر پاسخ'), findsWidgets);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('Report Center keeps deleted people selectable by stable label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [
            Task(
              id: 'historical',
              title: 'کار تاریخی',
              followUps: [
                FollowUp(
                  id: 'follow-up-deleted-person',
                  dateTime: DateTime(2026, 10, 7, 9),
                  personIds: ['person-deleted-stable-id'],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-section-اشخاص')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('report-filter-section-اشخاص')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-person-شخص حذف‌شده')),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('شخص حذف‌شده'), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-person-شخص حذف‌شده')), findsOneWidget);
  });

}

