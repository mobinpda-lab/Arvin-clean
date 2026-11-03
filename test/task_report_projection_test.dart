import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = TaskReportProjection();

  test('projects one, selected, or all canonical tasks without mutation', () {
    final tasks = [
      Task(
        id: 'one',
        title: 'گزارش فروش',
        description: 'توضیحات فارسی',
        tags: ['مهم'],
        checklist: ['[x] ارسال'],
      ),
      Task(id: 'two', title: 'کار دوم'),
      Task(id: 'trash', title: 'حذف‌شده', trashed: true),
    ];

    expect(projection.project(tasks).entries.map((e) => e.id), ['one', 'two']);
    expect(
      projection.project(tasks, selectedIds: {'one'}).entries.map((e) => e.id),
      ['one'],
    );
    final entry = projection.project(tasks, selectedIds: {'one'}).entries.single;
    expect(entry.title, 'گزارش فروش');
    expect(entry.description, 'توضیحات فارسی');
    expect(entry.tags, ['مهم']);
    expect(entry.checklist, ['[x] ارسال']);
  });
  test('disabled checklist rows remain on Task but are excluded from reports', () {
    final task = Task(
      id: 'disabled-report-checklist',
      title: 'کار با چک‌لیست خاموش',
      checklist: const ['[ ] کیف'],
      checklistEnabled: false,
    );

    final entry = projection.project([task]).entries.single;

    expect(task.checklist, const ['[ ] کیف']);
    expect(entry.checklist, isEmpty);
  });

  test('groups report entries in P1 to P4 order and preserves order within each group', () {
    final report = projection.project([
      Task(id: 'p3-first', title: 'اول P3', priority: TaskPriority.low),
      Task(id: 'p1', title: 'P1', priority: TaskPriority.high),
      Task(id: 'p4', title: 'P4', priority: TaskPriority.none),
      Task(id: 'p2', title: 'P2', priority: TaskPriority.medium),
      Task(id: 'p3-second', title: 'دوم P3', priority: TaskPriority.low),
    ]);
    expect(
      report.priorityGroups.map((group) => group.priority),
      [TaskPriority.high, TaskPriority.medium, TaskPriority.low, TaskPriority.none],
    );
    expect(
      report.priorityGroups.map((group) => group.entries.map((entry) => entry.id).toList()).toList(),
      [['p1'], ['p2'], ['p3-first', 'p3-second'], ['p4']],
    );
  });

}
