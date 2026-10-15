import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 7, 10, 0);

  test('combined filters use AND semantics without mutating tasks', () {
    final tasks = [
      Task(
        id: 'a',
        title: 'اول',
        dueDate: DateTime(2026, 10, 7, 15, 0),
        category: 'کار',
        tags: ['مهم'],
        priority: TaskPriority.high,
        followUps: [FollowUp(id: 'fa', dateTime: DateTime(2026, 10, 7, 9))],
        checklist: ['یک'],
      ),
      Task(
        id: 'b',
        title: 'دوم',
        dueDate: DateTime(2026, 10, 7, 15, 0),
        category: 'خانه',
        tags: ['مهم'],
        priority: TaskPriority.high,
      ),
      Task(
        id: 'c',
        title: 'سوم',
        dueDate: DateTime(2026, 10, 7, 18, 0),
        category: 'کار',
        tags: ['مهم'],
        priority: TaskPriority.high,
        followUps: [FollowUp(id: 'fc', dateTime: DateTime(2026, 10, 7, 9))],
        checklist: ['یک'],
      ),
    ];
    final projects = [
      ProjectPlan(id: 'p', title: 'پروژه', itemIds: ['a', 'c']),
    ];

    final result = const TaskReportFilter(
      timePreset: ReportTimePreset.today,
      fromTime: Duration(hours: 14),
      toTime: Duration(hours: 17),
      projectId: 'p',
      category: 'کار',
      tag: 'مهم',
      priority: TaskPriority.high,
      hasFollowUp: true,
      hasChecklist: true,
    ).apply(tasks, now: now, projects: projects);

    expect(result.map((task) => task.id), ['a']);
    expect(tasks.map((task) => task.id), ['a', 'b', 'c']);
  });

  test('time presets handle undated and future tasks', () {
    final tasks = [
      Task(id: 'past', title: 'گذشته', dueDate: DateTime(2026, 10, 6, 10)),
      Task(id: 'today', title: 'امروز', dueDate: DateTime(2026, 10, 7, 10)),
      Task(id: 'future', title: 'آینده', dueDate: DateTime(2026, 10, 8, 10)),
      Task(id: 'none', title: 'بدون زمان'),
    ];

    expect(
      const TaskReportFilter(timePreset: ReportTimePreset.past)
          .apply(tasks, now: now)
          .map((task) => task.id),
      ['past'],
    );
    expect(
      const TaskReportFilter(timePreset: ReportTimePreset.future)
          .apply(tasks, now: now)
          .map((task) => task.id),
      ['future'],
    );
    expect(
      const TaskReportFilter(timePreset: ReportTimePreset.undated)
          .apply(tasks, now: now)
          .map((task) => task.id),
      ['none'],
    );
  });
  test('Person and waiting filters target Follow-up records without conflating next action and Reminder', () {
    final waiting = Task(
      id: 'waiting-task',
      title: 'کار منتظر پاسخ',
      followUps: [
        FollowUp(
          id: 'waiting-ali',
          dateTime: DateTime(2026, 10, 6, 9),
          waitingForResponse: true,
          personIds: const ['ali'],
          nextFollowUp: DateTime(2026, 10, 9, 10),
          reminderDate: DateTime(2026, 10, 8, 8),
        ),
        FollowUp(
          id: 'not-waiting-sara',
          dateTime: DateTime(2026, 10, 6, 11),
          waitingForResponse: false,
          personIds: const ['sara'],
          nextFollowUp: DateTime(2026, 10, 10, 11),
        ),
      ],
    );
    final completed = Task(
      id: 'completed-task',
      title: 'تکمیل‌شده',
      completed: true,
      followUps: [
        FollowUp(
          id: 'completed-waiting',
          dateTime: DateTime(2026, 10, 6, 12),
          waitingForResponse: true,
          personIds: const ['ali'],
        ),
      ],
    );
    const filter = TaskReportFilter(
      personIds: {'ali'},
      waitingForResponseOnly: true,
      timePreset: ReportTimePreset.future,
    );

    final result = filter.apply(
      [waiting, completed],
      now: now,
      ignoreTaskTime: true,
    );
    expect(result.map((task) => task.id), ['waiting-task']);
    expect(filter.matchesFollowUpTime(waiting.followUps.first, now: now), isTrue);
    expect(filter.matchesFollowUpTime(
      FollowUp(
        id: 'reminder-is-future-but-next-action-is-past',
        dateTime: DateTime(2026, 10, 6, 12),
        nextFollowUp: DateTime(2026, 10, 6, 8),
        reminderDate: DateTime(2026, 10, 20, 8),
      ),
      now: now,
    ), isFalse);
  });

}
