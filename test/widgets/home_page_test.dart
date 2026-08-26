import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the current HomePage shell', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'فعال'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'بایگانی'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'سطل زباله'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);
  });

  testWidgets('loads an existing legacy task from arvin.tasks', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"legacy-ui-1","title":"کار آزمایشی","description":"توضیح"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار آزمایشی'), findsOneWidget);
    expect(find.text('توضیح'), findsOneWidget);
  });

  testWidgets('search filters the currently loaded legacy tasks', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"one","title":"تماس فروش"},{"id":"two","title":"جلسه فنی"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تماس فروش'), findsOneWidget);
    expect(find.text('جلسه فنی'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'فروش');
    await tester.pump();

    expect(find.text('تماس فروش'), findsOneWidget);
    expect(find.text('جلسه فنی'), findsNothing);
  });

  testWidgets('Home search uses canonical Persian and FollowUp text',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"persian","title":"يادداشت كاری"},{"id":"followup","title":"کار دوم","followUps":[{"id":"f1","dateTime":"2026-08-25T10:00:00.000","note":"تماس با مشتری","result":"موفق"}]},{"id":"other","title":"خرید"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'یادداشت کاری');
    await tester.pump();
    expect(find.text('يادداشت كاری'), findsOneWidget);
    expect(find.text('کار دوم'), findsNothing);

    await tester.enterText(find.byType(TextField), 'مشتری');
    await tester.pump();
    expect(find.text('کار دوم'), findsOneWidget);
    expect(find.text('يادداشت كاری'), findsNothing);
    expect(find.text('خرید'), findsNothing);
  });

  testWidgets('first delete still moves an active task to trash', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"active","title":"کار فعال"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final result = await dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('حذف دائمی'), findsNothing);
    expect(find.text('کار فعال'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'سطل زباله'));
    await tester.pumpAndSettle();
    expect(find.text('کار فعال'), findsOneWidget);
  });

  testWidgets('permanent delete from trash requires explicit confirmation',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"trashed","title":"حذف آزمایشی","trashed":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'سطل زباله'));
    await tester.pumpAndSettle();

    expect(find.text('حذف آزمایشی'), findsOneWidget);

    var dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final cancelled = dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(find.text('حذف دائمی'), findsOneWidget);
    expect(find.textContaining('قابل بازگشت نیست'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'لغو'));
    await tester.pumpAndSettle();

    expect(await cancelled, isFalse);
    expect(find.text('حذف آزمایشی'), findsOneWidget);

    dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final confirmed = dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'حذف برای همیشه'));
    await tester.pumpAndSettle();

    expect(await confirmed, isTrue);
    expect(find.text('حذف آزمایشی'), findsNothing);
    expect(find.text('سطل زباله خالی است'), findsOneWidget);
  });
}
