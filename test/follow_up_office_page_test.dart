import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/follow_up.dart';

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

  testWidgets('selects one of multiple tasks and persists only to that task',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'کار اول',
          'followUps': <Object>[],
        },
        {
          'id': 't2',
          'title': 'کار دوم',
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

    expect(find.text('انتخاب کار'), findsOneWidget);
    expect(find.text('کار اول'), findsOneWidget);
    expect(find.text('کار دوم'), findsOneWidget);

    await tester.tap(find.text('کار دوم'));
    await tester.pumpAndSettle();
    expect(find.byType(FollowUpEntryPage), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'پیگیری کار دوم');
    await tester.tap(find.text('ذخیره پیگیری'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final tasks = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final first = Map<String, dynamic>.from(tasks[0] as Map);
    final second = Map<String, dynamic>.from(tasks[1] as Map);
    final firstFollowUps = first['followUps'] as List<dynamic>;
    final secondFollowUps = second['followUps'] as List<dynamic>;
    final saved =
        Map<String, dynamic>.from(secondFollowUps.single as Map);

    expect(firstFollowUps, isEmpty);
    expect(saved['note'], 'پیگیری کار دوم');
    expect(find.text('پیگیری برای «کار دوم» ثبت شد'), findsOneWidget);
  });

  testWidgets('shows a retry message and keeps data unchanged on write error',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'کار خطاپذیر',
          'followUps': <Object>[],
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: FollowUpOfficePage(
          repository: _ThrowingFollowUpRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت پیگیری'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'نباید ذخیره شود');
    await tester.tap(find.text('ذخیره پیگیری'));
    await tester.pumpAndSettle();

    expect(
      find.text('ثبت پیگیری انجام نشد؛ دوباره تلاش کنید'),
      findsOneWidget,
    );

    final prefs = await SharedPreferences.getInstance();
    final tasks = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final task = Map<String, dynamic>.from(tasks.single as Map);

    expect(task['followUps'], isEmpty);
    final button = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(button.onPressed, isNotNull);
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

class _ThrowingFollowUpRepository extends FollowUpRepository {
  const _ThrowingFollowUpRepository();

  @override
  Future<void> add(String taskId, FollowUp followUp) async {
    throw StateError('simulated write failure');
  }
}
