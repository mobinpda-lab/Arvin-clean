import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('TaskStore preserves completed state across save and load', () async {
    final store = TaskStore();
    await store.save(<Task>[
      Task(
        id: 'completed-1',
        title: 'Completed task',
        description: 'Must survive scheduled backup',
        tags: <String>['backup'],
        completed: true,
      ),
    ]);

    final loaded = await store.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'completed-1');
    expect(loaded.single.title, 'Completed task');
    expect(loaded.single.completed, isTrue);
  });

  test('TaskStore remains compatible with older data without completed', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      TaskStore.key,
      '[{"id":"old-1","title":"Old task","description":"legacy","tags":[],"archived":false,"trashed":false}]',
    );

    final loaded = await TaskStore().load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'old-1');
    expect(loaded.single.completed, isFalse);
  });

  test('TaskStore preserves FollowUp completion state across save and load', () async {
    final store = TaskStore();
    final followUpDate = DateTime.utc(2026, 9, 3, 10);
    await store.save(<Task>[
      Task(
        id: 'followup-1',
        title: 'Follow-up task',
        followUpEnabled: true,
        followUps: <FollowUp>[
          FollowUp(
            id: 'fu-1',
            dateTime: followUpDate,
            note: 'Call customer',
            completed: true,
          ),
        ],
      ),
    ]);

    final loaded = await store.load();

    expect(loaded.single.followUps, hasLength(1));
    expect(loaded.single.followUps.single.id, 'fu-1');
    expect(loaded.single.followUps.single.note, 'Call customer');
    expect(loaded.single.followUps.single.completed, isTrue);
  });

  test('concurrent canonical mutations preserve both changes', () async {
    final store = TaskStore();
    await store.save(<Task>[Task(id: 'task-1', title: 'Original')]);

    await Future.wait<void>([
      store.mutate<void>((tasks) {
        tasks.single.title = 'Renamed';
      }),
      store.mutate<void>((tasks) {
        tasks.single.tags = <String>['important'];
      }),
    ]);

    final loaded = await store.load();
    expect(loaded.single.title, 'Renamed');
    expect(loaded.single.tags, <String>['important']);
  });

  test('a fresh TaskStore instance sees the canonical write', () async {
    final writer = TaskStore();
    await writer.save(<Task>[
      Task(id: 'fresh-read-1', title: 'Persisted task'),
    ]);

    final reader = TaskStore();
    final loaded = await reader.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'fresh-read-1');
    expect(loaded.single.title, 'Persisted task');
  });


  test('canonical taxonomy catalog preserves unassigned categories and tags', () async {
    final store = TaskStore();
    await store.save(<Task>[
      Task(id: 'taxonomy-1', title: 'A', category: 'موجود', tags: <String>['مهم']),
    ]);

    await store.createCategory('بدون استفاده');
    await store.createTag('برچسب مستقل');

    expect(await store.loadCategories(), containsAll(<String>['موجود', 'بدون استفاده']));
    expect(await store.loadTags(), containsAll(<String>['مهم', 'برچسب مستقل']));

    await store.deleteCategoryCatalog('بدون استفاده');
    await store.deleteTagCatalog('برچسب مستقل');

    expect(await store.loadCategories(), isNot(contains('بدون استفاده')));
    expect(await store.loadTags(), isNot(contains('برچسب مستقل')));
    expect(await store.load(), hasLength(1));
  });

  test('referenced taxonomy cannot be destructively deleted or renamed', () async {
    final store = TaskStore();
    await store.save(<Task>[
      Task(
        id: 'taxonomy-used',
        title: 'وابسته',
        category: 'کاری',
        tags: <String>['مهم'],
      ),
    ]);
    await store.createCategory('کاری');
    await store.createTag('مهم');

    expect(
      store.deleteCategoryCatalog('کاری'),
      throwsA(isA<StateError>()),
    );
    expect(
      store.deleteTagCatalog('مهم'),
      throwsA(isA<StateError>()),
    );

    await store.renameCategoryCatalog('کاری', 'کارهای روزانه');
    await store.renameTagCatalog('مهم', 'ضروری');

    final loaded = await store.load();
    expect(loaded.single.category, 'کارهای روزانه');
    expect(loaded.single.tags, contains('ضروری'));
    expect(await store.loadCategories(), contains('کارهای روزانه'));
    expect(await store.loadTags(), contains('ضروری'));
  });

  test('TaskStore rejects malformed canonical document instead of empty fallback',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TaskStore.key, '{"not":"a-list"}');

    expect(TaskStore().load(), throwsA(isA<FormatException>()));
  });

  test('FollowUp remains compatible with older data without completed', () {
    final followUp = FollowUp.fromJson(<String, dynamic>{
      'id': 'legacy-fu',
      'dateTime': '2026-09-03T10:00:00.000Z',
      'note': 'Legacy follow-up',
    });

    expect(followUp.completed, isFalse);
  });
}
