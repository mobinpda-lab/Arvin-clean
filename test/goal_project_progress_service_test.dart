import 'package:arvin/goal_project_progress_service.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = GoalProjectProgressService();

  test('projects progress from canonical Task.completed state', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(
          id: 'p1',
          title: 'پروژه اول',
          itemIds: const ['t1', 't2'],
        ),
        ProjectPlan(
          id: 'p2',
          title: 'پروژه دوم',
          itemIds: const ['t3'],
        ),
      ],
    );

    final result = service.project(
      goal,
      canonicalTasks: [
        Task(id: 't1', title: 'اول', completed: true),
        Task(id: 't2', title: 'دوم'),
        Task(id: 't3', title: 'سوم', completed: true),
      ],
    );

    expect(result.validation.isValid, isTrue);
    expect(result.totalItems, 3);
    expect(result.completedItems, 2);
    expect(result.completionRatio, closeTo(2 / 3, 0.0001));
    expect(result.projects[0].completionRatio, 0.5);
    expect(result.projects[1].completionRatio, 1.0);
  });

  test('missing canonical ids make progress ratio unavailable', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(
          id: 'p1',
          title: 'پروژه',
          itemIds: const ['known', 'missing'],
        ),
      ],
    );

    final result = service.project(
      goal,
      canonicalTasks: [Task(id: 'known', title: 'موجود', completed: true)],
    );

    expect(result.validation.missingItemIds, ['missing']);
    expect(result.completionRatio, isNull);
    expect(result.projects.single.completionRatio, isNull);
    expect(result.completedItems, 1);
    expect(result.totalItems, 2);
  });

  test('duplicate ownership never produces a misleading ratio', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(id: 'p1', title: 'اول', itemIds: const ['shared']),
        ProjectPlan(id: 'p2', title: 'دوم', itemIds: const ['shared']),
      ],
    );

    final result = service.project(
      goal,
      canonicalTasks: [Task(id: 'shared', title: 'مشترک', completed: true)],
    );

    expect(result.validation.duplicateItemIds, ['shared']);
    expect(result.completionRatio, isNull);
    expect(result.projects.every((project) => !project.isValid), isTrue);
  });

  test('duplicate canonical Task ids fail closed instead of last-write-wins', () {
    final result = service.project(
      GoalPlan(
        id: 'goal',
        title: 'هدف',
        projects: [
          ProjectPlan(id: 'p1', title: 'پروژه', itemIds: const ['same']),
        ],
      ),
      canonicalTasks: [
        Task(id: 'same', title: 'نسخه اول', completed: false),
        Task(id: 'same', title: 'نسخه دوم', completed: true),
      ],
    );

    expect(result.validation.isValid, isTrue);
    expect(result.projects.single.isValid, isFalse);
    expect(result.projects.single.completionRatio, isNull);
    expect(result.completionRatio, isNull);
  });

  test('empty valid goal has deterministic zero progress', () {
    final result = service.project(
      GoalPlan(id: 'goal', title: 'خالی'),
      canonicalTasks: const [],
    );

    expect(result.validation.isValid, isTrue);
    expect(result.totalItems, 0);
    expect(result.completedItems, 0);
    expect(result.completionRatio, 0.0);
  });
}
