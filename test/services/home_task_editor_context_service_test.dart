import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_task_editor_context_service.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_project_assignment_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads Projects, selected membership and sorted known categories', () async {
    final store = ProjectStore();
    await store.save([
      ProjectPlan(
        id: 'p1',
        title: 'پروژه یک',
        itemIds: ['t1'],
      ),
    ]);
    final service = HomeTaskEditorContextService(
      assignmentService: TaskProjectAssignmentService(store: store),
    );
    final task = Task(id: 't1', title: 'کار', category: 'مالی');

    final context = await service.load(
      tasks: [
        task,
        Task(id: 't2', title: 'دو', category: 'اداری'),
        Task(id: 't3', title: 'سه', category: ' مالی '),
        Task(id: 't4', title: 'چهار'),
      ],
      task: task,
    );

    expect(context.projects, hasLength(1));
    expect(context.selectedProjectId, 'p1');
    expect(context.knownCategories, ['اداری', 'مالی']);
  });

  test('new Task context stays unassigned', () async {
    final store = ProjectStore();
    await store.save([ProjectPlan(id: 'p1', title: 'پروژه')]);
    final service = HomeTaskEditorContextService(
      assignmentService: TaskProjectAssignmentService(store: store),
    );

    final context = await service.load(
      tasks: [Task(id: 't1', title: 'کار', category: 'فروش')],
    );

    expect(context.selectedProjectId, isNull);
    expect(context.knownCategories, ['فروش']);
  });
}
