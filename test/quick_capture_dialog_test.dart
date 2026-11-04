import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/arvin_colors.dart';
import 'package:arvin/quick_capture_dialog.dart';

void main() {
  testWidgets('Quick Capture defaults to اولویت ۲ and persists selected priority', (tester) async {
    Task? captured;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuickCaptureDialog(
      idFactory: () => 'priority-capture',
      now: () => DateTime(2026, 11, 3, 10),
      onCaptured: (task) async { captured = task; },
    ))));
    await tester.pumpAndSettle();
    final p2 = find.byKey(const ValueKey('quick-capture-priority-medium'));
    final p1 = find.byKey(const ValueKey('quick-capture-priority-high'));
    expect(tester.widget<ChoiceChip>(p2).selected, isTrue);
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
    await tester.tap(p1);
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('quick-capture-input')), 'کار فوری');
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();
    expect(captured, isNotNull);
    expect(captured!.priority, TaskPriority.high);
    expect(tester.widget<ChoiceChip>(p2).selected, isTrue);
  });

  testWidgets('Quick Capture priorities stay in one accessible Persian row on narrow screens',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QuickCaptureDialog(now: () => DateTime(2026, 11, 3, 10)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final keys = [
      'quick-capture-priority-high',
      'quick-capture-priority-medium',
      'quick-capture-priority-low',
      'quick-capture-priority-none',
    ];
    final rects = <Rect>[];
    for (final key in keys) {
      final finder = find.byKey(ValueKey(key));
      expect(finder, findsOneWidget);
      rects.add(tester.getRect(finder));
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
    }
    expect(rects.map((rect) => rect.top).toSet(), hasLength(1));
    expect(rects[0].center.dx, greaterThan(rects[1].center.dx));
    expect(rects[1].center.dx, greaterThan(rects[2].center.dx));
    expect(rects[2].center.dx, greaterThan(rects[3].center.dx));
    expect(rects.every((rect) => rect.width >= 48), isTrue);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('quick-capture-priority-row')), findsOneWidget);

    final p1 = tester.widget<ChoiceChip>(find.byKey(ValueKey(keys[0])));
    final p2 = tester.widget<ChoiceChip>(find.byKey(ValueKey(keys[1])));
    final p3 = tester.widget<ChoiceChip>(find.byKey(ValueKey(keys[2])));
    final p4 = tester.widget<ChoiceChip>(find.byKey(ValueKey(keys[3])));
    expect(p1.side?.color, ArvinColors.priorityP1.withValues(alpha: 0.35));
    expect(p2.side?.color, ArvinColors.priorityP2.withValues(alpha: 0.9));
    expect(p3.side?.color, ArvinColors.priorityP3.withValues(alpha: 0.35));
    expect(p4.side?.color, ArvinColors.priorityP4.withValues(alpha: 0.35));
    expect(p2.selected, isTrue);
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

    expect(find.text('موعد'), findsOneWidget);
    expect(find.text('تکرار'), findsOneWidget);
    expect(find.text('یادآور'), findsOneWidget);

    await tester.tap(find.text('موعد'));
    await tester.pumpAndSettle();
    expect(find.text('امروز'), findsOneWidget);
    expect(find.text('تاریخ و ساعت سفارشی'), findsOneWidget);
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب تاریخ'), findsWidgets);
    expect(find.text('فروردین'), findsNothing);
    final dateConfirm = find.widgetWithText(FilledButton, 'انتخاب تاریخ');
    await tester.tap(dateConfirm);
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
    expect(find.text('موعد'), findsOneWidget);
    await tester.tap(find.text('موعد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();
    expect(find.text('انتخاب تاریخ'), findsWidgets);
    final dateConfirm = find.widgetWithText(FilledButton, 'انتخاب تاریخ');
    expect(dateConfirm, findsOneWidget);
    await tester.tap(dateConfirm);
    await tester.pumpAndSettle();
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

    await tester.tap(find.text('موعد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();

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
    expect(find.text('تاریخ و ساعت سفارشی'), findsOneWidget);
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'انتخاب تاریخ'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
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
    await tester.tap(find.text('موعد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();
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

    await tester.tap(find.text('موعد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز'));
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


  testWidgets('timed Quick Add automatically uses the due time as reminder',
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
    await tester.tap(find.byKey(const ValueKey('quick-capture-due-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, fixedNow);
    expect(captured!.reminderDate, fixedNow);
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
    await tester.tap(find.byKey(const ValueKey('quick-capture-due-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز'));
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


  testWidgets('Quick Entry follow-up and checklist controls activate Task-owned Roll Boxes',
      (tester) async {
    Task? captured;
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
                    isScrollControlled: true,
                    builder: (_) => QuickCaptureDialog(
                      idFactory: () => 'quick-follow-up-checklist',
                      now: () => DateTime(2026, 10, 12, 9),
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
      'خرید فرش اتاق',
    );

    expect(find.byKey(const ValueKey('quick-capture-follow-up-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('quick-capture-follow-up-rollbox')), findsNothing);

    final checklistToggle = find.byKey(
      const ValueKey('quick-capture-checklist-enabled'),
    );
    await tester.ensureVisible(checklistToggle);
    await tester.tap(checklistToggle);
    await tester.pumpAndSettle();
    final checklistRollBox = find.byKey(
      const ValueKey('quick-capture-checklist-rollbox'),
    );
    expect(checklistRollBox, findsOneWidget);

    await tester.ensureVisible(checklistRollBox);
    await tester.tap(checklistRollBox);
    await tester.pumpAndSettle();
    await tester.tap(find.text('افزودن مورد چک‌لیست'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-checklist-item-input')),
      'تماس با فروشنده',
    );
    await tester.tap(
      find.byKey(const ValueKey('quick-capture-checklist-item-save')),
    );
    await tester.pumpAndSettle();

    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.followUpEnabled, isFalse);
    expect(captured!.followUps, isEmpty);

    expect(captured!.checklistEnabled, isTrue);
    expect(captured!.checklist, ['[ ] تماس با فروشنده']);
    expect(captured!.followUps, isEmpty);
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
    await tester.tap(find.byKey(const ValueKey('quick-capture-due-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('universal-time-selected-value')), findsOneWidget);
    expect(find.byKey(const ValueKey('universal-time-hour-outer-10')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('universal-time-hour-outer-10')));
    await tester.tap(find.byKey(const ValueKey('universal-time-minute-30')));
    await tester.ensureVisible(find.byKey(const ValueKey('universal-time-save')));
    await tester.tap(find.byKey(const ValueKey('universal-time-save')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.dueDate, DateTime(2026, 9, 27, 10, 30));
    expect(captured!.reminderDate, captured!.dueDate);
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
    await tester.tap(find.byKey(const ValueKey('quick-capture-due-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تاریخ و ساعت سفارشی'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'انتخاب تاریخ'));
    await tester.pumpAndSettle();
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

}
