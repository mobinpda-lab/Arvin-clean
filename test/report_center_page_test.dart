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
  testWidgets('Person waiting report renders per-Follow-up rows and separates next action from Reminder', (tester) async {
    final task = Task(
      id: 'person-report-task',
      title: 'هماهنگی قرارداد',
      followUps: [
        FollowUp(
          id: 'follow-up-ali',
          dateTime: DateTime(2026, 10, 6, 9),
          note: 'پیگیری علی',
          result: 'منتظر پاسخ',
          waitingForResponse: true,
          personIds: const ['ali'],
          nextFollowUp: DateTime(2026, 10, 9, 10),
          reminderDate: DateTime(2026, 10, 8, 8),
        ),
        FollowUp(
          id: 'follow-up-sara',
          dateTime: DateTime(2026, 10, 6, 11),
          note: 'پیگیری سارا',
          waitingForResponse: true,
          personIds: const ['sara'],
          nextFollowUp: DateTime(2026, 10, 10, 11),
        ),
      ],
    );
    final completedTask = Task(
      id: 'completed-person-report-task',
      title: 'کار تکمیل‌شده',
      completed: true,
      followUps: [
        FollowUp(
          id: 'completed-waiting',
          dateTime: DateTime(2026, 10, 6, 12),
          note: 'نباید در انتظار فعال باشد',
          waitingForResponse: true,
          personIds: const ['ali'],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [task, completedTask],
          people: [
            PersonReference(id: 'ali', displayName: 'علی رضایی'),
            PersonReference(id: 'sara', displayName: 'سارا احمدی'),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('report-filter-person-ali')));
    await tester.tap(find.byKey(const ValueKey('report-filter-person-ali')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('report-filter-waiting-response-only')));
    await tester.tap(find.byKey(const ValueKey('report-filter-waiting-response-only')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 1 پیگیری'), findsOneWidget);
    expect(find.textContaining('پیگیری علی'), findsOneWidget);
    expect(find.textContaining('علی رضایی'), findsOneWidget);
    expect(find.textContaining('اقدام بعدی:'), findsOneWidget);
    expect(find.textContaining('یادآور:'), findsOneWidget);
    expect(find.textContaining('پیگیری سارا'), findsNothing);
    expect(find.textContaining('نباید در انتظار فعال باشد'), findsNothing);
  });

  testWidgets('waiting report keeps orphaned Person associations visible without a directory entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [
            Task(
              id: 'orphaned-person-task',
              title: 'پیگیری با شخص حذف‌شده',
              followUps: [
                FollowUp(
                  id: 'orphaned-person-follow-up',
                  dateTime: DateTime(2026, 10, 6, 9),
                  note: 'پیگیری باز',
                  waitingForResponse: true,
                  personIds: const ['person-removed'],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('report-filter-waiting-response-only')));
    await tester.tap(find.byKey(const ValueKey('report-filter-waiting-response-only')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.textContaining('پیگیری باز'), findsOneWidget);
    expect(find.textContaining('شخص حذف‌شده'), findsOneWidget);
  });

}

