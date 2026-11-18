import 'package:arvin/main.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openMore(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
  }

  testWidgets('Today menu action shows only active canonical tasks due today',
      (tester) async {
    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day, 12);
    final tomorrow = today.add(const Duration(days: 1));

    await TaskStore().save([
      Task(
        id: 'today',
        title: 'کار امروز',
        followUpEnabled: true,
        dueDate: today,
      ),
      Task(
        id: 'tomorrow',
        title: 'کار فردا',
        followUpEnabled: true,
        dueDate: tomorrow,
      ),
      Task(
        id: 'completed',
        title: 'کار انجام‌شده امروز',
        completed: true,
        followUpEnabled: true,
        dueDate: today,
      ),
    ]);

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await openMore(tester);
    await tester.tap(find.widgetWithText(ListTile, 'امروز'));
    await tester.pumpAndSettle();

    expect(find.text('کار امروز'), findsOneWidget);
    expect(find.text('کار فردا'), findsNothing);
    expect(find.text('کار انجام‌شده امروز'), findsNothing);
  });

  testWidgets('Today menu action has a dedicated empty state', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await openMore(tester);
    await tester.tap(find.widgetWithText(ListTile, 'امروز'));
    await tester.pumpAndSettle();

    expect(find.text('کاری برای امروز وجود ندارد'), findsOneWidget);
  });

  testWidgets('About menu action opens the built-in Arvin about dialog',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await openMore(tester);
    final about = find.text('درباره آروین');
    if (about.evaluate().isEmpty) {
      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(about, 240, scrollable: scrollable);
    }
    await tester.ensureVisible(about);
    await tester.tap(about);
    await tester.pumpAndSettle();

    expect(find.byType(AboutDialog), findsOneWidget);
    expect(find.text('آروین'), findsWidgets);
    expect(find.text('مدیریت کارها و پیگیری‌ها'), findsOneWidget);
  });
}
