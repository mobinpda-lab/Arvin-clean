import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/services/person_follow_up_report_projection.dart';
import 'package:arvin/services/task_edit_apply_service.dart';
import 'package:arvin/services/task_report_filter.dart';

void main() {
  test('Task JSON preserves independent Center ID and true all-day due date', () {
    final task = Task(
      id: 'task-center-all-day',
      title: 'آماده‌سازی',
      centerId: 'center-school',
      dueDate: DateTime(2026, 11, 6),
      allDay: true,
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.centerId, 'center-school');
    expect(restored.dueDate, DateTime(2026, 11, 6));
    expect(restored.allDay, isTrue);
    expect(restored.toJson()['allDay'], isTrue);
  });

  test('Task edit application preserves the independently selected Center', () {
    final target = Task(id: 'task-1', title: 'کار', centerId: 'center-old');
    final edited = Task(id: 'task-1', title: 'کار ویرایش‌شده', centerId: 'center-new');

    TaskEditApplyService(now: () => DateTime(2026, 11, 6))
        .apply(target, edited);

    expect(target.centerId, 'center-new');
    expect(target.title, 'کار ویرایش‌شده');
  });

  test('Report Center filters directly by Task Center ID without requiring a Project', () {
    final matching = Task(id: 'matching', title: 'کار اول', centerId: 'center-a');
    final other = Task(id: 'other', title: 'کار دوم', centerId: 'center-b');

    final result = const TaskReportFilter(centerIds: {'center-a'}).apply(
      [matching, other],
      now: DateTime(2026, 11, 6, 12),
    );

    expect(result.map((task) => task.id), ['matching']);
  });

  test('Person report matches the stable personId saved on a waiting Follow-up', () {
    final task = Task(
      id: 'waiting-task',
      title: 'تماس با همکار',
      followUps: [
        FollowUp(
          id: 'waiting-follow-up',
          dateTime: DateTime(2026, 11, 6, 9),
          waitingForResponse: true,
          personIds: const ['person-42'],
        ),
      ],
    );
    const person = PersonReference(id: 'person-42', displayName: 'سارا');

    final projection = const PersonFollowUpReportProjection();
    final matching = projection.project(
      [task],
      people: const [person],
      personIds: const {'person-42'},
    );
    final notMatching = projection.project(
      [task],
      people: const [person],
      personIds: const {'person-other'},
    );

    expect(matching, hasLength(1));
    expect(matching.single.task.id, 'waiting-task');
    expect(matching.single.people.single.id, 'person-42');
    expect(notMatching, isEmpty);
  });
}
