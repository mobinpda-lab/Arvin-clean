import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openEditor(
    WidgetTester tester, {
    Task? task,
    Size logicalSize = const Size(540, 960),
    ValueChanged<Task?>? onResult,
  }) async {
    tester.view.physicalSize = logicalSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showDialog<Task>(
                    context: context,
                    builder: (_) => ArvinTaskEditorDialog(task: task),
                  );
                  onResult?.call(result);
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
  }

  testWidgets('same canonical editor preserves full-entry Task fields',
      (tester) async {
    Task? result;
    final due = DateTime(2026, 9, 20, 14, 30);
    final reminder = DateTime(2026, 9, 20, 13, 45);
    final task = Task(
      id: 'full-entry',
      title: 'کار کامل',
      dueDate: due,
      reminderDate: reminder,
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
      ),
      priority: TaskPriority.high,
      completed: true,
    );

    await openEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    expect(find.byKey(const ValueKey('task-editor-more-details')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-due-date-rollbox')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-reminder-date-rollbox')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-recurrence')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-priority')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-completed')), findsOneWidget);

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'full-entry');
    expect(result!.dueDate, due);
    expect(result!.reminderDate, reminder);
    expect(result!.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(result!.recurrence?.interval, 2);
    expect(result!.priority, TaskPriority.high);
    expect(result!.completed, isTrue);
  });

  testWidgets('full-entry controls remain scroll-accessible on short RTL viewport',
      (tester) async {
    await openEditor(
      tester,
      logicalSize: const Size(360, 560),
    );

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-title')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-more-details')));
    await tester.pumpAndSettle();

    final priority = find.byKey(const ValueKey('task-editor-priority'));
    await tester.ensureVisible(priority);
    await tester.pumpAndSettle();
    expect(priority, findsOneWidget);

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    expect(save, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hiding keyboard keeps draft and one save returns one Task',
      (tester) async {
    final results = <Task?>[];
    await openEditor(
      tester,
      onResult: results.add,
    );

    final title = find.byKey(const ValueKey('task-editor-title'));
    await tester.enterText(title, 'پیش‌نویس حفظ شود');
    await tester.pump();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    expect(find.text('پیش‌نویس حفظ شود'), findsOneWidget);
    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(results, hasLength(1));
    expect(results.single, isNotNull);
    expect(results.single!.title, 'پیش‌نویس حفظ شود');
  });

  testWidgets('custom due time opens the circular Clock Dial and preserves the task time',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'custom-time',
      title: 'زمان سفارشی',
      dueDate: DateTime(2026, 9, 20, 14, 30),
    );

    await openEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    final timeBox =
        find.byKey(const ValueKey('task-editor-due-time-rollbox'));
    await tester.ensureVisible(timeBox);
    await tester.tap(timeBox);
    await tester.pumpAndSettle();

    final customTime = find.text('ساعت سفارشی');
    expect(customTime, findsOneWidget);
    await tester.ensureVisible(customTime);
    await tester.tap(customTime);
    await tester.pumpAndSettle();

    // The owner-accepted product contract uses Flutter's circular Clock Dial;
    // the old custom RollBox confirmation dialog must no longer be expected.
    expect(find.byKey(const ValueKey('task-editor-time-confirm')), findsNothing);
    expect(find.text('۱۴:۳۰'), findsWidgets);

    // Close the canonical time picker without changing the selected time.
    final cancel = find.text('لغو');
    expect(cancel, findsOneWidget);
    await tester.tap(cancel);
    await tester.pumpAndSettle();

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, DateTime(2026, 9, 20, 14, 30));
  });

  testWidgets('date-only due date persists as explicit All-Day without a time', (tester) async {
    Task? result;
    await openEditor(tester, onResult: (value) => result = value);

    final dateBox = find.byKey(const ValueKey('task-editor-due-date-rollbox'));
    await tester.ensureVisible(dateBox);
    await tester.tap(dateBox);
    await tester.pumpAndSettle();

    final today = find.text('امروز');
    expect(today, findsOneWidget);
    await tester.tap(today);
    await tester.pumpAndSettle();

    final allDay = find.byKey(const ValueKey('task-editor-due-all-day'));
    await tester.ensureVisible(allDay);
    await tester.pumpAndSettle();
    final allDayTile = tester.widget<CheckboxListTile>(allDay);
    expect(allDayTile.value, isTrue);

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, isNotNull);
    expect(result!.allDay, isTrue);
    expect(result!.dueDate!.hour, 0);
    expect(result!.dueDate!.minute, 0);
  });

  testWidgets('full Task editor adds independent reminders without replacing legacy reminder', (tester) async {
    Task? result;
    final legacyDate = DateTime(2026, 10, 20, 9, 30);
    final task = Task(
      id: 'editor-multi',
      title: 'خرید فرش',
      reminderDate: legacyDate,
      followUps: [
        FollowUp(
          id: 'follow-up-preserved',
          dateTime: DateTime(2026, 10, 18, 12),
          nextFollowUp: DateTime(2026, 10, 25, 10),
        ),
      ],
    );
    await openEditor(tester, task: task, onResult: (value) => result = value);

    final add = find.byKey(const ValueKey('task-editor-add-reminder'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.reminderDate, legacyDate);
    expect(result!.taskReminders, hasLength(2));
    expect(result!.taskReminders.map((item) => item.sequence), [1, 2]);
    expect(result!.taskReminders.map((item) => item.id).toSet().length, 2);
    expect(result!.taskReminders.first.title, 'خرید فرش — یادآور ۱');
    expect(result!.nextReminderSequence, 3);
    expect(result!.followUps.single.nextFollowUp, DateTime(2026, 10, 25, 10));
  });

  testWidgets('editing or deleting one reminder leaves other reminders and nextFollowUp intact', (tester) async {
    Task? result;
    final nextFollowUp = DateTime(2026, 10, 25, 10);
    final task = Task(
      id: 'editor-independent',
      title: 'جلسه',
      reminderDate: DateTime(2026, 10, 20, 9),
      taskReminders: [
        TaskReminder(
          id: 'keep-reminder',
          taskId: 'editor-independent',
          title: 'اول',
          date: DateTime(2026, 10, 21, 10),
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 1),
          sequence: 1,
        ),
        TaskReminder(
          id: 'remove-reminder',
          taskId: 'editor-independent',
          title: 'دوم',
          date: DateTime(2026, 10, 22, 11),
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 1),
          sequence: 2,
        ),
      ],
      nextReminderSequence: 3,
      followUps: [
        FollowUp(
          id: 'follow-up-preserved',
          dateTime: DateTime(2026, 10, 18, 12),
          nextFollowUp: nextFollowUp,
        ),
      ],
    );
    await openEditor(tester, task: task, onResult: (value) => result = value);

    final title = find.byKey(const ValueKey('task-editor-reminder-title-keep-reminder'));
    await tester.ensureVisible(title);
    await tester.enterText(title, 'عنوان تغییرکرده');
    await tester.pump();
    final remove = find.byKey(const ValueKey('task-editor-remove-reminder-remove-reminder'));
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.taskReminders, hasLength(1));
    expect(result!.taskReminders.single.id, 'keep-reminder');
    expect(result!.taskReminders.single.title, 'عنوان تغییرکرده');
    expect(result!.reminderDate, DateTime(2026, 10, 20, 9));
    expect(result!.followUps.single.nextFollowUp, nextFollowUp);
    expect(result!.nextReminderSequence, 3);
  });


  testWidgets('deleting migrated legacy reminder clears compatibility mirror on save', (tester) async {
    Task? result;
    final task = Task.fromJson(<String, dynamic>{
      'id': 'migrated-editor',
      'title': 'کار قدیمی',
      'reminderDate': '2026-10-20T09:30:00.000',
    });
    expect(task.taskReminders, hasLength(1));
    expect(task.legacyReminderMigrationCompleted, isTrue);

    await openEditor(tester, task: task, onResult: (value) => result = value);
    final reminderId = task.taskReminders.single.id;
    final remove = find.byKey(
      ValueKey('task-editor-remove-reminder-$reminderId'),
    );
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();

    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.taskReminders, isEmpty);
    expect(result!.reminderDate, isNull);
    expect(result!.legacyReminderMigrationCompleted, isTrue);
    expect(result!.nextReminderSequence, 2);
  });


  testWidgets('full editor adds a real FollowUp record without a flag',
      (tester) async {
    Task? result;
    await openEditor(tester, onResult: (value) => result = value);

    expect(
      find.byKey(const ValueKey('task-editor-followup-enabled')),
      findsNothing,
    );
    final add = find.byKey(const ValueKey('task-editor-add-follow-up'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'تماس با مشتری');
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    expect(find.text('تماس با مشتری'), findsOneWidget);
    final save = find.byKey(const ValueKey('task-editor-header-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUps, hasLength(1));
    expect(result!.followUps.single.note, 'تماس با مشتری');
    expect(result!.followUpEnabled, isTrue);
  });


}
