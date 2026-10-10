import 'package:arvin/models/task.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpEditor(
    WidgetTester tester, {
    Task? task,
    List<String> knownTags = const [],
    ValueChanged<Task?>? onResult,
  }) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2;
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
                    builder: (_) => ArvinTaskEditorDialog(task: task, knownTags: knownTags),
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

  testWidgets('existing follow-up task shows explicit toggle and date plus time',
      (tester) async {
    final task = Task(
      id: '1',
      title: 'تماس با علی',
      description: 'پیگیری مشتری',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 27, 10, 30),
      tags: const ['مشتری'],
    );

    await pumpEditor(tester, task: task);

    expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);
    expect(find.text('کار پیگیری‌دار'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-enabled')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-date-rollbox')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-time-rollbox')), findsOneWidget);
    expect(find.text('۱۴۰۵/۰۶/۰۵'), findsOneWidget);
    expect(find.text('۱۰:۳۰'), findsOneWidget);
    expect(find.text('مشتری'), findsOneWidget);

    final save = tester.widget<FilledButton>(
      find.byKey(const ValueKey('task-editor-header-save')),
    );
    expect(save.style?.backgroundColor?.resolve({}), const Color(0xFF4A4CAB));
  });

  testWidgets('editing and saving preserves the exact existing follow-up time',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'edit',
      title: 'جلسه',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 27, 10, 30),
    );

    await pumpEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.followUpEnabled, isTrue);
    expect(result!.followUpDate, DateTime(2026, 8, 27, 10, 30));
  });

  testWidgets('changing Jalali date preserves the selected hour and minute',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'date-change',
      title: 'جلسه',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 27, 10, 30),
    );

    await pumpEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-followup-date-rollbox')));
    await tester.tap(find.byKey(const ValueKey('task-editor-followup-date-rollbox')));
    await tester.pumpAndSettle();
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('فردا'), findsOneWidget);

    await tester.tap(find.text('فردا'));
    await tester.pumpAndSettle();

    expect(find.text('۱۰:۳۰'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpDate, isNotNull);
    expect(result!.followUpDate!.hour, 10);
    expect(result!.followUpDate!.minute, 30);
  });

  testWidgets('new ordinary task keeps follow-up controls hidden until enabled',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    expect(find.text('کار پیگیری‌دار'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-date-rollbox')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-followup-time-rollbox')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'کار بدون پیگیری',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpEnabled, isFalse);
    expect(result!.followUpDate, isNull);
  });

  testWidgets('enabling follow-up converts the same task and prefills a time',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-followup-enabled')));
    await tester.tap(find.byKey(const ValueKey('task-editor-followup-enabled')));
    await tester.pump();

    expect(find.byKey(const ValueKey('task-editor-followup-date-rollbox')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-followup-time-rollbox')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'کار پیگیری‌دار جدید',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpEnabled, isTrue);
    expect(result!.followUpDate, isNotNull);
  });

  testWidgets('disabling future follow-up never erases existing history',
      (tester) async {
    Task? result;
    final history = [
      FollowUp(
        id: 'f1',
        dateTime: DateTime(2026, 8, 20, 9),
        note: 'تماس اول',
      ),
      FollowUp(
        id: 'f2',
        dateTime: DateTime(2026, 8, 22, 11, 15),
        note: 'تماس دوم',
      ),
    ];
    final task = Task(
      id: 'history',
      title: 'پرونده مشتری',
      followUpEnabled: true,
      followUpDate: DateTime(2026, 8, 28, 12),
      followUps: history,
      category: 'مشتریان',
      checklist: const ['[ ] ارسال قرارداد'],
    );

    await pumpEditor(
      tester,
      task: task,
      onResult: (value) => result = value,
    );

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-followup-enabled')));
    await tester.tap(find.byKey(const ValueKey('task-editor-followup-enabled')));
    await tester.pump();
    expect(find.text('سوابق پیگیری قبلی حفظ می‌شوند.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'history');
    expect(result!.followUpEnabled, isFalse);
    expect(result!.followUpDate, isNull);
    expect(result!.followUps, hasLength(2));
    expect(result!.followUps.last.note, 'تماس دوم');
    expect(result!.category, 'مشتریان');
    expect(result!.checklist, const ['[ ] ارسال قرارداد']);
  });
  testWidgets('Back-style close prompts and can save Task edits without data loss',
      (tester) async {
    Task? result;
    await pumpEditor(tester, knownTags: const ['فوری'], onResult: (value) => result = value);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'کار ذخیره‌شده هنگام خروج',
    );
    await tester.tap(find.byTooltip('برچسب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فوری'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعمال'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('بستن'));
    await tester.pumpAndSettle();

    expect(find.text('تغییرات ذخیره نشده'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-editor-exit-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.title, 'کار ذخیره‌شده هنگام خروج');
    expect(result!.tags, contains('فوری'));
  });

  testWidgets('explicit Task cancel remains zero-write', (tester) async {
    Task? result = Task(id: 'sentinel', title: 'sentinel');
    await pumpEditor(tester, onResult: (value) => result = value);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'نباید ذخیره شود',
    );
    await tester.tap(find.byTooltip('بستن'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-editor-exit-discard')));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text('تغییرات ذخیره نشده'), findsNothing);
  });

  testWidgets('new Task keeps checklist disabled until explicitly enabled', (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);
    expect(find.byKey(const ValueKey('task-editor-checklist-toggle')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('task-editor-checklist-toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('task-editor-checklist-input')), 'کیف');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.checklist, const ['[ ] کیف']);
    expect(result!.checklistEnabled, isTrue);
  });

  testWidgets('disabling a checklist preserves its rows and re-enabling restores them',
      (tester) async {
    Task? disabledResult;
    final task = Task(id: 'checklist-toggle', title: 'آماده‌سازی', checklist: const ['[ ] کیف', '[ ] کتاب']);
    await pumpEditor(tester, task: task, onResult: (value) => disabledResult = value);
    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-editor-checklist-toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();
    expect(disabledResult, isNotNull);
    expect(disabledResult!.checklist, const ['[ ] کیف', '[ ] کتاب']);
    expect(disabledResult!.checklistEnabled, isFalse);

    Task? enabledResult;
    await pumpEditor(tester, task: disabledResult, onResult: (value) => enabledResult = value);
    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('task-editor-checklist-toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsOneWidget);
    expect(find.text('کیف'), findsOneWidget);
    expect(find.text('کتاب'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();
    expect(enabledResult, isNotNull);
    expect(enabledResult!.checklist, const ['[ ] کیف', '[ ] کتاب']);
    expect(enabledResult!.checklistEnabled, isTrue);
  });

  testWidgets('task editor checklist supports add, toggle, edit and persistence',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'checklist-task',
      title: 'آماده‌سازی مدرسه',
      checklist: const ['[ ] کیف', '[x] خوراکی'],
    );

    await pumpEditor(tester, task: task, onResult: (value) => result = value);

    expect(find.byKey(const ValueKey('task-editor-checklist-block')), findsOneWidget);
    expect(find.text('کیف'), findsOneWidget);
    expect(find.text('خوراکی'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('task-editor-checklist-check-0')),
    );
    await tester.tap(
      find.byKey(const ValueKey('task-editor-checklist-check-0')),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-checklist-input')),
      'لباس',
    );
    await tester.tap(
      find.byKey(const ValueKey('task-editor-checklist-add')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('task-editor-checklist-edit-1')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-editor-checklist-edit-input')),
      'خوراکی اصلاح‌شده',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-checklist-edit-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.checklist, const [
      '[x] کیف',
      '[x] خوراکی اصلاح‌شده',
      '[ ] لباس',
    ]);
  });

  testWidgets('task editor checklist supports drag reorder', (tester) async {
    final task = Task(
      id: 'drag-checklist-task',
      title: 'ترتیب',
      checklist: const ['[ ] اول', '[ ] دوم', '[ ] سوم'],
    );
    await pumpEditor(tester, task: task);

    final handle = find.byKey(const ValueKey('task-editor-checklist-drag-1'));
    await tester.ensureVisible(handle);
    await tester.timedDrag(handle, const Offset(0, 120), const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final item0 = find.byKey(const ValueKey('task-editor-checklist-item-0'));
    final item1 = find.byKey(const ValueKey('task-editor-checklist-item-1'));
    expect(item0, findsOneWidget);
    expect(item1, findsOneWidget);
  });

  testWidgets('task editor recurrence uses RollBox and preserves interval', (tester) async {
    Task? result;
    final task = Task(
      id: 'recurrence-rollbox',
      title: 'کار تکرارشونده',
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      ),
    );

    await pumpEditor(tester, task: task, onResult: (value) => result = value);

    final rollBox = find.byKey(const ValueKey('task-editor-recurrence'));
    expect(rollBox, findsOneWidget);
    expect(find.text('روزانه'), findsWidgets);

    await tester.ensureVisible(rollBox);
    await tester.tap(rollBox);
    await tester.pumpAndSettle();

    expect(find.text('بدون تکرار'), findsOneWidget);
    expect(find.text('روزانه'), findsWidgets);
    expect(find.text('هفتگی'), findsOneWidget);

    await tester.tap(find.text('هفتگی').last);
    await tester.pumpAndSettle();
    expect(find.text('هفتگی'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.recurrence, isNotNull);
    expect(result!.recurrence!.frequency, RecurrenceFrequency.weekly);
    expect(result!.recurrence!.interval, 2);
  });


  testWidgets('task editor exposes repeat lifecycle settings and preserves definition', (tester) async {
    Task? result;
    final task = Task(
      id: 'repeat-lifecycle',
      title: 'کار تکرارشونده',
      recurrence: RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        startDate: DateTime(2026, 10, 10),
        endDate: DateTime(2026, 12, 31),
        count: 7,
        active: true,
      ),
    );

    await pumpEditor(tester, task: task, onResult: (value) => result = value);

    expect(find.byKey(const ValueKey('task-editor-repeat-enabled')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-repeat-start')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-repeat-end')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-recurrence-count')), findsOneWidget);

    final count = find.byKey(const ValueKey('task-editor-recurrence-count'));
    await tester.enterText(count, '7');

    await tester.tap(find.byKey(const ValueKey('task-editor-repeat-enabled')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.recurrence, isNotNull);
    expect(result!.recurrence!.frequency, RecurrenceFrequency.weekly);
    expect(result!.recurrence!.interval, 2);
    expect(result!.recurrence!.startDate, DateTime(2026, 10, 10));
    expect(result!.recurrence!.endDate, DateTime(2026, 12, 31));
    expect(result!.recurrence!.count, 7);
    expect(result!.recurrence!.active, isFalse);
  });

  testWidgets('timed task automatically gets one reminder at the same time',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'کار زمان‌دار',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('task-editor-due-time-rollbox')),
    );
    await tester.tap(
      find.byKey(const ValueKey('task-editor-due-time-rollbox')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('۱۰:۳۰'));
    await tester.tap(find.text('۱۰:۳۰'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, isNotNull);
    expect(result!.allDay, isFalse);
    expect(result!.reminderDate, result!.dueDate);
  });

  testWidgets('manual reminder is not overwritten when due time changes',
      (tester) async {
    Task? result;
    final task = Task(
      id: 'manual-reminder',
      title: 'کار با یادآوری دستی',
      dueDate: DateTime(2026, 8, 27, 10),
      reminderDate: DateTime(2026, 8, 27, 9),
      allDay: false,
    );

    await pumpEditor(tester, task: task, onResult: (value) => result = value);

    await tester.ensureVisible(
      find.byKey(const ValueKey('task-editor-due-time-rollbox')),
    );
    await tester.tap(
      find.byKey(const ValueKey('task-editor-due-time-rollbox')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('۱۱:۰۰'));
    await tester.tap(find.text('۱۱:۰۰'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, DateTime(2026, 8, 27, 11));
    expect(result!.reminderDate, DateTime(2026, 8, 27, 9));
  });

}
