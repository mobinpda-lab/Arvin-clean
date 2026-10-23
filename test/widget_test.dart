import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Arvin starts with the canonical centered Home identity',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
  });

  testWidgets('Home exposes the canonical workflow controls', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('دسته'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('بیشتر'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    final moreSheet = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-more-report')),
      300,
      scrollable: moreSheet,
    );
    expect(find.byKey(const ValueKey('home-more-report')), findsOneWidget);
    expect(find.text('گزارش‌ها'), findsWidgets);
    expect(find.text('پشتیبان‌گیری'), findsOneWidget);
  });

  testWidgets('HomePage loads legacy storage through the unified reader',
      (tester) async {
    final legacyTask = {
      'id': 'legacy-1',
      'title': 'کار مهاجرتی',
      'description': 'داده قدیمی باید در Home دیده شود',
      'followUpDate': '2026-08-20T10:30:00.000',
      'tags': ['مهاجرت'],
      'archived': false,
      'trashed': false,
      'completed': false,
    };
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([legacyTask]),
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کار مهاجرتی'), findsOneWidget);
    expect(find.text('داده قدیمی باید در Home دیده شود'), findsNothing);
  });


  testWidgets('Home renders independent recurring past, today and next occurrence windows',
      (tester) async {
    const taskId = 'home-recurring-window-task';
    final anchor = DateTime(2026, 10, 21, 9);
    final fixedNow = DateTime(2026, 10, 23, 12);
    await TaskStore().save([
      Task(
        id: taskId,
        title: 'آماده‌سازی روزانه',
        reminderDate: anchor,
        recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        category: 'مدرسه',
        tags: ['صبح'],
        checklist: const ['[ ] کیف', '[ ] خوراکی'],
        checklistOccurrences: {
          anchor.toIso8601String(): const ['[x] کیف', '[ ] خوراکی'],
        },
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(clock: () => fixedNow),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final yesterdayKey = ValueKey(
      'home-recurring-occurrence-$taskId-${DateTime(2026, 10, 22, 9).toIso8601String()}',
    );
    final todayKey = ValueKey(
      'home-recurring-occurrence-$taskId-${DateTime(2026, 10, 23, 9).toIso8601String()}',
    );
    final tomorrowKey = ValueKey(
      'home-recurring-occurrence-$taskId-${DateTime(2026, 10, 24, 9).toIso8601String()}',
    );
    expect(find.byKey(yesterdayKey), findsOneWidget);
    expect(find.byKey(todayKey), findsOneWidget);
    expect(find.byKey(tomorrowKey), findsOneWidget);
    expect(find.textContaining('معوق'), findsWidgets);
    expect(find.textContaining('کارهای امروز'), findsWidgets);
    expect(find.textContaining('پیش‌نمایش آینده'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('home-resume-from-today')));
    await tester.pumpAndSettle();
    expect(find.byKey(yesterdayKey), findsNothing);
    expect(find.byKey(todayKey), findsOneWidget);
    expect(find.byKey(tomorrowKey), findsOneWidget);

    // Opening task details and returning must preserve the current Home view.
    await tester.ensureVisible(find.byKey(todayKey));
    await tester.tap(find.byKey(todayKey));
    await tester.pumpAndSettle();
    expect(find.text('آماده‌سازی روزانه'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(yesterdayKey), findsNothing);
    expect(find.byKey(todayKey), findsOneWidget);
    expect(find.byKey(tomorrowKey), findsOneWidget);

    final beforeCompletion = (await TaskStore().load()).single;
    expect(beforeCompletion.reminderDate, anchor);
    expect(beforeCompletion.occurrenceHistory, isEmpty);
    expect(beforeCompletion.checklistOccurrences, {
      anchor.toIso8601String(): const ['[x] کیف', '[ ] خوراکی'],
    });

    final todayCompleteKey = ValueKey(
      'home-recurring-complete-$taskId-${DateTime(2026, 10, 23, 9).toIso8601String()}',
    );
    await tester.ensureVisible(find.byKey(todayCompleteKey));
    await tester.tap(find.byKey(todayCompleteKey));
    await tester.pumpAndSettle();

    final afterCompletion = (await TaskStore().load()).single;
    expect(afterCompletion.occurrenceHistory, {
      DateTime(2026, 10, 23, 9).toIso8601String(): {
        'scheduledDate': DateTime(2026, 10, 23, 9).toIso8601String(),
        'status': 'completed',
        'completionDate': fixedNow.toIso8601String(),
      },
    });
    expect(afterCompletion.reminderDate, anchor);
    expect(afterCompletion.completed, isFalse);
    expect(afterCompletion.checklistOccurrences, beforeCompletion.checklistOccurrences);
    expect((await TaskStore().load()), hasLength(1));

    // A fresh Home route resets only the in-memory Resume choice.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(clock: () => fixedNow),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(yesterdayKey), findsOneWidget);
    expect(find.byKey(todayKey), findsOneWidget);
    expect(find.byKey(tomorrowKey), findsOneWidget);
    final afterReentry = (await TaskStore().load()).single;
    expect(afterReentry.occurrenceHistory, afterCompletion.occurrenceHistory);
    expect(afterReentry.reminderDate, anchor);
  });

  testWidgets('HomePage shows the empty-state message after loading',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کاری برای نمایش وجود ندارد'), findsOneWidget);
    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('دسته'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
  });
}
