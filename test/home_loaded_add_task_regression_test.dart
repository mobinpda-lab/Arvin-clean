import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loaded canonical tasks remain mutable when Home adds a task',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"existing","title":"کار قبلی"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار قبلی'), findsOneWidget);

    await tester.tap(find.text('کار جدید'));
    await tester.pumpAndSettle();

    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'عنوان',
    );
    final descriptionField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'توضیحات',
    );

    await tester.enterText(titleField, 'کار تازه');
    await tester.enterText(descriptionField, 'بعد از Load اضافه شد');
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    expect(find.text('کار قبلی'), findsOneWidget);
    expect(find.text('کار تازه'), findsOneWidget);
    expect(find.text('بعد از Load اضافه شد'), findsOneWidget);
  });
}
