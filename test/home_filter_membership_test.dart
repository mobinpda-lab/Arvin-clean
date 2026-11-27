import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/home/home_filter_membership.dart';
import 'package:arvin/models/goal_project.dart';

void main() {
  group('Home Project dimension', () {
    final projects = <ProjectPlan>[
      ProjectPlan(id: 'project-a', title: 'A', itemIds: const ['task-a']),
      ProjectPlan(id: 'project-b', title: 'B', itemIds: const ['task-b']),
      ProjectPlan(id: 'project-c', title: 'C', itemIds: const ['task-c']),
    ];

    test('OR-matches any selected Project and rejects unselected memberships', () {
      final selected = <String>{'project-a', 'project-b'};
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'task-a', projects: projects, selectedProjectIds: selected,
      ), isTrue);
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'task-b', projects: projects, selectedProjectIds: selected,
      ), isTrue);
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'task-c', projects: projects, selectedProjectIds: selected,
      ), isFalse);
    });

    test('No Project matches only Tasks without any Project membership', () {
      const noProject = HomeFilterMembership.noProjectId;
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'unassigned', projects: projects, selectedProjectIds: {noProject},
      ), isTrue);
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'task-a', projects: projects, selectedProjectIds: {noProject},
      ), isFalse);
    });

    test('selected Projects and No Project are OR-combined', () {
      const noProject = HomeFilterMembership.noProjectId;
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'task-a', projects: projects,
        selectedProjectIds: {'project-a', noProject},
      ), isTrue);
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'unassigned', projects: projects,
        selectedProjectIds: {'project-a', noProject},
      ), isTrue);
      expect(HomeFilterMembership.matchesProjectDimension(
        taskId: 'task-c', projects: projects,
        selectedProjectIds: {'project-a', noProject},
      ), isFalse);
    });
  });

  group('Home Category dimension', () {
    test('OR-matches any selected Category after trimming', () {
      const selected = {'شخصی', 'کاری'};
      expect(HomeFilterMembership.matchesCategoryDimension(
        taskCategory: ' شخصی ', selectedCategoryNames: selected,
      ), isTrue);
      expect(HomeFilterMembership.matchesCategoryDimension(
        taskCategory: 'کاری', selectedCategoryNames: selected,
      ), isTrue);
      expect(HomeFilterMembership.matchesCategoryDimension(
        taskCategory: 'خانه', selectedCategoryNames: selected,
      ), isFalse);
      expect(HomeFilterMembership.matchesCategoryDimension(
        taskCategory: null, selectedCategoryNames: selected,
      ), isFalse);
    });
  });

  test('different dimensions remain AND-combined', () {
    final projects = <ProjectPlan>[
      ProjectPlan(id: 'project-a', title: 'A', itemIds: const ['task-a']),
      ProjectPlan(id: 'project-b', title: 'B', itemIds: const ['task-b']),
    ];
    const selectedProjects = {'project-a', 'project-b'};
    const selectedCategories = {'شخصی', 'کاری'};

    final matches = HomeFilterMembership.matchesProjectDimension(
          taskId: 'task-a',
          projects: projects,
          selectedProjectIds: selectedProjects,
        ) &&
        HomeFilterMembership.matchesCategoryDimension(
          taskCategory: 'شخصی',
          selectedCategoryNames: selectedCategories,
        );
    expect(matches, isTrue);

    final failsCrossDimensionAnd = HomeFilterMembership.matchesProjectDimension(
          taskId: 'task-c',
          projects: projects,
          selectedProjectIds: selectedProjects,
        ) &&
        HomeFilterMembership.matchesCategoryDimension(
          taskCategory: 'شخصی',
          selectedCategoryNames: selectedCategories,
        );
    expect(failsCrossDimensionAnd, isFalse);
  });
}
