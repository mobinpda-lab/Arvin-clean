import 'package:arvin/models/task.dart';
import 'package:arvin/services/sync_merge_service.dart';
import 'package:arvin/services/task_sync_plan_service.dart';
import 'package:arvin/services/task_sync_revision_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = TaskSyncPlanService();
  final fixedTime = DateTime.utc(2026, 8, 27, 12);

  Task task(String id, String title) => Task(
        id: id,
        title: title,
        createdAt: fixedTime,
      );

  test('plans union of local and remote canonical ids deterministically', () async {
    final plan = await service.plan(
      localTasks: [
        task('b', 'same'),
        task('a', 'local only'),
      ],
      remoteTasks: [
        task('c', 'remote only'),
        task('b', 'same'),
      ],
    );

    expect(plan.items.map((item) => item.id).toList(), ['a', 'b', 'c']);
    expect(
      plan.items.map((item) => item.result.decision).toList(),
      [
        SyncMergeDecision.localOnly,
        SyncMergeDecision.identical,
        SyncMergeDecision.remoteOnly,
      ],
    );
    expect(plan.hasConflicts, isFalse);
    expect(plan.conflictCount, 0);
  });

  test('divergent canonical Tasks remain an explicit conflict without base evidence', () async {
    final plan = await service.plan(
      localTasks: [task('same', 'local edit')],
      remoteTasks: [task('same', 'remote edit')],
    );

    expect(plan.items, hasLength(1));
    expect(plan.items.single.result.decision, SyncMergeDecision.conflict);
    expect(plan.items.single.requiresUserResolution, isTrue);
    expect(plan.conflictCount, 1);
  });

  test('common ancestor evidence allows only the changed side to win', () async {
    final base = task('same', 'base');
    final baseRevision = await TaskSyncRevisionService().fromTask(base);

    final localPlan = await service.plan(
      localTasks: [task('same', 'local changed')],
      remoteTasks: [task('same', 'base')],
      baseFingerprints: {'same': baseRevision.fingerprint},
    );
    expect(
      localPlan.items.single.result.decision,
      SyncMergeDecision.useLocal,
    );

    final remotePlan = await service.plan(
      localTasks: [task('same', 'base')],
      remoteTasks: [task('same', 'remote changed')],
      baseFingerprints: {'same': baseRevision.fingerprint},
    );
    expect(
      remotePlan.items.single.result.decision,
      SyncMergeDecision.useRemote,
    );
  });

  test('duplicate ids on either side fail closed', () async {
    await expectLater(
      service.plan(
        localTasks: [task('dup', 'one'), task('dup', 'two')],
        remoteTasks: const [],
      ),
      throwsArgumentError,
    );

    await expectLater(
      service.plan(
        localTasks: const [],
        remoteTasks: [task('dup', 'one'), task('dup', 'two')],
      ),
      throwsArgumentError,
    );
  });

  test('empty Task ids fail closed before merge planning', () async {
    await expectLater(
      service.plan(
        localTasks: [task('', 'invalid')],
        remoteTasks: const [],
      ),
      throwsArgumentError,
    );
  });

  test('empty local and remote sets produce an empty deterministic plan', () async {
    final plan = await service.plan(
      localTasks: const [],
      remoteTasks: const [],
    );

    expect(plan.items, isEmpty);
    expect(plan.hasConflicts, isFalse);
  });
}
