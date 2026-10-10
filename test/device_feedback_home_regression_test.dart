import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home keeps backup in the More menu instead of the header',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.byTooltip('پشتیبان'), findsNothing);
    expect(find.byIcon(Icons.backup_outlined), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);
    expect(find.text('پشتیبان‌گیری'), findsOneWidget);
  });

  testWidgets('Home uses the canonical header identity block', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const ValueKey('home-bismillah')), findsOneWidget);
    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-title-block')), findsOneWidget);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
  });

  testWidgets('compact Home keeps Task card and add action clear of navigation',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"compact-task","title":"کار جمع‌وجور"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final task = find.byKey(const ValueKey('compact-task'));
    final add = find.byKey(const ValueKey('home-canonical-add'));
    final moreNavigation = find.byKey(const ValueKey('primary-nav-more'));
    expect(task, findsOneWidget);
    expect(add, findsOneWidget);
    expect(moreNavigation, findsOneWidget);

    final taskRect = tester.getRect(task);
    final listViewportRect = tester.getRect(
      find.byKey(const ValueKey('home-task-list-viewport')),
    );
    final addRect = tester.getRect(add);
    final navigationRect = tester.getRect(moreNavigation);
    expect(taskRect.bottom, lessThanOrEqualTo(listViewportRect.bottom));
    expect(listViewportRect.bottom, lessThanOrEqualTo(addRect.top));
    expect(addRect.bottom, lessThanOrEqualTo(navigationRect.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('normal-height Home keeps empty groups and floating add action',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(find.text('تاریخ‌گذشته'), findsOneWidget);
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('فردا'), findsOneWidget);
    expect(find.text('آینده'), findsOneWidget);
    expect(find.text('فاقد زمان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL swipe mapping remains configurable and data-safe',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"archive-me","title":"برای بایگانی"},{"id":"trash-me","title":"برای حذف"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final dismissibles =
        tester.widgetList<Dismissible>(find.byType(Dismissible)).toList();
    expect(dismissibles, hasLength(2));

    final archiveDismissible = dismissibles.firstWhere(
      (item) => item.key == const ValueKey('archive-me'),
    );
    final trashDismissible = dismissibles.firstWhere(
      (item) => item.key == const ValueKey('trash-me'),
    );

    expect(archiveDismissible.direction, DismissDirection.horizontal);
    expect(trashDismissible.direction, DismissDirection.horizontal);
    expect(
      await archiveDismissible.confirmDismiss!(DismissDirection.startToEnd),
      isTrue,
    );
    await tester.pumpAndSettle();

    expect(find.text('برای بایگانی'), findsNothing);
    expect(find.text('برای حذف'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'بایگانی'));
    await tester.pumpAndSettle();
    expect(find.text('برای بایگانی'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'بازگردانی به فعال'));
    await tester.pumpAndSettle();

    expect(find.text('برای بایگانی'), findsOneWidget);
    expect(find.text('برای حذف'), findsOneWidget);
  });
}
