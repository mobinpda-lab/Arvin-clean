import 'package:arvin/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android launches Persian Home and creates a canonical Task',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('arvin-home');

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'عنوان',
      description: 'Task dialog title field',
    );
    final descriptionField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'توضیحات',
      description: 'Task dialog description field',
    );
    final tagField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'تگ',
      description: 'Task dialog tag field',
    );

    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(tagField, findsOneWidget);

    await tester.enterText(titleField, 'تست واقعی اندروید');
    await tester.enterText(
      descriptionField,
      'ثبت از مسیر Home روی Emulator',
    );
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    expect(find.text('تست واقعی اندروید'), findsOneWidget);
    expect(find.text('ثبت از مسیر Home روی Emulator'), findsOneWidget);
  });
}
