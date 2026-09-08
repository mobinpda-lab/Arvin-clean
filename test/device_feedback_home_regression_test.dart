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
    expect(find.byKey(const ValueKey('home-title-block')), findsOneWidget);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
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

    expect(find.text('برای بایگانی'), findsNothing);
    expect(find.text('برای حذف'), findsNothing);
  });
}
