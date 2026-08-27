import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/goal_progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = GoalProgressService();

  test('derives project and goal progress from canonical Task completion', () {
    final goal = GoalPlan(
      id: 'goal-1',
      title: 'خرید خانه',
      projects: [
        ProjectPlan(
          id: 'loan',
          title: 'وام',
          itemIds: const ['docs', 'bank'],
        ),
        ProjectPlan(
          id: 'search',
          title: 'جستجو',
          itemIds: const ['visit'],
        ),
      ],
    );

    final result = service.project(
      goal,
      canonicalTasks: [
        Task(id: 'docs', title: 'مدارک', completed: true),
        Task(id: 'bank', title: 'بانک'),
        Task(id: 'visit', title: 'بازدید', completed: true),
      ],
    );

    expect(result.validation.isValid, isTrue);
    expect(result.totalItems, 3);
    expect(result.completedItems, 2);
    expect(result.ratio, closeTo(2 / 3, 0.0001));
    expect(result.isComplete, isFalse);
    expect(result.projects.first.totalItems, 2);
    expect(result.projects.first.completedItems, 1);
    expect(result.projects.last.isComplete, isTrue);
  });

  test('surfaces missing references instead of treating them as complete', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(
          id: 'project',
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
    expect(result.totalItems, 2);
    expect(result.completedItems, 1);
    expect(result.ratio, 0.5);
    expect(result.isComplete, isFalse);
    expect(result.projects.single.missingItemIds, ['missing']);
  });

  test('duplicate project ownership does not inflate overall goal progress', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(id: 'a', title: 'الف', itemIds: const ['shared']),
        ProjectPlan(id: 'b', title: 'ب', itemIds: const ['shared']),
      ],
    );

    final result = service.project(
      goal,
      canonicalTasks: [
        Task(id: 'shared', title: 'مشترک', completed: true),
      ],
    );

    expect(result.validation.duplicateItemIds, ['shared']);
    expect(result.totalItems, 1);
    expect(result.completedItems, 1);
    expect(result.isComplete, isFalse);
  });

  test('empty goal has zero progress and is not complete', () {
    final result = service.project(
      GoalPlan(id: 'empty', title: 'خالی'),
      canonicalTasks: const [],
    );

    expect(result.totalItems, 0);
    expect(result.completedItems, 0);
    expect(result.ratio, 0);
    expect(result.isComplete, isFalse);
  });

  test('rejects duplicate canonical Task ids instead of choosing a winner', () {
    expect(
      () => service.project(
        GoalPlan(
          id: 'goal',
          title: 'هدف',
          projects: [
            ProjectPlan(id: 'p', title: 'پروژه', itemIds: const ['same']),
          ],
        ),
        canonicalTasks: [
          Task(id: 'same', title: 'اول'),
          Task(id: 'same', title: 'دوم'),
        ],
      ),
      throwsArgumentError,
    );
  });
}
