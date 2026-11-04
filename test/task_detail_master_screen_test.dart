import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

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
        onEdit: (value) async => value,
        onTaskChanged: (value) async => value,
        onAddFollowUp: (value, followUp) async => value,
        onChecklistChanged: (value, checklist) async => value,
      ),
    ));

    expect(find.byKey(const ValueKey('task-detail-independent-reminders')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-add-reminder')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-checklist')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-add-checklist')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-latest-followup')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-timeline')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-add-followup')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-recurrence')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-recurrence-add')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-template-source')), findsNothing);
    expect(find.text('افراد مرتبط'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-recurrence')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-recurrence-add')), findsOneWidget);
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

    expect(find.byKey(const ValueKey('task-detail-independent-reminders')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-reminder-smart-reminder')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-checklist')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-template-source')), findsOneWidget);
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
}
