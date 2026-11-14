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
          FollowUp(id: 'a-follow-up', dateTime: DateTime(2026, 10, 7, 15)),
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


  test('report sorting keeps due date primary and priority secondary', () {
    final sameDate = DateTime(2026, 10, 7, 15);
    final lowerPriority = Task(
      id: 'lower-priority',
      title: 'اولویت پایین‌تر',
      dueDate: sameDate,
      priority: TaskPriority.low,
    );
    final highestPriority = Task(
      id: 'highest-priority',
      title: 'اولویت بالاتر',
      dueDate: sameDate,
      priority: TaskPriority.high,
    );
    final laterDate = Task(
      id: 'later-date',
      title: 'تاریخ دیرتر',
      dueDate: DateTime(2026, 10, 8, 9),
      priority: TaskPriority.high,
    );

    final result = const TaskReportFilter().apply(
      [lowerPriority, laterDate, highestPriority],
      now: now,
    );

    expect(
      result.map((task) => task.id),
      ['highest-priority', 'lower-priority', 'later-date'],
    );
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

  test('template name and template task origin combine with Center and existing dimensions', () {
    final now = DateTime(2026, 11, 3, 10);
    final task = Task(id: 'copy-511', title: 'بررسی فن', templateTaskId: 'tt-fan', category: 'سرویس', tags: ['فوری'], dueDate: DateTime(2026, 11, 3, 12));
    final project = ProjectPlan(id: 'p511', title: 'کالیبراسیون 511', centerId: '511', templateId: 'tpl-a', templateNameSnapshot: 'کالیبراسیون یخچال', itemIds: ['copy-511']);
    final filter = const TaskReportFilter(centerIds: {'511'}, templateIds: {'tpl-a'}, templateTaskId: 'tt-fan', projectIds: {'p511'}, categories: {'سرویس'}, tags: {'فوری'}, timePreset: ReportTimePreset.today);
    expect(filter.apply([task], now: now, projects: [project]).map((item) => item.id), ['copy-511']);
    expect(filter.copyWith(templateIds: {}).centerIds, {'511'});
    expect(filter.copyWith(clearTemplateTaskId: true).templateIds, {'tpl-a'});
  });

  test('legacy projects without center or template stay outside selected template reports unless explicitly included', () {
    final now = DateTime(2026, 11, 3, 10);
    final legacy = Task(id: 'legacy', title: 'کار قدیمی');
    final generated = Task(id: 'generated', title: 'کار قالب', templateTaskId: 'tt');
    final projects = [
      ProjectPlan(id: 'legacy-project', title: 'قدیمی', itemIds: ['legacy']),
      ProjectPlan(id: 'generated-project', title: 'قالبی', centerId: '511', templateId: 'tpl', itemIds: ['generated']),
    ];
    final base = const TaskReportFilter(templateIds: {'tpl'});
    expect(base.apply([legacy, generated], now: now, projects: projects).map((task) => task.id), ['generated']);
    expect(base.copyWith(includeLegacyProjectsWithoutTemplate: true).apply([legacy, generated], now: now, projects: projects).map((task) => task.id).toSet(), {'legacy', 'generated'});
  });

  test('legacy Projects without Center are included only when explicitly requested alongside a selected Center', () {
    final now = DateTime(2026, 11, 3);
    final centered = Task(id: 'centered', title: 'کار مرکز');
    final legacy = Task(id: 'legacy-center', title: 'کار قدیمی');
    final projects = [
      ProjectPlan(id: 'p511', title: 'مرکزی', centerId: '511', itemIds: ['centered']),
      ProjectPlan(id: 'p-old', title: 'قدیمی', itemIds: ['legacy-center']),
    ];
    final base = const TaskReportFilter(centerIds: {'511'});
    expect(base.apply([centered, legacy], now: now, projects: projects).map((t) => t.id), ['centered']);
    expect(base.copyWith(includeLegacyProjectsWithoutCenter: true).apply([centered, legacy], now: now, projects: projects).map((t) => t.id).toSet(), {'centered', 'legacy-center'});
  });

  test('follow-up time range matches completedAt, not parent dueDate, and returns unique Tasks', () {
    final now = DateTime(2026, 10, 7, 10);
    final inRange = Task(
      id: 'followup-in-range',
      title: 'پیگیری در بازه',
      dueDate: DateTime(2026, 11, 20),
      followUps: [
        FollowUp(id: 'fu-old', completedAt: DateTime(2026, 10, 1)),
        FollowUp(id: 'fu-match', completedAt: DateTime(2026, 10, 6, 9), personIds: ['p1']),
      ],
    );
    final dueDateOnly = Task(
      id: 'due-date-only',
      title: 'موعد داخل بازه، پیگیری خارج بازه',
      dueDate: DateTime(2026, 10, 6, 9),
      followUps: [
        FollowUp(id: 'fu-outside', completedAt: DateTime(2026, 9, 30)),
      ],
    );
    final mismatchedRecords = Task(
      id: 'mismatched-records',
      title: 'شخص و زمان در دو پیگیری متفاوت',
      followUps: [
        FollowUp(id: 'fu-person-outside', completedAt: DateTime(2026, 9, 30), personIds: ['p1']),
        FollowUp(id: 'fu-date-other-person', completedAt: DateTime(2026, 10, 6), personIds: ['p2']),
      ],
    );
    final result = TaskReportFilter(
      hasFollowUp: true,
      personIds: {'p1'},
      fromDate: DateTime(2026, 10, 5),
      toDate: DateTime(2026, 10, 7),
    ).apply([inRange, dueDateOnly, mismatchedRecords], now: now);
    expect(result.map((task) => task.id), ['followup-in-range']);
    expect(result, hasLength(1));
  });

  test('record-level follow-up filter combines dimensions with OR inside and AND between them', () {
    final task = Task(
      id: 'filtered-task',
      title: 'کار فیلترشده',
      centerId: 'center-a',
      category: 'تعمیر',
      tags: ['فوری', 'مهم'],
      dueDate: DateTime(2026, 12, 1),
      followUps: [
        FollowUp(id: 'fu-in', completedAt: DateTime(2026, 10, 6), personIds: ['p1']),
        FollowUp(id: 'fu-out', completedAt: DateTime(2026, 9, 1), personIds: ['p2']),
      ],
    );
    final projects = [
      ProjectPlan(
        id: 'project-a',
        title: 'پروژه الف',
        centerId: 'center-a',
        itemIds: ['filtered-task', 'wrong-category'],
      ),
    ];
    final wrongCategory = Task(
      id: 'wrong-category',
      title: 'دسته ناسازگار',
      centerId: 'center-a',
      category: 'اداری',
      tags: ['فوری'],
      followUps: [
        FollowUp(id: 'fu-wrong-category', completedAt: DateTime(2026, 10, 6), personIds: ['p1']),
      ],
    );
    final filter = TaskReportFilter(
      hasFollowUp: true,
      centerIds: {'center-a', 'center-b'},
      projectIds: {'project-a', 'project-b'},
      categories: {'تعمیر', 'فروش'},
      tags: {'فوری', 'مهم'},
      personIds: {'p1'},
      fromDate: DateTime(2026, 10, 1),
      toDate: DateTime(2026, 10, 7),
    );
    expect(filter.matchesFollowUpRecord(
      task, task.followUps.first, now: DateTime(2026, 10, 7), projects: projects,
    ), isTrue);
    expect(filter.matchesFollowUpRecord(
      task, task.followUps.last, now: DateTime(2026, 10, 7), projects: projects,
    ), isFalse);
    expect(filter.matchesFollowUpRecord(
      wrongCategory, wrongCategory.followUps.single,
      now: DateTime(2026, 10, 7), projects: projects,
    ), isFalse);
    expect(filter.apply([task, wrongCategory], now: DateTime(2026, 10, 7), projects: projects), hasLength(1));
  });


  test('past follow-up report keeps history when the parent Task is completed', () {
    final completedTask = Task(
      id: 'completed-parent',
      title: 'کار تکمیل‌شده با سابقه',
      completed: true,
      dueDate: DateTime(2026, 12, 20),
      followUps: [
        FollowUp(
          id: 'completed-parent-history',
          completedAt: DateTime(2026, 10, 1),
          completed: true,
        ),
      ],
    );
    final result = const TaskReportFilter(
      hasFollowUp: true,
      timePreset: ReportTimePreset.past,
    ).apply([completedTask], now: DateTime(2026, 10, 7));
    expect(result.map((task) => task.id), ['completed-parent']);
  });

}
