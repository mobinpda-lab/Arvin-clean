import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
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

  testWidgets('RTL right swipe opens Follow-up entry without creating history',
      (tester) async {
    const taskId = 'rtl-convert-right';
    const taskTitle = 'تبدیل به پیگیری از راست';
    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.convertToFollowUp,
      swipeLeftAction: TaskSwipeAction.none,
    );
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"$taskId","title":"$taskTitle"}]',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle(timeout: const Duration(seconds: 5));
    await tester.drag(
      find.byType(Dismissible).first,
      const Offset(500, 0),
      duration: const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle(timeout: const Duration(seconds: 5));
    expect(find.text('ثبت پیگیری'), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-up-entry-back')), findsOneWidget);
    var stored = await TaskStore().load();
    expect(stored, hasLength(1));
    expect(stored.single.id, taskId);
    expect(stored.single.followUpEnabled, isFalse);
    expect(stored.single.followUps, isEmpty);
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-back')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 5));
    expect(find.text(taskTitle), findsOneWidget);
    stored = await TaskStore().load();
    expect(stored, hasLength(1));
    expect(stored.single.id, taskId);
    expect(stored.single.followUpEnabled, isFalse);
    expect(stored.single.followUps, isEmpty);
  });

  testWidgets('RTL left swipe opens Follow-up entry without creating history',
      (tester) async {
    const taskId = 'rtl-convert-left';
    const taskTitle = 'تبدیل به پیگیری از چپ';
    final settings = const AppSettings(
      themeMode: ThemeMode.light,
      usePersianDate: true,
      fontFamily: null,
      swipeRightAction: TaskSwipeAction.none,
      swipeLeftAction: TaskSwipeAction.convertToFollowUp,
    );
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"$taskId","title":"$taskTitle"}]',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(settings: settings),
        ),
      ),
    );
    await tester.pumpAndSettle(timeout: const Duration(seconds: 5));
    await tester.drag(
      find.byType(Dismissible).first,
      const Offset(-500, 0),
      duration: const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle(timeout: const Duration(seconds: 5));
    expect(find.text('ثبت پیگیری'), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-up-entry-back')), findsOneWidget);
    var stored = await TaskStore().load();
    expect(stored, hasLength(1));
    expect(stored.single.id, taskId);
    expect(stored.single.followUpEnabled, isFalse);
    expect(stored.single.followUps, isEmpty);
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-back')));
    await tester.pumpAndSettle(timeout: const Duration(seconds: 5));
    expect(find.text(taskTitle), findsOneWidget);
    stored = await TaskStore().load();
    expect(stored, hasLength(1));
    expect(stored.single.id, taskId);
    expect(stored.single.followUpEnabled, isFalse);
    expect(stored.single.followUps, isEmpty);
  });
}
