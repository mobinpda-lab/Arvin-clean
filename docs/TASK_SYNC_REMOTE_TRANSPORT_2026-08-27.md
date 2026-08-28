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

The stale stacked PR #351 is superseded by fresh PR #382.

Parent Sync apply PR #380 is now merged to `main` at `c51a68e968ce0939ea521d4a647a6cc7fdf3a904`. GitHub has reduced #382 to exactly the three intended remote-transport files: this document, `task_sync_remote_transport.dart`, and its focused tests.

This commit is the fresh post-parent reconciliation point. Final promotion requires a new exact-head Fast Gate against current main, followed by full Quality, debug/release APK and Home/People Device evidence on the same head before merge.

## Next dependent slice

After this contract is merged on current main, add orchestration/provider work that performs:

`remote fetch -> deterministic merge plan -> explicit conflict resolution -> remote compare-and-swap -> canonical local apply -> durable sync metadata/retry queue`

Production provider credentials must remain outside portable Backup/settings payloads.
