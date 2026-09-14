import '../../models/task.dart';
import '../../services/task_project_assignment_service.dart';
import 'home_group.dart';

/// Builds Home project groups from the canonical ProjectStore path.
///
/// This intentionally does not add project data to Task. Project membership
/// remains owned by ProjectStore/ProjectPlan.itemIds.
class HomeProjectGroupingService {
  HomeProjectGroupingService({TaskProjectAssignmentService? assignment})
      : assignment = assignment ?? TaskProjectAssignmentService();

  final TaskProjectAssignmentService assignment;

  Future<List<HomeGroup<Task>>> group(List<Task> tasks) async {
    final projects = await assignment.loadProjects();
    final groups = <HomeGroup<Task>>[];
    final assignedIds = <String>{};

    for (final project in projects) {
      final items = tasks
          .where((task) => project.itemIds.contains(task.id))
          .toList();
      assignedIds.addAll(items.map((task) => task.id));

      groups.add(HomeGroup<Task>(
        id: project.id,
        title: project.title,
        items: items,
      ));
    }

    groups.add(HomeGroup<Task>(
      id: 'without-project',
      title: 'بدون پروژه',
      items: tasks.where((task) => !assignedIds.contains(task.id)).toList(),
    ));

    return groups;
  }
}
