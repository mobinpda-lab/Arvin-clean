# Canonical Task Sync Plan — 2026-08-27

Refs #303 #92 #195 #287 #290 #298 #299.

## Purpose
Advance multi-device sync by composing the already-merged Task revision adapter and safe merge-decision core across complete local/remote canonical Task sets.

## Flow
`Task sets -> TaskSyncRevisionService -> SyncMergeService -> deterministic TaskSyncPlan`

## Behavior
- local and remote Task ids are unioned and sorted deterministically;
- revisions come only from canonical `Task.toJson()` through the merged revision service;
- local-only, remote-only and identical records are explicit;
- common-ancestor fingerprint evidence can prove that only one side changed;
- divergent changes without sufficient ancestor evidence remain explicit conflicts;
- duplicate or empty Task ids fail closed instead of becoming last-write-wins behavior.

## Safety boundary
- no network/provider/cloud selection;
- no persistence/repository/storage write;
- no background work;
- no timestamp-based winner;
- no conflict auto-resolution;
- no second Task model or sync store.

## Validation
Focused tests cover deterministic union order, local/remote-only records, identical records, explicit divergence conflicts, ancestor-proven one-side changes, duplicate ids, empty ids and empty sets.

Keep this lane Draft until exact-head Fast CI is green. If `main` moves first, reconcile without force-push and invalidate old-base evidence before promotion.