import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_entry_page.dart';
import 'package:arvin/models/task.dart';

void main() {
  testWidgets('saves a Persian follow-up entry and returns the FollowUp', (tester) async {
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
                      initialDateTime: DateTime(2026, 8, 14, 9, 30),
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

    await tester.enterText(find.byType(TextField).first, 'تماس مجدد');
    await tester.enterText(find.byType(TextField).last, 'پاسخ دریافت شد');
    await tester.tap(find.text('ذخیره پیگیری'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.note, 'تماس مجدد');
    expect(result!.result, 'پاسخ دریافت شد');
    expect(result!.dateTime, DateTime(2026, 8, 14, 9, 30));
  });
}
