import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saves and restores canonical project identity color and membership', () async {
    final store = ProjectStore();
    final projects = [
      ProjectPlan(
        id: 'project-1',
        title: 'کاری',
        colorValue: 0xFF2F80ED,
        itemIds: const ['task-1', 'task-2'],
      ),
    ];

    await store.save(projects);
    final restored = await store.load();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'project-1');
    expect(restored.single.title, 'کاری');
    expect(restored.single.colorValue, 0xFF2F80ED);
    expect(restored.single.itemIds, ['task-1', 'task-2']);
  });

  test('empty storage loads safely and clear removes project collection', () async {
    final store = ProjectStore();
    expect(await store.load(), isEmpty);

    await store.save([ProjectPlan(id: 'p', title: 'پروژه')]);
    expect(await store.load(), hasLength(1));

    await store.clear();
    expect(await store.load(), isEmpty);
  });

  test('legacy project json inherits codec defaults', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ProjectStore.key: '[{"id":"legacy","title":"قدیمی"}]',
    });

    final restored = await ProjectStore().load();

    expect(restored.single.id, 'legacy');
    expect(restored.single.itemIds, isEmpty);
  });
}
