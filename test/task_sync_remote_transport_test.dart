import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_sync_remote_transport.dart';

void main() {
  Task task(String id, String title) => Task(id: id, title: title);

  test('snapshot round-trips canonical Tasks and ancestor evidence', () {
    final snapshot = RemoteTaskSyncSnapshot(
      generation: '7',
      tasks: <Task>[task('a', 'الف')],
      ancestorFingerprints: const <String, String>{'a': 'ancestor-a'},
    );

    final decoded = RemoteTaskSyncSnapshot.fromJson(snapshot.toJson());

    expect(decoded.generation, '7');
    expect(decoded.tasks.single.id, 'a');
    expect(decoded.tasks.single.title, 'الف');
    expect(decoded.ancestorFingerprints['a'], 'ancestor-a');
  });

  test('snapshot rejects duplicate Task ids and orphan ancestor evidence', () {
    expect(
      () => RemoteTaskSyncSnapshot(
        generation: '1',
        tasks: <Task>[task('a', 'A'), task('a', 'Duplicate')],
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => RemoteTaskSyncSnapshot(
        generation: '1',
        tasks: <Task>[task('a', 'A')],
        ancestorFingerprints: const <String, String>{'missing': 'hash'},
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('compare-and-swap applies once and duplicate retry is idempotent',
      () async {
    final transport = InMemoryTaskSyncRemoteTransport(
      RemoteTaskSyncSnapshot(
        generation: '1',
        tasks: <Task>[task('a', 'Before')],
      ),
    );
    final proposed = RemoteTaskSyncSnapshot(
      generation: '1',
      tasks: <Task>[task('a', 'After')],
    );

    final first = await transport.compareAndSwap(
      snapshot: proposed,
      expectedGeneration: '1',
      operationId: 'op-1',
    );
    final duplicate = await transport.compareAndSwap(
      snapshot: proposed,
      expectedGeneration: '1',
      operationId: 'op-1',
    );

    expect(first.applied, isTrue);
    expect(first.generation, '2');
    expect(duplicate.applied, isFalse);
    expect(duplicate.generation, '2');
    expect((await transport.fetch()).tasks.single.title, 'After');
    expect(transport.appliedOperationIds, contains('op-1'));
  });

  test('stale remote generation fails instead of overwriting', () async {
    final transport = InMemoryTaskSyncRemoteTransport(
      RemoteTaskSyncSnapshot(
        generation: '5',
        tasks: <Task>[task('a', 'Remote newest')],
      ),
    );

    await expectLater(
      transport.compareAndSwap(
        snapshot: RemoteTaskSyncSnapshot(
          generation: '4',
          tasks: <Task>[task('a', 'Stale proposal')],
        ),
        expectedGeneration: '4',
        operationId: 'op-stale',
      ),
      throwsA(
        isA<TaskSyncRemoteConflict>()
            .having((value) => value.expectedGeneration, 'expected', '4')
            .having((value) => value.actualGeneration, 'actual', '5'),
      ),
    );

    expect((await transport.fetch()).tasks.single.title, 'Remote newest');
  });

  test('offline failure leaves stable retry identity for next attempt',
      () async {
    final transport = InMemoryTaskSyncRemoteTransport(
      RemoteTaskSyncSnapshot(generation: '1', tasks: <Task>[task('a', 'A')]),
    )..available = false;
    final envelope = TaskSyncRetryEnvelope(
      operationId: 'stable-op',
      expectedGeneration: '1',
      snapshot: RemoteTaskSyncSnapshot(
        generation: '1',
        tasks: <Task>[task('a', 'B')],
      ),
    );

    await expectLater(
      transport.compareAndSwap(
        snapshot: envelope.snapshot,
        expectedGeneration: envelope.expectedGeneration,
        operationId: envelope.operationId,
      ),
      throwsA(isA<TaskSyncRemoteUnavailable>()),
    );

    final retry = envelope.nextAttempt();
    expect(retry.operationId, envelope.operationId);
    expect(retry.expectedGeneration, envelope.expectedGeneration);
    expect(retry.attempt, 1);
  });

  test('malformed serialized snapshot fails closed', () {
    expect(
      () => RemoteTaskSyncSnapshot.fromJson(<String, dynamic>{
        'formatVersion': 1,
        'generation': '1',
        'tasks': <Object>['not-a-task'],
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
