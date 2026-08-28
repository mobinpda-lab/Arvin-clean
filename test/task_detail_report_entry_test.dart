import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_projection.dart';

void main() {
  test('Task Detail exposes canonical PDF print share report entry', () {
    final source = File('lib/task_detail_page.dart').readAsStringSync();

    expect(source, contains("import 'task_report_page.dart';"));
    expect(source, contains("ValueKey('task-detail-report')"));
    expect(source, contains('TaskReportPage(tasks: [_task])'));
    expect(source, contains('PDF، چاپ و اشتراک‌گذاری'));
  });

  test('single Task report projection preserves complete FollowUp history', () {
    final task = Task(
      id: 'task-1',
      title: 'تماس با علی',
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 26, 9, 20),
          note: 'اولین تماس',
        ),
        FollowUp(
          id: 'f2',
          dateTime: DateTime(2026, 8, 28, 10, 45),
          note: 'هماهنگی انجام شد',
        ),
      ],
    );

    final report = const TaskReportProjection().project(
      [task],
      selectedIds: {'task-1'},
    );

    expect(report.entries, hasLength(1));
    expect(report.entries.single.id, 'task-1');
    expect(report.entries.single.followUps.map((item) => item.id), ['f1', 'f2']);
  });
}
