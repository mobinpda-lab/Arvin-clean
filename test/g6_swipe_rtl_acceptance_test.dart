import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/task_store.dart';

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

  testWidgets('RTL Move-to-Today keeps the task and does not dismiss it',
      (tester) async {
    const taskTitle = 'انتقال به امروز بدون حذف';

    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.moveToToday,
      swipeLeftAction: TaskSwipeAction.none,
    );

    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"move-today","title":"$taskTitle","dueDate":"2026-09-20T10:00:00.000Z"}]',
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

    expect(result, isFalse);
    expect(find.text(taskTitle), findsOneWidget);
    expect(find.text('«$taskTitle» به امروز منتقل شد'), findsOneWidget);
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

  testWidgets('RTL right swipe opens Follow-up Office without mutating the Task',
      (tester) async {
    const taskId = 'rtl-convert-right';

    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.convertToFollowUp,
      swipeLeftAction: TaskSwipeAction.none,
    );

    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"$taskId","title":"تبدیل به پیگیری از راست"}]',
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
    final pending = dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(find.byType(FollowUpOfficePage), findsOneWidget);
    final beforeExit = await TaskStore().load();
    expect(beforeExit, hasLength(1));
    expect(beforeExit.single.id, taskId);
    expect(beforeExit.single.followUps, isEmpty);
    expect(beforeExit.single.followUpEnabled, isFalse);

    Navigator.of(tester.element(find.byType(FollowUpOfficePage))).pop();
    await tester.pumpAndSettle();
    expect(await pending, isFalse);

    final afterExit = await TaskStore().load();
    expect(afterExit, hasLength(1));
    expect(afterExit.single.id, taskId);
    expect(afterExit.single.followUps, isEmpty);
    expect(afterExit.single.followUpEnabled, isFalse);
  });

  testWidgets('RTL left swipe opens Follow-up Office without mutating the Task',
      (tester) async {
    const taskId = 'rtl-convert-left';

    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.none,
      swipeLeftAction: TaskSwipeAction.convertToFollowUp,
    );

    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"$taskId","title":"تبدیل به پیگیری از چپ"}]',
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
    final pending = dismissible.confirmDismiss!(DismissDirection.startToEnd);
    await tester.pumpAndSettle();

    expect(find.byType(FollowUpOfficePage), findsOneWidget);
    final beforeExit = await TaskStore().load();
    expect(beforeExit, hasLength(1));
    expect(beforeExit.single.id, taskId);
    expect(beforeExit.single.followUps, isEmpty);
    expect(beforeExit.single.followUpEnabled, isFalse);

    Navigator.of(tester.element(find.byType(FollowUpOfficePage))).pop();
    await tester.pumpAndSettle();
    expect(await pending, isFalse);

    final afterExit = await TaskStore().load();
    expect(afterExit, hasLength(1));
    expect(afterExit.single.id, taskId);
    expect(afterExit.single.followUps, isEmpty);
    expect(afterExit.single.followUpEnabled, isFalse);
  });
}
}
