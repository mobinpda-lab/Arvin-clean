import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() async => TaskStore.resetTestDatabase());
  tearDown(() async => TaskStore.resetTestDatabase());

  test('today focus selection survives TaskStore reload and can be removed', () async {
    final store = TaskStore();
    await store.save([
      Task(
        id: 'focus-persist',
        title: 'کار برگزیده',
        isSelectedForToday: true,
        isFavorite: false,
      ),
    ]);

    final loaded = await TaskStore().load();
    expect(loaded.single.isSelectedForToday, isTrue);
    expect(loaded.single.isFavorite, isFalse);

    loaded.single.isSelectedForToday = false;
    await TaskStore().save(loaded);
    expect((await TaskStore().load()).single.isSelectedForToday, isFalse);
  });
}
