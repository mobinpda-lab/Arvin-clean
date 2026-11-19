import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_taxonomy_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required List<Task> tasks,
  }) async {
    final store = TaskStore();
    await store.save(tasks);
    await tester.pumpWidget(
      MaterialApp(
        home: TaskTaxonomyManagementPage(store: store),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('rename category preserves same canonical tasks', (tester) async {
    await pumpPage(
      tester,
      tasks: <Task>[
        Task(id: '1', title: 'A', category: 'فروش', tags: <String>['مهم']),
        Task(id: '2', title: 'B', category: 'فروش', tags: <String>['دیگر']),
      ],
    );

    await tester.tap(
      find.byKey(const ValueKey('taxonomy-category-rename-فروش')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('taxonomy-category-rename-input')),
      'مشتریان',
    );
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    final loaded = await TaskStore().load();
    expect(loaded.map((task) => task.id), containsAll(<String>['1', '2']));
    expect(loaded.every((task) => task.category == 'مشتریان'), isTrue);
    expect(loaded.first.tags, <String>['مهم']);
    expect(find.text('مشتریان'), findsOneWidget);
    expect(find.text('فروش'), findsNothing);
    expect(await TaskStore().loadCategories(), contains('مشتریان'));
    expect(await TaskStore().loadCategories(), isNot(contains('فروش')));
  });

  testWidgets('rename tag refreshes management list and canonical catalog',
      (tester) async {
    await pumpPage(
      tester,
      tasks: <Task>[
        Task(id: '1', title: 'A', tags: <String>['قدیمی']),
      ],
    );

    await tester.tap(find.byKey(const ValueKey('taxonomy-tag-rename-قدیمی')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('taxonomy-tag-rename-input')),
      'جدید',
    );
    await tester.tap(find.text('ذخیره'));
    await tester.pumpAndSettle();

    final loaded = await TaskStore().load();
    expect(loaded.single.tags, <String>['جدید']);
    expect(find.text('جدید'), findsOneWidget);
    expect(find.text('قدیمی'), findsNothing);
    expect(await TaskStore().loadTags(), contains('جدید'));
    expect(await TaskStore().loadTags(), isNot(contains('قدیمی')));
  });

  testWidgets('referenced tag deletion is blocked and data stays intact',
      (tester) async {
    await pumpPage(
      tester,
      tasks: <Task>[
        Task(
          id: '1',
          title: 'A',
          category: 'فروش',
          tags: <String>['مهم', 'مشتری'],
        ),
      ],
    );

    await tester.tap(find.byKey(const ValueKey('taxonomy-tag-delete-مهم')));
    await tester.pumpAndSettle();

    expect(find.textContaining('قابل حذف نیست'), findsOneWidget);
    expect(
      find.text(
        'برچسب «مهم» در 1 کار سابقه ارجاع دارد و قابل حذف نیست؛ برای حفظ سوابق، حذف آن مسدود شده است.',
      ),
      findsOneWidget,
    );

    final loaded = await TaskStore().load();
    expect(loaded, hasLength(1));
    expect(loaded.single.id, '1');
    expect(loaded.single.category, 'فروش');
    expect(loaded.single.tags, <String>['مهم', 'مشتری']);
    expect(await TaskStore().loadTags(), contains('مهم'));
  });

  testWidgets('referenced category deletion is blocked and data stays intact',
      (tester) async {
    await pumpPage(
      tester,
      tasks: <Task>[
        Task(id: '1', title: 'A', category: 'فروش'),
        Task(id: '2', title: 'B', category: 'فروش'),
      ],
    );

    await tester.tap(
      find.byKey(const ValueKey('taxonomy-category-delete-فروش')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'دسته «فروش» در 2 کار سابقه ارجاع دارد و قابل حذف نیست؛ برای حفظ سوابق، حذف آن مسدود شده است.',
      ),
      findsOneWidget,
    );

    final loaded = await TaskStore().load();
    expect(loaded, hasLength(2));
    expect(loaded.every((task) => task.category == 'فروش'), isTrue);
    expect(await TaskStore().loadCategories(), contains('فروش'));
  });
  testWidgets('new unused category stays visible and selectable in management',
      (tester) async {
    final store = TaskStore();
    await store.save(<Task>[]);
    await store.createCategory('دسته مستقل');

    await tester.pumpWidget(
      MaterialApp(
        home: TaskTaxonomyManagementPage(store: store),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دسته مستقل'), findsOneWidget);
    expect(find.text('0 مورد'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('taxonomy-category-delete-دسته مستقل')),
      findsOneWidget,
    );
  });

}
