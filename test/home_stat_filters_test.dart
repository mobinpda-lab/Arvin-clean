import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/iran_clock.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/center_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    await CenterStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[\n        {"id":"active","title":"کار فعال","category":"اداری","tags":["مهم"],"completed":false},\n        {"id":"done","title":"کار انجام شده","category":"شخصی","completed":true},\n        {"id":"late","title":"کار عقب افتاده","completed":false,"dueDate":"2020-01-01T08:00:00.000"},\n        {"id":"archived","title":"کار بایگانی","archived":true}\n      ]',
    });
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    await CenterStore.resetTestDatabase();
  });

  testWidgets('Home exposes the four canonical REV5 filter controls', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-compact-filter-wrap')), findsOneWidget);
    for (final key in [
      'home-filter-card-time',
      '      'home-filter-card-project',
      'home-filter-card-category',
      'home-filter-card-tags',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    for (final key in [
      'home-filter-card-time',
      'home-filter-card-center',
      'home-filter-card-project',
      'home-filter-card-category',
      'home-filter-card-tags',
    ]) {
      expect(tester.getRect(find.byKey(ValueKey(key))).height, greaterThanOrEqualTo(48));
    }
    expect(tester.takeException(), isNull);

    final taskListScrollable = find.descendant(
      of: find.byKey(const ValueKey('home-task-list-viewport')),
      matching: find.byWidgetPredicate(
        (widget) => widget is Scrollable &&
            widget.axisDirection == AxisDirection.down,
      ),
    );
    expect(taskListScrollable, findsOneWidget);

    // Overdue work is intentionally grouped before active and completed work.
    // Visit it first: scrollUntilVisible advances in one direction and cannot
    // return to this leading group after scrolling down to later groups.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('late')),
      400,
      scrollable: taskListScrollable,
      maxScrolls: 20,
    );
    expect(find.text('کار عقب افتاده'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('active')),
      400,
      scrollable: taskListScrollable,
      maxScrolls: 20,
    );
    expect(find.text('کار فعال'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('done')),
      400,
      scrollable: taskListScrollable,
      maxScrolls: 20,
    );
    expect(find.text('کار انجام شده'), findsOneWidget);

    expect(find.text('کار بایگانی'), findsNothing);
  });

  testWidgets('Home header keeps general filter left of menu in RTL',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-notifications')), findsNothing);
    expect(find.byKey(const ValueKey('home-search-button')), findsOneWidget);
    final generalFilterCenter = tester.getCenter(find.byKey(const ValueKey('home-general-filter-button')));
    final menuCenter = tester.getCenter(find.byKey(const ValueKey('home-drawer-button')));
    expect(menuCenter.dx, greaterThan(generalFilterCenter.dx));
  });

  testWidgets('Home keeps core controls reachable on a short Android viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byKey(const ValueKey('home-bismillah-svg')), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is SvgPicture &&
          (widget.bytesLoader as dynamic).assetName == 'assets/images/branding/bismillah.svg'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
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
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home grouping does not mutate canonical task storage',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getString('arvin.tasks');

    final categoryChip = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryChip);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();
    final tagChip = find.byKey(const ValueKey('home-filter-card-tags'));
    await tester.ensureVisible(tagChip);
    await tester.tap(tagChip);
    await tester.pumpAndSettle();

    expect(prefs.getString('arvin.tasks'), before);
  });
  testWidgets('Home time filter exposes precise date and time range controls',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final timeChip = find.byKey(const ValueKey('home-filter-card-time'));
    await tester.ensureVisible(timeChip);
    await tester.tap(timeChip);
    await tester.pumpAndSettle();

    expect(find.text('انتخاب‌شده: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-time-filter-today-focus')), findsOneWidget);
    final sheetScrollable = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.text('بازهٔ دلخواه'), 300, scrollable: sheetScrollable);
    final customRange = find.byKey(const ValueKey('home-time-filter-customRange'));
    expect(customRange, findsOneWidget);
    await tester.ensureVisible(customRange);
    await tester.tap(customRange);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب‌شده: 1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('از تاریخ'), 300, scrollable: sheetScrollable);
    expect(find.text('از تاریخ'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('تا تاریخ'), 300, scrollable: sheetScrollable);
    expect(find.text('تا تاریخ'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('از ساعت'), 300, scrollable: sheetScrollable);
    expect(find.text('از ساعت'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('تا ساعت'), 300, scrollable: sheetScrollable);
    expect(find.text('تا ساعت'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('تأیید / اعمال فیلتر'), 300, scrollable: sheetScrollable);
    expect(find.text('تأیید / اعمال فیلتر'), findsOneWidget);
    expect(find.text('اعمال بازه'), findsNothing);
  });

  testWidgets('category checkbox selection applies OR only after confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"one","title":"اداری","category":"اداری"},{"id":"two","title":"شخصی","category":"شخصی"},{"id":"three","title":"مالی","category":"مالی"}]',
    });
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    final categoryChip = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryChip);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();
    expect(find.text('همه'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('multi-select-option-اداری')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('شخصی'), 240, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('multi-select-option-شخصی')));
    await tester.pumpAndSettle();
    // Draft choices are not applied before the explicit confirmation.
    expect(find.byKey(const ValueKey('task-card-title-three')), findsOneWidget);
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('home-filter-card-category')), matching: find.text('2')), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('home-filter-card-category')), matching: find.text('دسته')), findsOneWidget);
    expect(find.text('اداری'), findsWidgets);
    expect(find.text('شخصی'), findsWidgets);
    expect(find.text('مالی'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tag choices are OR within Tags and AND with Category', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"one","title":"اول","category":"اداری","tags":["مهم","فوری"]},{"id":"two","title":"دوم","category":"اداری","tags":["فوری"]},{"id":"three","title":"سوم","category":"شخصی","tags":["مهم"]}]',
    });
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    final categoryChip = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryChip);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('multi-select-option-اداری')));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    final tagsChip = find.byKey(const ValueKey('home-filter-card-tags'));
    await tester.ensureVisible(tagsChip);
    await tester.tap(tagsChip);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('مهم'), 240, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('multi-select-option-مهم')));
    await tester.scrollUntilVisible(find.text('فوری'), 240, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('multi-select-option-فوری')));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    expect(find.text('اول'), findsOneWidget);
    expect(find.text('دوم'), findsOneWidget);
    expect(find.text('سوم'), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('home-filter-card-tags')), matching: find.text('2')), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('home-filter-card-tags')), matching: find.text('برچسب')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('time checkbox selections use OR without a numeric badge', (tester) async {
    final iranNow = IranClock.now();
    final now = DateTime(iranNow.year, iranNow.month, iranNow.day, 12);
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"past-time","title":"کار گذشته","dueDate":"${yesterday.toIso8601String()}"},{"id":"today-time","title":"کار امروز","dueDate":"${now.toIso8601String()}"},{"id":"future-time","title":"کار فردا","dueDate":"${tomorrow.toIso8601String()}"}]',
    });
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    final timeChip = find.byKey(const ValueKey('home-filter-card-time'));
    await tester.ensureVisible(timeChip);
    await tester.tap(timeChip);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-time-filter-past')));
    await tester.tap(find.byKey(const ValueKey('home-time-filter-today')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('home-filter-card-time')), matching: find.text('2')), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('home-filter-card-time')), matching: find.text('زمان')), findsOneWidget);
    expect(find.text('کار گذشته'), findsOneWidget);
    expect(find.text('کار امروز'), findsOneWidget);
    expect(find.text('کار فردا'), findsNothing);
    expect(tester.takeException(), isNull);
  });


  testWidgets('four REV5 icon filters fit 360, 390 and 412dp without overlap',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const ArvinApp());
      await tester.pumpAndSettle();

      final rects = [
        for (final key in [
          'home-filter-card-time',
          'home-filter-card-center',
          'home-filter-card-project',
          'home-filter-card-category',
          'home-filter-card-tags',
        ])
          tester.getRect(find.byKey(ValueKey(key))),
      ];
      for (final rect in rects) {
        expect(rect.width, greaterThanOrEqualTo(48), reason: 'width=$width');
        expect(rect.height, greaterThanOrEqualTo(48), reason: 'width=$width');
      }
      for (var i = 0; i < rects.length; i++) {
        for (var j = i + 1; j < rects.length; j++) {
          expect(rects[i].overlaps(rects[j]), isFalse, reason: 'width=$width');
        }
      }
      expect(tester.takeException(), isNull, reason: 'width=$width');
    }
  });

  testWidgets('calendar Today includes due-today and overdue open work, not Focus-only future work',
      (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 10));
    final tomorrow = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1))
        .add(const Duration(hours: 10));
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"calendar-today","title":"موعد امروز","dueDate":"${today.toIso8601String()}"},{"id":"calendar-overdue","title":"کار عقب‌افتاده","dueDate":"${yesterday.toIso8601String()}"},{"id":"calendar-completed-overdue","title":"گذشته انجام‌شده","dueDate":"${yesterday.toIso8601String()}","completed":true},{"id":"calendar-focus-future","title":"فقط برگزیدهٔ آینده","dueDate":"${tomorrow.toIso8601String()}","isSelectedForToday":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-general-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'امروز تقویمی'));
    await tester.pumpAndSettle();

    expect(find.text('موعد امروز'), findsOneWidget);
    expect(find.text('کار عقب‌افتاده'), findsOneWidget);
    expect(find.text('گذشته انجام‌شده'), findsNothing);
    expect(find.text('فقط برگزیدهٔ آینده'), findsNothing);
  });

  testWidgets('time filter calendar Today excludes completed tasks and keeps overdue open work',
      (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 10));
    final tomorrow = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1))
        .add(const Duration(hours: 10));
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"time-today-open","title":"کار باز امروز","dueDate":"${today.toIso8601String()}"},{"id":"time-overdue-open","title":"کار باز عقب‌افتاده","dueDate":"${yesterday.toIso8601String()}"},{"id":"time-today-done","title":"کار انجام‌شده امروز","dueDate":"${today.toIso8601String()}","completed":true},{"id":"time-focus-future","title":"فقط تمرکز آینده","dueDate":"${tomorrow.toIso8601String()}","isSelectedForToday":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-time-filter-today')));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    expect(find.text('کار باز امروز'), findsOneWidget);
    expect(find.text('کار باز عقب‌افتاده'), findsOneWidget);
    expect(find.text('کار انجام‌شده امروز'), findsNothing);
    expect(find.text('فقط تمرکز آینده'), findsNothing);
  });

}
