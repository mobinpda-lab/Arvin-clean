import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/services/task_template_store.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/services/persian_date_formatter.dart';
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

  testWidgets('Unified Task Details edits due time and all-day state with canonical pickers', (tester) async {
    Task? persisted;
    final task = Task(
      id: 'inline-due-date',
      title: 'کار با موعد',
      dueDate: DateTime(2026, 11, 20, 9, 30),
      allDay: false,
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
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    final scrollable = _taskDetailPageScrollable(tester);
    final dueCard = find.byKey(const ValueKey('task-detail-due-date-card'));
    await tester.scrollUntilVisible(dueCard, 240, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-due-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-manual-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('universal-time-manual-input')), '11:45');
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-all-day')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(persisted?.dueDate, DateTime(2026, 11, 20, 11, 45));
    expect(persisted?.allDay, isTrue);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    final clearableScroll = _taskDetailPageScrollable(tester);
    await tester.scrollUntilVisible(dueCard, 240, scrollable: clearableScroll);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-due-clear')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(persisted?.dueDate, isNull);
    expect(persisted?.allDay, isFalse);
  });

  testWidgets('Unified Task Details adds a reminder and saves it with the form', (tester) async {
    Task? persisted;
    final task = Task(id: 'inline-reminder-add', title: 'کار با یادآور');
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
    final scrollable = _taskDetailPageScrollable(tester);
    final addReminder = find.byKey(const ValueKey('task-detail-add-reminder'));
    await tester.scrollUntilVisible(addReminder, 240, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(addReminder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('task-detail-reminder-title-input')), 'تماس با مشتری');
    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأیید'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();
    expect(find.text('تماس با مشتری'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(persisted?.taskReminders, hasLength(1));
    expect(persisted?.taskReminders.single.title, 'تماس با مشتری');
    expect(persisted?.taskReminders.single.date, isNotNull);
  });

  testWidgets('Unified Task Details edits a reminder title before saving the form', (tester) async {
    Task? persisted;
    final task = Task(
      id: 'inline-reminder-edit',
      title: 'کار با یادآور',
      taskReminders: [
        TaskReminder(
          id: 'reminder-edit-1',
          title: 'عنوان قبلی',
          date: DateTime(2026, 11, 20, 9),
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
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    final scrollable = _taskDetailPageScrollable(tester);
    final editTitle = find.byKey(const ValueKey('task-detail-reminder-edit-title-reminder-edit-1'));
    await tester.scrollUntilVisible(editTitle, 240, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(editTitle);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-detail-reminder-edit-title-input-reminder-edit-1')),
      'عنوان اصلاح‌شده',
    );
    await tester.tap(find.text('ذخیره عنوان'));
    await tester.pumpAndSettle();
    expect(persisted, isNull);
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(persisted?.taskReminders.single.title, 'عنوان اصلاح‌شده');
  });

  testWidgets('Unified Task Details edits and persists recurrence in the same form', (tester) async {
    Task? persisted;
    final recurrenceStart = DateTime(2026, 11, 15);
    final task = Task(
      id: 'inline-recurrence',
      title: 'کار تکرارشونده',
      dueDate: recurrenceStart,
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
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    final scrollable = _taskDetailPageScrollable(tester);
    final addRule = find.byKey(const ValueKey('task-detail-recurrence-add'));
    await tester.scrollUntilVisible(addRule, 240, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(addRule);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-recurrence-frequency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('هفتگی').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('task-detail-recurrence-interval')), '2');
    await tester.enterText(find.byKey(const ValueKey('task-detail-recurrence-count')), '4');
    await tester.tap(find.byKey(const ValueKey('task-detail-recurrence-end-date-pick')));
    await tester.pumpAndSettle();
    final jalaliDay = const PersianDateFormatter().toJalali(recurrenceStart).day;
    await tester.tap(find.byKey(ValueKey('persian-date-day-$jalaliDay')));
    await tester.tap(find.text('تأیید'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(persisted?.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(persisted?.recurrence?.interval, 2);
    expect(persisted?.recurrence?.count, 4);
    expect(
      persisted?.recurrence?.endDate,
      DateTime(recurrenceStart.year, recurrenceStart.month, recurrenceStart.day, 23, 59, 59, 999),
    );
  });

  testWidgets('Task Details presents canonical follow-up title, note and waiting-for-response state', (tester) async {
    final task = Task(
      id: 'followup-status-presentation',
      title: 'کار در انتظار پاسخ',
      followUps: [
        FollowUp(
          id: 'waiting-followup',
          dateTime: DateTime(2026, 11, 4, 14),
          title: 'تماس با مشتری',
          note: 'پاسخ دریافت نشد',
          waitingForResponse: true,
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onTaskChanged: (value) async => value,
      ),
    ));
    await tester.pumpAndSettle();

    final summary = find.byKey(const ValueKey('task-detail-summary-card'));
    expect(
      find.descendant(of: summary, matching: find.text('در انتظار پاسخ')),
      findsOneWidget,
    );
    final scrollable = _taskDetailPageScrollable(tester);
    final latest = find.byKey(const ValueKey('task-detail-latest-followup'));
    await tester.scrollUntilVisible(latest, 240, scrollable: scrollable);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-latest-followup-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-latest-followup-note')), findsOneWidget);
    expect(find.text('تماس با مشتری'), findsOneWidget);
    expect(find.text('پاسخ دریافت نشد'), findsOneWidget);
    expect(find.text('در انتظار پاسخ'), findsAtLeastNWidgets(1));
  });

  testWidgets('Unified Task Details stages checklist edits, reorders and saves or cancels atomically', (tester) async {
    Task? persisted;
    final source = Task(
      id: 'inline-checklist-draft',
      title: 'کار با چک‌لیست',
      checklistEnabled: true,
      checklist: const ['[ ] مرحله اول', '[ ] مرحله دوم'],
      followUps: [
        FollowUp(id: 'history-keep', dateTime: DateTime(2026, 11, 4), note: 'تاریخچه محفوظ'),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: source,
        onTaskChanged: (candidate) async {
          persisted = candidate;
          return candidate;
        },
        onChecklistChanged: (candidate, values) async => candidate,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-checklist-down-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('task-detail-checklist-add-input')), 'مرحله سوم');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('مرحله دوم'), findsOneWidget);
    expect(find.text('مرحله اول'), findsOneWidget);
    expect(find.text('مرحله سوم'), findsOneWidget);
    expect(persisted, isNull);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-cancel')));
    await tester.pumpAndSettle();
    expect(source.checklist, ['[ ] مرحله اول', '[ ] مرحله دوم']);
    expect(persisted, isNull);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-checklist-down-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(persisted?.checklist, ['[ ] مرحله دوم', '[ ] مرحله اول']);
    expect(persisted?.followUps.single.id, 'history-keep');
  });

  testWidgets('Unified Task Details stages status and priority in the same form until save', (tester) async {
    Task? persisted;
    final task = Task(
      id: 'inline-status-priority',
      title: 'کار با وضعیت و اولویت',
      priority: TaskPriority.medium,
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
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-priority-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(TaskPriority.high.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-status-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('علامت‌گذاری به‌عنوان انجام‌شده'));
    await tester.pumpAndSettle();

    expect(persisted, isNull);
    expect(task.priority, TaskPriority.medium);
    expect(task.completed, isFalse);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(persisted?.priority, TaskPriority.high);
    expect(persisted?.completed, isTrue);
    expect(persisted?.completedAt, isNotNull);
  });

  testWidgets('Unified Task Details preserves the page scroll offset entering and cancelling edit', (tester) async {
    final task = Task(
      id: 'scroll-preservation',
      title: 'کار با جزئیات زیاد',
      description: 'شرح طولانی',
      checklistEnabled: true,
      checklist: List<String>.generate(12, (index) => '[ ] مرحله شماره ${index + 1}'),
      taskReminders: List<TaskReminder>.generate(
        4,
        (index) => TaskReminder(
          id: 'scroll-reminder-$index',
          title: 'یادآور $index',
          date: DateTime(2026, 11, 5, 10 + index),
          sequence: index + 1,
        ),
      ),
      followUps: [
        FollowUp(id: 'scroll-followup', dateTime: DateTime(2026, 11, 4), note: 'پیگیری'),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onTaskChanged: (value) async => value,
        onChecklistChanged: (value, checklist) async => value,
      ),
    ));
    await tester.pumpAndSettle();
    final scrollable = _taskDetailPageScrollable(tester);
    await tester.drag(find.byKey(const ValueKey('task-detail-content-list')), const Offset(0, -280));
    await tester.pumpAndSettle();
    final position = tester.state<ScrollableState>(scrollable).position;
    final before = position.pixels;
    expect(before, greaterThan(0));

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(position.pixels, before);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-cancel')));
    await tester.pumpAndSettle();
    expect(position.pixels, before);
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
    expect(find.byKey(const ValueKey('task-detail-independent-reminders')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-checklist')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-latest-followup')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-timeline')), findsOneWidget);

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
    expect(find.byKey(const ValueKey('task-detail-recurrence')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-recurrence-add')), findsNothing);
    expect(find.byKey(const ValueKey('task-detail-template-source')), findsNothing);
    expect(find.text('افراد مرتبط'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-recurrence')), findsOneWidget);
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
    final templateSource = find.byKey(const ValueKey('task-detail-template-source'));
    await tester.scrollUntilVisible(templateSource, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(templateSource, findsOneWidget);
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
    expect(find.byKey(const ValueKey('task-detail-latest-followup')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-timeline')), findsOneWidget);
  });

  testWidgets('Task Details converts a Task to a persisted template without mutating source', (tester) async {
    await TaskTemplateStore.resetTestDatabase();
    addTearDown(TaskTemplateStore.resetTestDatabase);
    final task = Task(
      id: 'task-template-ui-source',
      title: 'بازبینی پمپ',
      description: 'شرح پایدار',
      category: 'فنی',
      tags: const ['ایمنی'],
      checklist: const ['[x] کنترل برق', '[ ] کنترل فشار'],
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 11, 20),
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        centerName: 'مرکز مرکزی',
        projectTitle: 'پروژه تعمیرات',
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('task-detail-convert-template')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('task-detail-template-name')), 'بازبینی پمپ دوره‌ای');
    await tester.tap(find.byKey(const ValueKey('task-detail-template-confirm')));
    await tester.pumpAndSettle();

    final saved = await TaskTemplateStore().load();
    expect(saved, hasLength(1));
    expect(saved.single.name, 'بازبینی پمپ دوره‌ای');
    expect(saved.single.title, 'بازبینی پمپ');
    expect(saved.single.centerNameSnapshot, 'مرکز مرکزی');
    expect(saved.single.projectNameSnapshot, 'پروژه تعمیرات');
    expect(task.title, 'بازبینی پمپ');
    expect(task.dueDate, DateTime(2026, 11, 20));
    expect(task.checklist.first, '[x] کنترل برق');
    expect(find.text('الگوی کار ذخیره شد؛ کار اصلی و سابقه آن تغییر نکرد.'), findsOneWidget);
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
      checklistEnabled: true,
      checklist: const ['[ ] کنترل اولیه'],
      taskReminders: [
        TaskReminder(
          id: 'visual-reminder',
          title: 'یادآوری کنترل',
          date: DateTime(2026, 11, 14, 9),
          sequence: 1,
        ),
      ],
      recurrence: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        startDate: DateTime(2026, 11, 15),
      ),
      followUps: [
        FollowUp(
          id: 'visual-followup',
          dateTime: DateTime(2026, 11, 10, 10),
          note: 'تماس با مسئول',
        ),
      ],
      templateTaskId: 'visual-template',
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        centerName: 'مرکز نمونه',
        project: ProjectPlan(
          id: 'visual-project',
          title: 'پروژه نمونه',
          templateId: 'visual-template',
          templateNameSnapshot: 'الگوی نمونه',
        ),
        onEdit: (value) async => value,
        onTaskChanged: (value) async => value,
      ),
    ));
    await tester.pumpAndSettle();

    final summary = find.byKey(const ValueKey('task-detail-summary-card'));
    final metadata = find.byKey(const ValueKey('task-detail-metadata'));
    expect(summary, findsOneWidget);
    expect(metadata, findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata-chips')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata-center')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-metadata-tags')), findsOneWidget);
    expect(find.text('مشخصات کار'), findsOneWidget);
    // These controls belong to the summary card; assert them before lazy-list scrolling.
    expect(find.byKey(const ValueKey('task-detail-status-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-priority-menu')), findsOneWidget);

    final summaryY = tester.getTopLeft(summary).dy;
    final metadataY = tester.getTopLeft(metadata).dy;
    final timeX = tester.getCenter(find.byKey(const ValueKey('task-detail-metadata-time'))).dx;
    final centerX = tester.getCenter(find.byKey(const ValueKey('task-detail-metadata-center'))).dx;
    final projectX = tester.getCenter(find.byKey(const ValueKey('task-detail-metadata-project'))).dx;
    final categoryX = tester.getCenter(find.byKey(const ValueKey('task-detail-metadata-category'))).dx;
    final tagsX = tester.getCenter(find.byKey(const ValueKey('task-detail-metadata-tags'))).dx;

    final detailScrollable = _taskDetailPageScrollable(tester);
    final scrollPosition = tester.state<ScrollableState>(detailScrollable).position;

    final template = find.byKey(const ValueKey('task-detail-template-source'));
    await tester.scrollUntilVisible(template, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(template, findsOneWidget);
    final templateY = scrollPosition.pixels + tester.getTopLeft(template).dy;

    final dueDate = find.byKey(const ValueKey('task-detail-due-date-card'));
    await tester.scrollUntilVisible(dueDate, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(dueDate, findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date-full')), findsNothing);
    final dueY = scrollPosition.pixels + tester.getTopLeft(dueDate).dy;

    final assignee = find.byKey(const ValueKey('task-detail-assignee-card'));
    await tester.scrollUntilVisible(assignee, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(assignee, findsOneWidget);
    expect(find.text('مسئول مستقلی برای این کار ثبت نشده است'), findsOneWidget);
    expect(find.text('افراد مرتبط'), findsNothing);
    final assigneeY = scrollPosition.pixels + tester.getTopLeft(assignee).dy;

    final description = find.byKey(const ValueKey('task-detail-description-card'));
    await tester.scrollUntilVisible(description, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(description, findsOneWidget);
    expect(find.text('شرح مستقل'), findsOneWidget);
    final descriptionY = scrollPosition.pixels + tester.getTopLeft(description).dy;

    final reminders = find.byKey(const ValueKey('task-detail-independent-reminders'));
    await tester.scrollUntilVisible(reminders, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    final remindersY = scrollPosition.pixels + tester.getTopLeft(reminders).dy;

    final recurrence = find.byKey(const ValueKey('task-detail-recurrence'));
    await tester.scrollUntilVisible(recurrence, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    final recurrenceY = scrollPosition.pixels + tester.getTopLeft(recurrence).dy;

    final checklist = find.byKey(const ValueKey('task-detail-checklist'));
    await tester.scrollUntilVisible(checklist, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    final checklistY = scrollPosition.pixels + tester.getTopLeft(checklist).dy;

    final latest = find.byKey(const ValueKey('task-detail-latest-followup'));
    await tester.scrollUntilVisible(latest, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    final latestY = scrollPosition.pixels + tester.getTopLeft(latest).dy;

    final timeline = find.byKey(const ValueKey('task-detail-timeline'));
    await tester.scrollUntilVisible(timeline, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    final timelineY = scrollPosition.pixels + tester.getTopLeft(timeline).dy;

    expect(timeX, greaterThan(centerX));
    expect(centerX, greaterThan(projectX));
    expect(projectX, greaterThan(categoryX));
    expect(categoryX, greaterThan(tagsX));
    expect(metadataY, lessThan(summaryY));
    expect(summaryY, lessThan(descriptionY));
    expect(descriptionY, lessThan(templateY));
    expect(templateY, lessThan(dueY));
    expect(dueY, lessThan(assigneeY));
    expect(assigneeY, lessThan(remindersY));
    expect(remindersY, lessThan(recurrenceY));
    expect(recurrenceY, lessThan(checklistY));
    expect(checklistY, lessThan(latestY));
    expect(latestY, lessThan(timelineY));
    expect(
      tester.widget<Directionality>(
        find.ancestor(
          of: find.byKey(const ValueKey('task-detail-page')),
          matching: find.byType(Directionality),
        ).first,
      ).textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('Task Details opens checklist entry and persists a newly added item', (tester) async {
    Task? persisted;
    var saveCalls = 0;
    final task = Task(
      id: 'checklist-add-regression',
      title: 'کار با چک‌لیست تازه',
      checklistEnabled: false,
    );
    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onChecklistChanged: (candidate, checklist) async {
          saveCalls++;
          candidate.checklist = List<String>.of(checklist);
          candidate.updatedAt = DateTime.now();
          persisted = candidate;
          return candidate;
        },
      ),
    ));

    final detailScrollable = _taskDetailPageScrollable(tester);
    final addChecklist = find.byKey(const ValueKey('task-detail-add-checklist'));
    await tester.scrollUntilVisible(addChecklist, 240, scrollable: detailScrollable);
    await tester.pumpAndSettle();
    expect(addChecklist, findsOneWidget);
    await tester.tap(addChecklist);
    await tester.pumpAndSettle();

    final input = find.byKey(const ValueKey('task-detail-checklist-add-input'));
    expect(input, findsOneWidget);
    await tester.enterText(input, 'آماده‌سازی کیف');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(saveCalls, 1);
    expect(persisted?.checklist, contains('[ ] آماده‌سازی کیف'));
    expect(find.byKey(const ValueKey('task-detail-checklist')), findsOneWidget);
    expect(find.text('آماده‌سازی کیف'), findsOneWidget);
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
        onAddFollowUp: (value, followUp) async => value,
        onDelete: (value) async {},
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
    final completeButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('task-detail-complete')),
    );
    expect(completeButton.style!.backgroundColor!.resolve({}), const Color(0xFF3F3D56));
    final list = tester.widget<ListView>(find.byKey(const ValueKey('task-detail-content-list')));
    expect(list.padding, const EdgeInsets.fromLTRB(16, 14, 16, 120));
    await tester.tap(find.byKey(const ValueKey('task-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-complete')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-add-followup-bottom')), findsOneWidget);
    final followUpCenterX = tester.getCenter(find.byKey(const ValueKey('task-detail-add-followup-bottom'))).dx;
    final completeCenterX = tester.getCenter(find.byKey(const ValueKey('task-detail-complete'))).dx;
    expect(followUpCenterX, greaterThan(completeCenterX));
    expect(find.byKey(const ValueKey('task-detail-delete-menu')), findsOneWidget);
  });
}
