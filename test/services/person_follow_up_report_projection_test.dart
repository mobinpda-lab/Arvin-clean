import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/person_follow_up_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ana = PersonReference(id: 'ana', displayName: 'آنا');
  final reza = PersonReference(id: 'reza', displayName: 'رضا');
  final directory = <PersonReference>[ana, reza];
  final now = DateTime(2026, 10, 15, 10);

  FollowUp waiting(String id, List<String> personIds, {DateTime? next, DateTime? reminder}) =>
      FollowUp(
        id: id,
        dateTime: now,
        note: 'پیگیری $id',
        result: 'نتیجه آزاد به تنهایی نباید وضعیت انتظار بسازد',
        personIds: personIds,
        waitingForResponse: true,
        nextFollowUp: next,
        reminderDate: reminder,
      );

  test('projects separate waiting rows for multiple people and follow-ups on one task', () {
    final task = Task(
      id: 'task-1',
      title: 'تماس با مشتری',
      followUpEnabled: false,
      followUps: [
        waiting('fu-ana', ['ana'], next: DateTime(2026, 10, 16, 9),
            reminder: DateTime(2026, 10, 15, 18)),
        waiting('fu-reza', ['reza']),
        waiting('fu-both', ['ana', 'reza']),
      ],
    );

    final rows = const PersonFollowUpReportProjection()
        .project([task], people: directory);

    expect(rows.map((row) => row.followUp.id), ['fu-ana', 'fu-reza', 'fu-both']);
    expect(rows[0].people.single.id, 'ana');
    expect(rows[1].people.single.id, 'reza');
    expect(rows[2].people.map((person) => person.id), ['ana', 'reza']);
    expect(rows[0].nextFollowUp, DateTime(2026, 10, 16, 9));
    expect(rows[0].reminderDate, DateTime(2026, 10, 15, 18));
    expect(rows[0].nextFollowUp, isNot(equals(rows[0].reminderDate)));
  });

  test('person filter returns only rows linked to that canonical person', () {
    final task = Task(
      id: 'task-1',
      title: 'تماس',
      followUps: [
        waiting('fu-ana', ['ana']),
        waiting('fu-reza', ['reza']),
      ],
    );

    final rows = const PersonFollowUpReportProjection()
        .project([task], people: directory, personId: 'reza');

    expect(rows.map((row) => row.followUp.id), ['fu-reza']);
    expect(rows.single.people.single.id, 'reza');
  });

  test('excludes completed, archived, trashed tasks and completed follow-ups', () {
    final tasks = [
      Task(id: 'open', title: 'باز', followUps: [waiting('active', ['ana'])]),
      Task(id: 'done', title: 'تمام', completed: true, followUps: [waiting('done', ['ana'])]),
      Task(id: 'archived', title: 'بایگانی', archived: true, followUps: [waiting('archived', ['ana'])]),
      Task(id: 'trash', title: 'حذف', trashed: true, followUps: [waiting('trash', ['ana'])]),
      Task(id: 'follow-up-done', title: 'پیگیری تمام', followUps: [
        FollowUp(id: 'closed', dateTime: now, personIds: ['ana'], waitingForResponse: true, completed: true),
      ]),
    ];

    final rows = const PersonFollowUpReportProjection()
        .project(tasks, people: directory);

    expect(rows.map((row) => row.followUp.id), ['active']);
  });

  test('ignores legacy result-only waiting and empty or removed person links', () {
    final tasks = [
      Task(id: 'legacy-flag', title: 'قدیمی', followUpEnabled: true, followUps: [
        FollowUp(id: 'legacy', dateTime: now, result: 'منتظر پاسخ', personIds: ['ana']),
      ]),
      Task(id: 'empty', title: 'بدون فرد', followUps: [
        waiting('empty', []),
      ]),
      Task(id: 'removed', title: 'فرد حذف‌شده', followUps: [
        waiting('removed', ['deleted-person']),
      ]),
    ];

    final rows = const PersonFollowUpReportProjection()
        .project(tasks, people: directory);

    expect(rows.map((row) => row.followUp.id), ['removed']);
    expect(rows.single.people.single.id, 'deleted-person');
    expect(rows.single.people.single.displayName, 'شخص حذف‌شده');
  });

  test('next-action cutoff is independent and excludes missing or later next action', () {
    final task = Task(
      id: 'task',
      title: 'اقدام بعدی',
      followUps: [
        waiting('due', ['ana'], next: DateTime(2026, 10, 15, 9),
            reminder: DateTime(2026, 10, 20, 9)),
        waiting('later', ['ana'], next: DateTime(2026, 10, 17, 9)),
        waiting('none', ['ana']),
      ],
    );

    final rows = const PersonFollowUpReportProjection().project(
      [task],
      people: directory,
      nextActionDueBy: DateTime(2026, 10, 15, 23, 59),
    );

    expect(rows.map((row) => row.followUp.id), ['due']);
    expect(rows.single.reminderDate, DateTime(2026, 10, 20, 9));
  });

  test('keeps a waiting Follow-up visible with a deleted-person placeholder', () {
    final task = Task(
      id: 'task-deleted-person-report',
      title: 'کار دارای سابقه',
      followUpEnabled: false,
      followUps: [
        waiting('fu-deleted-person-report', ['deleted-person-id']),
      ],
    );

    final rows = const PersonFollowUpReportProjection().project(
      [task],
      people: const <PersonReference>[],
    );

    expect(rows, hasLength(1));
    expect(rows.single.task.id, 'task-deleted-person-report');
    expect(rows.single.followUp.id, 'fu-deleted-person-report');
    expect(rows.single.people.single.id, 'deleted-person-id');
    expect(rows.single.people.single.displayName, 'شخص حذف‌شده');
  });

}
