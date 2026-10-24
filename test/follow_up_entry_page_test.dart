import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  Future<void> openEditor(
    WidgetTester tester, {
    required Future<void> Function(BuildContext context) open,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => open(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> saveEditor(WidgetTester tester) async {
    final save = find.byKey(const ValueKey('follow-up-entry-save'));
    expect(save, findsOneWidget);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  testWidgets('new Follow-up records capture history but do not create schedule fields', (tester) async {
    FollowUp? result;
    final initial = DateTime(2026, 8, 14, 9, 30);
    await openEditor(tester, open: (context) async {
      result = await Navigator.of(context).push<FollowUp>(
        MaterialPageRoute(builder: (_) => FollowUpEntryPage(initialDateTime: initial)),
      );
    });
    expect(find.byKey(const ValueKey('follow-up-reminder-block')), findsNothing);
    expect(find.text('انتخاب پیگیری بعدی'), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('follow-up-entry-title')), 'تماس مجدد');
    await tester.enterText(find.byKey(const ValueKey('follow-up-entry-note')), 'شرح تماس');
    await tester.enterText(find.byKey(const ValueKey('follow-up-entry-result')), 'پاسخ دریافت شد');
    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.title, 'تماس مجدد');
    expect(result!.note, 'شرح تماس');
    expect(result!.result, 'پاسخ دریافت شد');
    expect(result!.dateTime, initial);
    expect(result!.reminderDate, isNull);
    expect(result!.nextFollowUp, isNull);
  });

  testWidgets('editing a history record preserves retired schedule data without exposing controls', (tester) async {
    FollowUp? result;
    final reminder = DateTime(2026, 9, 2, 7, 45);
    final next = DateTime(2026, 9, 3, 10, 15);
    final initial = FollowUp(
      id: 'fu-history',
      dateTime: DateTime(2026, 8, 28, 10, 15),
      note: 'تماس',
      result: 'انجام شد',
      reminderDate: reminder,
      nextFollowUp: next,
    );
    await openEditor(tester, open: (context) async {
      result = await Navigator.of(context).push<FollowUp>(
        MaterialPageRoute(builder: (_) => FollowUpEntryPage(initialFollowUp: initial)),
      );
    });
    expect(find.byKey(const ValueKey('follow-up-reminder-block')), findsNothing);
    expect(find.text('انتخاب پیگیری بعدی'), findsNothing);
    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.reminderDate, reminder);
    expect(result!.nextFollowUp, next);
    expect(result!.note, initial.note);
    expect(result!.result, initial.result);
  });
}
