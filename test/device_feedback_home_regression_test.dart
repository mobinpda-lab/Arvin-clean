import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home removes backup shortcut and keeps backup in drawer',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byTooltip('پشتیبان'), findsNothing);
    expect(find.byIcon(Icons.backup_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-backup')), findsOneWidget);
    expect(find.text('پشتیبان‌گیری و بازیابی'), findsOneWidget);
  });

  testWidgets('Bismillah uses the lowered Home header block', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-bismillah')), findsOneWidget);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.toolbarHeight, 78);

    final padding = tester.widget<Padding>(
      find.byKey(const ValueKey('home-title-block')),
    );
    expect(padding.padding, const EdgeInsets.only(top: 12));
  });

  testWidgets('RTL default left swipe archives and right swipe trashes',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"archive-me","title":"برای بایگانی"},{"id":"trash-me","title":"برای حذف"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    var archiveDismissible = tester.widget<Dismissible>(
      find.ancestor(
        of: find.text('برای بایگانی'),
        matching: find.byType(Dismissible),
      ),
    );
    expect(archiveDismissible.direction, DismissDirection.horizontal);

    // In RTL, startToEnd is the physical leftward swipe.
    expect(
      await archiveDismissible.confirmDismiss!(DismissDirection.startToEnd),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(find.text('برای بایگانی'), findsNothing);

    final trashDismissible = tester.widget<Dismissible>(
      find.ancestor(
        of: find.text('برای حذف'),
        matching: find.byType(Dismissible),
      ),
    );

    // In RTL, endToStart is the physical rightward swipe.
    expect(
      await trashDismissible.confirmDismiss!(DismissDirection.endToStart),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(find.text('برای حذف'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'بایگانی'));
    await tester.pumpAndSettle();
    expect(find.text('برای بایگانی'), findsOneWidget);
    expect(find.text('برای حذف'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'سطل زباله'));
    await tester.pumpAndSettle();
    expect(find.text('برای حذف'), findsOneWidget);
  });
}
