import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('adds and reloads follow-up without changing the task envelope', () async {
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

    expect(loaded, hasLength(2));
    expect(loaded.first.dateTime, DateTime(2026, 8, 14, 9, 30));
    expect(loaded.last.id, 'f2');
    expect(loaded.last.result, 'پاسخ دریافت شد');
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
