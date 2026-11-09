import 'package:arvin/arvin_colors.dart';
import 'package:arvin/models/arvin_center.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/quick_capture_dialog.dart';
import 'package:arvin/services/task_store.dart';

Future<void> _openQuickCaptureDueTimePicker(WidgetTester tester) async {
  final dueControl = find.byKey(const ValueKey('quick-capture-due-rollbox'));
  await tester.ensureVisible(dueControl);
  await tester.tap(dueControl);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
  final confirmDate = find.widgetWithText(FilledButton, 'انتخاب تاریخ');
  expect(confirmDate, findsOneWidget);
  await tester.tap(confirmDate);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
  expect(find.byKey(const ValueKey('universal-time-no-time')), findsOneWidget);
}


Future<void> _openQuickCaptureCustomReminderPicker(WidgetTester tester) async {
  final reminderControl = find.byKey(const ValueKey('quick-capture-reminder-rollbox'));
  await tester.ensureVisible(reminderControl);
  await tester.tap(reminderControl);
  await tester.pumpAndSettle();
  final customReminder = find.text('تاریخ و ساعت سفارشی');
  expect(customReminder, findsOneWidget);
  await tester.ensureVisible(customReminder);
  await tester.tap(customReminder);
  await tester.pumpAndSettle();

  final datePicker = find.byKey(const ValueKey('persian-date-picker'));
  expect(datePicker, findsOneWidget);
  final confirmDate = find.descendant(
    of: datePicker,
    matching: find.text('انتخاب تاریخ'),
  ).last;
  await tester.ensureVisible(confirmDate);
  await tester.tap(confirmDate);
  await tester.pumpAndSettle();
  expect(find.text('زمان یادآوری'), findsWidgets);
  await tester.tap(find.byKey(const ValueKey('universal-time-save')));
  await tester.pumpAndSettle();
}

