import 'package:arvin/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android launches Persian Home and creates a canonical Task',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    expect(find.text('عنوان'), findsOneWidget);
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));

    await tester.enterText(fields.at(0), 'تست واقعی اندروید');
    await tester.enterText(fields.at(1), 'ثبت از مسیر Home روی Emulator');
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    expect(find.text('تست واقعی اندروید'), findsOneWidget);
    expect(find.text('ثبت از مسیر Home روی Emulator'), findsOneWidget);
  });
}
