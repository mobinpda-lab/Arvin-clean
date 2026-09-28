import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/home/grouping/home_grouping_service.dart';
import 'package:arvin/home/grouping/home_group_mode.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';

void main() {
  const service = HomeGroupingService();

  Task task(
    String id, {
    String? category,
    List<String> tags = const <String>[],
  }) =>
      Task(
        id: id,
        title: id,
        category: category,
        tags: tags,
      );

  test('Home grouping keeps project/category/tag views distinct', () {
    final items = <Task>[
      task('one', category: 'کاری', tags: <String>['مهم', 'پیگیری']),
      task('two', category: 'شخصی', tags: <String>['مهم']),
      task('three'),
    ];
    final projects = <ProjectPlan>[
      ProjectPlan(
        id: 'project-1',
        title: 'آروین',
        itemIds: <String>['one', 'two'],
      ),
    ];

    final projectGroups = service.buildGroups(
      HomeGroupMode.projects,
      items,
      projects: projects,
    );
    expect(projectGroups.firstWhere((g) => g.id == 'project-1').items.map((x) => x.id),
        containsAll(<String>['one', 'two']));

    final categoryGroups = service.buildGroups(
      HomeGroupMode.categories,
      items,
    );
    expect(categoryGroups.map((g) => g.title), containsAll(<String>['کاری', 'شخصی', 'بدون دسته']));

    final labelGroups = service.buildGroups(
      HomeGroupMode.labels,
      items,
    );
    expect(labelGroups.map((g) => g.title), containsAll(<String>['مهم', 'پیگیری', 'بدون برچسب']));
  });
}