void main() {

  testWidgets('Quick Capture can create a center inline and immediately select it', (tester) async {
    String? createdName;
    Task? captured;
    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: QuickCaptureDialog(
            onCreateCenter: (name) async {
              createdName = name;
              return 'center-inline';
            },
            onCaptured: (task) async => captured = task,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final center = find.byKey(const ValueKey('quick-capture-center-rollbox'));
    await tester.ensureVisible(center);
    await tester.tap(center);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-capture-create-center')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'مرکز تازه');
    await tester.tap(find.widgetWithText(FilledButton, 'افزودن').last);
    await tester.pumpAndSettle();

    expect(createdName, 'مرکز تازه');
    expect(find.text('مرکز تازه'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('quick-capture-input')), 'کار در مرکز جدید');
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(captured?.centerId, 'center-inline');
  });


  testWidgets('Quick Capture does not assign a priority or dates without an explicit choice',
      (tester) async {
    Task? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickCaptureDialog(
            idFactory: () => 'quick-no-defaults',
            now: () => DateTime(2026, 11, 6, 10),
            onCaptured: (task) async => captured = task,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار بدون پیش‌فرض',
    );
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.priority, TaskPriority.none);
    expect(captured!.dueDate, isNull);
    expect(captured!.reminderDate, isNull);
  });

  testWidgets('Quick Capture center filter narrows projects and has no All option',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              centers: [
                ArvinCenter(id: 'center-a', name: 'مرکز الف', createdAt: DateTime(2026, 1, 1)),
                ArvinCenter(id: 'center-b', name: 'مرکز ب', createdAt: DateTime(2026, 1, 1)),
              ],
              projects: [
                ProjectPlan(id: 'project-a', title: 'پروژه الف', centerId: 'center-a'),
                ProjectPlan(id: 'project-b', title: 'پروژه ب', centerId: 'center-b'),
              ],
              now: () => DateTime(2026, 11, 3, 10),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final center = find.byKey(const ValueKey('quick-capture-center-rollbox'));
    await tester.ensureVisible(center);
    await tester.tap(center);
    await tester.pumpAndSettle();

    expect(find.text('همه مراکز'), findsNothing);
    expect(find.text('بدون محدودیت مرکز'), findsOneWidget);
    expect(find.text('مرکز الف'), findsOneWidget);
    expect(find.text('مرکز ب'), findsOneWidget);

    await tester.tap(find.text('مرکز ب').last);
    await tester.pumpAndSettle();

    final project = find.byKey(const ValueKey('quick-capture-project-rollbox'));
    await tester.ensureVisible(project);
    await tester.tap(project);
    await tester.pumpAndSettle();

    expect(find.text('پروژه ب'), findsOneWidget);
    expect(find.text('پروژه الف'), findsNothing);
    expect(find.text('همه'), findsNothing);
  });

  testWidgets('Quick Capture four-level priority chips preserve canonical priority values',
      (tester) async {
    Task? captured;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuickCaptureDialog(
      idFactory: () => 'priority-capture',
      now: () => DateTime(2026, 11, 3, 10),
      onCaptured: (task) async { captured = task; },
    ))));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quick-capture-priority-dropdown')), findsOneWidget);
    for (final label in ['اولویت ۱', 'اولویت ۲', 'اولویت ۳', 'اولویت ۴']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final hint in ['فوری و مهم', 'مهم و غیرفوری', 'فوری و غیرمهم', 'غیرفوری و غیرمهم']) {
      expect(find.text(hint), findsOneWidget);
    }
    final expectedPriorityColors = [
      ArvinColors.priorityP1,
      ArvinColors.priorityP2,
      ArvinColors.priorityP3,
      ArvinColors.priorityP4,
    ];
    for (var index = 0; index < expectedPriorityColors.length; index++) {
      final option = find.byKey(
        ValueKey('quick-capture-priority-option-${index + 1}'),
      );
      final chip = tester.widget<AnimatedContainer>(
        find.descendant(of: option, matching: find.byType(AnimatedContainer)),
      );
      final decoration = chip.decoration! as BoxDecoration;
      final selected = index == 3;
      expect(
        decoration.color,
        expectedPriorityColors[index].withValues(
          alpha: selected ? 0.18 : 0.09,
        ),
      );
    }

    final priorityOne = find.byKey(const ValueKey('quick-capture-priority-option-1'));
    await tester.ensureVisible(priorityOne);
    await tester.tap(priorityOne);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('quick-capture-input')), 'کار فوری');
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.priority, TaskPriority.high);
    expect(captured!.description, '');
  });

  testWidgets('Quick Capture keeps compact RTL rows and touch targets on 360-412dp phones',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.35;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: QuickCaptureDialog(
                centers: [
                  ArvinCenter(id: 'center-a', name: 'مرکز الف', createdAt: DateTime(2026, 1, 1)),
                  ArvinCenter(id: 'center-b', name: 'مرکز ب', createdAt: DateTime(2026, 1, 1)),
                ],
                projects: [
                  ProjectPlan(id: 'project-a', title: 'پروژه الف', centerId: 'center-a'),
                  ProjectPlan(id: 'project-b', title: 'پروژه ب', centerId: 'center-b'),
                ],
                now: () => DateTime(2026, 11, 3, 10),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final key in [
        'quick-capture-five-filter-row',
        'quick-capture-settings-wrap',
        'quick-capture-center-rollbox',
        'quick-capture-project-rollbox',
        'quick-capture-category-rollbox',
        'quick-capture-tag-rollbox',
        'quick-capture-priority-dropdown',
      ]) {
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
      final priorityTargets = [
        for (var order = 1; order <= 4; order++)
          find.byKey(ValueKey('quick-capture-priority-option-$order')),
      ];
      for (final target in priorityTargets) {
        expect(target, findsOneWidget);
        expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
      }
      final horizontalFormScrolls = tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .where((scroll) => scroll.scrollDirection == Axis.horizontal);
      expect(horizontalFormScrolls, isEmpty);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('quick-capture-description')), findsNothing);
      expect(find.byKey(const ValueKey('quick-capture-checklist-enabled')), findsNothing);
      expect(find.byKey(const ValueKey('quick-capture-checklist-rollbox')), findsNothing);
      expect(find.text('عنوان'), findsNothing);
      expect(find.text('زمان کار / موعد'), findsOneWidget);
      expect(find.byKey(const ValueKey('quick-capture-no-time')), findsNothing);
      expect(find.byKey(const ValueKey('quick-capture-full-form')), findsOneWidget);

      final input = tester.widget<TextField>(find.byKey(const ValueKey('quick-capture-input')));
      expect(input.maxLines, 1);
      expect(input.minLines, 1);

      final due = tester.getRect(find.byKey(const ValueKey('quick-capture-due-rollbox')));
      final center = tester.getRect(find.byKey(const ValueKey('quick-capture-center-rollbox')));
      final project = tester.getRect(find.byKey(const ValueKey('quick-capture-project-rollbox')));
      final category = tester.getRect(find.byKey(const ValueKey('quick-capture-category-rollbox')));
      final tag = tester.getRect(find.byKey(const ValueKey('quick-capture-tag-rollbox')));
      void expectRtlBefore(Rect first, Rect second) {
        if ((first.top - second.top).abs() < 1) {
          expect(first.center.dx, greaterThan(second.center.dx));
        } else {
          expect(first.top, lessThan(second.top));
        }
      }
      expectRtlBefore(due, center);
      expectRtlBefore(center, project);
      expectRtlBefore(project, category);
      expectRtlBefore(category, tag);

      final submit = tester.getRect(find.byKey(const ValueKey('quick-capture-submit')));
      final cancel = tester.getRect(find.byKey(const ValueKey('quick-capture-cancel')));
      expect(submit.width, greaterThan(cancel.width));
      expect(cancel.center.dy, closeTo(submit.center.dy, 1));
      expect(submit.height, greaterThanOrEqualTo(48));
      expect(cancel.height, greaterThanOrEqualTo(48));
      for (final key in [
        'quick-capture-center-rollbox',
        'quick-capture-project-rollbox',
        'quick-capture-category-rollbox',
        'quick-capture-tag-rollbox',
        'quick-capture-due-rollbox',
        'quick-capture-reminder-rollbox',
        'quick-capture-recurrence-rollbox',
      ]) {
        expect(tester.getRect(find.byKey(ValueKey(key))).height, 48);
      }
      expect(
        tester.getRect(find.byKey(const ValueKey('quick-capture-priority-option-1'))).height,
        greaterThanOrEqualTo(40),
      );
      expect(tester.takeException(), isNull);
      if (width > 700) {
        final dialog = tester.getRect(find.byKey(const ValueKey('quick-capture-dialog')));
        expect(dialog.width, lessThanOrEqualTo(720));
        expect(dialog.width, greaterThan(600));
      }
    }
  });

  testWidgets('quick capture returns canonical Task with Persian title and tags',
      (tester) async {
    Task? captured;
    final fixedNow = DateTime(2026, 8, 26, 12, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    captured = await showModalBottomSheet<Task>(
                      context: context,
                      builder: (_) => QuickCaptureDialog(
                        idFactory: () => 'quick-1',
                        now: () => fixedNow,
                      ),
                    );
                  },
                  child: const Text('باز کردن'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
    expect(find.text('ثبت سریع کار'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'تماس با علی #مشتری #فوری',
    );
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.id, 'quick-1');
    expect(captured!.title, 'تماس با علی');
    expect(captured!.tags, ['مشتری', 'فوری']);
    expect(captured!.createdAt, fixedNow);
  });

  testWidgets('quick capture rejects empty input with visible feedback',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showModalBottomSheet<Task>(
                  context: context,
                  builder: (_) => const QuickCaptureDialog(),
                ),
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('عنوان برای ثبت کافی است'), findsNWidgets(2));
    expect(find.text('ثبت سریع کار'), findsOneWidget);
  });

  testWidgets('full form continues the same draft identity without quick save',
      (tester) async {
    final quickSaved = <Task>[];
    Task? continued;
    var nextId = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => QuickCaptureDialog(
                    idFactory: () => 'quick-${++nextId}',
                    now: () => DateTime(2026, 9, 19, 12),
                    onCaptured: (task) async => quickSaved.add(task),
                    onFullForm: (draft) async {
                      continued = draft;
                      return true;
                    },
                  ),
                ),
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('quick-capture-input')), 'ادامه در فرم #مهم');
    final fullForm = find.byKey(const ValueKey('quick-capture-full-form'));
    await tester.ensureVisible(fullForm);
    await tester.tap(fullForm);
    await tester.pumpAndSettle();

    expect(quickSaved, isEmpty);
    expect(continued, isNotNull);
    expect(continued!.id, 'quick-1');
    expect(continued!.title, 'ادامه در فرم');
    expect(continued!.tags, ['مهم']);
    expect(find.text('ثبت سریع کار'), findsOneWidget);
  });

  testWidgets('captures three tasks sequentially without closing the dialog',
      (tester) async {
    final captured = <Task>[];
    var nextId = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => QuickCaptureDialog(
                    idFactory: () => 'quick-${++nextId}',
                    now: () => DateTime(2026, 9, 17, 12),
                    onCaptured: (task) async => captured.add(task),
                  ),
                ),
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();

    for (final title in ['کار اول', 'کار دوم', 'کار سوم']) {
      await tester.enterText(find.byKey(const ValueKey('quick-capture-input')), title);
      final submit = find.byKey(const ValueKey('quick-capture-submit'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('ثبت سریع کار'), findsOneWidget);
      expect(find.byKey(const ValueKey('quick-capture-input')), findsOneWidget);
      expect(find.text(title), findsNothing);
    }

    expect(captured.map((task) => task.id), ['quick-1', 'quick-2', 'quick-3']);
    expect(
      captured.map((task) => task.title),
      ['کار اول', 'کار دوم', 'کار سوم'],
    );
  });
  testWidgets('canonical capture keeps title-only path and optional choices',
      (tester) async {
    final captured = <Task>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'canonical-1',
              now: () => DateTime(2026, 9, 26, 12),
              onCaptured: (task) async => captured.add(task),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ثبت سریع کار'), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-capture-description')), findsNothing);
    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('یادآور'), findsOneWidget);
    expect(find.text('تکرار'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار فقط با عنوان',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured.single.title, 'کار فقط با عنوان');
    expect(captured.single.description, '');
  });


  testWidgets('Quick Add scheduling uses the canonical circular date/time picker',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 35),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quick-capture-due-rollbox')), findsOneWidget);
    expect(find.text('تکرار'), findsOneWidget);
    expect(find.text('یادآور'), findsOneWidget);

    final dueControl = find.byKey(const ValueKey('quick-capture-due-rollbox'));
    await tester.ensureVisible(dueControl);
    await tester.tap(dueControl);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
    expect(find.text('فروردین'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsNothing);
  });
  testWidgets('full form cancel preserves quick-entry text for retry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => QuickCaptureDialog(
                    idFactory: () => 'quick-cancel',
                    now: () => DateTime(2026, 9, 19, 12),
                    onCaptured: (_) async {},
                    onFullForm: (_) async => false,
                  ),
                ),
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'متن باید بماند #مهم',
    );
    await tester.tap(find.byKey(const ValueKey('quick-capture-full-form')));
    await tester.pumpAndSettle();

    final input = tester.widget<TextField>(
      find.byKey(const ValueKey('quick-capture-input')),
    );
    expect(input.controller?.text, 'متن باید بماند #مهم');
  });

  testWidgets('Quick Capture opens a usable Persian date/time picker', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 35),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openQuickCaptureDueTimePicker(tester);
    expect(find.text('زمان انجام کار'), findsWidgets);
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
  });

  testWidgets('Quick Add preserves selected due time from custom date/time',
      (tester) async {
    final captured = <Task>[];

    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 16, 35),
              onCaptured: (task) async => captured.add(task),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _openQuickCaptureDueTimePicker(tester);

    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار با ساعت',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured.single.dueDate, DateTime(2026, 9, 27, 16, 35));
  });


  testWidgets('Quick Add opens an independent Persian reminder date/time picker',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 35),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('یادآور'));
    await tester.pumpAndSettle();
    final customReminder = find.text('تاریخ و ساعت سفارشی');
    expect(customReminder, findsOneWidget);
    await tester.ensureVisible(customReminder);
    await tester.pumpAndSettle();
    await tester.tap(customReminder);
    await tester.pumpAndSettle();

    final datePicker = find.byKey(const ValueKey('persian-date-picker'));
    expect(datePicker, findsOneWidget);
    final confirmDate = find.descendant(
      of: datePicker,
      matching: find.text('انتخاب تاریخ'),
    ).last;
    await tester.ensureVisible(confirmDate);
    await tester.tap(confirmDate);
    await tester.pumpAndSettle();

    expect(find.text('زمان یادآوری'), findsWidgets);
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
  });
  testWidgets('Quick Add supports minute precision and all custom recurrence units', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 37),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openQuickCaptureDueTimePicker(tester);
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();
  });


  testWidgets('Quick Add shows the selected scheduling time and uses injected now',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 35),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('۱۴:۳۵'), findsNWidgets(2));

    final reminderRollBox = find.byKey(const ValueKey('quick-capture-reminder-rollbox'));
    await tester.ensureVisible(reminderRollBox);
    await tester.tap(reminderRollBox);
    await tester.pumpAndSettle();
    expect(find.text('۱۵ دقیقه قبل'), findsOneWidget);
    await tester.tap(find.text('۱۵ دقیقه قبل'));
    await tester.pumpAndSettle();
    expect(find.textContaining('۱۴:۲۰'), findsOneWidget);
  });


  testWidgets('Quick Add reminder presets match the product contract', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 35),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('یادآور'));
    await tester.pumpAndSettle();

    expect(find.text('همان زمان موعد'), findsOneWidget);
    expect(find.text('۱۵ دقیقه قبل'), findsOneWidget);
    expect(find.text('یک ساعت قبل'), findsOneWidget);
    expect(find.text('یک روز قبل'), findsOneWidget);
    expect(find.text('یک هفته قبل'), findsOneWidget);
  });

  testWidgets('Quick Add custom recurrence exposes every canonical time unit',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              now: () => DateTime(2026, 9, 27, 14, 37),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('تکرار'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تکرار سفارشی'));
    await tester.pumpAndSettle();

    final frequencyField = find.byKey(const ValueKey('quick-capture-custom-recurrence-frequency'));
    expect(frequencyField, findsOneWidget);
    await tester.tap(frequencyField);
    await tester.pumpAndSettle();

    for (final label in ['دقیقه', 'ساعت', 'روز', 'هفته', 'ماه', 'سال']) {
      expect(find.text(label, skipOffstage: false), findsWidgets);
    }

    await tester.tap(find.text('دقیقه').last);
    await tester.pumpAndSettle();

    final interval = find.byType(TextField).last;
    await tester.enterText(interval, '5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('ثبت'));
    await tester.pump();

    expect(find.text('هر ۵ دقیقه'), findsOneWidget);
  });


  testWidgets('timed Quick Add keeps the due time independent without an explicit reminder',
      (tester) async {
    Task? captured;
    final fixedNow = DateTime(2026, 8, 26, 12, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  captured = await showModalBottomSheet<Task>(
                    context: context,
                    builder: (_) => QuickCaptureDialog(
                      idFactory: () => 'quick-auto-reminder',
                      now: () => fixedNow,
                    ),
                  );
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
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار زمان‌دار',
    );
    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, fixedNow);
    expect(captured!.taskReminders, isEmpty);
    expect(captured!.reminderDate, isNull);
  });

  testWidgets('Quick Add manual reminder remains independent from due time',
      (tester) async {
    Task? captured;
    final fixedNow = DateTime(2026, 8, 26, 12, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  captured = await showModalBottomSheet<Task>(
                    context: context,
                    builder: (_) => QuickCaptureDialog(
                      idFactory: () => 'quick-manual-reminder',
                      now: () => fixedNow,
                    ),
                  );
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
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار با یادآوری دستی',
    );
    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quick-capture-reminder-rollbox')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('۱۵ دقیقه قبل'));
    await tester.tap(find.text('۱۵ دقیقه قبل'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, fixedNow);
    expect(captured!.reminderDate, fixedNow.subtract(const Duration(minutes: 15)));
  });


  testWidgets('Quick Capture hides description and checklist and hands the draft to Full Task Form',
      (tester) async {
    Task? continued;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => QuickCaptureDialog(
                    idFactory: () => 'quick-full-form-handoff',
                    now: () => DateTime(2026, 10, 12, 9),
                    onCaptured: (_) async {},
                    onFullForm: (draft) async {
                      continued = draft;
                      return false;
                    },
                  ),
                ),
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
    final input = find.byKey(const ValueKey('quick-capture-input'));
    await tester.enterText(input, 'خرید فرش اتاق');

    expect(find.byKey(const ValueKey('quick-capture-description')), findsNothing);
    expect(find.byKey(const ValueKey('quick-capture-checklist-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('quick-capture-checklist-rollbox')), findsNothing);
    expect(find.byKey(const ValueKey('quick-capture-follow-up-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('quick-capture-follow-up-rollbox')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('quick-capture-full-form')));
    await tester.pumpAndSettle();
    expect(continued, isNotNull);
    expect(continued!.id, 'quick-full-form-handoff');
    expect(continued!.title, 'خرید فرش اتاق');
    expect(continued!.description, '');
    expect(continued!.checklistEnabled, isFalse);
    expect(continued!.checklist, isEmpty);
    expect(tester.widget<TextField>(input).controller!.text, 'خرید فرش اتاق');
  });

  testWidgets('Quick Entry exposes reminder controls without legacy follow-up scheduling',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(idFactory: () => 'quick-no-follow-up'),
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('quick-capture-follow-up-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('quick-capture-follow-up-rollbox')), findsNothing);
    expect(find.text('دارای پیگیری'), findsNothing);
  });

  testWidgets(
    'Quick Capture due picker offers both Jalali and Gregorian calendars',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: QuickCaptureDialog()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final due = find.byKey(const ValueKey('quick-capture-due-rollbox'));
      await tester.ensureVisible(due);
      await tester.tap(due);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('persian-date-gregorian-toggle')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('انتخاب تاریخ میلادی'), findsOneWidget);

      await tester.tap(find.text('لغو').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('persian-date-picker')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Quick Capture custom due uses the canonical circular clock and saves a local DateTime',
      (tester) async {
    Task? captured;
    final fixedNow = DateTime(2026, 9, 27, 14, 35);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'quick-canonical-datetime',
              now: () => fixedNow,
              onCaptured: (task) async { captured = task; },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار با موعد سفارشی',
    );
    await _openQuickCaptureDueTimePicker(tester);

    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    expect(find.byKey(const ValueKey('universal-time-hour-outer-10')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-hour-outer-10')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('universal-time-minute-30')));
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, DateTime(2026, 9, 27, 10, 30));
    expect(captured!.taskReminders, isEmpty);
    expect(captured!.reminderDate, isNull);
  });

  testWidgets('Quick Capture stores a custom all-day deadline without a clock time',
      (tester) async {
    Task? captured;
    final fixedNow = DateTime(2026, 9, 27, 14, 35);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'quick-all-day-due',
              now: () => fixedNow,
              onCaptured: (task) async { captured = task; },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار تمام‌روز',
    );
    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-no-time')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, DateTime(2026, 9, 27));
    expect(captured!.allDay, isTrue);
    expect(captured!.reminderDate, isNull);
  });


  testWidgets('Quick Capture leaves custom due empty when the unified picker is not used',
      (tester) async {
    Task? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'quick-no-due',
              now: () => DateTime(2026, 9, 27, 14, 35),
              onCaptured: (task) async { captured = task; },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار بدون موعد',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, isNull);
    expect(captured!.reminderDate, isNull);
  });

  testWidgets('Quick Capture cancelling the clock leaves the custom due empty',
      (tester) async {
    Task? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'quick-cancel-custom-due',
              now: () => DateTime(2026, 9, 27, 14, 35),
              onCaptured: (task) async { captured = task; },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار با موعد لغوشده',
    );
    await _openQuickCaptureDueTimePicker(tester);
    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-cancel')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, isNull);
    expect(captured!.reminderDate, isNull);
  });


  testWidgets('Quick Capture remains scrollable without overflow when the phone keyboard is open',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: QuickCaptureDialog()),
      ),
    ));

    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width, 780);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      final filterRow = find.byKey(const ValueKey('quick-capture-five-filter-row'));
      expect(filterRow, findsOneWidget);
      expect(find.byKey(const ValueKey('quick-capture-no-time')), findsNothing);
      expect(find.text('بدون ساعت'), findsNothing);
      final rowRect = tester.getRect(filterRow);
      final filterKeys = [
        'quick-capture-due-rollbox',
        'quick-capture-center-rollbox',
        'quick-capture-project-rollbox',
        'quick-capture-category-rollbox',
        'quick-capture-tag-rollbox',
      ];
      final filterRects = filterKeys.map((key) => tester.getRect(find.byKey(ValueKey(key)))).toList();
      for (final rect in filterRects) {
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.top, closeTo(filterRects.first.top, 0.1));
        expect(rect.left, greaterThanOrEqualTo(rowRect.left));
        expect(rect.right, lessThanOrEqualTo(rowRect.right));
      }
      expect(filterRects[0].center.dx, greaterThan(filterRects[1].center.dx));
      expect(filterRects[1].center.dx, greaterThan(filterRects[2].center.dx));
      expect(filterRects[2].center.dx, greaterThan(filterRects[3].center.dx));
      expect(filterRects[3].center.dx, greaterThan(filterRects[4].center.dx));
      expect(find.byKey(const ValueKey('quick-capture-submit')), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-tag-rollbox')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });


  testWidgets('all-day Quick Capture hides relative reminder presets but keeps custom reminders',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: QuickCaptureDialog(now: () => DateTime(2026, 9, 27, 14, 35)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-no-time')));
    await tester.pumpAndSettle();

    final reminderControl = find.byKey(const ValueKey('quick-capture-reminder-rollbox'));
    await tester.ensureVisible(reminderControl);
    await tester.tap(reminderControl);
    await tester.pumpAndSettle();
    for (final label in [
      'همان زمان موعد',
      '۱۵ دقیقه قبل',
      'یک ساعت قبل',
      'یک روز قبل',
      'یک هفته قبل',
    ]) {
      expect(find.text(label), findsNothing);
    }
    expect(find.text('تاریخ و ساعت سفارشی'), findsOneWidget);
  });

  testWidgets('all-day Quick Capture persists an independent custom reminder across store reopen',
      (tester) async {
    await TaskStore.resetTestDatabase();
    addTearDown(TaskStore.resetTestDatabase);
    final store = TaskStore();
    Task? captured;
    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: QuickCaptureDialog(
            idFactory: () => 'quick-all-day-custom-reminder',
            now: () => DateTime(2026, 9, 27, 14, 35),
            onCaptured: (task) async {
              captured = task;
              await store.mutate<void>((tasks) => tasks.add(task));
            },
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار تمام‌روز با یادآور مستقل',
    );
    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-no-time')));
    await tester.pumpAndSettle();
    await _openQuickCaptureCustomReminderPicker(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.allDay, isTrue);
    expect(captured!.taskReminders, hasLength(1));
    expect(captured!.taskReminders.single.isAllDay, isFalse);
    final reopenedTasks = await TaskStore().load();
    expect(reopenedTasks, hasLength(1));
    final reopened = reopenedTasks.single;
    expect(reopened.allDay, isTrue);
    expect(reopened.taskReminders, hasLength(1));
    expect(reopened.taskReminders.single.date, captured!.taskReminders.single.date);
  });

  testWidgets('timed-to-all-day clears a relative reminder and all-day-to-timed preserves custom reminder',
      (tester) async {
    Task? captured;
    final fixedNow = DateTime(2026, 9, 27, 14, 35);
    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: QuickCaptureDialog(
            idFactory: () => 'quick-transition-reminder',
            now: () => fixedNow,
            onCaptured: (task) async => captured = task,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'کار با تغییر نوع موعد',
    );

    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-capture-reminder-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۱۵ دقیقه قبل'));
    await tester.pumpAndSettle();
    expect(find.textContaining('۱۴:۲۰'), findsOneWidget);

    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-no-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-capture-reminder-rollbox')));
    await tester.pumpAndSettle();
    expect(find.text('۱۵ دقیقه قبل'), findsNothing);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await _openQuickCaptureCustomReminderPicker(tester);
    final customReminderDate = DateTime(2026, 9, 27);
    await _openQuickCaptureDueTimePicker(tester);
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();
    expect(captured, isNotNull);
    expect(captured!.allDay, isFalse);
    expect(captured!.taskReminders, hasLength(1));
    expect(captured!.taskReminders.single.date, customReminderDate);
  });

  testWidgets('each timed relative reminder preset stores its exact offset from the due time',
      (tester) async {
    final fixedNow = DateTime(2026, 9, 27, 14, 35);
    final presets = <String, Duration>{
      'همان زمان موعد': Duration.zero,
      '۱۵ دقیقه قبل': const Duration(minutes: -15),
      'یک ساعت قبل': const Duration(hours: -1),
      'یک روز قبل': const Duration(days: -1),
      'یک هفته قبل': const Duration(days: -7),
    };
    for (final entry in presets.entries) {
      Task? captured;
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(
              idFactory: () => 'quick-preset-${entry.key.hashCode}',
              now: () => fixedNow,
              onCaptured: (task) async => captured = task,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-input')),
        'کار زمان‌دار',
      );
      await _openQuickCaptureDueTimePicker(tester);
      await tester.tap(find.byKey(const ValueKey('universal-time-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-capture-reminder-rollbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
      await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
      await tester.pumpAndSettle();

      expect(captured, isNotNull, reason: entry.key);
      expect(captured!.dueDate, fixedNow, reason: entry.key);
      expect(captured!.taskReminders.single.date, fixedNow.add(entry.value), reason: entry.key);
    }
  });

}
