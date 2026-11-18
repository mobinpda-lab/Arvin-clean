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

  testWidgets('bulk entry preselects supplied canonical ids', (tester) async {
    final initial = <String>{'one', 'two'};
    await tester.pumpWidget(
      MaterialApp(
        home: TaskReportPage(
          tasks: [
            Task(id: 'one', title: 'اول'),
            Task(id: 'two', title: 'دوم'),
            Task(id: 'three', title: 'سوم'),
          ],
          initialSelectedIds: initial,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('report-task-one')),
      ).value,
      isTrue,
    );
    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('report-task-two')),
      ).value,
      isTrue,
    );
    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('report-task-three')),
      ).value,
      isFalse,
    );
    expect(find.text('انتخاب‌شده (2)'), findsOneWidget);
    expect(initial, {'one', 'two'});
  });

  testWidgets('preselection ignores trashed and unknown ids', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TaskReportPage(
          tasks: [
            Task(id: 'active', title: 'فعال'),
            Task(id: 'trash', title: 'حذف‌شده', trashed: true),
          ],
          initialSelectedIds: const {'active', 'trash', 'missing'},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('report-task-trash')), findsNothing);
    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('report-task-active')),
      ).value,
      isTrue,
    );
    expect(find.text('انتخاب‌شده (1)'), findsOneWidget);
  });
}
