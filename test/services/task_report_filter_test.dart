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
        followUpEnabled: true,
        followUps: [FollowUp(id: 'fa', dateTime: DateTime(2026, 10, 7, 9))],
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

  test('Follow-up report filter ignores the legacy flag when no record exists', () {
    final legacyFlagOnly = Task(
      id: 'legacy-flag-only',
      title: 'قدیمی',
      followUpEnabled: true,
    );
    final canonicalFollowUp = Task(
      id: 'canonical-follow-up',
      title: 'پیگیری واقعی',
      followUps: [FollowUp(id: 'f1', dateTime: DateTime(2026, 10, 7, 9))],
    );

    final withFollowUp = const TaskReportFilter(hasFollowUp: true)
        .apply([legacyFlagOnly, canonicalFollowUp], now: now);
    final withoutFollowUp = const TaskReportFilter(hasFollowUp: false)
        .apply([legacyFlagOnly, canonicalFollowUp], now: now);

    expect(withFollowUp.map((task) => task.id), ['canonical-follow-up']);
    expect(withoutFollowUp.map((task) => task.id), ['legacy-flag-only']);
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
  test('Person filter selects Tasks by canonical Follow-up Person IDs', () {
    final tasks = [
      Task(
        id: 'ali-task',
        title: 'پاسخ علی',
        followUps: [
          FollowUp(
            id: 'ali-follow-up',
            dateTime: DateTime(2026, 10, 7, 8),
            waitingForResponse: true,
            personIds: const ['ali'],
          ),
        ],
      ),
      Task(
        id: 'sara-task',
        title: 'پاسخ سارا',
        followUps: [
          FollowUp(
            id: 'sara-follow-up',
            dateTime: DateTime(2026, 10, 7, 8),
            waitingForResponse: true,
            personIds: const ['sara'],
          ),
        ],
      ),
      Task(id: 'legacy', title: 'بدون شخص', followUpEnabled: true),
    ];

    final result = const TaskReportFilter(personIds: {'ali'})
        .apply(tasks, now: now, ignoreTaskTime: true);
    expect(result.map((task) => task.id), ['ali-task']);
  });

  test('waiting report excludes completed follow-ups and inactive Tasks', () {
    final tasks = [
      Task(
        id: 'active-waiting',
        title: 'منتظر پاسخ',
        followUps: [
          FollowUp(
            id: 'active',
            dateTime: DateTime(2026, 10, 7, 8),
            waitingForResponse: true,
          ),
          FollowUp(
            id: 'completed',
            dateTime: DateTime(2026, 10, 7, 9),
            waitingForResponse: true,
            completed: true,
          ),
        ],
      ),
      Task(
        id: 'done-task',
        title: 'کار تمام‌شده',
        completed: true,
        followUps: [
          FollowUp(
            id: 'done-waiting',
            dateTime: DateTime(2026, 10, 7, 8),
            waitingForResponse: true,
          ),
        ],
      ),
      Task(
        id: 'archived-task',
        title: 'کار بایگانی',
        archived: true,
        followUps: [
          FollowUp(
            id: 'archived-waiting',
            dateTime: DateTime(2026, 10, 7, 8),
            waitingForResponse: true,
          ),
        ],
      ),
    ];

    final result = const TaskReportFilter(waitingForResponseOnly: true)
        .apply(tasks, now: now, ignoreTaskTime: true);
    expect(result.map((task) => task.id), ['active-waiting']);
  });

  test('Follow-up date filtering uses nextFollowUp independently of Reminder', () {
    final followUp = FollowUp(
      id: 'next-action',
      dateTime: DateTime(2026, 10, 6, 8),
      reminderDate: DateTime(2026, 10, 7, 10),
      nextFollowUp: DateTime(2026, 10, 8, 10),
    );

    expect(
      const TaskReportFilter(timePreset: ReportTimePreset.future)
          .matchesFollowUpTime(followUp, now: now),
      isTrue,
    );
    expect(
      const TaskReportFilter(timePreset: ReportTimePreset.today)
          .matchesFollowUpTime(followUp, now: now),
      isFalse,
    );
  });

}
