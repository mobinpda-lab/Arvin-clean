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

The stale stacked PR #351 is superseded by a fresh stack based on PR #380 / branch `feat/issue-342-sync-plan-apply-main`. This preserves the dependency while ensuring the parent implementation itself was rebuilt from current main.

After the parent is merged, this lane must be retargeted/reconciled to fresh main before final heavy validation and merge.

## Next dependent slice

After the apply lane and this contract are merged on current main, add orchestration/provider work that performs:

`remote fetch -> deterministic merge plan -> explicit conflict resolution -> remote compare-and-swap -> canonical local apply -> durable sync metadata/retry queue`

Production provider credentials must remain outside portable Backup/settings payloads.
