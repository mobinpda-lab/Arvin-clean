import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_taxonomy_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
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
    expect(find.textContaining('ابتدا موارد را منتقل/تغییرنام دهید'), findsOneWidget);

    final loaded = await TaskStore().load();
    expect(loaded, hasLength(1));
    expect(loaded.single.id, '1');
    expect(loaded.single.category, 'فروش');
    expect(loaded.single.tags, <String>['مهم', 'مشتری']);
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

    expect(find.textContaining('در 2 مورد استفاده می‌شود'), findsOneWidget);

    final loaded = await TaskStore().load();
    expect(loaded, hasLength(2));
    expect(loaded.every((task) => task.category == 'فروش'), isTrue);
  });
}
