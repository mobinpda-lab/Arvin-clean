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

  test('FollowUp remains compatible with older data without completed', () {
    final followUp = FollowUp.fromJson(<String, dynamic>{
      'id': 'legacy-fu',
      'dateTime': '2026-09-03T10:00:00.000Z',
      'note': 'Legacy follow-up',
    });

    expect(followUp.completed, isFalse);
  });
}
