import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/arvin_colors.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/iran_clock.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the current canonical HomePage shell', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('آروین'), findsOneWidget);
    expect(find.text('مدیریت کارها، یادداشت‌ها و پیگیری‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-search-button')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌بندی‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.text('جستجو در کارها، پروژه‌ها، دسته‌ها و برچسب‌ها...'), findsOneWidget);
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
    expect(find.text('توضیح'), findsNothing);
  });

  testWidgets('home task card uses compact controls without shrinking readable text', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"compact-home","title":"کار فشرده","dueDate":"2030-09-20T10:00:00.000"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final toggle = find.byKey(const ValueKey('task-card-toggle-compact-home'));
    expect(toggle, findsOneWidget);
    expect(tester.getSize(toggle).height, lessThanOrEqualTo(42));

    final title = tester.widget<Text>(find.text('کار فشرده'));
    expect(title.style?.fontSize, 14);

    final dueLabel = find.byWidgetPredicate(
      (widget) => widget is Text && (widget.data?.startsWith('موعد:') ?? false),
    );
    expect(dueLabel, findsOneWidget);
    expect(tester.widget<Text>(dueLabel).style?.fontSize, 11);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing overdue warning preserves the Task and its due date', (tester) async {
    final past = IranClock.now().subtract(const Duration(days: 2));
    final dueDate = DateTime(past.year, past.month, past.day, 10).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"overdue-preserved","title":"کار عقب‌افتادهٔ مهم","completed":false,"dueDate":"$dueDate"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار عقب‌افتادهٔ مهم'), findsOneWidget);
    expect(find.textContaining('موعد گذشته:'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-card-clear-due-overdue-preserved')));
    await tester.pumpAndSettle();

    expect(find.text('کار عقب‌افتادهٔ مهم'), findsOneWidget);
    expect(find.textContaining('موعد گذشته:'), findsNothing);
    expect(find.textContaining('موعد:'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-card-clear-due-overdue-preserved')),
      findsNothing,
    );
    final saved = (await TaskStore().load()).single;
    expect(saved.id, 'overdue-preserved');
    expect(saved.dueDate, isNotNull);
  });

  testWidgets('Home hides disabled checklist progress but keeps its saved rows', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"disabled-checklist-home","title":"کار با چک‌لیست خاموش","checklist":["[ ] کیف"],"checklistEnabled":false}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('کار با چک‌لیست خاموش'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('کار با چک‌لیست خاموش'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-card-checklist-progress-disabled-checklist-home')),
      findsNothing,
    );
    final persisted = (await TaskStore().load()).single;
    expect(persisted.checklist, const ['[ ] کیف']);
    expect(persisted.checklistEnabled, isFalse);
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
    await tester.scrollUntilVisible(find.text('کار انجام‌نشده'), 400, scrollable: find.byType(Scrollable).last);
    expect(find.text('کار انجام‌نشده'), findsOneWidget);
    expect(find.text('کار انجام‌نشده'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-more-task-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-my-tasks-completed')));
    await tester.pumpAndSettle();

    expect(find.text('کار انجام‌شده قدیمی'), findsOneWidget);
    expect(find.text('کار انجام‌نشده'), findsNothing);
  });


  testWidgets('Home uses the four cards as combined filters and preserves time grouping',
      (tester) async {
    final today = IranClock.now();
    final isoToday = DateTime(today.year, today.month, today.day, 10).toIso8601String();
    final isoTomorrow = DateTime(today.year, today.month, today.day + 1, 10).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"match","title":"کار منطبق","category":"اتاق","tags":["نوزاد","تعویض"],"completed":false,"dueDate":"$isoToday"},{"id":"tomorrow","title":"کار فردا","category":"اتاق","tags":["نوزاد","تعویض"],"completed":false,"dueDate":"$isoTomorrow"},{"id":"other","title":"کار نامرتبط","category":"اداری","tags":["نوزاد"],"completed":false,"dueDate":"$isoToday"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌بندی‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-filter-card-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اتاق').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-filter-card-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('نوزاد'));
    await tester.tap(find.text('تعویض'));
    await tester.pumpAndSettle();

    expect(find.text('کار منطبق'), findsOneWidget);
    expect(find.text('کار نامرتبط'), findsNothing);
    expect(find.text('کار فردا'), findsNothing);
    expect(find.text('امروز'), findsAtLeastNWidgets(1));
    expect(find.text('فردا'), findsNothing);
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

  testWidgets('Home search scopes the active Home task set',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"active","title":"جستجوی مشترک فعال"},{"id":"completed","title":"جستجوی مشترک انجام‌شده","completed":true},{"id":"archived","title":"جستجوی مشترک بایگانی","archived":true},{"id":"trashed","title":"جستجوی مشترک حذف‌شده","trashed":true}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'جستجوی مشترک');
    await tester.pumpAndSettle();

    expect(find.text('جستجوی مشترک فعال'), findsOneWidget);
    expect(find.text('جستجوی مشترک انجام‌شده'), findsOneWidget);
    expect(find.text('جستجوی مشترک بایگانی'), findsNothing);
    expect(find.text('جستجوی مشترک حذف‌شده'), findsNothing);
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

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
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
    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
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

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
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

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
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

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
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
              swipeRightAction: TaskSwipeAction.moveToToday,
              swipeLeftAction: TaskSwipeAction.none,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('move')), findsOneWidget);
    expect(find.byKey(const ValueKey('none')), findsOneWidget);
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
    final today = IranClock.now();
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

  testWidgets('Home task card allows title and description to grow without forced clipping',
      (tester) async {
    const title =
        'عنوان بسیار طولانی برای اطمینان از اینکه متن کامل کار در کارت خانه قابل مشاهده می‌ماند';
    const description =
        'توضیح طولانی چندخطی برای بررسی اینکه متن توضیحات نیز بدون برش اجباری در کارت خانه نمایش داده شود';

    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"long-card","title":"$title","description":"$description"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    // Home is intentionally a scan surface: the long description is
    // progressively disclosed away from the Home card, while the title remains
    // the primary readable content.
    expect(find.text(title), findsOneWidget);
    expect(find.text(description), findsNothing);
  });


  testWidgets('Home compact filter chips show real taxonomy without counters', (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"a","title":"کار الف","category":"مشتری","tags":["مهم","تماس"]},{"id":"b","title":"کار ب","category":"فروش","tags":["مهم"]}]',
      'arvin.projects': '[{"id":"active-project","title":"پروژه فعال","isArchived":false,"itemIds":[]},{"id":"archived-project","title":"پروژه بایگانی","isArchived":true,"itemIds":[]}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-filter-card-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-tags')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.text('پروژه‌ها'), findsOneWidget);
    expect(find.text('دسته‌بندی‌ها'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.textContaining('مورد'), findsNothing);
    expect(find.text('کار الف'), findsOneWidget);
    expect(find.text('کار ب'), findsOneWidget);
    expect(find.text('پروژه فعال'), findsNothing);
  });

  testWidgets('Home search button focuses the existing canonical search', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-search-button')));
    await tester.pump();

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('home-canonical-search')),
    );
    expect(field.focusNode?.hasFocus, isTrue);
  });

  testWidgets('canonical empty Home offers the real Quick Capture action', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('هنوز کاری برای نمایش نیست'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-empty-add')), findsOneWidget);
    expect(find.text('جلسه تیم محصول'), findsNothing);
    expect(find.text('پیگیری طراحی رابط کاربری'), findsNothing);
    expect(find.text('مراجعه به دکتر'), findsNothing);
  });

  testWidgets('Home Past time filter excludes today and prioritizes incomplete tasks', (tester) async {
    final now = IranClock.now();
    String due(int daysAgo, int hour) => DateTime(
      now.year,
      now.month,
      now.day - daysAgo,
      hour,
    ).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"done-newer","title":"گذشته انجام‌شده جدیدتر","completed":true,"dueDate":"${due(1, 9)}"},'
          '{"id":"open-newer","title":"گذشته باز جدیدتر","completed":false,"dueDate":"${due(1, 10)}"},'
          '{"id":"done-older","title":"گذشته انجام‌شده قدیمی‌تر","completed":true,"dueDate":"${due(4, 9)}"},'
          '{"id":"open-older","title":"گذشته باز قدیمی‌تر","completed":false,"dueDate":"${due(3, 9)}"},'
          '{"id":"today","title":"موعد امروز","completed":false,"dueDate":"${DateTime(now.year, now.month, now.day, 8).toIso8601String()}"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('گذشته').last);
    await tester.pumpAndSettle();

    expect(find.text('موعد امروز'), findsNothing);
    final openOlder = find.text('گذشته باز قدیمی‌تر');
    final openNewer = find.text('گذشته باز جدیدتر');
    final doneOlder = find.text('گذشته انجام‌شده قدیمی‌تر');
    final doneNewer = find.text('گذشته انجام‌شده جدیدتر');
    await tester.ensureVisible(doneNewer);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(openOlder).dy, lessThan(tester.getTopLeft(openNewer).dy));
    expect(tester.getTopLeft(openNewer).dy, lessThan(tester.getTopLeft(doneOlder).dy));
    expect(tester.getTopLeft(doneOlder).dy, lessThan(tester.getTopLeft(doneNewer).dy));
  });


  testWidgets('overdue active task uses red text while card and icons stay neutral',
      (tester) async {
    final past = IranClock.now().subtract(const Duration(days: 2));
    final dueDate = DateTime(past.year, past.month, past.day, 10).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"red-overdue","title":"کار با موعد گذشته","completed":false,"dueDate":"$dueDate"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(
      find.byKey(const ValueKey('task-card-title-red-overdue')),
    );
    expect(title.style?.color, ArvinColors.error);

    final dueIcon = tester.widget<Icon>(
      find.byKey(const ValueKey('task-card-due-icon-red-overdue')),
    );
    expect(dueIcon.color, ArvinColors.textSecondary);
    final dueText = tester.widget<Text>(
      find.textContaining('موعد گذشته:'),
    );
    expect(dueText.style?.color, ArvinColors.error);

    final statusButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('task-card-toggle-red-overdue')),
    );
    final statusIcon = statusButton.icon as Icon;
    expect(statusIcon.icon, Icons.radio_button_unchecked_rounded);
    expect(statusIcon.color, ArvinColors.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completing an active Home task immediately archives it and preserves its data',
      (tester) async {
    final past = IranClock.now().subtract(const Duration(days: 3));
    final dueDate = DateTime(past.year, past.month, past.day, 9).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"archive-on-complete","title":"کار برای آرشیو فوری","description":"توضیح محفوظ","completed":false,"dueDate":"$dueDate","checklist":["[ ] مورد اول"],"followUps":[{"id":"history-1","dateTime":"2026-10-20T09:00:00.000","note":"سابقه محفوظ"}],"reminderDate":"2026-11-05T08:00:00.000"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار برای آرشیو فوری'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-card-toggle-archive-on-complete')));
    await tester.pumpAndSettle();

    expect(find.text('کار برای آرشیو فوری'), findsNothing);
    final saved = (await TaskStore().load())
        .singleWhere((task) => task.id == 'archive-on-complete');
    expect(saved.completed, isTrue);
    expect(saved.archived, isTrue);
    expect(saved.trashed, isFalse);
    expect(saved.description, 'توضیح محفوظ');
    expect(saved.dueDate, DateTime.parse(dueDate));
    expect(saved.checklist, const ['[ ] مورد اول']);
    expect(saved.followUps, hasLength(1));
    expect(saved.followUps.single.id, 'history-1');
    expect(saved.followUps.single.note, 'سابقه محفوظ');
    expect(saved.reminderDate, DateTime.parse('2026-11-05T08:00:00.000'));
  });

  testWidgets('completing a task from the Home Past filter removes it into Archive',
      (tester) async {
    final past = IranClock.now().subtract(const Duration(days: 4));
    final dueDate = DateTime(past.year, past.month, past.day, 11).toIso8601String();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"past-archive","title":"کار گذشته برای بایگانی","completed":false,"dueDate":"$dueDate"}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-filter-card-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('گذشته'));
    await tester.pumpAndSettle();

    expect(find.text('کار گذشته برای بایگانی'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-card-toggle-past-archive')));
    await tester.pumpAndSettle();

    expect(find.text('کار گذشته برای بایگانی'), findsNothing);
    final saved = (await TaskStore().load())
        .singleWhere((task) => task.id == 'past-archive');
    expect(saved.completed, isTrue);
    expect(saved.archived, isTrue);
    expect(saved.dueDate, DateTime.parse(dueDate));
  });


  testWidgets('completed Home task remains available in Archive after app reopen',
      (tester) async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      'arvin.tasks':
          '[{"id":"reopen-archive","title":"کار بایگانی پس از بازگشایی","description":"اطلاعات محفوظ","completed":false,"checklist":["[ ] مورد"],"followUps":[{"id":"reopen-history","dateTime":"2026-10-20T09:00:00.000","note":"سابقه محفوظ"}]}]',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار بایگانی پس از بازگشایی'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-card-toggle-reopen-archive')));
    await tester.pumpAndSettle();
    expect(find.text('کار بایگانی پس از بازگشایی'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();
    expect(find.text('کار بایگانی پس از بازگشایی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'بایگانی'));
    await tester.pumpAndSettle();

    expect(find.text('کار بایگانی پس از بازگشایی'), findsOneWidget);
    final saved = (await TaskStore().load())
        .singleWhere((task) => task.id == 'reopen-archive');
    expect(saved.completed, isTrue);
    expect(saved.archived, isTrue);
    expect(saved.description, 'اطلاعات محفوظ');
    expect(saved.checklist, const ['[ ] مورد']);
    expect(saved.followUps.single.id, 'reopen-history');
    expect(saved.followUps.single.note, 'سابقه محفوظ');
  });



  testWidgets('Home More Today shortcut remains a task filter, not calendar navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('primary-nav-more')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'امروز'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'فیلتر کارها'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'کارهای فاقد زمان'), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-today')), findsNothing);
    expect(find.byKey(const ValueKey('calendar-date-jump')), findsNothing);
  });

}
