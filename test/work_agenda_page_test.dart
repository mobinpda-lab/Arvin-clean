import 'package:arvin/models/task.dart';
import 'package:arvin/work_agenda_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows one Task once with all same-day work reasons', (tester) async {
    final day = DateTime(2026, 8, 29);
    final task = Task(
      id: 'task-1',
      title: 'تحویل قرارداد',
      dueDate: DateTime(2026, 8, 29, 10),
      reminderDate: DateTime(2026, 8, 29, 9),
      followUps: [
        FollowUp(
          id: 'fu-1',
          dateTime: DateTime(2026, 8, 28, 12),
          nextFollowUp: DateTime(2026, 8, 29, 11),
          reminderDate: DateTime(2026, 8, 29, 10, 30),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorkAgendaPage(tasks: [task], initialDay: day),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تحویل قرارداد'), findsOneWidget);
    expect(find.textContaining('موعد کار'), findsOneWidget);
    expect(find.textContaining('یادآوری کار'), findsOneWidget);
    expect(find.textContaining('پیگیری'), findsWidgets);
    expect(find.text('۱۴۰۵/۰۶/۰۷'), findsWidgets);
  });

  testWidgets('can switch to inclusive range mode without changing data source',
      (tester) async {
    final day = DateTime(2026, 8, 29);
    final task = Task(
      id: 'task-2',
      title: 'جلسه',
      dueDate: DateTime(2026, 8, 29, 8),
    );

    await tester.pumpWidget(
      MaterialApp(home: WorkAgendaPage(tasks: [task], initialDay: day)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('بازه'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('work-agenda-start')), findsOneWidget);
    expect(find.byKey(const ValueKey('work-agenda-end')), findsOneWidget);
    expect(find.text('جلسه'), findsOneWidget);
  });
}
