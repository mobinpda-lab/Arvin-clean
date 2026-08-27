enum SyncMergeDecision {
  localOnly,
  remoteOnly,
  identical,
  useLocal,
  useRemote,
  conflict,
}

class SyncRevision {
  const SyncRevision({
    required this.id,
    required this.fingerprint,
    this.modifiedAt,
  });

  final String id;

  /// Stable hash/fingerprint of the canonical serialized record.
  final String fingerprint;
  final DateTime? modifiedAt;
}

class SyncMergeResult {
  const SyncMergeResult({
    required this.decision,
    this.local,
    this.remote,
  });

  final SyncMergeDecision decision;
  final SyncRevision? local;
  final SyncRevision? remote;

  bool get requiresUserResolution => decision == SyncMergeDecision.conflict;
}

/// Pure merge-decision foundation for multi-device sync.
///
/// Divergent records are never resolved by timestamps alone. Without common
/// ancestor evidence the service reports an explicit conflict, preventing a
/// silent last-write-wins data loss policy from entering production.
class SyncMergeService {
  const SyncMergeService();

  SyncMergeResult decide({
    SyncRevision? local,
    SyncRevision? remote,
    String? baseFingerprint,
  }) {
    if (local == null && remote == null) {
      throw ArgumentError('At least one sync revision is required.');
    }

    if (local == null) {
      return SyncMergeResult(
        decision: SyncMergeDecision.remoteOnly,
        remote: remote,
      );
    }
    if (remote == null) {
      return SyncMergeResult(
        decision: SyncMergeDecision.localOnly,
        local: local,
      );
    }
    if (local.id != remote.id) {
      throw ArgumentError('Local and remote revision ids must match.');
    }

    if (local.fingerprint == remote.fingerprint) {
      return SyncMergeResult(
        decision: SyncMergeDecision.identical,
        local: local,
        remote: remote,
      );
    }

    if (baseFingerprint != null) {
      final localChanged = local.fingerprint != baseFingerprint;
      final remoteChanged = remote.fingerprint != baseFingerprint;

      if (localChanged && !remoteChanged) {
        return SyncMergeResult(
          decision: SyncMergeDecision.useLocal,
          local: local,
          remote: remote,
        );
      }
      if (!localChanged && remoteChanged) {
        return SyncMergeResult(
          decision: SyncMergeDecision.useRemote,
          local: local,
          remote: remote,
        );
      }
    }

    return SyncMergeResult(
      decision: SyncMergeDecision.conflict,
      local: local,
      remote: remote,
    );
  }
}
