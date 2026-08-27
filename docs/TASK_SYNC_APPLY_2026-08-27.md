# Canonical Task Sync Apply — 2026-08-27

Issue #342. Refs #303 #299 #290 #195.

## Goal
Advance multi-device Sync from read-only merge planning toward the canonical persistence boundary without choosing a network provider or introducing another Task store.

## Flow

`local/remote Tasks -> TaskSyncPlanService -> explicit conflict choices -> TaskSyncApplyService -> TaskStore/arvin.tasks`

## Behavior

- Existing local records preserve their current TaskStore order.
- Remote-only records are appended in deterministic plan order.
- `localOnly`, `identical` and `useLocal` keep the local Task.
- `remoteOnly` and `useRemote` select the remote Task.
- `conflict` requires one explicit per-Task `useLocal` or `useRemote` choice.
- Unknown conflict choices fail closed.
- Before any write, the current canonical TaskStore is compared with the local snapshot represented by the plan. If the local set or any local payload changed after planning, the apply is rejected as stale.
- Only one `TaskStore.save` occurs, after the complete plan is valid and every conflict is resolved.

## Safety boundary

- no network/provider/cloud selection;
- no background work;
- no second Task repository/database/key;
- no timestamp winner;
- no automatic conflict resolution;
- no partial write on validation failure;
- no UI in this slice.

## Validation

Focused tests cover deterministic merge application, local-order preservation, remote replacement, explicit conflict resolution, stale-plan rejection and zero-mutation failures.

This slice does not by itself complete multi-device Sync. Provider transport, durable remote state, user-facing conflict UI and end-to-end device synchronization remain separate gates.
