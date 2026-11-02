import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await CenterStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  test('Center identity is stable, names are unique, and archived state is retained', () async {
    final db = NativeDatabase.memory(); addTearDown(db.close);
    final store = CenterStore(executor: db);
    await store.create(id: 'center-511', name: '511');
    await store.rename(id: 'center-511', name: 'مرکز ۵۱۱');
    await store.setArchived(id: 'center-511', archived: true);
    final item = (await store.load()).single;
    expect(item.id, 'center-511'); expect(item.name, 'مرکز ۵۱۱'); expect(item.isArchived, isTrue);
    await expectLater(store.create(id: 'other', name: ' مرکز ۵۱۱ '), throwsStateError);
  });
  test('legacy Projects remain unassigned while explicit Center association persists', () async {
    final db = NativeDatabase.memory(); addTearDown(db.close);
    await TaskStore(executor: db).save([Task(id: 'legacy-task', title: 'کار قدیمی')]);
    final centers = CenterStore(executor: db);
    await centers.create(id: 'center-512', name: '512');
    final projects = ProjectStore(executor: db);
    await projects.save([
      ProjectPlan(id: 'legacy-project', title: 'قدیمی', itemIds: const ['legacy-task']),
      ProjectPlan(id: 'new-project', title: 'جدید', centerId: 'center-512'),
    ]);
    final restored = await projects.load();
    expect(restored.firstWhere((p) => p.id == 'legacy-project').centerId, isNull);
    expect(restored.firstWhere((p) => p.id == 'new-project').centerId, 'center-512');
  });
}
