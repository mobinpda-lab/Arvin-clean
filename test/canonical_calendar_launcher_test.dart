import 'package:arvin/models/task.dart';
import 'package:arvin/widgets/canonical_calendar_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launcher accepts canonical follow-ups without parallel storage',
      (tester) async {
    final task = Task(
      id: 'task-1',
      title: 'تماس با مشتری',
      followUps: <FollowUp>[
        FollowUp(
          id: 'follow-1',
          dateTime: DateTime(2026, 8, 26, 9),
          note: 'پیگیری قرارداد',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CanonicalCalendarLauncher(tasks: <Task>[task]),
      ),
    );

    expect(find.byType(CanonicalCalendarLauncher), findsOneWidget);
  });
}
