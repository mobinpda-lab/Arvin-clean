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
        followUpEnabled: true,
        followUps: <FollowUp>[
          FollowUp(id: 'a-follow-up', dateTime: DateTime(2026, 10, 7, 9)),
        ],
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
        followUpEnabled: true,
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
  test('waiting-for-response tri-state filters active follow-ups without parallel state', () {
    final tasks = [
      Task(
        id: 'waiting',
        title: 'منتظر پاسخ',
        followUps: [
          FollowUp(
            id: 'waiting-follow-up',
            dateTime: now,
            personIds: ['ana'],
            waitingForResponse: true,
          ),
        ],
      ),
      Task(
        id: 'not-waiting',
        title: 'بدون انتظار',
        followUps: [
          FollowUp(
            id: 'completed-waiting-follow-up',
            dateTime: now,
            personIds: ['ana'],
            waitingForResponse: true,
            completed: true,
          ),
        ],
      ),
      Task(id: 'no-follow-up', title: 'بدون پیگیری'),
    ];

    expect(
      const TaskReportFilter(waitingForResponse: true)
          .apply(tasks, now: now)
          .map((task) => task.id),
      ['waiting'],
    );
    expect(
      const TaskReportFilter(waitingForResponse: false)
          .apply(tasks, now: now)
          .map((task) => task.id),
      ['not-waiting', 'no-follow-up'],
    );
    expect(const TaskReportFilter().copyWith(clearWaitingForResponse: true).isActive, isFalse);
  });


  test('external calendar filter is explicit and uses the canonical time window', () {
    final eventTime = DateTime(2026, 10, 7, 15);
    final filter = const TaskReportFilter().copyWith(
      timePreset: ReportTimePreset.today,
      showExternalCalendarEvents: true,
    );
    expect(filter.isActive, isTrue);
    expect(filter.showExternalCalendarEvents, isTrue);
    expect(
      filter.matchesExternalCalendarDate(
        eventTime,
        now: DateTime(2026, 10, 7, 10),
      ),
      isTrue,
    );
    expect(
      filter.matchesExternalCalendarDate(
        eventTime,
        now: DateTime(2026, 10, 8, 10),
      ),
      isFalse,
    );
    expect(
      filter.copyWith(
        timePreset: ReportTimePreset.all,
        showExternalCalendarEvents: false,
      ).isActive,
      isFalse,
    );
  });



  test('center and task filters combine with project, category, tag and time without resetting other dimensions', () {
    final now = DateTime(2026, 11, 3, 10);
    final matching = Task(id: 'task-511', title: 'فن', category: 'تعمیر', tags: ['فوری'], dueDate: DateTime(2026, 11, 3, 12));
    final otherCenter = Task(id: 'task-512', title: 'فن', category: 'تعمیر', tags: ['فوری'], dueDate: DateTime(2026, 11, 3, 12));
    final projects = [
      ProjectPlan(id: 'p511', title: 'کالیبراسیون 511', centerId: '511', itemIds: ['task-511']),
      ProjectPlan(id: 'p512', title: 'کالیبراسیون 512', centerId: '512', itemIds: ['task-512']),
    ];
    final selected = const TaskReportFilter(centerIds: {'511'}, taskId: 'task-511', projectIds: {'p511'}, categories: {'تعمیر'}, tags: {'فوری'}, timePreset: ReportTimePreset.today);
    expect(selected.apply([matching, otherCenter], now: now, projects: projects).map((task) => task.id), ['task-511']);
    expect(selected.copyWith(clearTaskId: true).centerIds, {'511'});
    expect(selected.copyWith(clearTaskId: true).projectIds, {'p511'});
    expect(selected.copyWith(centerIds: {}).taskId, 'task-511');
    expect(selected.isActive, isTrue);
  });
}
