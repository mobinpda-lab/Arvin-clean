import 'package:arvin/models/project_template.dart';
import 'package:arvin/project_template_management_page.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/project_template_service.dart';
import 'package:arvin/services/project_template_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Project Template task uses canonical Category and Tag selectors and persists created catalog values',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final database = NativeDatabase.memory();
      addTearDown(database.close);
      final taskStore = TaskStore(executor: database);
      final templateStore = ProjectTemplateStore(executor: database);
      final centerStore = CenterStore(executor: database);
      final projectStore = ProjectStore(executor: database);
      await taskStore.createCategory('سرویس');
      await taskStore.createTag('ایمنی');
      final now = DateTime(2026, 11, 12);
      await templateStore.save(
        ProjectTemplate(
          id: 'template-selector',
          name: 'قالب نگهداری',
          tasks: [
            ProjectTemplateTask(
              id: 'template-selector-task',
              title: 'بازرسی',
              category: 'سرویس',
              tags: const ['ایمنی'],
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      );
      final service = ProjectTemplateService(
        templateStore: templateStore,
        centerStore: centerStore,
        projectStore: projectStore,
        taskStore: taskStore,
      );
      await tester.pumpWidget(
        MaterialApp(home: ProjectTemplateManagementPage(service: service)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('بازرسی'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('project-template-task-category-rollbox')), findsOneWidget);
      expect(find.byKey(const ValueKey('project-template-task-tag-rollbox')), findsOneWidget);
      expect(find.text('دسته (اختیاری)'), findsNothing);
      expect(find.text('برچسب‌ها (با ویرگول جدا شوند)'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('project-template-task-category-rollbox')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'دسته تازه قالب');
      await tester.tap(find.byKey(const ValueKey('project-template-task-category-create')));
      await tester.pumpAndSettle();
      expect(await taskStore.loadCategories(), contains('دسته تازه قالب'));

      await tester.tap(find.byKey(const ValueKey('project-template-task-tag-rollbox')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('multi-select-create-0')), 'برچسب تازه قالب');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('تأیید / اعمال فیلتر'));
      await tester.pumpAndSettle();
      expect(await taskStore.loadTags(), contains('برچسب تازه قالب'));

      await tester.tap(find.text('ذخیره کار'));
      await tester.pumpAndSettle();
      final saved = (await templateStore.load()).single.tasks.single;
      expect(saved.category, 'دسته تازه قالب');
      expect(saved.tags, ['ایمنی', 'برچسب تازه قالب']);
    },
  );
}
