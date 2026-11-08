import 'package:arvin/main.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/persian_date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home follows the owner header, real summary values and Today navigation',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = IranClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueToday = DateTime(now.year, now.month, now.day, 10).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"task-a","title":"کار واقعی الف","category":"فروش","tags":["مهم","مشتری"],"dueDate":"$dueToday"},{"id":"task-b","title":"کار واقعی ب","category":"اداری","tags":["مهم"]}]',
      'arvin.projects':
          '[{"id":"active-project","title":"پروژه فعال","isArchived":false,"itemIds":[]},{"id":"archived-project","title":"پروژه بایگانی","isArchived":true,"itemIds":[]}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('آروین'), findsOneWidget);
    expect(find.text('مدیریت کارها، یادداشت‌ها و پیگیری‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-search-button')), findsOneWidget);
    for (final key in [
      'home-filter-card-time',
      'home-filter-card-center',
      'home-filter-card-project',
      'home-filter-card-category',
      'home-filter-card-tags',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('home-notifications')), findsNothing);
    expect(find.text('امروز'), findsWidgets);
    final todayJalali = const PersianDateFormatter().format(today, usePersianDate: true);
    final weekdayName = switch (today.weekday) {
      DateTime.monday => 'دوشنبه',
      DateTime.tuesday => 'سه‌شنبه',
      DateTime.wednesday => 'چهارشنبه',
      DateTime.thursday => 'پنج‌شنبه',
      DateTime.friday => 'جمعه',
      DateTime.saturday => 'شنبه',
      DateTime.sunday => 'یکشنبه',
      _ => '',
    };
    expect(find.text('$weekdayName $todayJalali'), findsAtLeastNWidgets(1));
    expect(find.text('کار واقعی الف'), findsOneWidget);
    expect(find.text('کار واقعی ب'), findsOneWidget);
    expect(find.text('جلسه تیم محصول'), findsNothing);
    expect(find.text('پیگیری طراحی رابط کاربری'), findsNothing);
    expect(find.text('مراجعه به دکتر'), findsNothing);

    for (final id in ['time', 'center', 'project', 'category', 'tags']) {
      expect(find.byKey(ValueKey('home-filter-card-$id')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('home-compact-filter-row')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-compact-filter-wrap')), findsOneWidget);

    final add = find.byKey(const ValueKey('home-canonical-add'));
    expect(add, findsOneWidget);
    expect(tester.getCenter(add).dx, greaterThan(195));
    expect(tester.takeException(), isNull);
  });
}
