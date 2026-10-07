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
    expect(find.byKey(const ValueKey('report-filter-apply')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-clear')), findsOneWidget);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('بازه دقیق'), findsOneWidget);
  });
}
