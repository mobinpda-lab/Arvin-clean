import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_list_scope_service.dart';

void main() {
  Task task(
    String id, {
    bool followUpEnabled = false,
    List<FollowUp> followUps = const [],
    bool archived = false,
    bool trashed = false,
    bool completed = false,
  }) {
    return Task(
      id: id,
      title: id,
      followUpEnabled: followUpEnabled,
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

  test('simple-note scope uses canonical unified Item semantics', () {
    final note = task('note');
    final enabled = task('enabled', followUpEnabled: true);
    final historyOnly = task(
      'history',
      followUps: <FollowUp>[
        FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 28, 9)),
      ],
    );

    final result = const TaskListScopeService().project(
      <Task>[note, enabled, historyOnly],
      scope: TaskListScope.simpleNotes,
    );

    expect(result, <Task>[note]);
  });

  test('follow-up scope accepts explicit enablement or canonical history', () {
    final note = task('note');
    final enabled = task('enabled', followUpEnabled: true);
    final historyOnly = task(
      'history',
      followUps: <FollowUp>[
        FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 28, 9)),
      ],
    );

    final result = const TaskListScopeService().project(
      <Task>[note, enabled, historyOnly],
      scope: TaskListScope.followUpEnabled,
    );

    expect(result, <Task>[enabled, historyOnly]);
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
