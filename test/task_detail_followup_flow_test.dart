import 'package:arvin/models/task.dart';
import 'package:arvin/services/waiting_for_response_service.dart';
import 'package:arvin/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ordinary Task detail also exposes real Follow-up entry',
      (tester) async {
    final task = Task(
      id: 'ordinary',
      title: 'ارسال قرارداد',
      description: 'نسخه نهایی برای مشتری',
      dueDate: DateTime(2026, 8, 30, 14, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async => value,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('task-detail-page')), findsOneWidget);
    expect(find.text('ارسال قرارداد'), findsOneWidget);
    expect(find.text('نسخه نهایی برای مشتری'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-due-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-edit')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-add-followup')), findsOneWidget);
  });

  testWidgets('Task detail removes the redundant status badge and shows description placeholder',
      (tester) async {
    final task = Task(id: 'empty-description', title: 'کار بدون توضیح');

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onDescriptionChanged: (current, description) async => current,
        ),
      ),
    );

    expect(find.text('توضیحی ثبت نشده است'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-description-edit')), findsOneWidget);
    expect(find.text('در انتظار انجام'), findsNothing);
    expect(find.text('در انتظار پاسخ'), findsNothing);
    expect(find.text('پیگیری دار'), findsNothing);
    expect(find.text('ثبت یادداشت'), findsNothing);
  });

  testWidgets('inline description edit updates updatedAt and preserves completion and Follow-up history',
      (tester) async {
    final completedAt = DateTime(2026, 10, 29, 9, 30);
    final followUpDate = DateTime(2026, 10, 28, 11);
    final nextFollowUp = DateTime(2026, 11, 2, 12);
    final originalFollowUp = FollowUp(
      id: 'immutable-follow-up',
      dateTime: followUpDate,
      note: 'تاریخچه غیرقابل تغییر',
      nextFollowUp: nextFollowUp,
      completed: true,
    );
    final previousUpdatedAt = DateTime(2026, 10, 27, 8);
    final task = Task(
      id: 'inline-description',
      title: 'کار دارای توضیح',
      description: 'متن قبلی',
      updatedAt: previousUpdatedAt,
      completed: true,
      completedAt: completedAt,
      followUpEnabled: true,
      followUpDate: followUpDate,
      followUps: <FollowUp>[originalFollowUp],
    );
    final savedAt = DateTime(2026, 10, 31, 12);

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onDescriptionChanged: (current, description) async {
            current.description = description;
            current.updatedAt = savedAt;
            return current;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('task-detail-description-edit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-detail-description-input')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('task-detail-description-input')),
      'توضیح به‌روزشده',
    );
    await tester.tap(find.byKey(const ValueKey('task-detail-description-save')));
    await tester.pumpAndSettle();

    expect(task.description, 'توضیح به‌روزشده');
    expect(task.updatedAt, savedAt);
    expect(task.completedAt, completedAt);
    expect(task.followUps, hasLength(1));
    expect(identical(task.followUps.single, originalFollowUp), isTrue);
    expect(task.followUps.single.note, 'تاریخچه غیرقابل تغییر');
    expect(task.followUps.single.nextFollowUp, nextFollowUp);
    expect(task.followUps.single.dateTime, followUpDate);
    expect(task.followUpEnabled, isTrue);
    expect(task.followUpDate, followUpDate);
    expect(find.text('توضیح به‌روزشده'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-detail-description-input')), findsNothing);
    expect(find.text('ثبت یادداشت'), findsNothing);
  });

  testWidgets('Task detail renders due date as Jalali with Persian digits',
      (tester) async {
    final task = Task(
      id: 'jalali-detail',
      title: 'نمایش تاریخ',
      dueDate: DateTime(2026, 8, 30, 14, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async => value,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('task-detail-due-date')), findsOneWidget);
    expect(find.text('۱۴۰۵/۰۶/۰۸ • ۱۴:۳۰'), findsOneWidget);
    expect(find.textContaining('2026'), findsNothing);
  });

  testWidgets('follow-up Task round add opens entry and appends canonical history',
      (tester) async {
    final task = Task(
      id: 'follow-up',
      title: 'پیگیری مشتری',
      followUpEnabled: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async => value,
          onAddFollowUp: (value, followUp) async {
            value.followUps = <FollowUp>[...value.followUps, followUp];
            value.followUpEnabled = true;
            return value;
          },
        ),
      ),
    );

    expect(find.text('هنوز پیگیری ثبت نشده است'), findsOneWidget);
    final add = find.byKey(const ValueKey('task-detail-add-followup'));
    expect(add, findsOneWidget);
    await tester.tap(add);
    await tester.pumpAndSettle();

    expect(find.text('ثبت پیگیری'), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-up-entry-title')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.title, isNull);
    expect(task.followUps.single.note, isEmpty);
    expect(find.byKey(ValueKey('task-detail-followup-${task.followUps.single.id}')),
        findsOneWidget);
    expect(find.text('پیگیری'), findsWidgets);
  });

  testWidgets('existing FollowUp edits in place from detail without duplication',
      (tester) async {
    final original = FollowUp(
      id: 'edit-f1',
      dateTime: DateTime(2026, 8, 28, 10, 15),
      note: 'متن اولیه',
    );
    final task = Task(
      id: 'edit-task',
      title: 'پیگیری قابل ویرایش',
      followUpEnabled: true,
      followUps: <FollowUp>[original],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async => value,
          onAddFollowUp: (value, followUp) async => value,
          onEditFollowUp: (value, followUp) async {
            expect(value.id, 'edit-task');
            expect(followUp.id, 'edit-f1');
            return followUp;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('task-detail-latest-edit-followup-edit-f1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('ویرایش پیگیری'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('follow-up-entry-note')),
      'متن اصلاح‌شده',
    );
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, 'edit-f1');
    expect(task.followUps.single.note, 'متن اصلاح‌شده');
    expect(find.text('متن اصلاح‌شده'), findsWidgets);
  });

  testWidgets('detail shows latest elapsed time, results and consecutive intervals',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final first = FollowUp(
      id: 'f1',
      dateTime: DateTime(2026, 8, 20, 9, 20),
      note: 'اولین تماس',
    );
    final second = FollowUp(
      id: 'f2',
      dateTime: DateTime(2026, 8, 22, 9, 20),
      note: 'تماس دوم',
      result: WaitingForResponseService.canonicalResult,
    );
    final latest = FollowUp(
      id: 'f3',
      dateTime: DateTime(2026, 8, 27, 12, 20),
      note: 'پیگیری',
      result: 'هماهنگی انجام شد',
    );
    final task = Task(
      id: 'history',
      title: 'تماس با علی',
      followUpEnabled: true,
      followUps: <FollowUp>[second, latest, first],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          now: DateTime(2026, 8, 30, 16, 20),
          onEdit: (value) async => value,
          onAddFollowUp: (value, followUp) async => value,
        ),
      ),
    );

    expect(
      find.text('● ۳ روز و ۴ ساعت از آخرین پیگیری گذشته'),
      findsOneWidget,
    );
    expect(find.text('هماهنگی انجام شد'), findsOneWidget);
    expect(find.text('منتظر پاسخ'), findsOneWidget);
    expect(find.text('فاصله از پیگیری قبلی: ۵ روز و ۳ ساعت'), findsOneWidget);
    expect(find.text('فاصله از پیگیری قبلی: ۲ روز'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('task-detail-followup-interval-f1')),
      findsNothing,
    );

    final latestY = tester
        .getTopLeft(find.byKey(const ValueKey('task-detail-followup-f3')))
        .dy;
    final secondY = tester
        .getTopLeft(find.byKey(const ValueKey('task-detail-followup-f2')))
        .dy;
    final firstY = tester
        .getTopLeft(find.byKey(const ValueKey('task-detail-followup-f1')))
        .dy;
    expect(latestY, lessThan(secondY));
    expect(secondY, lessThan(firstY));
  });

  testWidgets('Edit result refreshes the same detail page', (tester) async {
    final task = Task(id: 'same-id', title: 'عنوان قبلی');

    await tester.pumpWidget(
      MaterialApp(
        home: TaskDetailPage(
          task: task,
          onEdit: (value) async {
            value.title = 'عنوان جدید';
            return value;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
    await tester.pumpAndSettle();

    expect(task.id, 'same-id');
    expect(find.text('عنوان جدید'), findsOneWidget);
  });
}
