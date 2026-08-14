import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  testWidgets('shows follow-up history and next follow-up', (tester) async {
    final day = DateTime(2026, 8, 14, 9, 30);
    final next = DateTime(2026, 8, 20, 11, 0);
    final task = Task(
      id: '1',
      title: 'مشتری آروین',
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: day,
          note: 'تماس انجام شد',
          result: 'منتظر پاسخ',
          nextFollowUp: next,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: FollowUpOfficePage(tasks: [task]),
        ),
      ),
    );

    expect(find.text('دفتر پیگیری'), findsOneWidget);
    expect(find.text('مشتری آروین'), findsOneWidget);
    expect(find.text('تماس انجام شد'), findsOneWidget);
    expect(find.text('نتیجه: منتظر پاسخ'), findsOneWidget);
    expect(find.textContaining('پیگیری بعدی:'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no follow-ups', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: FollowUpOfficePage(tasks: <Task>[]),
        ),
      ),
    );

    expect(find.text('هنوز پیگیری‌ای ثبت نشده است'), findsOneWidget);
  });
}
