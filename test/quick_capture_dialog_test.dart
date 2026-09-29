import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/quick_capture_dialog.dart';

void main() {
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
    await tester.tap(find.byKey(const ValueKey('quick-capture-submit')));
    await tester.pumpAndSettle();

    expect(captured.single.title, 'کار فقط با عنوان');
  });


  testWidgets('Quick Add scheduling uses RollBox and Persian custom date/time',
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
    final dateConfirm = find.byKey(const ValueKey('quick-capture-date-confirm'));
    await tester.tap(dateConfirm);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب ساعت'), findsWidgets);
    expect(find.text('ساعت'), findsOneWidget);
    expect(find.text('دقیقه'), findsOneWidget);
    expect(find.text('۱۴:۳۵'), findsOneWidget);
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
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
    expect(find.text('انتخاب ساعت'), findsWidgets);
    expect(find.text('ساعت'), findsOneWidget);
    expect(find.text('دقیقه'), findsOneWidget);
  });
}
