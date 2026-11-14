import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/project_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('canonical Center links support many Projects and independent edge removal', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    await G1DriftSchema.install(database);
    final centers = CenterStore(executor: database);
    final projects = ProjectStore(executor: database);

    await centers.create(id: 'center-a', name: 'مرکز الف');
    await centers.create(id: 'center-b', name: 'مرکز ب');
    await projects.save([
      ProjectPlan(id: 'project-a', title: 'پروژه الف'),
      ProjectPlan(id: 'project-b', title: 'پروژه ب'),
    ]);

    await centers.addProjectRelationship(centerId: 'center-a', projectId: 'project-a');
    await centers.addProjectRelationship(centerId: 'center-a', projectId: 'project-b');
    await centers.addProjectRelationship(centerId: 'center-b', projectId: 'project-a');

    expect(await centers.projectIds('center-a'), ['project-a', 'project-b']);
    expect(await centers.projectIds('center-b'), ['project-a']);

    await centers.removeProjectRelationship(centerId: 'center-a', projectId: 'project-a');

    expect(await centers.projectIds('center-a'), ['project-b']);
    expect(await centers.projectIds('center-b'), ['project-a']);
    final restored = await projects.load();
    expect(restored.map((project) => project.id), ['project-a', 'project-b']);
    expect(restored.first.centerIds, ['center-b']);
  });

  test('Center deletion is blocked by canonical Project dependency', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    await G1DriftSchema.install(database);
    final centers = CenterStore(executor: database);
    final projects = ProjectStore(executor: database);

    await centers.create(id: 'center-a', name: 'مرکز الف');
    await projects.save([ProjectPlan(id: 'project-a', title: 'پروژه الف')]);
    await centers.addProjectRelationship(centerId: 'center-a', projectId: 'project-a');

    await expectLater(
      centers.delete(id: 'center-a'),
      throwsA(isA<CenterDeleteBlocked>()),
    );
    expect((await projects.load()).single.id, 'project-a');

    await centers.removeProjectRelationship(centerId: 'center-a', projectId: 'project-a');
    await centers.delete(id: 'center-a');
    expect(await centers.load(), isEmpty);
    expect((await projects.load()).single.id, 'project-a');
  });

  test('Center deletion is blocked by direct Task reference', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    await G1DriftSchema.install(database);
    final centers = CenterStore(executor: database);
    await centers.create(id: 'center-task', name: 'مرکز کار');
    await database.runInsert(
      '''INSERT INTO tasks
         (id, storage_ordinal, title, description, priority, archived, trashed,
          completed, is_favorite, center_id)
         VALUES ('task-a', 0, 'کار', '', 'medium', 0, 0, 0, 0, 'center-task')''',
      const [],
    );
    await expectLater(
      centers.delete(id: 'center-task'),
      throwsA(isA<CenterDeleteBlocked>()),
    );
  });
}
