import 'package:arvin/home/grouping/home_group_mode.dart';
import 'package:arvin/home/grouping/home_grouping_service.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = HomeGroupingService();

  Task task(
    String id, {
    DateTime? dueDate,
    DateTime? createdAt,
    String? category,
    List<String> tags = const [],
    bool completed = false,
    bool trashed = false,
    bool allDay = false,
  }) {
    return Task(
      id: id,
      title: id,
      dueDate: dueDate,
      createdAt: createdAt,
      category: category,
      tags: tags,
      completed: completed,
      trashed: trashed,
      allDay: allDay,
    );
  }

  test('time projection uses due date day without today/future overlap', () {
    // Fixed noon keeps the 23:00 deadline in Today regardless of the CI
    // machine's current Iran-local time.
    final now = DateTime(2026, 11, 7, 12);
    final todayAt2300 = DateTime(now.year, now.month, now.day, 23);
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    final yesterday = DateTime(now.year, now.month, now.day - 1, 9);

    final groups = service.buildGroups(
      HomeGroupMode.time,
      [
        task('late-today', dueDate: todayAt2300),
        task('tomorrow', dueDate: tomorrow),
        task('overdue', dueDate: yesterday),
        task('completed-overdue', dueDate: yesterday, completed: true),
        task('no-date'),
      ],
      now: now,
    );

    expect(
      groups.singleWhere((group) => group.id == 'today').items
          .map((item) => item.id),
      ['late-today'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'tomorrow').items
          .map((item) => item.id),
      ['tomorrow'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'overdue').items
          .map((item) => item.id),
      ['overdue'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'overdue').items.map((item) => item.id),
      isNot(contains('completed-overdue')),
    );
    expect(
      groups.singleWhere((group) => group.id == 'no_date').items
          .map((item) => item.id),
      ['no-date'],
    );
  });

  test('timed deadlines become overdue immediately; all-day deadlines wait until day end', () {
    final now = DateTime(2026, 11, 7, 12, 30);
    final groups = service.buildGroups(
      HomeGroupMode.time,
      [
        task('timed-overdue', dueDate: DateTime(2026, 11, 7, 11, 30)),
        task('timed-not-yet-due', dueDate: DateTime(2026, 11, 7, 13, 30)),
        task(
          'all-day-today',
          dueDate: DateTime(2026, 11, 7),
          allDay: true,
        ),
        task(
          'all-day-yesterday',
          dueDate: DateTime(2026, 11, 6),
          allDay: true,
        ),
        task(
          'completed-timed-overdue',
          dueDate: DateTime(2026, 11, 7, 10),
          completed: true,
        ),
      ],
      now: now,
    );

    expect(
      groups.singleWhere((group) => group.id == 'overdue').items
          .map((item) => item.id),
      ['timed-overdue', 'all-day-yesterday'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'today').items
          .map((item) => item.id),
      ['timed-not-yet-due', 'all-day-today', 'completed-timed-overdue'],
    );
  });

  test('time groups keep completed past separate and sort by priority then creation time', () {
    final now = DateTime(2026, 11, 7, 12);
    final groups = service.buildGroups(
      HomeGroupMode.time,
      [
        task('newer', dueDate: DateTime(2026, 11, 6, 10), createdAt: DateTime(2026, 11, 2)),
        task('older', dueDate: DateTime(2026, 11, 6, 10), createdAt: DateTime(2026, 11, 1)),
        task('completed', dueDate: DateTime(2026, 11, 6, 10), completed: true),
        task('tomorrow', dueDate: DateTime(2026, 11, 8, 9)),
        task('undated'),
      ],
      now: now,
    );

    expect(
      groups.map((group) => group.id),
      ['overdue', 'completed_past', 'today', 'tomorrow', 'future', 'no_date'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'overdue').items.map((item) => item.id),
      ['older', 'newer'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'completed_past').items.map((item) => item.id),
      ['completed'],
    );
    expect(
      groups.singleWhere((group) => group.id == 'no_date').title,
      'فاقد زمان',
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
