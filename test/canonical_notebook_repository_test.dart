import 'package:drift/native.dart';
import 'package:arvin/services/canonical_notebook_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await database.close();
  });

  test('Notebook persists through canonical TaskStore only', () async {
    final repository = CanonicalNotebookRepository(
      store: TaskStore(executor: database),
      now: () => DateTime.utc(2026, 8, 26, 10),
    );

    final note = await repository.createNote(id: 'note-1');
    await repository.updateNote(
      id: note.id,
      title: 'جلسه فردا',
      description: 'نکات مهم جلسه',
      checklist: const ['[x] دعوت اعضا', '[ ] آماده‌سازی گزارش'],
    );

    final stored = (await TaskStore(executor: database).load()).single;
    expect(stored.id, 'note-1');
    expect(stored.title, 'جلسه فردا');
    expect(stored.description, 'نکات مهم جلسه');
    expect(stored.checklist, ['[x] دعوت اعضا', '[ ] آماده‌سازی گزارش']);
    expect(stored.isSimpleNote, isTrue);
    expect(stored.isNotebookItem, isTrue);
    expect(stored.followUps, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey(TaskStore.key), isTrue);
    expect(preferences.getKeys(), {TaskStore.key});
  });

  test('preset starter checklist is created in the same canonical Task', () async {
    final repository = CanonicalNotebookRepository(
      store: TaskStore(),
      now: () => DateTime.utc(2026, 8, 27, 11),
    );

    final note = await repository.createNote(
      id: 'shopping-note',
      title: 'لیست خرید',
      checklist: const ['[ ] نان', '[ ] شیر', '[ ] میوه'],
    );

    final stored = (await TaskStore().load()).single;
    expect(stored.id, note.id);
    expect(stored.title, 'لیست خرید');
    expect(stored.checklist, ['[ ] نان', '[ ] شیر', '[ ] میوه']);
    expect(stored.isSimpleNote, isFalse);
    expect(stored.isNotebookItem, isTrue);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), {TaskStore.key});
  });
  test('note converts to Task on the same canonical identity', () async {
    var now = DateTime.utc(2026, 9, 19, 10);
    final repository = CanonicalNotebookRepository(
      store: TaskStore(),
      now: () => now,
    );
    final note = await repository.createNote(
      id: 'convert-me',
      title: 'پیگیری قرارداد',
      category: 'کاری',
    );
    await repository.updateTags(id: note.id, tags: const ['مهم', 'قرارداد']);
    final createdAt = (await TaskStore().load()).single.createdAt;

    now = DateTime.utc(2026, 9, 19, 11);
    final converted = await repository.convertNoteToTask(note.id);
    final all = await TaskStore().load();

    expect(all, hasLength(1));
    expect(converted.id, 'convert-me');
    expect(all.single.id, 'convert-me');
    expect(all.single.createdAt, createdAt);
    expect(all.single.updatedAt, now);
    expect(all.single.category, 'کاری');
    expect(all.single.tags, ['مهم', 'قرارداد']);
    expect(all.single.followUpEnabled, isTrue);
    expect(all.single.followUps, isEmpty);
    expect(all.single.dueDate, isNull);
    expect(all.single.isSimpleNote, isTrue);
    expect(all.single.isNotebookItem, isTrue);
    expect(await repository.loadNote('convert-me'), isNotNull);
  });

}
