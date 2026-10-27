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

  testWidgets('editing preserves legacy scheduling timestamps without exposing controls',
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

    expect(find.text('انتخاب پیگیری بعدی'), findsNothing);
    expect(find.byKey(const ValueKey('follow-up-reminder-block')), findsNothing);

    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.reminderDate, reminder);
    expect(result!.nextFollowUp, initial.nextFollowUp);
  });

  testWidgets('legacy FollowUp reminder is hidden but preserved without retired controls',
      (tester) async {
    FollowUp? result;
    final initial = FollowUp(
      id: 'fu-clear',
      dateTime: DateTime(2026, 8, 28, 12),
      reminderDate: DateTime(2026, 8, 29, 8, 30),
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

    expect(find.byKey(const ValueKey('follow-up-reminder-clear')), findsNothing);
    expect(find.text('انتخاب پیگیری بعدی'), findsNothing);

    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.reminderDate, initial.reminderDate);
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


  testWidgets(
    'FollowUp time picker remains RTL and cancel preserves dateTime',
    (tester) async {
      FollowUp? result;
      final initial = DateTime(2026, 9, 8, 9, 15);

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
                child: const Text('open-time-picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-time-picker'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('follow-up-entry-time')));
      await tester.pumpAndSettle();

      final selectedTime = find.byKey(
        const ValueKey('universal-time-selected-value'),
      );
      expect(selectedTime, findsOneWidget);
      expect(
        find.byKey(const ValueKey('universal-time-cancel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('universal-time-save')),
        findsOneWidget,
      );
      expect(
        Directionality.of(tester.element(selectedTime)),
        TextDirection.rtl,
      );

      await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
      await tester.pumpAndSettle();
      await saveEditor(tester);

      expect(result, isNotNull);
      expect(result!.dateTime, initial);
    },
  );

}
