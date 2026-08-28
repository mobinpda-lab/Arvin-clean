import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  Future<FollowUp?> openEditor(
    WidgetTester tester, {
    DateTime? initialDateTime,
    FollowUp? initialFollowUp,
  }) async {
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
                      initialDateTime: initialDateTime,
                      initialFollowUp: initialFollowUp,
                    ),
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
    return result;
  }

  Future<void> saveEditor(WidgetTester tester) async {
    final save = find.byKey(const ValueKey('follow-up-entry-save'));
    await tester.ensureVisible(save);
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
    expect(find.byKey(const ValueKey('follow-up-reminder-block')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('follow-up-entry-title')),
      'تماس مجدد',
    );
    await tester.enterText(find.byType(TextField).last, 'پاسخ دریافت شد');
    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.note, 'تماس مجدد');
    expect(result!.result, 'پاسخ دریافت شد');
    expect(result!.dateTime, initial);
    expect(result!.reminderDate, isNull);
  });

  testWidgets('blank optional title saves as canonical پیگیری', (tester) async {
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
    expect(result!.note, 'پیگیری');
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

    final reminderBlock = find.byKey(const ValueKey('follow-up-reminder-block'));
    await tester.ensureVisible(reminderBlock);
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

    final clear = find.byKey(const ValueKey('follow-up-reminder-clear'));
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('follow-up-reminder-clear')), findsNothing);

    await saveEditor(tester);

    expect(result, isNotNull);
    expect(result!.id, initial.id);
    expect(result!.reminderDate, isNull);
  });
}
