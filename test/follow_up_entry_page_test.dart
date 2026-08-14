import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/follow_up_entry_page.dart';

void main() {
  testWidgets('saves a Persian follow-up entry and returns the FollowUp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FollowUpEntryPage(
          initialDateTime: DateTime(2026, 8, 14, 9, 30),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'تماس مجدد');
    await tester.enterText(find.byType(TextField).last, 'پاسخ دریافت شد');
    await tester.tap(find.text('ذخیره پیگیری'));
    await tester.pump();

    expect(find.text('ثبت پیگیری'), findsOneWidget);
  });
}
