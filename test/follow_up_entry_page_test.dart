import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  Future<FollowUp?> openEntry(
    WidgetTester tester, {
    required DateTime initialDateTime,
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
    await tester.enterText(find.byType(TextField).last, 'پاسخ دریافت شد');
    final save = find.byKey(const ValueKey('follow-up-entry-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.note, 'تماس مجدد');
    expect(result!.result, 'پاسخ دریافت شد');
    expect(result!.dateTime, initial);
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

    final save = find.byKey(const ValueKey('follow-up-entry-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.note, 'پیگیری');
    expect(result!.dateTime, initial);
  });
}
