import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/follow_up.dart';
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

  test('TaskStore round-trips follow-up history', () async {
    final followUp = FollowUp(
      id: 'follow-up-1',
      dateTime: DateTime(2026, 8, 14, 10, 30),
      note: 'تماس با مشتری',
      result: 'پاسخ دریافت شد',
      nextFollowUp: DateTime(2026, 8, 18, 9),
    );

    await TaskStore().save(<Task>[
      Task(
        id: 'task-follow-up',
        title: 'پیگیری مشتری',
        followUps: <FollowUp>[followUp],
      ),
    ]);

    final loaded = await TaskStore().load();
    final result = loaded.single.followUps.single;

    expect(loaded.single.followUps, hasLength(1));
    expect(result.id, 'follow-up-1');
    expect(result.dateTime, followUp.dateTime);
    expect(result.note, 'تماس با مشتری');
    expect(result.result, 'پاسخ دریافت شد');
    expect(result.nextFollowUp, DateTime(2026, 8, 18, 9));
    expect(loaded.single.latestFollowUp?.id, 'follow-up-1');
  });

  test('TaskStore migrates legacy followUpDate into follow-up history', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      TaskStore.key,
      '[{"id":"legacy-follow-up","title":"Legacy task","description":"legacy","followUpDate":"2026-08-14T10:30:00.000","tags":[],"archived":false,"trashed":false,"completed":false}]',
    );

    final loaded = await TaskStore().load();

    expect(loaded, hasLength(1));
    expect(loaded.single.followUpDate, DateTime(2026, 8, 14, 10, 30));
    expect(loaded.single.followUps, hasLength(1));
    expect(loaded.single.followUps.single.id, 'legacy-follow-up-legacy-follow-up');
    expect(
      loaded.single.followUps.single.dateTime,
      DateTime(2026, 8, 14, 10, 30),
    );
  });
}
