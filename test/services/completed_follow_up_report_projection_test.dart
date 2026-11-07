import 'package:arvin/models/task.dart';
import 'package:arvin/services/completed_follow_up_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = CompletedFollowUpReportProjection();

  test('filters only genuine Follow-up completedAt within the local half-open day', () {
    final day = DateTime(2026, 11, 1);
    final tasks = [
      Task(
        id: 'task-a',
        title: 'کار الف',
        dueDate: DateTime(2026, 11, 1, 10),
        completedAt: DateTime(2026, 11, 1, 11),
        followUps: [
          FollowUp(
            id: 'a-before',
            dateTime: DateTime(2026, 10, 31, 23, 59, 59, 999),
            note: 'روز قبل',
          ),
          FollowUp(
            id: 'a-start',
            dateTime: DateTime(2026, 11, 1),
            note: 'ابتدای روز',
          ),
          FollowUp(
            id: 'a-later',
            dateTime: DateTime(2026, 11, 1, 9, 30),
            note: 'پیگیری دوم',
          ),
          FollowUp(
            id: 'a-end',
            dateTime: DateTime(2026, 11, 2),
            note: 'ابتدای روز بعد',
          ),
        ],
      ),
      Task(
        id: 'task-b',
        title: 'کار ب',
        completed: true,
        completedAt: DateTime(2026, 11, 1, 15),
        dueDate: DateTime(2026, 11, 1, 16),
        followUps: [
          FollowUp(
            id: 'b-one',
            dateTime: DateTime(2026, 11, 1, 12),
            note: 'سابقه کار ب',
          ),
        ],
      ),
      Task(
        id: 'task-c',
        title: 'فقط یادآور و موعد',
        dueDate: DateTime(2026, 11, 1, 8),
      ),
    ];

    final rows = projection.forLocalDay(tasks, day);
    expect(rows.map((row) => row.followUp.id).toList(),
        ['a-start', 'a-later', 'b-one']);
    expect(rows.map((row) => row.taskId).toSet(), {'task-a', 'task-b'});
  });

  test('same-day multiple records aggregate by stable taskId and sort by time', () {
    final tasks = [
      Task(
        id: 'same-task-id',
        title: 'نام تکراری',
        followUps: [
          FollowUp(id: 'later', dateTime: DateTime(2026, 11, 1, 17)),
          FollowUp(id: 'earlier', dateTime: DateTime(2026, 11, 1, 8)),
        ],
      ),
      Task(
        id: 'other-task-id',
        title: 'نام تکراری',
        followUps: [
          FollowUp(id: 'other', dateTime: DateTime(2026, 11, 1, 9)),
        ],
      ),
    ];

    final rows = projection.forLocalDay(tasks, DateTime(2026, 11, 1));
    expect(rows.map((row) => row.followUp.id).toList(),
        ['earlier', 'other', 'later']);
    expect(rows.map((row) => row.taskId).toSet(),
        {'same-task-id', 'other-task-id'});
  });

  test('tasks without genuine Follow-up records are excluded', () {
    final tasks = [
      Task(
        id: 'task-only-completed',
        title: 'تکمیل شده',
        completed: true,
        completedAt: DateTime(2026, 11, 1, 10),
      ),
      Task(
        id: 'task-only-due-date',
        title: 'موعد امروز',
        dueDate: DateTime(2026, 11, 1, 10),
      ),
    ];
    expect(
      projection.forLocalDay(tasks, DateTime(2026, 11, 1)),
      isEmpty,
    );
  });
}
