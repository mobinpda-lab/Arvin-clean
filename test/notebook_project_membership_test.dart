import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/canonical_notebook_repository.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_project_assignment_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async => database.close());

  CanonicalNotebookRepository repositoryWithProjects(
    ProjectStore projectStore, {
    DateTime? now,
  }) {
    return CanonicalNotebookRepository(
      store: TaskStore(executor: database),
      projectAssignmentService: TaskProjectAssignmentService(store: projectStore),
      now: () => now ?? DateTime.utc(2026, 9, 12, 12),
    );
  }

  test('Notebook reuses canonical Project membership for the same Note id',
      () async {
    final projectStore = ProjectStore(executor: database);
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

    final storedNote = (await TaskStore(executor: database).load()).single;
    expect(storedNote.id, 'note-project');
    expect(storedNote.title, 'یادداشت پروژه');
    expect(storedNote.toJson().containsKey('projectId'), isFalse);

    await expectLater(
      repository.updateProject(id: 'missing-note', projectId: 'project-a'),
      throwsStateError,
    );
  });

  test('Notebook project membership survives editor UI removal', () async {
    final projectStore = ProjectStore(executor: database);
    await projectStore.save([
      ProjectPlan(id: 'active-project', title: 'پروژه فعال'),
      ProjectPlan(
        id: 'archived-project',
        title: 'پروژه قدیمی',
        isArchived: true,
      ),
    ]);
    final repository = repositoryWithProjects(projectStore);
    final note = await repository.createNote(
      id: 'ui-project-note',
      title: 'یادداشت من',
    );

    await repository.updateProject(
      id: note.id,
      projectId: 'active-project',
    );

    expect(await repository.projectIdForNote(note.id), 'active-project');
    final stored = await repository.loadNote(note.id);
    expect(stored?.id, 'ui-project-note');
    expect(stored?.title, 'یادداشت من');

    final taskStoreRecord = (await TaskStore().load()).single;
    expect(taskStoreRecord.id, 'ui-project-note');
    expect(taskStoreRecord.toJson().containsKey('projectId'), isFalse);
  });

  test('archived Project membership remains canonical without editor selector',
      () async {
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

    expect(
      await repository.projectIdForNote('archived-note'),
      'archived-project',
    );
    final projects = await projectStore.load();
    expect(projects.single.itemIds, ['archived-note']);
    expect(projects.single.isArchived, isTrue);

    final stored = await repository.loadNote('archived-note');
    expect(stored?.id, 'archived-note');
    expect(stored?.title, 'یادداشت قدیمی');
  });
}
