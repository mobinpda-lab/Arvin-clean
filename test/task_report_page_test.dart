import 'package:arvin/models/task.dart';
import 'package:arvin/task_report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('report UI exposes single, selected and all scopes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TaskReportPage(
          tasks: [
            Task(id: 'one', title: 'اول'),
            Task(id: 'two', title: 'دوم'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('report-single-one')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-single-two')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-all')), findsOneWidget);

    var selected = tester.widget<FilledButton>(
      find.byKey(const ValueKey('report-selected')),
    );
    expect(selected.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('report-task-one')));
    await tester.pump();

    selected = tester.widget<FilledButton>(
      find.byKey(const ValueKey('report-selected')),
    );
    expect(selected.onPressed, isNotNull);
    expect(find.text('انتخاب‌شده (1)'), findsOneWidget);
  });
}
