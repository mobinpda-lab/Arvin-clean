import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/follow_up.dart';
import '../lib/models/task.dart';
import '../lib/widgets/follow_up_history_card.dart';

void main() {
  testWidgets('shows latest follow-up date and time', (tester) async {
    final task = ArvinTask(id: '1', title: 'کار');
    task.addFollowUp(
      FollowUp(
        id: 'old',
        dateTime: DateTime(2026, 8, 13, 9, 5),
        note: 'قدیمی',
      ),
    );
    task.addFollowUp(
      FollowUp(
        id: 'new',
        dateTime: DateTime(2026, 8, 14, 14, 35),
        note: 'جدید',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FollowUpHistoryCard(task: task)),
      ),
    );

    expect(find.text('آخرین پیگیری'), findsOneWidget);
    expect(find.text('2026/08/14  14:35'), findsOneWidget);
  });

  testWidgets('opens complete follow-up history', (tester) async {
    final task = ArvinTask(id: '1', title: 'کار');
    task.addFollowUp(
      FollowUp(
        id: '1',
        dateTime: DateTime(2026, 8, 14, 10, 20),
        note: 'تماس انجام شد',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FollowUpHistoryCard(task: task)),
      ),
    );

    await tester.tap(find.text('آخرین پیگیری'));
    await tester.pumpAndSettle();

    expect(find.text('تماس انجام شد'), findsOneWidget);
  });
}
