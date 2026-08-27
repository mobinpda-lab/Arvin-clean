import 'package:arvin/main.dart' as app;
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

    final skipGuide = find.text('رد کردن');
    if (skipGuide.evaluate().isNotEmpty) {
      await tester.tap(skipGuide);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    final titleField = find.byKey(const ValueKey('task-editor-title'));
    final descriptionField =
        find.byKey(const ValueKey('task-editor-description'));
    final tagField = find.byKey(const ValueKey('task-editor-tag'));

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(titleField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(tagField, findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-block')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-time')), findsOneWidget);

    await tester.enterText(titleField, 'تست واقعی اندروید');
    await tester.enterText(
      descriptionField,
      'ثبت از مسیر Home روی Emulator',
    );
    await tester.enterText(tagField, 'آزمایش');
    await tester.tap(find.byKey(const ValueKey('task-editor-add-tag')));
    await tester.pumpAndSettle();
    expect(find.text('آزمایش'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(find.text('تست واقعی اندروید'), findsOneWidget);
    expect(find.text('ثبت از مسیر Home روی Emulator'), findsOneWidget);
  });
}
