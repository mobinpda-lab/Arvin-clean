import 'package:arvin/home/grouping/home_group_mode.dart';
import 'package:arvin/home/grouping/home_grouping_service.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/services/iran_clock.dart';

void main() {
  const service = HomeGroupingService();

  Task task(
    String id, {
    DateTime? dueDate,
    String? category,
    List<String> tags = const [],
    bool completed = false,
    bool trashed = false,
  }) {
    return Task(
      id: id,
      title: id,
      dueDate: dueDate,
      category: category,
      tags: tags,
      completed: completed,
      trashed: trashed,
    );
  }

  test('time projection uses due date day without today/future overlap', () {
    final now = IranClock.now();
    final todayAt2300 = DateTime(now.year, now.month, now.day, 23);
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    final yesterday = DateTime(now.year, now.month, now.day - 1, 9);

    final groups = service.buildGroups(
      HomeGroupMode.time,
      [
        task('late-today', dueDate: todayAt2300),
        task('tomorrow', dueDate: tomorrow),
        task('overdue', dueDate: yesterday),
        task('no-date'),
      ],
    );

    expect(
      groups.singleWhere((group) => group.id == 'today').items
          .map((item) => item.id),
      ['late-today'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'future').items
          .map((item) => item.id),
      ['tomorrow'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'overdue').items
          .map((item) => item.id),
      ['overdue'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'no_date').items
          .map((item) => item.id),
      ['no-date'],
    );
  });

  test('project projection uses ProjectPlan item ids and no-project fallback', () {
    final tasks = [task('a'), task('b'), task('c')];
    final projects = [
      ProjectPlan(id: 'p1', title: 'Project 1', itemIds: const ['a']),
      ProjectPlan(id: 'p2', title: 'Project 2', itemIds: const ['b']),
    ];

    final groups = service.buildGroups(
      HomeGroupMode.projects,
      tasks,
      projects: projects,
    );

    expect(
      groups.singleWhere((group) => group.id == 'p1').items
          .map((item) => item.id),
      ['a'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'p2').items
          .map((item) => item.id),
      ['b'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'no_project').items
          .map((item) => item.id),
      ['c'],
    );
  });

  test('project projection never multiplies one task across corrupt memberships', () {
    final tasks = [task('a')];
    final projects = [
      ProjectPlan(id: 'p1', title: 'Project 1', itemIds: const ['a']),
      ProjectPlan(id: 'p2', title: 'Project 2', itemIds: const ['a']),
    ];

    final groups = service.buildGroups(
      HomeGroupMode.projects,
      tasks,
      projects: projects,
    );

    final projectedIds = groups
        .expand((group) => group.items)
        .map((item) => item.id)
        .toList();

    expect(projectedIds, ['a']);
  });

  test('category projection normalizes empty values into uncategorized', () {
    final groups = service.buildGroups(
      HomeGroupMode.categories,
      [
        task('a', category: 'کاری'),
        task('b'),
        task('c', category: '   '),
      ],
    );

    expect(
      groups.singleWhere((group) => group.id == 'کاری').items
          .map((item) => item.id),
      ['a'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'uncategorized').items
          .map((item) => item.id),
      ['b', 'c'],
    );
  });

  test('label projection supports multi-label without duplicate persisted task data', () {
    final original = task('a', tags: ['مهم', 'کاری', 'کاری']);
    final withoutTag = task('b', tags: ['  ']);

    final groups = service.buildGroups(
      HomeGroupMode.labels,
      [original, withoutTag],
    );

    expect(
      groups.singleWhere((group) => group.id == 'مهم').items
          .map((item) => item.id),
      ['a'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'کاری').items
          .map((item) => item.id),
      ['a'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'untagged').items
          .map((item) => item.id),
      ['b'],
    );
    expect(original.tags, ['مهم', 'کاری', 'کاری']);
  });

  test('trashed tasks are excluded from every Home projection', () {
    final hidden = task('hidden', trashed: true, tags: ['x'], category: 'y');

    for (final mode in HomeGroupMode.values) {
      final groups = service.buildGroups(
        mode,
        [hidden],
        projects: [
          ProjectPlan(id: 'p', title: 'P', itemIds: const ['hidden']),
        ],
      );
      expect(groups.expand((group) => group.items), isEmpty);
    }
  });
}
