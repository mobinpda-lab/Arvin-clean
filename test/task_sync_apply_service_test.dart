import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/sync_merge_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/task_sync_apply_service.dart';
import 'package:arvin/services/task_sync_plan_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Task task(String id, String title) => Task(id: id, title: title);

  TaskSyncPlanItem item({
    required String id,
    required SyncMergeDecision decision,
    Task? local,
    Task? remote,
  }) {
    return TaskSyncPlanItem(
      id: id,
      result: SyncMergeResult(decision: decision),
      localTask: local,
      remoteTask: remote,
    );
  }

  test('applies plan once, preserves local order and appends remote-only',
      () async {
    final store = TaskStore();
    final localB = task('b', 'B local');
    final localA = task('a', 'A local');
    final remoteB = task('b', 'B remote');
    final remoteC = task('c', 'C remote');
    await store.save(<Task>[localB, localA]);

    final plan = TaskSyncPlan(<TaskSyncPlanItem>[
      item(
        id: 'a',
        decision: SyncMergeDecision.localOnly,
        local: localA,
      ),
      item(
        id: 'b',
        decision: SyncMergeDecision.useRemote,
        local: localB,
        remote: remoteB,
      ),
      item(
        id: 'c',
        decision: SyncMergeDecision.remoteOnly,
        remote: remoteC,
      ),
    ]);

    final result = await TaskSyncApplyService(store: store).apply(plan: plan);
    final loaded = await store.load();

    expect(result.resolvedConflictCount, 0);
    expect(loaded.map((value) => value.id), <String>['b', 'a', 'c']);
    expect(loaded.first.title, 'B remote');
    expect(loaded.last.title, 'C remote');
  });

  test('unresolved conflict fails without mutating canonical storage', () async {
    final store = TaskStore();
    final local = task('a', 'Local');
    final remote = task('a', 'Remote');
    await store.save(<Task>[local]);
    final plan = TaskSyncPlan(<TaskSyncPlanItem>[
      item(
        id: 'a',
        decision: SyncMergeDecision.conflict,
        local: local,
        remote: remote,
      ),
    ]);

    await expectLater(
      TaskSyncApplyService(store: store).apply(plan: plan),
      throwsA(isA<StateError>()),
    );

    final loaded = await store.load();
    expect(loaded.single.title, 'Local');
  });

  test('explicit conflict choice is required and persisted', () async {
    final store = TaskStore();
    final local = task('a', 'Local');
    final remote = task('a', 'Remote');
    await store.save(<Task>[local]);
    final plan = TaskSyncPlan(<TaskSyncPlanItem>[
      item(
        id: 'a',
        decision: SyncMergeDecision.conflict,
        local: local,
        remote: remote,
      ),
    ]);

    final result = await TaskSyncApplyService(store: store).apply(
      plan: plan,
      conflictChoices: const <String, TaskSyncConflictChoice>{
        'a': TaskSyncConflictChoice.useRemote,
      },
    );

    expect(result.resolvedConflictCount, 1);
    expect((await store.load()).single.title, 'Remote');
  });

  test('stale plan fails closed when local task changed after planning',
      () async {
    final store = TaskStore();
    final plannedLocal = task('a', 'Before');
    await store.save(<Task>[plannedLocal]);
    final plan = TaskSyncPlan(<TaskSyncPlanItem>[
      item(
        id: 'a',
        decision: SyncMergeDecision.localOnly,
        local: plannedLocal,
      ),
    ]);

    await store.save(<Task>[task('a', 'Newer local edit')]);

    await expectLater(
      TaskSyncApplyService(store: store).apply(plan: plan),
      throwsA(isA<StateError>()),
    );
    expect((await store.load()).single.title, 'Newer local edit');
  });

  test('rejects conflict choices for non-conflict ids', () async {
    final store = TaskStore();
    final local = task('a', 'Local');
    await store.save(<Task>[local]);
    final plan = TaskSyncPlan(<TaskSyncPlanItem>[
      item(
        id: 'a',
        decision: SyncMergeDecision.localOnly,
        local: local,
      ),
    ]);

    await expectLater(
      TaskSyncApplyService(store: store).apply(
        plan: plan,
        conflictChoices: const <String, TaskSyncConflictChoice>{
          'a': TaskSyncConflictChoice.useLocal,
        },
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect((await store.load()).single.title, 'Local');
  });
}
