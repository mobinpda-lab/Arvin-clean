import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('adds and reloads a real follow-up while preserving legacy scheduling date', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t1","title":"کار","followUpDate":"2026-08-14T09:30:00.000"}]',
    });

    final store = TaskStore();
    final followUp = FollowUp(
      id: 'f2',
      dateTime: DateTime(2026, 8, 15, 10, 15),
      note: 'تماس مجدد',
      result: 'پاسخ دریافت شد',
    );

    await store.addFollowUp('t1', followUp);
    final loaded = await store.loadFollowUps('t1');
    final task = (await store.load()).single;

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'f2');
    expect(loaded.single.result, 'پاسخ دریافت شد');
    expect(task.followUpDate, DateTime(2026, 8, 14, 9, 30));
    expect(task.followUpEnabled, isTrue);
    expect(task.updatedAt, isNotNull);
  });

  test('converts a normal Task to FollowUp without changing identity', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t-convert","title":"کار معمولی","description":"متن","category":"مشتریان","tags":["فوری"]}]',
    });
    final store = TaskStore();
    await store.convertToFollowUp('t-convert');
    final task = (await store.load()).single;
    expect(task.id, 't-convert');
    expect(task.title, 'کار معمولی');
    expect(task.description, 'متن');
    expect(task.category, 'مشتریان');
    expect(task.tags, ['فوری']);
    expect(task.followUpEnabled, isTrue);
    expect(task.followUps, isEmpty);
  });

  test('converting an existing FollowUp task is idempotent', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': '[{"id":"t-existing","title":"پیگیری","followUpEnabled":true,"followUps":[{"id":"f1","dateTime":"2026-08-15T10:15:00.000"}]}]',
    });
    final store = TaskStore();
    await store.convertToFollowUp('t-existing');
    final task = (await store.load()).single;
    expect(task.id, 't-existing');
    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.id, 'f1');
  });

  test('throws when adding a follow-up to an unknown task', () async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});

    final store = TaskStore();
    final followUp = FollowUp(
      id: 'f1',
      dateTime: DateTime(2026, 8, 15, 10, 15),
    );

    expect(
      () => store.addFollowUp('missing', followUp),
      throwsA(isA<StateError>()),
    );
  });
}
