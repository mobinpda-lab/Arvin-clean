import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/models/follow_up.dart';

void main() {
  Future<void> tapVisible(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
  }

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
    await tapVisible(tester, 'ذخیره پیگیری');
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

  testWidgets('marks a new follow-up as waiting and persists canonical token',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'مشتری منتظر',
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
    await tester.enterText(find.byType(TextField).first, 'پیام ارسال شد');
    await tester.tap(find.text('منتظر پاسخ دیگران'));
    await tester.pump();

    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.value, isTrue);
    expect(tester.widget<TextField>(find.byType(TextField).last).enabled, isFalse);

    await tapVisible(tester, 'ذخیره پیگیری');
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final tasks = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final task = Map<String, dynamic>.from(tasks.single as Map);
    final followUps = task['followUps'] as List<dynamic>;
    final saved = Map<String, dynamic>.from(followUps.single as Map);

    expect(saved['result'], 'waiting_for_response');
    expect(find.text('منتظر پاسخ'), findsOneWidget);
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
    await tapVisible(tester, 'ذخیره پیگیری');
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

  testWidgets('waiting filter uses only each task latest follow-up result',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'waiting',
          'title': 'کار منتظر',
          'followUps': [
            {
              'id': 'w1',
              'dateTime': '2026-08-25T10:00:00.000',
              'note': 'ارسال شد',
              'result': 'waiting_for_response',
              'nextFollowUp': null,
            },
          ],
        },
        {
          'id': 'resolved',
          'title': 'کار پاسخ‌گرفته',
          'followUps': [
            {
              'id': 'r1',
              'dateTime': '2026-08-24T10:00:00.000',
              'note': 'قدیمی',
              'result': 'منتظر پاسخ',
              'nextFollowUp': null,
            },
            {
              'id': 'r2',
              'dateTime': '2026-08-26T10:00:00.000',
              'note': 'پاسخ آمد',
              'result': 'resolved',
              'nextFollowUp': null,
            },
          ],
        },
        {
          'id': 'alias',
          'title': 'کار منتظر فارسی',
          'followUps': [
            {
              'id': 'a1',
              'dateTime': '2026-08-26T09:00:00.000',
              'note': 'پیام',
              'result': 'در انتظار پاسخ',
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(home: FollowUpOfficePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('کار منتظر'), findsOneWidget);
    expect(find.text('کار پاسخ‌گرفته'), findsNWidgets(2));
    expect(find.text('کار منتظر فارسی'), findsOneWidget);

    await tester.tap(find.byTooltip('فقط منتظر پاسخ'));
    await tester.pumpAndSettle();

    expect(find.text('کار منتظر'), findsOneWidget);
    expect(find.text('کار منتظر فارسی'), findsOneWidget);
    expect(find.text('کار پاسخ‌گرفته'), findsNothing);
    expect(find.text('منتظر پاسخ'), findsNWidgets(2));
  });

  testWidgets('edits an existing follow-up without creating a duplicate',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'قرارداد مشتری',
          'followUps': [
            {
              'id': 'f1',
              'dateTime': '2026-08-25T10:00:00.000',
              'note': 'تماس اولیه',
              'result': 'منتظر پاسخ',
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(home: FollowUpOfficePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('تماس اولیه'), findsOneWidget);
    await tester.tap(find.byTooltip('ویرایش پیگیری'));
    await tester.pumpAndSettle();

    expect(find.byType(FollowUpEntryPage), findsOneWidget);
    expect(find.text('ویرایش پیگیری'), findsOneWidget);
    expect(find.text('ذخیره تغییرات'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.text('منتظر پاسخ دیگران'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'تماس ویرایش‌شده');
    await tester.enterText(find.byType(TextField).last, 'پاسخ نهایی');
    await tapVisible(tester, 'ذخیره تغییرات');
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final tasks = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    final task = Map<String, dynamic>.from(tasks.single as Map);
    final followUps = task['followUps'] as List<dynamic>;
    final saved = Map<String, dynamic>.from(followUps.single as Map);

    expect(followUps, hasLength(1));
    expect(saved['id'], 'f1');
    expect(saved['note'], 'تماس ویرایش‌شده');
    expect(saved['result'], 'پاسخ نهایی');
    expect(find.text('تماس ویرایش‌شده'), findsOneWidget);
    expect(find.text('پیگیری «قرارداد مشتری» ویرایش شد'), findsOneWidget);
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
    await tapVisible(tester, 'ذخیره پیگیری');
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
