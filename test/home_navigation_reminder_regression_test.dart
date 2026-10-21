import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home reminder bell opens the canonical reminder calendar',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-notifications')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-context-help')), findsOneWidget);
    expect(
      find.text('اعلان‌ها در بخش اعلان‌های برنامه مدیریت می‌شوند'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home hamburger and bottom More open different menus',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-drawer-task-filters')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-more-quick-capture')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-drawer-task-filters')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-my-tasks-today')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-my-tasks-undated')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-more-quick-capture')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-drawer-task-filters')), findsNothing);
    expect(find.byKey(const ValueKey('home-my-tasks-undated')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
