import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/models/arvin_center.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/services/person_follow_up_report_projection.dart';
import 'package:arvin/services/task_edit_apply_service.dart';
import 'package:arvin/services/task_report_filter.dart';
import 'package:arvin/quick_capture_dialog.dart';

void main() {
  test('Task JSON preserves independent Center ID and true all-day due date', () {
    final task = Task(
      id: 'task-center-all-day',
      title: 'آماده‌سازی',
      centerId: 'center-school',
      dueDate: DateTime(2026, 11, 6),
      allDay: true,
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.centerId, 'center-school');
    expect(restored.dueDate, DateTime(2026, 11, 6));
    expect(restored.allDay, isTrue);
    expect(restored.toJson()['allDay'], isTrue);
  });

  test('Task edit application preserves the independently selected Center', () {
    final target = Task(id: 'task-1', title: 'کار', centerId: 'center-old');
    final edited = Task(id: 'task-1', title: 'کار ویرایش‌شده', centerId: 'center-new');

    TaskEditApplyService(now: () => DateTime(2026, 11, 6))
        .apply(target, edited);

    expect(target.centerId, 'center-new');
    expect(target.title, 'کار ویرایش‌شده');
  });

  test('Report Center filters directly by Task Center ID without requiring a Project', () {
    final matching = Task(id: 'matching', title: 'کار اول', centerId: 'center-a');
    final other = Task(id: 'other', title: 'کار دوم', centerId: 'center-b');

    final result = const TaskReportFilter(centerIds: {'center-a'}).apply(
      [matching, other],
      now: DateTime(2026, 11, 6, 12),
    );

    expect(result.map((task) => task.id), ['matching']);
  });


  test('Report Center person filter returns only Tasks waiting for that stable personId', () {
    final waiting = Task(
      id: 'waiting-for-person',
      title: 'منتظر پاسخ',
      followUps: [
        FollowUp(
          id: 'waiting-person-follow-up',
          dateTime: DateTime(2026, 11, 6, 9),
          waitingForResponse: true,
          personIds: const ['person-42'],
        ),
      ],
    );
    final notWaiting = Task(
      id: 'not-waiting-for-person',
      title: 'پیگیری عادی',
      followUps: [
        FollowUp(
          id: 'ordinary-follow-up',
          dateTime: DateTime(2026, 11, 6, 10),
          waitingForResponse: false,
          personIds: const ['person-42'],
        ),
      ],
    );

    final result = const TaskReportFilter(personIds: {'person-42'}).apply(
      [waiting, notWaiting],
      now: DateTime(2026, 11, 6, 12),
    );

    expect(result.map((task) => task.id), ['waiting-for-person']);
  });

  test('Person report matches the stable personId saved on a waiting Follow-up', () {
    final task = Task(
      id: 'waiting-task',
      title: 'تماس با همکار',
      followUps: [
        FollowUp(
          id: 'waiting-follow-up',
          dateTime: DateTime(2026, 11, 6, 9),
          waitingForResponse: true,
          personIds: const ['person-42'],
        ),
      ],
    );
    final person = PersonReference(id: 'person-42', displayName: 'سارا');

    final projection = const PersonFollowUpReportProjection();
    final matching = projection.project(
      [task],
      people: [person],
      personIds: const {'person-42'},
    );
    final notMatching = projection.project(
      [task],
      people: [person],
      personIds: const {'person-other'},
    );

    expect(matching, hasLength(1));
    expect(matching.single.task.id, 'waiting-task');
    expect(matching.single.people.single.id, 'person-42');
    expect(notMatching, isEmpty);
  });

  testWidgets('Quick Capture saves the explicit no-time choice as a true all-day Task', (tester) async {
    Task? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickCaptureDialog(
            idFactory: () => 'quick-capture-all-day',
            now: () => DateTime(2026, 11, 6, 9, 45),
            onCaptured: (task) async { captured = task; },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'آماده‌سازی کیف مدرسه',
    );
    await tester.tap(find.byKey(const ValueKey('quick-capture-due-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('امروز').last);
    await tester.pumpAndSettle();
    final noTime = find.byKey(const ValueKey('quick-capture-no-time'));
    await tester.ensureVisible(noTime);
    await tester.tap(noTime);
    await tester.pumpAndSettle();
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.allDay, isTrue);
    expect(captured!.dueDate, DateTime(2026, 11, 6));
    expect(captured!.reminderDate, isNull);
  });

  testWidgets('Full Task Details saves an independently selected Center', (tester) async {
    Task? saved;
    final center = ArvinCenter(
      id: 'center-editor',
      name: 'مرکز آموزشی',
      createdAt: DateTime(2026, 11, 6),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                saved = await showDialog<Task>(
                  context: context,
                  builder: (_) => ArvinTaskEditorDialog(centers: [center]),
                );
              },
              child: const Text('open-center-editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-center-editor'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-editor-center-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مرکز آموزشی').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.centerId, 'center-editor');
  });
}
