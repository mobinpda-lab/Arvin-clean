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
}
