import 'package:arvin/models/goal_project.dart';
import 'package:arvin/notebook_page.dart';
import 'package:arvin/services/canonical_notebook_repository.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_project_assignment_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  CanonicalNotebookRepository repositoryWithProjects(
    ProjectStore projectStore, {
    DateTime? now,
  }) {
    return CanonicalNotebookRepository(
      store: TaskStore(),
      projectAssignmentService: TaskProjectAssignmentService(store: projectStore),
      now: () => now ?? DateTime.utc(2026, 9, 12, 12),
    );
  }

  test('Notebook reuses canonical Project membership for the same Note id',
      () async {
    final projectStore = ProjectStore();
    await projectStore.save([
      ProjectPlan(id: 'project-a', title: 'الف'),
      ProjectPlan(id: 'project-b', title: 'ب'),
    ]);
    final repository = repositoryWithProjects(projectStore);
    final note = await repository.createNote(
      id: 'note-project',
      title: 'یادداشت پروژه',
    );

    expect(await repository.projectIdForNote(note.id), isNull);

    await repository.updateProject(id: note.id, projectId: 'project-a');
    var projects = await projectStore.load();
    expect(projects.first.itemIds, ['note-project']);
    expect(projects.last.itemIds, isEmpty);
    expect(await repository.projectIdForNote(note.id), 'project-a');

    await repository.updateProject(id: note.id, projectId: 'project-b');
    projects = await projectStore.load();
    expect(projects.first.itemIds, isEmpty);
    expect(projects.last.itemIds, ['note-project']);
    expect(await repository.projectIdForNote(note.id), 'project-b');

    await repository.updateProject(id: note.id, projectId: null);
    projects = await projectStore.load();
    expect(projects.every((project) => project.itemIds.isEmpty), isTrue);
    expect(await repository.projectIdForNote(note.id), isNull);

    final storedNote = (await TaskStore().load()).single;
    expect(storedNote.id, 'note-project');
    expect(storedNote.title, 'یادداشت پروژه');
    expect(storedNote.toJson().containsKey('projectId'), isFalse);

    await expectLater(
      repository.updateProject(id: 'missing-note', projectId: 'project-a'),
      throwsStateError,
    );
  });

  testWidgets('Notebook editor assigns Project without replacing Note identity',
      (tester) async {
    final projectStore = ProjectStore();
    await projectStore.save([
      ProjectPlan(id: 'active-project', title: 'پروژه فعال'),
      ProjectPlan(
        id: 'archived-project',
        title: 'پروژه قدیمی',
        isArchived: true,
      ),
    ]);
    final repository = repositoryWithProjects(projectStore);
    await repository.createNote(id: 'ui-project-note', title: 'یادداشت من');

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NotebookPage(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('notebook-note-ui-project-note')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('notebook-project-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-selector-active-project')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-selector-archived-project')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('notebook-edit')));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('project-selector-active-project')),
    );
    await tester.pumpAndSettle();

    expect(
      await repository.projectIdForNote('ui-project-note'),
      'active-project',
    );
    final stored = await repository.loadNote('ui-project-note');
    expect(stored?.id, 'ui-project-note');
    expect(stored?.title, 'یادداشت من');
  });

  testWidgets('selected archived Project remains visible in Notebook editor',
      (tester) async {
    final projectStore = ProjectStore();
    await projectStore.save([
      ProjectPlan(
        id: 'archived-project',
        title: 'پروژه قدیمی',
        isArchived: true,
      ),
    ]);
    final repository = repositoryWithProjects(projectStore);
    await repository.createNote(id: 'archived-note', title: 'یادداشت قدیمی');
    await repository.updateProject(
      id: 'archived-note',
      projectId: 'archived-project',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NotebookPage(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-note-archived-note')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('project-selector-archived-project')),
      findsOneWidget,
    );
    expect(find.text('پروژه قدیمی (بایگانی‌شده)'), findsOneWidget);
  });
}
