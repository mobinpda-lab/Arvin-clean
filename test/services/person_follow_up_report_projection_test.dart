import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/person_follow_up_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ana = PersonReference(id: 'ana', displayName: 'آنا');
  final reza = PersonReference(id: 'reza', displayName: 'رضا');
  final now = DateTime(2026, 10, 15, 10);

  test('waiting projection uses the structured flag, not free-form result text', () {
    final task = Task(
      id: 'task-1',
      title: 'پیگیری قرارداد',
      followUps: [
        FollowUp(
          id: 'structured-waiting',
          dateTime: now,
          result: 'نتیجه آزاد',
          waitingForResponse: true,
          personIds: const ['ana'],
        ),
        FollowUp(
          id: 'text-only',
          dateTime: now,
          result: 'منتظر پاسخ',
          waitingForResponse: false,
          personIds: const ['ana'],
        ),
      ],
    );

    final rows = const PersonFollowUpReportProjection().project(
      [task],
      people: [ana, reza],
      personIds: const {'ana'},
      waitingForResponseOnly: true,
    );

    expect(rows.map((row) => row.followUp.id), ['structured-waiting']);
    expect(rows.single.people.single.id, 'ana');
  });

  test('person report can include non-waiting Follow-ups and keep dangling IDs visible', () {
    final task = Task(
      id: 'task-2',
      title: 'پیگیری قدیمی',
      followUps: [
        FollowUp(
          id: 'not-waiting',
          dateTime: now,
          waitingForResponse: false,
          personIds: const ['reza'],
        ),
        FollowUp(
          id: 'removed-person',
          dateTime: now,
          waitingForResponse: true,
          personIds: const ['removed'],
        ),
      ],
    );

    final projection = const PersonFollowUpReportProjection();
    final personRows = projection.project(
      [task],
      people: [ana, reza],
      personIds: const {'reza'},
      waitingForResponseOnly: false,
    );
    expect(personRows.map((row) => row.followUp.id), ['not-waiting']);

    final danglingRows = projection.project(
      [task],
      people: [ana, reza],
      waitingForResponseOnly: true,
      includeDanglingPeople: true,
    );
    expect(danglingRows.map((row) => row.followUp.id), ['removed-person']);
    expect(danglingRows.single.people.single.displayName, 'شخص حذف‌شده');
  });
}
