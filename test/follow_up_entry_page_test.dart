import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  Future<void> saveEditor(WidgetTester tester) async {
    final save = find.byKey(const ValueKey('follow-up-entry-save'));
    expect(save, findsOneWidget);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  Future<void> revealReminder(WidgetTester tester) async {
    final reminder = find.byKey(const ValueKey('follow-up-reminder-block'));
    await tester.scrollUntilVisible(
      reminder,
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(reminder, findsOneWidget);
  }

  testWidgets('saves entered follow-up title and preserves prefilled date time',
      (tester) async {
    FollowUp? result;
    final initial = DateTime(2026, 8, 14, 9, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialDateTime: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('۱۴۰۵/۰۵/۲۳'), findsOneWidget);
    expect(find.text('۰۹:۳۰'), findsOneWidget);
    expect(find.text('عنوان پیگیری (اختیاری)'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('follow-up-entry-title')),
      'تماس مجدد',
    );
    final noteField = find.byKey(const ValueKey('follow-up-entry-note'));
    await tester.ensureVisible(noteField);
    await tester.enterText(noteField, 'شرح تماس');
    final resultField = find.byKey(const ValueKey('follow-up-entry-result'));
    await tester.ensureVisible(resultField);
    await tester.enterText(resultField, 'پاسخ دریافت شد');
    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.title, 'تماس مجدد');
    expect(result!.note, 'شرح تماس');
    expect(result!.result, 'پاسخ دریافت شد');
    expect(result!.dateTime, initial);
    expect(result!.reminderDate, isNull);
  });

  testWidgets('first Next Follow-up initializes a matching independent reminder once',
      (tester) async {
    FollowUp? result;
    final initial = DateTime(2026, 8, 27, 9, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialDateTime: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final nextButton = find.text('انتخاب پیگیری بعدی');
    await revealReminder(tester);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('persian-date-day-6')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'تأیید'));
    await tester.pumpAndSettle();

    await saveEditor(tester);

    final expected = DateTime(2026, 8, 28, 9, 30);
    expect(result, isNotNull);
    expect(result!.nextFollowUp, expected);
    expect(result!.reminderDate, expected);
  });

  testWidgets('first Next Follow-up preserves an existing reminder', (tester) async {
    FollowUp? result;
    final reminder = DateTime(2026, 9, 2, 7, 45);
    final initial = FollowUp(
      id: 'fu-existing-reminder',
      dateTime: DateTime(2026, 8, 27, 9, 30),
      reminderDate: reminder,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialFollowUp: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await revealReminder(tester);
    await tester.tap(find.text('انتخاب پیگیری بعدی'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('persian-date-day-6')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'تأیید'));
    await tester.pumpAndSettle();
    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.nextFollowUp, DateTime(2026, 8, 28, 9, 30));
    expect(result!.reminderDate, reminder);
  });

  testWidgets('editing reminder date does not change Next Follow-up', (tester) async {
    FollowUp? result;
    final reminder = DateTime(2026, 9, 2, 7, 45);
    final nextFollowUp = DateTime(2026, 9, 5, 10, 15);
    final initial = FollowUp(
      id: 'fu-independent-edit',
      dateTime: DateTime(2026, 8, 27, 9, 30),
      reminderDate: reminder,
      nextFollowUp: nextFollowUp,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialFollowUp: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await revealReminder(tester);
    await tester.tap(find.byKey(const ValueKey('follow-up-reminder-date')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('persian-date-day-12')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'تأیید'));
    await tester.pumpAndSettle();
    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.reminderDate, DateTime(2026, 9, 3, 7, 45));
    expect(result!.nextFollowUp, nextFollowUp);
  });

  testWidgets('blank optional title remains absent in the model', (tester) async {
    FollowUp? result;
    final initial = DateTime(2026, 8, 28, 0, 5);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialDateTime: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('follow-up-entry-title')))
          .controller
          ?.text,
      isEmpty,
    );

    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.title, isNull);
    expect(result!.note, isEmpty);
    expect(result!.dateTime, initial);
  });

  testWidgets('editing preserves the exact independent reminder timestamp',
      (tester) async {
    FollowUp? result;
    final reminder = DateTime(2026, 9, 2, 7, 45);
    final initial = FollowUp(
      id: 'fu-reminder',
      dateTime: DateTime(2026, 8, 28, 10, 15),
      note: 'تماس',
      result: 'انجام شد',
      reminderDate: reminder,
      nextFollowUp: DateTime(2026, 9, 3, 10, 15),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialFollowUp: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await revealReminder(tester);
    expect(find.text('۱۴۰۵/۰۶/۱۱'), findsOneWidget);
    expect(find.text('۰۷:۴۵'), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-up-reminder-clear')), findsOneWidget);

    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.reminderDate, reminder);
    expect(result!.nextFollowUp, initial.nextFollowUp);
  });

  testWidgets('existing reminder can be cleared without changing FollowUp identity',
      (tester) async {
    FollowUp? result;
    final nextFollowUp = DateTime(2026, 9, 1, 14, 15);
    final initial = FollowUp(
      id: 'fu-clear',
      dateTime: DateTime(2026, 8, 28, 12),
      reminderDate: DateTime(2026, 8, 29, 8, 30),
      nextFollowUp: nextFollowUp,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(initialFollowUp: initial),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await revealReminder(tester);
    final clear = find.byKey(const ValueKey('follow-up-reminder-clear'));
    expect(clear, findsOneWidget);
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('follow-up-reminder-clear')), findsNothing);

    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.reminderDate, isNull);
    expect(result!.nextFollowUp, nextFollowUp);
  });
  testWidgets('FollowUp Back prompts and save preserves entered changes',
      (tester) async {
    FollowUp? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<FollowUp>(
                  MaterialPageRoute(
                    builder: (_) => FollowUpEntryPage(
                      initialDateTime: DateTime(2026, 9, 8, 9, 15),
                    ),
                  ),
                );
              },
              child: const Text('open-safe-exit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-safe-exit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('follow-up-entry-title')),
      'پیگیری ذخیره‌شده',
    );

    await tester.tap(find.byKey(const ValueKey('follow-up-entry-back')));
    await tester.pumpAndSettle();

    expect(find.text('تغییرات ذخیره نشده'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('follow-up-exit-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.title, 'پیگیری ذخیره‌شده');
    expect(result!.dateTime, DateTime(2026, 9, 8, 9, 15));
  });

  testWidgets('unchanged FollowUp Back exits without a confirmation dialog',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => FollowUpEntryPage(
                    initialDateTime: DateTime(2026, 9, 8, 9, 15),
                  ),
                ),
              ),
              child: const Text('open-unchanged'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-unchanged'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-back')));
    await tester.pumpAndSettle();

    expect(find.text('تغییرات ذخیره نشده'), findsNothing);
    expect(find.text('open-unchanged'), findsOneWidget);
  });

}
