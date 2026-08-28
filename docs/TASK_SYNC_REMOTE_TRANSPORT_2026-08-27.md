# Task Sync Remote Transport Boundary — 2026-08-27

Issue #349. Rebuilt on the fresh #342 current-main implementation lane for Maximum Parallel delivery.

## Goal

Define the durable provider-neutral boundary required between Arvin's deterministic Sync plan/apply core and a real cloud transport.

## Remote snapshot

`RemoteTaskSyncSnapshot` contains only versioned canonical sync state:

- `formatVersion`;
- remote `generation` used as optimistic concurrency evidence;
- canonical `Task` JSON payloads;
- optional per-Task common-ancestor fingerprints.

Task ids must be non-empty and unique. Ancestor evidence may reference only Tasks present in the snapshot. Malformed input fails closed.

## Transport contract

`TaskSyncRemoteTransport` exposes:

- `fetch()` for the current versioned remote snapshot;
- `compareAndSwap(...)` for a conditional write using:
  - the proposed snapshot;
  - the generation observed during planning;
  - a stable operation id for retry idempotency.

A provider must reject a stale generation rather than silently overwrite newer remote data.

## Retry semantics

`TaskSyncRetryEnvelope` preserves the same operation id and expected generation across retries while increasing only the attempt number. This allows an offline or transient failure to be retried without turning the retry into a second logical write.

A reference in-memory transport demonstrates the required semantics for higher-level tests:

- the first valid compare-and-swap updates the remote generation;
- repeating the same operation id is a no-op and returns the generation earned by the first application;
- a stale expected generation produces an explicit conflict;
- unavailable transport produces an explicit retryable failure.

## Backup is not Sync

Existing `CloudBackupProvider` / Dropbox backup files remain portable Backup/Restore transport. They must not be reinterpreted as live multi-device Sync state. A future provider may share safe low-level HTTP/account plumbing, but Sync has separate generation, precondition, operation identity, conflict and retry semantics.

## Safety boundary

- no network/provider choice in this slice;
- no credential storage;
- no second Task model/database/repository;
- no timestamp winner or last-write-wins;
- no silent remote overwrite;
- no local TaskStore mutation in the transport layer;
- no automatic conflict choice.

## Current-main reconciliation — 2026-08-28

The stale stacked PR #351 is superseded by fresh PR #382 built from the current-main #380 Sync apply parent.

PR #382 is now retargeted to `main` while kept Draft so a new Fast Gate can validate the combined exact head without starting duplicate Heavy CI. Until #380 merges, the visible diff may include the parent apply files; after #380 lands, GitHub should reduce the diff to the remote transport slice only.

Final merge evidence is **not** inherited from this stacked Fast run. After #380 merges, this lane must be reconciled again to the new main, receive a fresh exact-head Fast run, then pass full Build/APK/Device before Ready/Merge.

## Next dependent slice

After the apply lane and this contract are merged on current main, add orchestration/provider work that performs:

`remote fetch -> deterministic merge plan -> explicit conflict resolution -> remote compare-and-swap -> canonical local apply -> durable sync metadata/retry queue`

Production provider credentials must remain outside portable Backup/settings payloads.
