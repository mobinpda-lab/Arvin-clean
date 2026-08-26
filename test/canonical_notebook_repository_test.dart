import 'package:arvin/services/canonical_notebook_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Notebook persists through canonical TaskStore only', () async {
    final repository = CanonicalNotebookRepository(
      store: TaskStore(),
      now: () => DateTime.utc(2026, 8, 26, 10),
    );

    final note = await repository.createNote(id: 'note-1');
    await repository.updateNote(
      id: note.id,
      title: 'جلسه فردا',
      description: 'نکات مهم جلسه',
      checklist: const ['[x] دعوت اعضا', '[ ] آماده‌سازی گزارش'],
    );

    final stored = (await TaskStore().load()).single;
    expect(stored.id, 'note-1');
    expect(stored.title, 'جلسه فردا');
    expect(stored.description, 'نکات مهم جلسه');
    expect(stored.checklist, ['[x] دعوت اعضا', '[ ] آماده‌سازی گزارش']);
    expect(stored.isSimpleNote, isTrue);
    expect(stored.followUps, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey(TaskStore.key), isTrue);
    expect(preferences.getKeys(), {TaskStore.key});
  });
}
