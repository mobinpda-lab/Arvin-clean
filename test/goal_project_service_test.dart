import 'package:arvin/models/goal_project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = GoalProjectService();

  test('accepts projects that only reference known canonical items', () {
    final goal = GoalPlan(
      id: 'goal-home',
      title: 'خرید خانه',
      projects: [
        ProjectPlan(
          id: 'loan',
          title: 'دریافت وام',
          itemIds: const ['documents', 'bank-followup'],
        ),
      ],
    );

    final result = service.validate(
      goal,
      canonicalItemIds: const ['documents', 'bank-followup', 'other'],
    );

    expect(result.isValid, isTrue);
    expect(result.missingItemIds, isEmpty);
    expect(result.duplicateItemIds, isEmpty);
    expect(result.duplicateProjectIds, isEmpty);
  });

  test('reports missing canonical item references', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(id: 'p1', title: 'پروژه', itemIds: const ['missing']),
      ],
    );

    final result = service.validate(goal, canonicalItemIds: const ['known']);

    expect(result.isValid, isFalse);
    expect(result.missingItemIds, ['missing']);
  });

  test('rejects duplicate item ownership inside one goal', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(id: 'p1', title: 'اول', itemIds: const ['task-1']),
        ProjectPlan(id: 'p2', title: 'دوم', itemIds: const ['task-1']),
      ],
    );

    final result = service.validate(goal, canonicalItemIds: const ['task-1']);

    expect(result.duplicateItemIds, ['task-1']);
    expect(result.isValid, isFalse);
  });

  test('reports duplicate project ids deterministically', () {
    final goal = GoalPlan(
      id: 'goal',
      title: 'هدف',
      projects: [
        ProjectPlan(id: 'same', title: 'اول'),
        ProjectPlan(id: 'same', title: 'دوم'),
      ],
    );

    final result = service.validate(goal, canonicalItemIds: const []);

    expect(result.duplicateProjectIds, ['same']);
    expect(result.isValid, isFalse);
  });
}
