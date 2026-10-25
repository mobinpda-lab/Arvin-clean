import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_list_scope_service.dart';

void main() {
  Task task(
    String id, {
    bool followUpEnabled = false,
    DateTime? followUpDate,
    List<FollowUp> followUps = const [],
    bool archived = false,
    bool trashed = false,
    bool completed = false,
  }) {
    return Task(
      id: id,
      title: id,
      followUpEnabled: followUpEnabled,
      followUpDate: followUpDate,
      followUps: followUps,
      archived: archived,
      trashed: trashed,
      completed: completed,
    );
  }

  test('all scope excludes archive and trash but keeps completion history', () {
    final active = task('active');
    final done = task('done', completed: true);
    final archived = task('archived', archived: true);
    final trashed = task('trashed', trashed: true);

    final result = const TaskListScopeService().project(
      <Task>[active, done, archived, trashed],
      scope: TaskListScope.all,
    );

    expect(result, <Task>[active, done]);
    expect(identical(result.first, active), isTrue);
  });

  test('simple-note scope ignores retired schedule fields but excludes history', () {
    final plain = task('plain');
    final enabled = task('enabled', followUpEnabled: true);
    final legacyDate = task(
      'legacy-date',
      followUpDate: DateTime(2026, 8, 28, 10),
    );
    final historyOnly = task(
      'history',
      followUps: <FollowUp>[
        FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 28, 9)),
      ],
    );

    final result = const TaskListScopeService().project(
      <Task>[plain, enabled, legacyDate, historyOnly],
      scope: TaskListScope.simpleNotes,
    );

    expect(result, <Task>[plain, enabled, legacyDate],
        reason: 'retired schedule fields are not active FollowUp behavior');
  });

  test('follow-up scope accepts enablement, legacy date, or history', () {
    final plain = task('plain');
    final enabled = task('enabled', followUpEnabled: true);
    final legacyDate = task(
      'legacy-date',
      followUpDate: DateTime(2026, 8, 28, 10),
    );
    final historyOnly = task(
      'history',
      followUps: <FollowUp>[
        FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 28, 9)),
      ],
    );

    final result = const TaskListScopeService().project(
      <Task>[plain, enabled, legacyDate, historyOnly],
      scope: TaskListScope.followUpHistory,
    );

    expect(result, <Task>[historyOnly]);
  });

  test('projection never mutates or reorders the source list', () {
    final first = task('first');
    final second = task('second', followUpEnabled: true);
    final source = <Task>[first, second];

    const TaskListScopeService().project(
      source,
      scope: TaskListScope.all,
    );

    expect(source, <Task>[first, second]);
  });
}
