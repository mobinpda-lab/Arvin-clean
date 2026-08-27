import 'package:arvin/services/sync_merge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = SyncMergeService();

  const local = SyncRevision(id: 'task-1', fingerprint: 'local');
  const remote = SyncRevision(id: 'task-1', fingerprint: 'remote');

  test('accepts identical local and remote records', () {
    const sameRemote = SyncRevision(id: 'task-1', fingerprint: 'local');

    final result = service.decide(local: local, remote: sameRemote);

    expect(result.decision, SyncMergeDecision.identical);
    expect(result.requiresUserResolution, isFalse);
  });

  test('selects the only changed side with common ancestor evidence', () {
    final localChanged = service.decide(
      local: local,
      remote: const SyncRevision(id: 'task-1', fingerprint: 'base'),
      baseFingerprint: 'base',
    );
    final remoteChanged = service.decide(
      local: const SyncRevision(id: 'task-1', fingerprint: 'base'),
      remote: remote,
      baseFingerprint: 'base',
    );

    expect(localChanged.decision, SyncMergeDecision.useLocal);
    expect(remoteChanged.decision, SyncMergeDecision.useRemote);
  });

  test('reports conflict when both sides diverged from the base', () {
    final result = service.decide(
      local: local,
      remote: remote,
      baseFingerprint: 'base',
    );

    expect(result.decision, SyncMergeDecision.conflict);
    expect(result.requiresUserResolution, isTrue);
  });

  test('never uses timestamps alone to silently resolve divergence', () {
    final result = service.decide(
      local: SyncRevision(
        id: 'task-1',
        fingerprint: 'local',
        modifiedAt: DateTime(2026, 8, 27, 12),
      ),
      remote: SyncRevision(
        id: 'task-1',
        fingerprint: 'remote',
        modifiedAt: DateTime(2026, 8, 27, 13),
      ),
    );

    expect(result.decision, SyncMergeDecision.conflict);
  });

  test('keeps one-sided records without manufacturing conflicts', () {
    expect(
      service.decide(local: local).decision,
      SyncMergeDecision.localOnly,
    );
    expect(
      service.decide(remote: remote).decision,
      SyncMergeDecision.remoteOnly,
    );
  });

  test('rejects mismatched record ids', () {
    expect(
      () => service.decide(
        local: local,
        remote: const SyncRevision(id: 'task-2', fingerprint: 'remote'),
      ),
      throwsArgumentError,
    );
  });
}
