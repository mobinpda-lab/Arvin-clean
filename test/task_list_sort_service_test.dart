import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_list_sort_service.dart';

void main() {
  Task task(
    String id, {
    String? title,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FollowUp> followUps = const [],
  }) {
    return Task(
      id: id,
      title: title ?? id,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      followUps: followUps,
    );
  }

  test('date sort supports both directions and keeps undated items last', () {
    final early = task('early', dueDate: DateTime(2026, 8, 28, 8));
    final late = task('late', dueDate: DateTime(2026, 8, 29, 8));
    final undated = task('undated');
    const service = TaskListSortService();

    expect(
      service.sort(<Task>[late, undated, early], by: TaskListSort.date),
      <Task>[early, late, undated],
    );
    expect(
      service.sort(
        <Task>[late, undated, early],
        by: TaskListSort.date,
        descending: true,
      ),
      <Task>[late, early, undated],
    );
  });

  test('latest sort uses newest meaningful task or follow-up timestamp', () {
    final created = task('created', createdAt: DateTime(2026, 8, 25));
    final updated = task(
      'updated',
      createdAt: DateTime(2026, 8, 20),
      updatedAt: DateTime(2026, 8, 27),
    );
    final followed = task(
      'followed',
      updatedAt: DateTime(2026, 8, 26),
      followUps: <FollowUp>[
        FollowUp(id: 'f1', dateTime: DateTime(2026, 8, 28, 10)),
      ],
    );

    final result = const TaskListSortService().sort(
      <Task>[followed, created, updated],
      by: TaskListSort.latest,
      descending: true,
    );

    expect(result, <Task>[followed, updated, created]);
  });

  test('last FollowUp sort ignores updatedAt and keeps no-history Tasks last', () {
    final olderHistory = task(
      'older-history',
      updatedAt: DateTime(2026, 8, 31),
      followUps: <FollowUp>[
        FollowUp(id: 'older-f1', dateTime: DateTime(2026, 8, 20, 9)),
      ],
    );
    final newerHistory = task(
      'newer-history',
      updatedAt: DateTime(2026, 8, 1),
      followUps: <FollowUp>[
        FollowUp(id: 'newer-f1', dateTime: DateTime(2026, 8, 23, 9)),
        FollowUp(id: 'newer-f2', dateTime: DateTime(2026, 8, 28, 11)),
      ],
    );
    final noHistory = task(
      'no-history',
      updatedAt: DateTime(2026, 9, 1),
    );
    const service = TaskListSortService();

    expect(
      service.sort(
        <Task>[noHistory, olderHistory, newerHistory],
        by: TaskListSort.lastFollowUp,
      ),
      <Task>[olderHistory, newerHistory, noHistory],
    );
    expect(
      service.sort(
        <Task>[noHistory, olderHistory, newerHistory],
        by: TaskListSort.lastFollowUp,
        descending: true,
      ),
      <Task>[newerHistory, olderHistory, noHistory],
    );
  });

  test('title sort supports ascending and descending without mutation', () {
    final alpha = task('a', title: 'Alpha');
    final beta = task('b', title: ' beta ');
    final source = <Task>[beta, alpha];
    const service = TaskListSortService();

    expect(
      service.sort(source, by: TaskListSort.title),
      <Task>[alpha, beta],
    );
    expect(
      service.sort(source, by: TaskListSort.title, descending: true),
      <Task>[beta, alpha],
    );
    expect(source, <Task>[beta, alpha]);
  });

  test('equal sort values use deterministic id tie break', () {
    final b = task('b', dueDate: DateTime(2026, 8, 28));
    final a = task('a', dueDate: DateTime(2026, 8, 28));

    final result = const TaskListSortService().sort(
      <Task>[b, a],
      by: TaskListSort.date,
    );

    expect(result.map((item) => item.id), <String>['a', 'b']);
  });
}
