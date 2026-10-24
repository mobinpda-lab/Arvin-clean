import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_timeline_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TaskTimelineService();

  test('builds a chronological timeline from Task timestamps, Reminder IDs and history', () {
    final task = Task(
      id: 'task-1',
      title: 'پرونده مشتری',
      createdAt: DateTime(2026, 8, 26, 8),
      dueDate: DateTime(2026, 8, 26, 11),
      taskReminders: [
        TaskReminder(id: 'r1', title: 'یادآوری', date: DateTime(2026, 8, 26, 12), sequence: 1),
      ],
      updatedAt: DateTime(2026, 8, 26, 15),
      followUps: [
        FollowUp(id: 'late', dateTime: DateTime(2026, 8, 26, 14), note: 'پیگیری دوم'),
        FollowUp(id: 'early', dateTime: DateTime(2026, 8, 26, 10), note: 'پیگیری اول'),
      ],
    );
    final timeline = service.build(task);
    expect(timeline.map((entry) => entry.kind).toList(), [
      TaskTimelineEntryKind.created,
      TaskTimelineEntryKind.followUp,
      TaskTimelineEntryKind.due,
      TaskTimelineEntryKind.reminder,
      TaskTimelineEntryKind.followUp,
      TaskTimelineEntryKind.updated,
    ]);
    expect(timeline.map((entry) => entry.dateTime.hour).toList(), [8, 10, 11, 12, 14, 15]);
    expect(timeline.where((entry) => entry.kind == TaskTimelineEntryKind.reminder).single.id,
        'task:task-1:reminder:r1');
  });

  test('preserves stable Follow-up history IDs, notes and results', () {
    final task = Task(
      id: 'task-2',
      title: 'فروش',
      followUps: [
        FollowUp(id: 'followup-42', dateTime: DateTime(2026, 8, 26, 11, 30), note: 'تماس با مشتری', result: 'پاسخ مثبت'),
      ],
    );
    final entry = service.build(task).single;
    expect(entry.id, 'followup:followup-42');
    expect(entry.kind, TaskTimelineEntryKind.followUp);
    expect(entry.note, 'تماس با مشتری');
    expect(entry.result, 'پاسخ مثبت');
  });

  test('legacy Follow-up schedule fields never fabricate timeline entries', () {
    final task = Task(
      id: 'legacy',
      title: 'قدیمی',
      followUpDate: DateTime(2026, 8, 27, 9),
      reminderDate: DateTime(2026, 8, 27, 10),
      followUps: [
        FollowUp(
          id: 'real',
          dateTime: DateTime(2026, 8, 28, 10),
          nextFollowUp: DateTime(2026, 8, 27, 11),
          reminderDate: DateTime(2026, 8, 27, 12),
        ),
      ],
    );
    final timeline = service.build(task);
    expect(timeline, hasLength(1));
    expect(timeline.single.id, 'followup:real');
  });

  test('same-time independent Reminder and due date retain distinct timeline entries', () {
    final sameTime = DateTime(2026, 8, 26, 12);
    final task = Task(
      id: 'same-time',
      title: 'هم‌زمان',
      createdAt: sameTime,
      dueDate: sameTime,
      taskReminders: [
        TaskReminder(id: 'r1', title: 'اول', date: sameTime, sequence: 1),
        TaskReminder(id: 'r2', title: 'دوم', date: sameTime, sequence: 2),
      ],
      updatedAt: sameTime,
      followUps: [FollowUp(id: 'b', dateTime: sameTime), FollowUp(id: 'a', dateTime: sameTime)],
    );
    expect(
      service.build(task).map((entry) => entry.id).toSet(),
      {
        'task:same-time:created',
        'task:same-time:due',
        'task:same-time:reminder:r1',
        'task:same-time:reminder:r2',
        'followup:a',
        'followup:b',
        'task:same-time:updated',
      },
    );
  });
}
