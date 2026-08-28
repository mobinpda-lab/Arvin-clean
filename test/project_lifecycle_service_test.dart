import 'package:arvin/models/goal_project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ProjectLifecycleService();

  test('project owns color independently from category and tags', () {
    final project = ProjectPlan(
      id: 'arvin',
      title: 'آروین',
      colorValue: 0xFF2F80ED,
    );

    expect(project.colorValue, 0xFF2F80ED);
    expect(project.canDelete, isTrue);
  });

  test('non-empty project cannot be deleted', () {
    final projects = [
      ProjectPlan(
        id: 'work',
        title: 'کاری',
        itemIds: const ['task-1'],
      ),
    ];

    expect(
      () => service.delete(projects, projectId: 'work'),
      throwsA(isA<ProjectDeleteBlocked>()),
    );
  });

  test('empty project can be deleted', () {
    final projects = [ProjectPlan(id: 'empty', title: 'خالی')];

    final result = service.delete(projects, projectId: 'empty');

    expect(result, isEmpty);
  });

  test('editing title or color preserves canonical task references', () {
    final projects = [
      ProjectPlan(
        id: 'p1',
        title: 'قدیمی',
        colorValue: 0xFF111111,
        itemIds: const ['task-1', 'task-2'],
      ),
    ];

    final result = service.edit(
      projects,
      projectId: 'p1',
      title: 'جدید',
      colorValue: 0xFF22AA66,
    );

    expect(result.single.title, 'جدید');
    expect(result.single.colorValue, 0xFF22AA66);
    expect(result.single.itemIds, ['task-1', 'task-2']);
  });

  test('assignTask moves a task between projects without duplicating payload', () {
    final projects = [
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-1']),
      ProjectPlan(id: 'b', title: 'ب'),
    ];

    final result = service.assignTask(
      projects,
      taskId: 'task-1',
      projectId: 'b',
    );

    expect(result.first.itemIds, isEmpty);
    expect(result.last.itemIds, ['task-1']);
  });

  test('assignTask supports unassigned task state', () {
    final projects = [
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-1']),
    ];

    final result = service.assignTask(
      projects,
      taskId: 'task-1',
      projectId: null,
    );

    expect(result.single.itemIds, isEmpty);
  });
}
