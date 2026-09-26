import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/services/app_settings_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RTL physical right swipe uses the configured right action',
      (tester) async {
    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.archive,
      swipeLeftAction: TaskSwipeAction.trash,
    );

    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"rtl-right","title":"حرکت به راست"}]',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final result =
        await dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('حرکت به راست'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'بایگانی'));
    await tester.pumpAndSettle();

    expect(find.text('حرکت به راست'), findsOneWidget);
  });

  testWidgets('RTL physical left swipe uses the configured left action',
      (tester) async {
    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.archive,
      swipeLeftAction: TaskSwipeAction.trash,
    );

    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"rtl-left","title":"حرکت به چپ"}]',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final result =
        await dismissible.confirmDismiss!(DismissDirection.startToEnd);
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('حرکت به چپ'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'سطل زباله'));
    await tester.pumpAndSettle();

    expect(find.text('حرکت به چپ'), findsOneWidget);
  });
}
