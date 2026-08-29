import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_project_assignment_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('assign moves Task membership and persists it canonically', () async {
    final store = ProjectStore();
    await store.save([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-1']),
      ProjectPlan(id: 'b', title: 'ب'),
    ]);
    final service = TaskProjectAssignmentService(store: store);

    final result = await service.assign(taskId: 'task-1', projectId: 'b');

    expect(result.first.itemIds, isEmpty);
    expect(result.last.itemIds, ['task-1']);
    final restored = await store.load();
    expect(restored.last.itemIds, ['task-1']);
    expect(await service.projectIdForTask('task-1'), 'b');
  });

  test('null Project keeps Task valid and unassigned', () async {
    final store = ProjectStore();
    await store.save([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-1']),
    ]);
    final service = TaskProjectAssignmentService(store: store);

    final result = await service.assign(taskId: 'task-1', projectId: null);

    expect(result.single.itemIds, isEmpty);
    expect(await service.projectIdForTask('task-1'), isNull);
  });

  test('unknown Project fails before changing stored membership', () async {
    final store = ProjectStore();
    await store.save([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-1']),
    ]);
    final service = TaskProjectAssignmentService(store: store);

    await expectLater(
      service.assign(taskId: 'task-1', projectId: 'missing'),
      throwsArgumentError,
    );
    expect((await store.load()).single.itemIds, ['task-1']);
  });
}
