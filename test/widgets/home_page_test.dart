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

  testWidgets('renders the current canonical HomePage shell', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.text('جستجو در کارها'), findsOneWidget);
    expect(find.text('کارهای من'), findsNothing);
    expect(find.text('مشاهده همه'), findsNothing);
  });

  testWidgets('loads an existing legacy task from arvin.tasks', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"legacy-ui-1","title":"کار آزمایشی","description":"توضیح"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار آزمایشی'), findsOneWidget);
    expect(find.text('توضیح'), findsOneWidget);
  });

  testWidgets('completed tasks remain visible in All and Completed filters', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"completed-old","title":"کار انجام‌شده قدیمی","completed":true,"dueDate":"2026-09-20T10:00:00.000"},{"id":"active","title":"کار انجام‌نشده","completed":false}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    // «همه کارها»: a completed task with an old due date must remain visible.
    expect(find.text('کار انجام‌شده قدیمی'), findsOneWidget);
    expect(find.text('کار انجام‌نشده'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-more-task-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-my-tasks-completed')));
    await tester.pumpAndSettle();

    expect(find.text('کار انجام‌شده قدیمی'), findsOneWidget);
    expect(find.text('کار انجام‌نشده'), findsNothing);
  });


  testWidgets('Home contextual category filter hides completed tasks while All shows them',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"completed","title":"کار انجام‌شده","completed":true,"category":"کاری"},{"id":"active","title":"کار فعال","completed":false,"category":"کاری"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار انجام‌شده'), findsOneWidget);
    expect(find.text('کار فعال'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-group-categories')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('کاری').last);
    await tester.pumpAndSettle();

    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار انجام‌شده'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-group-categories')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('همه').last);
    await tester.pumpAndSettle();

    expect(find.text('کار فعال'), findsOneWidget);
    expect(find.text('کار انجام‌شده'), findsOneWidget);
  });

  testWidgets('Home grouping cards open canonical filter selectors', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"p1","title":"کار پروژه","category":"کاری","tags":["مهم"]},{"id":"p2","title":"کار شخصی","category":"شخصی","tags":["مهم"]}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-group-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-projects')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-categories')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-group-labels')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-group-categories')));
    await tester.pumpAndSettle();
    expect(find.text('دسته'), findsOneWidget);
    expect(find.text('کاری'), findsOneWidget);
    expect(find.text('شخصی'), findsOneWidget);
    await tester.tap(find.text('کاری').last);
    await tester.pumpAndSettle();
    expect(find.text('کار پروژه'), findsOneWidget);
    expect(find.text('کار شخصی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-group-labels')));
    await tester.pumpAndSettle();
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.text('مهم'), findsOneWidget);
    await tester.tap(find.text('مهم'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعمال'));
    await tester.pumpAndSettle();
    expect(find.text('کار پروژه'), findsOneWidget);
    expect(find.text('کار شخصی'), findsOneWidget);
  });

  testWidgets('search filters the currently loaded legacy tasks', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"one","title":"تماس فروش"},{"id":"two","title":"جلسه فنی"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('تماس فروش'), findsOneWidget);
    expect(find.text('جلسه فنی'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'فروش');
    await tester.pump();

    expect(find.text('تماس فروش'), findsOneWidget);
    expect(find.text('جلسه فنی'), findsNothing);
  });

  testWidgets('Home search uses canonical Persian and FollowUp text',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"persian","title":"يادداشت كاری"},{"id":"followup","title":"کار دوم","followUps":[{"id":"f1","dateTime":"2026-08-25T10:00:00.000","note":"تماس با مشتری","result":"موفق"}]},{"id":"other","title":"خرید"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'یادداشت کاری');
    await tester.pump();
    expect(find.text('يادداشت كاری'), findsOneWidget);
    expect(find.text('کار دوم'), findsNothing);

    await tester.enterText(find.byType(TextField), 'مشتری');
    await tester.pump();
    expect(find.text('کار دوم'), findsOneWidget);
    expect(find.text('يادداشت كاری'), findsNothing);
    expect(find.text('خرید'), findsNothing);
  });

  testWidgets('default rightward swipe still moves an active task to trash',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"active","title":"کار فعال"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.direction, DismissDirection.horizontal);
    final result =
        await dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('کار فعال'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'سطل زباله'));
    await tester.pumpAndSettle();
    expect(find.text('کار فعال'), findsOneWidget);
  });

  testWidgets('permanent delete from trash requires explicit confirmation',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"trashed","title":"حذف آزمایشی","trashed":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'سطل زباله'));
    await tester.pumpAndSettle();

    expect(find.text('حذف آزمایشی'), findsOneWidget);
    var dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.direction, DismissDirection.horizontal);
    final cancelled =
        dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();

    expect(find.text('حذف دائمی'), findsOneWidget);
    expect(find.textContaining('قابل بازگشت نیست'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'لغو'));
    await tester.pumpAndSettle();
    expect(await cancelled, isFalse);
    expect(find.text('حذف آزمایشی'), findsOneWidget);

    dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    final confirmed =
        dismissible.confirmDismiss!(DismissDirection.endToStart);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'حذف برای همیشه'));
    await tester.pumpAndSettle();

    expect(await confirmed, isTrue);
    expect(find.text('حذف آزمایشی'), findsNothing);
    expect(find.text('سطل زباله خالی است'), findsOneWidget);
  });

  testWidgets('drawer opens archive and restores archived task to active',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"archived","title":"کار بایگانی","archived":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار بایگانی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'بایگانی'));
    await tester.pumpAndSettle();

    expect(find.text('کار بایگانی'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'بازگردانی به فعال'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'بازگردانی به فعال'));
    await tester.pumpAndSettle();

    expect(find.text('کار بایگانی'), findsOneWidget);
    expect(find.text('بایگانی خالی است'), findsNothing);
  });

  testWidgets('drawer opens trash and restores trashed task to active',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"trashed-restore","title":"کار سطل","trashed":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار سطل'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'سطل زباله'));
    await tester.pumpAndSettle();

    expect(find.text('کار سطل'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'بازگردانی به فعال'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'بازگردانی به فعال'));
    await tester.pumpAndSettle();

    expect(find.text('کار سطل'), findsOneWidget);
    expect(find.text('کاری برای نمایش وجود ندارد'), findsNothing);
    expect(find.text('کارهای من'), findsNothing);
  });

  testWidgets('unreadable canonical storage is explicit and blocks Home writes',
      (tester) async {
    const corrupt = '{"not":"a-list"}';
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': corrupt,
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('داده‌های کارها قابل خواندن نیست'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-storage-retry')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-more-quick-capture')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'داده‌های کارها قابل خواندن نیست؛ ابتدا «تلاش دوباره» را بزنید.',
      ),
      findsOneWidget,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('arvin.tasks'), corrupt);
  });

  testWidgets('RTL swipe directions honor independently configured archive and trash actions',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"right-task","title":"بایگانی راست"},{"id":"left-task","title":"سطل چپ"}]',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(
            settings: AppSettings(
              themeMode: ThemeMode.light,
              usePersianDate: true,
              fontFamily: null,
              swipeRightAction: TaskSwipeAction.archive,
              swipeLeftAction: TaskSwipeAction.trash,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cards = find.byType(Dismissible);
    expect(cards, findsNWidgets(2));

    final rightCard = tester.widget<Dismissible>(
      find.byKey(const ValueKey('right-task')),
    );
    final leftCard = tester.widget<Dismissible>(
      find.byKey(const ValueKey('left-task')),
    );

    expect(
      await rightCard.confirmDismiss!(DismissDirection.endToStart),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(find.text('بایگانی راست'), findsNothing);

    final remaining = tester.widget<Dismissible>(
      find.byKey(const ValueKey('left-task')),
    );
    expect(
      await remaining.confirmDismiss!(DismissDirection.startToEnd),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(find.text('سطل چپ'), findsNothing);

    final stored = await TaskStore().load();
    expect(stored.singleWhere((task) => task.id == 'right-task').archived, isTrue);
    expect(stored.singleWhere((task) => task.id == 'left-task').trashed, isTrue);
    expect(leftCard, isA<Dismissible>());
  });

  testWidgets('RTL Move-to-Today does not dismiss and None is a no-op',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"move","title":"انتقال امروز","dueDate":"2026-09-26T10:00:00.000"},{"id":"none","title":"بدون عمل"}]',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(
            settings: AppSettings(
              themeMode: ThemeMode.light,
              usePersianDate: true,
              fontFamily: null,
              swipeRightAction: TaskSwipeAction.moveToToday,
              swipeLeftAction: TaskSwipeAction.none,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cards = find.byType(Dismissible);
    expect(cards, findsNWidgets(2));

    final moveCard = tester.widget<Dismissible>(
      find.byKey(const ValueKey('move')),
    );
    expect(
      await moveCard.confirmDismiss!(DismissDirection.endToStart),
      isFalse,
    );
    await tester.pumpAndSettle();
    expect(find.text('انتقال امروز'), findsOneWidget);

    final moved = (await TaskStore().load()).singleWhere((task) => task.id == 'move');
    final today = DateTime.now();
    expect(moved.dueDate?.year, today.year);
    expect(moved.dueDate?.month, today.month);
    expect(moved.dueDate?.day, today.day);

    final noneCard = tester.widget<Dismissible>(
      find.byKey(const ValueKey('none')),
    );
    expect(
      await noneCard.confirmDismiss!(DismissDirection.startToEnd),
      isFalse,
    );
    await tester.pumpAndSettle();
    expect(find.text('بدون عمل'), findsOneWidget);
  });
}
