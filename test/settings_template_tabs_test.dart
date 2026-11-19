import 'package:arvin/task_template_management_page.dart';
import 'package:arvin/models/project_template.dart';
import 'package:arvin/services/project_template_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings template hub exposes two distinct operational tabs', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final now = DateTime(2026, 11, 5);
    await ProjectTemplateStore().save(ProjectTemplate(
      id: 'settings-project-template',
      name: 'الگوی نگهداری دوره‌ای',
      tasks: const [
        ProjectTemplateTask(
          id: 'settings-project-template-task',
          title: 'بازبینی موتور',
          checklist: ['کنترل روغن'],
        ),
      ],
      createdAt: now,
      updatedAt: now,
    ));
    await tester.pumpWidget(const MaterialApp(home: TemplatesSettingsPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('task-templates-tab')), findsOneWidget);
    expect(find.byKey(const ValueKey('project-templates-tab')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-template-management-list')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('project-templates-tab')));
    await tester.pumpAndSettle();
    expect(find.text('قالب جدید'), findsOneWidget);
    expect(find.text('الگوی نگهداری دوره‌ای'), findsOneWidget);
    expect(find.text('بازبینی موتور'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-templates-tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-template-management-list')), findsOneWidget);
  });
}
