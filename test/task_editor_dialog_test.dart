import 'package:arvin/models/task.dart';
import 'package:arvin/arvin_colors.dart';
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
    Size logicalSize = const Size(390, 844),
  }) async {
    tester.view.physicalSize = Size(logicalSize.width * 2, logicalSize.height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3A86EF),
          ).copyWith(primary: const Color(0xFF3A86EF)),
        ),
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

  testWidgets('Task editor five filters stay in one row at large text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpEditor(tester, logicalSize: const Size(320, 640));
    final row = find.byKey(const ValueKey('task-editor-five-filter-row'));
    expect(row, findsOneWidget);
    final filters = [
      'task-editor-due-date-time',
      'task-editor-center-rollbox',
      'task-editor-project-rollbox',
      'task-editor-category-rollbox',
      'task-editor-tag-rollbox',
    ].map((key) => find.byKey(ValueKey(key))).toList();
    final first = tester.getRect(filters.first);
    for (final filter in filters) {
      expect(filter, findsOneWidget);
      expect(tester.getRect(filter).height, greaterThanOrEqualTo(48));
      expect(tester.getRect(filter).top, closeTo(first.top, 0.1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Task editor stays responsive at 360/390/412dp with keyboard open and closed',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpEditor(tester, logicalSize: const Size(390, 844));

    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width * 2, 844 * 2);
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-editor-category-rollbox')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-editor-project-rollbox')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-editor-tag-rollbox')), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-editor-title')), findsOneWidget);
      expect(find.byKey(const ValueKey('task-editor-due-date-time')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    tester.view.resetViewInsets();
  });

  testWidgets('Task editor five filters remain single-row at 360/390/412dp', (tester) async {
    Task? result;
    await pumpEditor(
      tester,
      logicalSize: const Size(320, 640),
      onResult: (value) => result = value,
    );

    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width * 2, 640 * 2);
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();
      final row = find.byKey(const ValueKey('task-editor-five-filter-row'));
      expect(row, findsOneWidget);
      final rowRect = tester.getRect(row);
      expect(find.descendant(of: row, matching: find.byType(Scrollable)), findsNothing);
      expect(find.byKey(const ValueKey('task-editor-due-no-time')), findsNothing);
      expect(find.text('بدون ساعت'), findsNothing);
      final keys = [
        'task-editor-due-date-time',
        'task-editor-center-rollbox',
        'task-editor-project-rollbox',
        'task-editor-category-rollbox',
        'task-editor-tag-rollbox',
      ];
      final rects = keys.map((key) => tester.getRect(find.byKey(ValueKey(key)))).toList();
      for (final rect in rects) {
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.top, closeTo(rects.first.top, 0.1));
        expect(rect.left, greaterThanOrEqualTo(rowRect.left));
        expect(rect.right, lessThanOrEqualTo(rowRect.right));
      }
      expect(rects[0].center.dx, greaterThan(rects[1].center.dx));
      expect(rects[1].center.dx, greaterThan(rects[2].center.dx));
      expect(rects[2].center.dx, greaterThan(rects[3].center.dx));
      expect(rects[3].center.dx, greaterThan(rects[4].center.dx));
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
  });

  testWidgets('full Task form exposes canonical follow-up records instead of a toggle',
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
    expect(find.text('پیگیری‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-add-followup')), findsOneWidget);
    expect(find.text('کار پیگیری‌دار'), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-followup-enabled')), findsNothing);
    expect(find.text('زمان پیگیری'), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-followup-date-rollbox')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-followup-time-rollbox')), findsNothing);
    expect(find.text('مشتری'), findsOneWidget);

    final save = tester.widget<IconButton>(
      find.byKey(const ValueKey('task-editor-header-save')),
    );
    expect(save.onPressed, isNotNull);
    expect(save.color, const Color(0xFF3A86EF));
    expect(tester.widget<Icon>(find.descendant(
      of: find.byKey(const ValueKey('task-editor-header-save')),
      matching: find.byIcon(Icons.check_rounded),
    )).icon, Icons.check_rounded);
  });

  testWidgets('saving an ordinary Task does not invent follow-up records or timestamps',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUpEnabled, isFalse);
    expect(result!.followUpDate, isNull);
    expect(result!.followUps, isEmpty);
    expect(result!.priority, TaskPriority.medium);
  });


  testWidgets('Task editor saves a new follow-up record with separate title and note',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-add-followup')));
    await tester.tap(find.byKey(const ValueKey('task-editor-add-followup')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('follow-up-entry-title')),
      'تماس مجدد',
    );
    await tester.enterText(
      find.byKey(const ValueKey('follow-up-entry-note')),
      'در انتظار ارسال پاسخ',
    );
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.followUps, hasLength(1));
    expect(result!.followUps.single.title, 'تماس مجدد');
    expect(result!.followUps.single.note, 'در انتظار ارسال پاسخ');
    expect(result!.followUpEnabled, isFalse);
    expect(result!.followUpDate, isNull);
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

  testWidgets('new ordinary Task exposes the follow-up list without inventing records',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    expect(find.text('پیگیری‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-add-followup')), findsOneWidget);
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

  testWidgets('editing Task preserves legacy state and all existing follow-up history',
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

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'history');
    expect(result!.followUpEnabled, isTrue);
    expect(result!.followUpDate, DateTime(2026, 8, 28, 12));
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
    final tagPill = find.text('برچسب');
    await tester.ensureVisible(tagPill);
    await tester.tap(tagPill);
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
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-checklist-toggle')));
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
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-checklist-toggle')));
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
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-checklist-toggle')));
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

    final repeatEnabled = find.byKey(const ValueKey('task-editor-repeat-enabled'));
    await tester.ensureVisible(repeatEnabled);
    await tester.tap(repeatEnabled);
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
    final unified = find.byKey(const ValueKey('task-editor-due-date-time'));
    await tester.ensureVisible(unified);
    await tester.tap(unified);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-hour-outer-10')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('universal-time-minute-30')));
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
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

    final dateTimeButton = find.byKey(const ValueKey('task-editor-due-date-time'));
    await tester.ensureVisible(dateTimeButton);
    await tester.tap(dateTimeButton);
    await tester.pumpAndSettle();
    final datePicker = find.byKey(const ValueKey('persian-date-picker'));
    expect(datePicker, findsOneWidget);
    await tester.tap(find.descendant(
      of: datePicker,
      matching: find.text('انتخاب تاریخ'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-hour-outer-11')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('universal-time-minute-0')));
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, DateTime(2026, 8, 27, 11));
    expect(result!.reminderDate, DateTime(2026, 8, 27, 9));
  });

  testWidgets('new Task uses one date-time entry and the approved circular clock',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    final unified = find.byKey(const ValueKey('task-editor-due-date-time'));
    expect(unified, findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-due-no-time')), findsNothing);
    expect(find.text('بدون ساعت'), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-due-date-rollbox')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-due-time-button')), findsNothing);
    expect(find.byKey(const ValueKey('task-editor-due-time-rollbox')), findsNothing);

    await tester.ensureVisible(unified);
    await tester.tap(unified);
    await tester.pumpAndSettle();
    await tester.tap(find.text('انتخاب تاریخ و ساعت'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-hour-outer-10')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('universal-time-minute-30')));
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, isNotNull);
    expect(result!.dueDate!.hour, 10);
    expect(result!.dueDate!.minute, 30);
    expect(result!.allDay, isFalse);
    expect(result!.reminderDate, result!.dueDate);
  });

  testWidgets('Task editor saves a real all-day deadline from inside the clock dialog',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);
    final unified = find.byKey(const ValueKey('task-editor-due-date-time'));
    await tester.ensureVisible(unified);
    await tester.tap(unified);
    await tester.pumpAndSettle();
    await tester.tap(find.text('انتخاب تاریخ و ساعت'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('universal-time-no-time')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, isNotNull);
    expect(result!.dueDate!.hour, 0);
    expect(result!.dueDate!.minute, 0);
    expect(result!.allDay, isTrue);
    expect(result!.reminderDate, isNull);
  });


  testWidgets('new Task keeps due date and reminder absent when the unified control is untouched',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);

    expect(find.byKey(const ValueKey('task-editor-due-date-time')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.dueDate, isNull);
    expect(result!.allDay, isFalse);
    expect(result!.reminderDate, isNull);
  });

  testWidgets('Task editor priority labels wrap safely at narrow width',
      (tester) async {
    Task? result;
    await pumpEditor(
      tester,
      logicalSize: const Size(320, 800),
      onResult: (value) => result = value,
    );
    final row = find.byKey(const ValueKey('task-editor-priority'));
    await tester.ensureVisible(row);
    expect(row, findsOneWidget);

    final keys = [
      'task-editor-priority-high',
      'task-editor-priority-medium',
      'task-editor-priority-low',
      'task-editor-priority-none',
    ];
    final rects = <Rect>[];
    for (final key in keys) {
      final finder = find.byKey(ValueKey(key));
      expect(finder, findsOneWidget);
      rects.add(tester.getRect(finder));
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
    }
    final rowTops = rects.map((rect) => rect.top).toSet();
    expect(rowTops.length, greaterThan(1));
    expect(rowTops.length, lessThanOrEqualTo(2));
    for (final rect in rects) {
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
    }
    expect(rects.every((rect) => rect.width >= 48), isTrue);
    for (final label in ['اولویت ۱', 'اولویت ۲', 'اولویت ۳', 'اولویت ۴']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final description in [
      'اولویت ۱ — فوری و مهم',
      'اولویت ۲ — مهم، غیرفوری',
      'اولویت ۳ — فوری، غیرمهم',
      'اولویت ۴ — غیرفوری و غیرمهم',
    ]) {
      expect(find.byTooltip(description), findsOneWidget);
    }
    expect(find.text('P1'), findsNothing);
    expect(find.text('P2'), findsNothing);
    expect(find.text('P3'), findsNothing);
    expect(find.text('P4'), findsNothing);
    expect(tester.takeException(), isNull);

    final p2 = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('task-editor-priority-medium')),
    );
    expect(p2.selected, isTrue);
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('task-editor-priority-high'))).side?.color, ArvinColors.priorityP1.withValues(alpha: 0.35));
    expect(p2.side?.color, ArvinColors.priorityP2.withValues(alpha: 0.9));
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('task-editor-priority-low'))).side?.color, ArvinColors.priorityP3.withValues(alpha: 0.35));
    expect(tester.widget<ChoiceChip>(find.byKey(const ValueKey('task-editor-priority-none'))).side?.color, ArvinColors.priorityP4.withValues(alpha: 0.35));
    await tester.tap(find.byKey(const ValueKey('task-editor-priority-high')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.priority, TaskPriority.high);
  });

  testWidgets('Task editor cancelling the circular clock does not commit a partial date',
      (tester) async {
    Task? result;
    await pumpEditor(tester, onResult: (value) => result = value);
    final unified = find.byKey(const ValueKey('task-editor-due-date-time'));
    await tester.ensureVisible(unified);
    await tester.tap(unified);
    await tester.pumpAndSettle();
    await tester.tap(find.text('انتخاب تاریخ و ساعت'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.dueDate, isNull);
    expect(result!.allDay, isFalse);
    expect(result!.reminderDate, isNull);
  });


  testWidgets('Task editor remains scrollable without overflow with the mobile keyboard open',
      (tester) async {
    await pumpEditor(tester, logicalSize: const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    final title = find.byKey(const ValueKey('task-editor-title'));
    await tester.ensureVisible(title);
    expect(find.byKey(const ValueKey('task-editor-due-date-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-editor-center-rollbox')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
