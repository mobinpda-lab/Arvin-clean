# Arvin Maximum Parallel Continuation — 2026-08-27

Issue: #353

## Purpose
Persist the current operational state of the Maximum Parallel development wave so any later continuation can resume from GitHub reality without stopping independent production lanes.

This document records execution state and guardrails. It does not grant product progress by itself and does not replace live GitHub/CI evidence.

## Live baseline at documentation start
- `main`: `20c881d6f744bc53eb22ca63c59523e352433b49`
- latest merged baseline includes PR #337 People Android E2E
- all merge/readiness decisions must refresh `main`, PR state and exact-head workflow evidence before acting

## Active / prepared lanes

### PR #345 — Canonical Sync apply
Status at this snapshot: open, Ready, mergeable.

Purpose:
- consume a reviewed `TaskSyncPlan`
- require explicit per-Task conflict choices
- reject stale local state before any write
- preserve canonical TaskStore ordering and use one final canonical save
- no automatic conflict winner, no second Task repository, no partial write

Evidence already observed on its exact head during this wave included successful Fast/Parallel, quality/tests, APK build and Device Smoke. Before merge, refresh the exact current workflow state and `main` SHA again.

### PR #346 — Idempotent external Calendar sync plan
Status at this snapshot: open, Ready, mergeable.

Purpose:
- stable fingerprint for eligible canonical FollowUp reminders
- deterministic create/update/no-op/delete plan
- stable external event link metadata for duplicate prevention
- official holidays/prayer rows and completed reminders stay outside external sync
- no OAuth/token storage, no Calendar Provider writes or permissions in this contract slice

Provider execution remains a separate lane.

### PR #347 — Comprehensive target reconciliation
Status at this snapshot: open, Ready, mergeable.

Purpose:
- reconcile the comprehensive Arvin product direction with the live repository
- separate product acceptance outcomes from implementation technology choices
- record that SQLite, Riverpod and WorkManager are options rather than automatic product requirements
- keep real multi-device Sync and real idempotent external Calendar synchronization as hard remaining product gaps
- preserve canonical foundations and Maximum Parallel execution rules

### Issue #348 — Android Calendar Provider execution
Prepared next lane after #346 contract integration.

Target:
- enumerate/select writable Android calendars, including Google-backed calendars exposed through Android
- execute create/update/no-op/delete against the exact linked event
- persist minimal link metadata only after provider success
- explicit permission denial/revocation handling
- no OAuth token in SharedPreferences or portable backup
- provider failure must not mutate canonical Task/FollowUp data

### Issue #349 / PR #351 — Remote Sync transport, CAS and retry
PR #351 is intentionally stacked on #345 at this snapshot and remains Draft until parent reconciliation.

Purpose:
- versioned remote Task snapshot contract
- canonical Task JSON/revision evidence and optional ancestor fingerprints
- remote generation/etag/precondition evidence
- compare-and-swap writes to prevent silent remote overwrite
- stable operation identity and idempotent retry envelope
- no real network/provider credentials in the contract slice

Critical boundary:
`CloudBackupProvider` / Dropbox backup files are backup semantics, not live multi-device Sync state. Shared low-level transport plumbing is allowed only where safe; product semantics must remain separate.

After #345 merges, #351 must be rebuilt/reconciled from fresh `main` and revalidated. Stacked CI is contract evidence, not final merge evidence.

## Maximum Parallel production rule
Independent product, test, documentation and audit lanes SHOULD continue concurrently when their file/domain boundaries do not overlap.

Documentation, architecture reconciliation, reporting or CI observation MUST NOT stop non-conflicting product production.

A lane may wait only for a real technical dependency such as:
- required parent contract not yet merged;
- overlapping canonical file/foundation ownership;
- exact-head validation failure;
- stale branch that must be reconciled with current `main`;
- destructive/data/security risk that requires a safer boundary first.

Waiting in one lane never implies stopping unrelated lanes.

## Non-interference rules
- no direct product changes on `main` from documentation lanes
- one narrow Issue/Branch/PR per independent acceptance slice
- branch from current `main`, except deliberate stacked PRs with an explicit parent
- no force-push/history rewrite during normal continuation
- do not duplicate Task model, Task repository, persistence key, Sync engine, Calendar source of truth, Router/AppShell or UI foundation
- do not turn backup transport into live Sync semantics
- do not add Calendar permissions/provider writes before the provider contract lane
- do not grant scorecard/progress credit from documentation alone

## Validation / merge protocol
For each product lane:
1. refresh live `main` and PR head
2. confirm mergeability and file overlap
3. validate exact-head Analyze/Test/Parallel as applicable
4. validate full Build/APKs and Device/Emulator evidence required by that lane
5. merge only the exact validated head
6. refresh `main` after merge
7. run/observe post-merge current-main validation before promotion
8. only then update progress/scorecard evidence

For documentation-only lanes, use the same branch/PR discipline but do not require unrelated product behavior changes.

## Preferred continuation order
This is dependency order, not a command to serialize independent work:
1. merge/revalidate #345 when all exact-head gates and live-main checks remain green
2. rebuild #351 from the new `main`; continue remote transport/retry work
3. merge/revalidate #346 when its full exact-head gates are green
4. start/continue #348 Android Calendar Provider adapter from the merged contract
5. integrate #347 documentation reconciliation when its documentation/CI gate is clean
6. keep active UI/device/E2E lanes moving independently throughout

## Reporting rule
User-facing status reports stay short and non-technical:
- what became real
- what is currently validating
- what remains dependent
- any real blocker

Do not report future/queued work as completed. GitHub reality overrides this snapshot whenever the repository changes.
