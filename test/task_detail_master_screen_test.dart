import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/task_detail_page.dart';

Finder _taskDetailPageScrollable(WidgetTester tester) {
  final candidates = find.descendant(
    of: find.byKey(const ValueKey('task-detail-page')),
    matching: find.byType(Scrollable),
  );
  final pageScrollables = <Finder>[];
  for (var index = 0; index < candidates.evaluate().length; index++) {
    final candidate = candidates.at(index);
    final state = tester.state<ScrollableState>(candidate);
    if (state.position.axisDirection == AxisDirection.down &&
        state.position.maxScrollExtent > 0) {
      pageScrollables.add(candidate);
    }
  }
  expect(
    pageScrollables,
    hasLength(1),
    reason: 'Select the unique vertical Scrollable with real page scroll extent; '
        'TextField-internal Scrollables are not the detail-page list.',
  );
  return pageScrollables.single;
}

void main() {
  testWidgets('Master Task Details saves title and multiline description inline', (tester) async {
    Task? persisted;
    final task = Task(id: 'master-inline-1', title: 'عنوان قبلی', description: 'شرح قبلی');
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onTaskChanged: (candidate) async {
          persisted = candidate;
          return candidate;
        },
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('task-detail-inline-title')), 'عنوان تازه');
    await tester.enterText(find.byKey(const ValueKey('task-detail-inline-description')), 'خط اول\nخط دوم\nخط سوم');
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(persisted?.title, 'عنوان تازه');
    expect(persisted?.description, 'خط اول\nخط دوم\nخط سوم');
    expect(find.text('عنوان تازه'), findsOneWidget);
  });

  testWidgets('Master Task Details toggles an independent reminder', (tester) async {
    Task? persisted;
    final task = Task(
      id: 'master-reminder-1',
      title: 'کار یادآوری‌دار',
      taskReminders: [
        TaskReminder(
          id: 'reminder-toggle-1',
          title: 'تماس',
          date: DateTime(2026, 11, 5, 10),
          sequence: 1,
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onTaskChanged: (candidate) async {
          persisted = candidate;
          return candidate;
        },
      ),
    ));

    final tile = find.byKey(const ValueKey('task-detail-reminder-reminder-toggle-1'));
    await tester.scrollUntilVisible(
      tile,
      240,
      scrollable: _taskDetailPageScrollable(tester),
    );
    await tester.pumpAndSettle();
    expect(tile, findsOneWidget);
    await tester.tap(find.descendant(of: tile, matching: find.byType(Switch)));
    await tester.pumpAndSettle();

    expect(persisted?.taskReminders.single.isEnabled, isFalse);
  });


  testWidgets('Smart visibility keeps an ordinary Task detail compact', (tester) async {
    final task = Task(id: 'smart-simple', title: 'کار ساده');
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        project: ProjectPlan(
          id: 'smart-project',
          title: 'پروژه دارای الگو',
          templateId: 'project-template-only',
        ),
        onEdit: (value) async => value,
        onTaskChanged: (value) async => value,
        onAddFollowUp: (value, followUp) async => value,
        onChecklistChanged: (value, checklist) async => value,
      ),
    ));

    expect(find.byKey(const ValueKey('task-detail-description-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-independent-reminders')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-checklist')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-latest-followup')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-timeline')), findsNothing);

    final detailScrollable = _taskDetailPageScrollable(tester);
    final addReminder = find.byKey(const ValueKey('task-detail-add-reminder'));
    await tester.scrollUntilVisible(addReminder, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(addReminder, findsOneWidget);

    final addChecklist = find.byKey(const ValueKey('task-detail-add-checklist'));
    await tester.scrollUntilVisible(addChecklist, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(addChecklist, findsOneWidget);

    final addFollowUp = find.byKey(const ValueKey('task-detail-add-followup'));
    await tester.scrollUntilVisible(addFollowUp, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(addFollowUp, findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-recurrence')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-recurrence-add')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-template-source')), findsNothing);
    expect(find.text('افراد مرتبط'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-recurrence')), findsNothing);
    final recurrenceAdd = find.byKey(const ValueKey('task-detail-recurrence-add'));
    await tester.scrollUntilVisible(
      recurrenceAdd,
      300,
      scrollable: detailScrollable,
    );
    await tester.pumpAndSettle();
    expect(recurrenceAdd, findsOneWidget);
  });

  testWidgets('Smart visibility shows rich sections only when canonical data exists', (tester) async {
    final task = Task(
      id: 'smart-rich',
      title: 'کار چندمرحله‌ای',
      templateTaskId: 'template-task-42',
      checklistEnabled: true,
      checklist: const ['[ ] آماده‌سازی'],
      taskReminders: [
        TaskReminder(
          id: 'smart-reminder',
          title: 'یادآوری جلسه',
          date: DateTime(2026, 11, 5, 10),
          sequence: 1,
        ),
      ],
      recurrence: null,
      people: const [],
      followUps: const [],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onEdit: (value) async => value,
        onTaskChanged: (value) async => value,
        onChecklistChanged: (value, checklist) async => value,
      ),
    ));

    final detailScrollable = _taskDetailPageScrollable(tester);
    final reminders = find.byKey(const ValueKey('task-detail-independent-reminders'));
    await tester.scrollUntilVisible(reminders, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(reminders, findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-reminder-smart-reminder')), findsOneWidget);
    final checklist = find.byKey(const ValueKey('task-detail-checklist'));
    await tester.scrollUntilVisible(checklist, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(checklist, findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-detail-checklist-progress-bar')),
      findsOneWidget,
    );
    expect(find.text('افزودن مرحله جدید'), findsOneWidget);
    final templateSource = find.byKey(const ValueKey('task-detail-template-source'));
    await tester.scrollUntilVisible(
      templateSource,
      300,
      scrollable: detailScrollable,
    );
    await tester.pumpAndSettle();
    expect(templateSource, findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-latest-followup')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-timeline')), findsNothing);
  });

  testWidgets('Master Task Details exposes clone action and calls canonical handler', (tester) async {
    var cloned = false;
    final task = Task(id: 'master-clone-1', title: 'کار قابل تکثیر');
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onClone: (source) async {
          cloned = true;
          return Task(id: 'master-clone-2', title: 'کپی — ${source.title}');
        },
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('task-detail-clone')));
    await tester.pumpAndSettle();

    expect(cloned, isTrue);
    expect(find.text('یک کپی مستقل از کار ایجاد شد'), findsOneWidget);
  });

  testWidgets('Task Details presents summary, metadata and due date once in RTL order', (tester) async {
    final task = Task(
      id: 'visual-order-1',
      title: 'کار نمونه',
      description: 'شرح مستقل',
      dueDate: DateTime(2026, 11, 15, 10, 30),
      createdAt: DateTime(2026, 11, 1, 8),
      category: 'تجهیزات',
      tags: const ['فوری', 'بخش بستری'],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        centerName: 'مرکز نمونه',
        project: ProjectPlan(id: 'visual-project', title: 'پروژه نمونه'),
        onEdit: (value) async => value,
        onTaskChanged: (value) async => value,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('task-detail-summary-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-description-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-status-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-priority-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date-full')), findsNothing);
    expect(find.text('افراد مرتبط'), findsNothing);
    expect(find.text('مسئول مستقل برای این کار تعریف نشده است'), findsNothing);

    final summaryY = tester.getTopLeft(find.byKey(const ValueKey('task-detail-summary-card'))).dy;
    final descriptionY = tester.getTopLeft(find.byKey(const ValueKey('task-detail-description-card'))).dy;
    final metadataY = tester.getTopLeft(find.byKey(const ValueKey('task-detail-metadata'))).dy;
    final dueY = tester.getTopLeft(find.byKey(const ValueKey('task-detail-due-date-card'))).dy;
    expect(summaryY, lessThan(descriptionY));
    expect(descriptionY, lessThan(metadataY));
    expect(metadataY, lessThan(dueY));
    expect(tester.widget<Directionality>(find.ancestor(of: find.byKey(const ValueKey('task-detail-page')), matching: find.byType(Directionality)).first).textDirection, TextDirection.rtl);
  });

  testWidgets('Task Details does not present related people as assignees and keeps bottom content clear', (tester) async {
    final task = Task(
      id: 'related-people-1',
      title: 'کار با افراد مرتبط',
      people: [PersonReference(id: 'p1', displayName: 'شخص مرتبط')],
      checklistEnabled: true,
      checklist: const ['[ ] مورد پایانی'],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onChecklistChanged: (value, items) async => value,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('افراد مرتبط'), findsNothing);
    expect(find.text('شخص مرتبط'), findsNothing);
    expect(task.people.single.displayName, 'شخص مرتبط');
    expect(find.byKey(const ValueKey('task-detail-back')), findsOneWidget);
    final page = tester.widget<Scaffold>(find.byKey(const ValueKey('task-detail-page')));
    expect(page.backgroundColor, const Color(0xFFF5F6FA));
    final summary = tester.widget<Container>(find.byKey(const ValueKey('task-detail-summary-card')));
    final summaryDecoration = summary.decoration! as BoxDecoration;
    expect(summaryDecoration.color, Colors.white);
    expect(summaryDecoration.borderRadius, BorderRadius.circular(16));
    final deleteButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('task-detail-delete')),
    );
    final deleteStyle = deleteButton.style!;
    expect(deleteStyle.foregroundColor!.resolve({}), const Color(0xFFD04444));
    final completeButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('task-detail-complete')),
    );
    expect(completeButton.style!.backgroundColor!.resolve({}), const Color(0xFF4A4CAB));
    final list = tester.widget<ListView>(find.byKey(const ValueKey('task-detail-content-list')));
    expect(list.padding, const EdgeInsets.fromLTRB(16, 14, 16, 120));
    expect(find.byKey(const ValueKey('task-detail-delete')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-complete')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-bottom-edit')), findsOneWidget);
  });
}
