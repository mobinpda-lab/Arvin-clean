import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/follow_up.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('TaskStore preserves completed state and follow-up history', () async {
    final store = TaskStore();
    await store.save(<ArvinTask>[
      ArvinTask(
        id: 'completed-1',
        title: 'Completed task',
        description: 'Must survive scheduled backup',
        tags: <String>['backup'],
        completed: true,
        followUps: <FollowUp>[
          FollowUp(
            id: 'fu-1',
            dateTime: DateTime(2026, 8, 14, 10, 30),
            note: 'تماس انجام شد',
            nextFollowUp: DateTime(2026, 8, 18, 9),
          ),
        ],
      ),
    ]);

    final loaded = await store.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'completed-1');
    expect(loaded.single.title, 'Completed task');
    expect(loaded.single.completed, isTrue);
    expect(loaded.single.followUps, hasLength(1));
    expect(loaded.single.lastFollowUp?.note, 'تماس انجام شد');
    expect(loaded.single.lastFollowUpDate, DateTime(2026, 8, 14, 10, 30));
    expect(loaded.single.lastFollowUp?.nextFollowUp, DateTime(2026, 8, 18, 9));
  });

  test('TaskStore migrates legacy followUpDate into follow-up history', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      TaskStore.key,
      '[{"id":"old-follow-up","title":"Old task","description":"legacy","followUpDate":"2026-08-14T09:15:00.000","tags":[],"archived":false,"trashed":false,"completed":false}]',
    );
