import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FollowUp Office renders canonical Jalali date and Persian time',
      (tester) async {
    final task = Task(
      id: 'task-1',
      title: 'تماس با علی',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'followup-1',
          dateTime: DateTime(2026, 8, 28, 10, 45),
          note: 'هماهنگی انجام شد',
        ),
      ],
    );
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([task.toJson()]),
    });

    await tester.pumpWidget(
      const MaterialApp(home: FollowUpOfficePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('۱۴۰۵/۰۶/۰۶ • ساعت ۱۰:۴۵'), findsOneWidget);
    expect(find.textContaining('۲۰۲۶/۰۸/۲۸'), findsNothing);
  });
}
