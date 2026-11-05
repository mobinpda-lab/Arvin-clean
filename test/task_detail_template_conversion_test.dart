import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/task_template_store.dart';
import 'package:arvin/task_detail_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Task Details converts the current Task into a separate reusable template', (tester) async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final templates = TaskTemplateStore(executor: database);
    final dueDate = DateTime(2026, 11, 20, 9);
    final task = Task(
      id: 'detail-template-source',
      title: 'بازبینی موتور',
      description: 'شرح کامل عملیات',
      dueDate: dueDate,
      category: 'فنی',
      priority: TaskPriority.high,
      tags: const ['ایمنی'],
      checklist: const ['[x] کنترل برق', '[ ] کنترل روغن'],
      people: [PersonReference(id: 'person-1', displayName: 'همکار')],
      taskReminders: [
        TaskReminder(
          id: 'detail-template-reminder',
          title: 'یادآوری بازبینی',
          date: DateTime(2026, 11, 20, 8, 30),
          sequence: 1,
        ),
      ],
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        count: 6,
      ),
      completed: true,
      completedAt: DateTime(2026, 11, 3),
      followUps: [
        FollowUp(
          id: 'detail-template-followup',
          dateTime: DateTime(2026, 11, 2, 10),
          note: 'اقدام واقعی قبلی',
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        centerName: 'مرکز فنی',
        project: ProjectPlan(
          id: 'project-source-1',
          title: 'پروژه بازبینی',
          centerId: 'center-source-1',
        ),
        taskTemplateStore: templates,
        onTaskChanged: (value) async => value,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-convert-template')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-detail-template-name')),
      'بازبینی دوره‌ای',
    );
    await tester.tap(find.byKey(const ValueKey('task-detail-template-confirm')));
    await tester.pumpAndSettle();

    final saved = (await templates.load()).single;
    expect(saved.name, 'بازبینی دوره‌ای');
    expect(saved.title, 'بازبینی موتور');
    expect(saved.description, 'شرح کامل عملیات');
    expect(saved.category, 'فنی');
    expect(saved.priority, TaskPriority.high);
    expect(saved.tags, ['ایمنی']);
    expect(saved.checklist, ['کنترل برق', 'کنترل روغن']);
    expect(saved.people.single.id, 'person-1');
    expect(saved.reminders.single.hour, 8);
    expect(saved.reminders.single.minute, 30);
    expect(saved.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(saved.recurrence?.interval, 2);
    expect(saved.centerNameSnapshot, 'مرکز فنی');
    expect(saved.projectNameSnapshot, 'پروژه بازبینی');
    expect(saved.centerIdSnapshot, 'center-source-1');
    expect(saved.projectIdSnapshot, 'project-source-1');
    expect(task.dueDate, dueDate);
    expect(task.completed, isTrue);
    expect(task.followUps.single.id, 'detail-template-followup');
    expect(task.checklist.first, '[x] کنترل برق');
    expect(find.text('الگوی کار ذخیره شد؛ کار اصلی و سابقه آن تغییر نکرد.'), findsOneWidget);
  });
}
