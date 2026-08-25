import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/follow_up_office_page.dart';

void main() {
  testWidgets('shows dedicated follow-up office shell', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const MaterialApp(home: FollowUpOfficePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('دفتر پیگیری'), findsOneWidget);
    expect(find.text('ثبت پیگیری'), findsOneWidget);
  });

  testWidgets('adds and persists a follow-up for the only task',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'قرارداد مشتری',
          'followUps': <Object>[],
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(home: FollowUpOfficePage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت پیگیری'));
    await tester.pumpAndSettle();
    expect(find.byType(FollowUpEntryPage), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'تماس با مشتری');
    await tester.enterText(find.byType(TextField).last, 'پاسخ دریافت شد');
    await tester.tap(find.text('ذخیره پیگیری'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final tasks = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final task = Map<String, dynamic>.from(tasks.single as Map);
    final followUps = task['followUps'] as List<dynamic>;
    final saved = Map<String, dynamic>.from(followUps.single as Map);

    expect(saved['note'], 'تماس با مشتری');
    expect(saved['result'], 'پاسخ دریافت شد');
    expect(DateTime.tryParse(saved['dateTime'] as String), isNotNull);
    expect(find.text('تماس با مشتری'), findsOneWidget);
  });

  testWidgets('asks the user to create a task when the list is empty',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const MaterialApp(home: FollowUpOfficePage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت پیگیری'));
    await tester.pump();

    expect(find.text('ابتدا یک کار ثبت کنید'), findsOneWidget);
    expect(find.byType(FollowUpEntryPage), findsNothing);
  });
}
