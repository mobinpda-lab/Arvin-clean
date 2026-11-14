import 'package:arvin/models/project_template.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/task_template.dart';
import 'package:arvin/services/project_template_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/task_template_store.dart';
import 'package:arvin/services/task_taxonomy_mutation_service.dart';
import 'package:drift/native.dart';
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
    TaskStore? store,
  }) async {
    final targetStore = store ?? TaskStore();
    if (tasks.isNotEmpty) await targetStore.save(tasks);
    await tester.pumpWidget(
      MaterialApp(
        home: TaskTaxonomyManagementPage(store: targetStore),
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
        'برچسب «مهم» در 1 مورد از کارها، الگوها یا قالب‌های پروژه سابقه ارجاع دارد و قابل حذف نیست؛ برای حفظ سوابق، حذف آن مسدود شده است.',
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
        'دسته «فروش» در 2 مورد از کارها، الگوها یا قالب‌های پروژه سابقه ارجاع دارد و قابل حذف نیست؛ برای حفظ سوابق، حذف آن مسدود شده است.',
      ),
      findsOneWidget,
    );

    final loaded = await TaskStore().load();
    expect(loaded, hasLength(2));
    expect(loaded.every((task) => task.category == 'فروش'), isTrue);
    expect(await TaskStore().loadCategories(), contains('فروش'));
  });
  test(
    'TaskStore blocks direct taxonomy deletion when reusable templates reference it',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final database = NativeDatabase.memory();
      addTearDown(database.close);
      final store = TaskStore(executor: database);
      await store.createCategory('قالبی');
      await store.createTag('قالبی');
      final now = DateTime(2026, 11, 12);
      await TaskTemplateStore(executor: database).save(
        TaskTemplate(
          id: 'task-template-delete-guard',
          name: 'الگو',
          title: 'کار',
          category: 'قالبی',
          tags: const ['قالبی'],
          createdAt: now,
          updatedAt: now,
        ),
      );
      await expectLater(
        store.deleteCategoryCatalog('قالبی'),
        throwsA(isA<TaskTaxonomyDeleteBlocked>()),
      );
      await expectLater(
        store.deleteTagCatalog('قالبی'),
        throwsA(isA<TaskTaxonomyDeleteBlocked>()),
      );
      expect(await store.loadCategories(), contains('قالبی'));
      expect(await store.loadTags(), contains('قالبی'));
    },
  );

  testWidgets(
    'template-only taxonomy references block deletion and stay intact',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final database = NativeDatabase.memory();
      addTearDown(database.close);
      final store = TaskStore(executor: database);
      await store.createCategory('قالبی');
      await store.createTag('قالبی');
      final now = DateTime(2026, 11, 12);
      await TaskTemplateStore(executor: database).save(
        TaskTemplate(
          id: 'task-template-taxonomy',
          name: 'الگوی ایمنی',
          title: 'بازرسی',
          category: 'قالبی',
          tags: const ['قالبی'],
          createdAt: now,
          updatedAt: now,
        ),
      );
      await ProjectTemplateStore(executor: database).save(
        ProjectTemplate(
          id: 'project-template-taxonomy',
          name: 'قالب پروژه',
          tasks: [
            ProjectTemplateTask(
              id: 'project-template-task-taxonomy',
              title: 'کنترل',
              category: 'قالبی',
              tags: const ['قالبی'],
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      );
      await pumpPage(tester, tasks: const <Task>[], store: store);
      expect(find.text('2 مورد'), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey('taxonomy-category-delete-قالبی')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('دسته «قالبی» در 2 مورد از کارها، الگوها یا قالب‌های پروژه'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('taxonomy-tag-delete-قالبی')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('برچسب «قالبی» در 2 مورد از کارها، الگوها یا قالب‌های پروژه'),
        findsOneWidget,
      );
      expect(await store.loadCategories(), contains('قالبی'));
      expect(await store.loadTags(), contains('قالبی'));
      expect((await TaskTemplateStore(executor: database).load()).single.category, 'قالبی');
      expect(
        (await ProjectTemplateStore(executor: database).load()).single.tasks.single.category,
        'قالبی',
      );
    },
  );

  testWidgets(
    'renaming taxonomy updates Task, Task Template and Project Template references',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final database = NativeDatabase.memory();
      addTearDown(database.close);
      final store = TaskStore(executor: database);
      final now = DateTime(2026, 11, 12);
      await store.save([
        Task(
          id: 'taxonomy-task',
          title: 'کار اصلی',
          category: 'قدیمی',
          tags: const ['ایمنی قدیمی'],
        ),
      ]);
      await TaskTemplateStore(executor: database).save(
        TaskTemplate(
          id: 'task-template-rename',
          name: 'الگوی کار',
          title: 'کار الگو',
          category: 'قدیمی',
          tags: const ['ایمنی قدیمی'],
          createdAt: now,
          updatedAt: now,
        ),
      );
      await ProjectTemplateStore(executor: database).save(
        ProjectTemplate(
          id: 'project-template-rename',
          name: 'قالب پروژه',
          tasks: [
            ProjectTemplateTask(
              id: 'project-template-task-rename',
              title: 'کار قالب',
              category: 'قدیمی',
              tags: const ['ایمنی قدیمی'],
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      );
      await pumpPage(tester, tasks: await store.load(), store: store);
      await tester.tap(find.byKey(const ValueKey('taxonomy-category-rename-قدیمی')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('taxonomy-category-rename-input')), 'جدید');
      await tester.tap(find.text('ذخیره'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('taxonomy-tag-rename-ایمنی قدیمی')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('taxonomy-tag-rename-input')), 'ایمنی جدید');
      await tester.tap(find.text('ذخیره'));
      await tester.pumpAndSettle();

      final taskTemplate = (await TaskTemplateStore(executor: database).load()).single;
      final projectTemplate = (await ProjectTemplateStore(executor: database).load()).single;
      final savedTask = (await store.load()).single;
      expect(savedTask.category, 'جدید');
      expect(savedTask.tags, ['ایمنی جدید']);
      expect(taskTemplate.category, 'جدید');
      expect(taskTemplate.tags, ['ایمنی جدید']);
      expect(projectTemplate.tasks.single.category, 'جدید');
      expect(projectTemplate.tasks.single.tags, ['ایمنی جدید']);
      expect(await store.loadCategories(), contains('جدید'));
      expect(await store.loadTags(), contains('ایمنی جدید'));
    },
  );

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
