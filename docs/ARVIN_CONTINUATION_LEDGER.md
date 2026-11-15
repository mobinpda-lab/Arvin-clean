# ARVIN Continuation Ledger

## Purpose
This document preserves the implementation context extracted from the long ARVIN review conversation. It is a continuity reference; completion must always be proven by code, tests, builds, and evidence.

## Source of Truth
GitHub code + PR + tests + APK/device evidence are authoritative.

## Home
- Keep canonical visual shell.
- Validate against reference screenshots.
- Verify cards, RTL, typography, spacing, search, and primary add action.
- Expected flow:

Home Card -> Task Detail -> Edit / FollowUp

## Task Flow
All creation and editing paths must converge:

Quick Entry / Create / Edit -> Unified Task Editor -> Canonical Repository -> arvin.tasks

Avoid parallel models, stores, or write paths.

## Task Detail
Required:
- Task information
- FollowUp Timeline
- Add FollowUp
- Edit flow

## FollowUp
Required:
- Multiple followups per task
- History preservation
- Latest FollowUp projection
- Persian/Jalali handling
- Empty states

## Quick Entry
Quick capture must use the same canonical task path and not create a separate storage model.

## Notebook
Simple Note and Checklist must respect canonical architecture. Avoid duplicate storage paths.

## Calendar
Validate:
- No date means no calendar event
- Date only means all-day behavior
- Date plus time means timed event

## Visual Validation Gate
Before release:
1. Code
2. Tests
3. Build
4. Install
5. Screenshot comparison
6. Evidence

## Execution Order
1. Audit remaining Home routes and Task navigation.
2. Verify Unified Editor paths.
3. Verify FollowUp evidence.
4. Run tests.
5. Build APK.
6. Record evidence.

## Rule
Do not report a feature as completed without a GitHub artifact (commit/PR/test/build/evidence).

## REV10 unified execution checkpoint — 2026-11-15

### Exact repository baseline
- Protected `main` HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Canonical branch `recovery-02/main-based-integration` HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- The two refs were independently fetched from GitHub and are identical. The Canonical branch therefore starts this execution with zero product commits beyond Main.
- No product source, database, user data, Main ref, or historical PR was changed during the baseline inspection.

### Active legacy implementation lines (live GitHub metadata)
- PR #3384: OPEN / DRAFT / UNMERGED; base `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`; head `feature/command-07-a-sqlite-contract-remediation` at `310c0e20e3447c488c1e1c102c38bea5040708ca`; 218 commits, 120 changed files.
- PR #3463: OPEN / DRAFT / UNMERGED; base #3384 head `310c0e20e3447c488c1e1c102c38bea5040708ca`; head `rev10-m2m-v19-test-expansion` at `812082964c649be7660c41213209ec34aea7167b`; 139 commits, 42 changed files.
- PR #3470: OPEN / DRAFT / UNMERGED; base #3384 head `310c0e20e3447c488c1e1c102c38bea5040708ca`; head `fix/vazirmatn-typography-contract-20261114` at `d7c9322afb9cb32e607f53e139f8bd82a984c805`; 24 commits, 21 changed files.
- These PRs are stacked/sibling legacy lines, not a single Main-based delivery branch. They remain untouched and their history must be preserved.
- PR #3448 is a separate OPEN / DRAFT REV10 governance-document line, based on the REV9 documentation branch; it is not the product implementation PR and is not based on Main.

### Verified Main-tree facts
- `lib/services/g1_drift_schema.dart` on Main is schema version 7. It does not contain the REV10 v20 schema or the reported mutable-lifecycle-field constructor issue.
- `lib/services/g1_hierarchy_candidate_schema.dart` and `test/services/task_template_store_test.dart` are absent from the current Main tree.
- Main's `pubspec.yaml` declares the Vazirmatn family with Regular 400, Medium 500 and Bold 700 assets. This declaration alone does not prove font-file integrity or complete UI compliance.
- Main already has a substantial Backup/Restore surface and file-backed test coverage; this does not establish that REV10 relational entities and junction relationships are fully represented in product Backup/Restore.
- The historical `isNull` import changes are present in the PR #3463 file snapshots at their respective later commits, but their test files are not both present on Main. They must be transferred only with their required source/test dependencies, not pasted into unrelated files.

### Immediate execution boundary
- The first required integration unit is the REV10 v19-to-v20 schema/migration and its real file-backed acceptance suite, followed by the matching TaskStore/ProjectStore/CenterStore and Backup/Restore consumers.
- The reported `const` / `_lifecycleCompleted` issue is not present in Main's current v7 schema. It must be checked against the exact v20 candidate source and its failing CI log before any edit; no speculative change is authorized.
- Existing `build.yml` runs Analyze, six test shards and Debug/Release APK builds on pull_request events and supports workflow_dispatch. The GitHub connection exposes no workflow-dispatch action, so PR-triggered CI is the available automatic route in this execution.
- No acceptance result is inherited from another SHA. Every future result must be tied to the exact Canonical PR head.

### Acceptance status at this checkpoint
- REV10 schema and migration integration: NOT STARTED on Canonical.
- Task/Project/Center relationship persistence on Canonical: NOT ACCEPTED.
- Backup/Restore relational parity on Canonical: NOT ACCEPTED.
- Full UI integration and regression: NOT ACCEPTED.
- Final acceptance / release: NO-GO.
- Next work must be an implementation commit on this Canonical branch, then one Draft PR based on Main. No legacy PR is to be closed or merged until its useful changes are proven transferred.


## REV10 implementation continuation — 2026-11-15

### Canonical delivery path
- Primary PR: #3495, OPEN / DRAFT / UNMERGED.
- Base: `main`; Main remains unchanged at `45e4202b03a434459e4c021a04efa7e8396359db`.
- Head branch: `recovery-02/main-based-integration`.
- Product implementation commits currently on this branch: `4b83508fe7e4064cbc6407cb5955713b7d44b279` and `4456ce674f4eeb63aeebb7fc174166b199f70f16`.
- The only Canonical PR for delivery is #3495. Legacy PRs #3384, #3463 and #3470, plus governance PR #3448, remain untouched and preserved.

### Implemented safety slice — ProjectStore
- `ProjectStore.save` now delegates to transactional additive upsert; ordinary saves no longer delete/recreate the full Project collection.
- Project identity and Projects omitted from a partial update are preserved.
- The model and codec distinguish missing `itemIds` from an explicit empty list. Missing membership preserves SQL edges; an explicit empty list clears only that Project's membership.
- Unknown historical Project envelope fields are loaded into `legacyFields` and carried through upsert.
- Explicit deletion is performed in the same transaction as the upsert batch and is blocked while a Project still references Tasks.
- The Projects launcher now sends explicit removed IDs; TaskProjectAssignmentService uses additive upsert.
- Backup restore retains its explicit full-snapshot replacement path.
- `clear()` now uses guarded deletion and is rejected if any Project still has Task links.
- Added regression tests for partial upsert, relationship preservation, explicit membership clearing, metadata round-trip, delete rollback and guarded clear.
- These changes are a bounded safety slice on the existing Main schema; they do not implement REV10 M2M or v20 migration.

### Exact schema dependency discovered
- Main `lib/services/g1_drift_schema.dart`: schema version 7.
- PR #3384 head `310c0e20e3447c488c1e1c102c38bea5040708ca`: schema version 19.
- PR #3463 head `812082964c649be7660c41213209ec34aea7167b`: schema version 20.
- Therefore the REV10 v20 candidate cannot be transplanted directly onto Main. The v7-to-v19 foundation and its real migrations/consumers must be reconciled first; then the v19-to-v20 M2M migration can be integrated. Do not treat the candidate's v20 tests as proof that Main can safely open or migrate user databases.

### Historical compile-failure root causes
- At historical candidate SHA `b4bff298074c10e295094f4f6bb2a1b1dac1608a`, `G1DriftSchema` had a const constructor while also declaring mutable `_lifecycleCompleted`. Dart rejects that combination.
- Candidate history shows the constructor was made non-const in `b3d6fc4283632d5f7dd5f4954ab7c32cd90850a5`; current v20 candidate source at `812082...` is non-const. Main's current v7 schema does not contain this issue. No speculative Main edit was made.
- On candidate SHA `812082...`, Analyze logs identify ambiguous `isNull` imports in `test/services/task_template_store_test.dart` and `test/task_store_reminder_persistence_test.dart`. Historical fixes `83a6431c3ef6b4b77543a839e6f2a59690f6044d` and `718ca4c6e815319222a5d20291211c7eb56b2696` hide Drift's `isNull` in those imports. Those tests/dependencies are not both present on Main; port them only with the associated v19/v20 implementation and test suite.

### Historical CI evidence — candidate SHA only
- PR #3463 Build run `43629839831` failed on exact head `812082...`: Analyze failed on the ambiguous imports; all six test shards failed with compile and existing UI/regression assertions. Debug, Release and Staging APK builds passed; Visual passed.
- On that same exact SHA, SQLite v20 acceptance run `43629840018`, SQLite Snapshot run `43629839832`, and Follow-up Persistence run `43629839898` succeeded.
- Device Smoke run `43629839877` was still queued at the last observed state.
- These candidate results do not transfer to Canonical or establish product acceptance.

### Canonical CI boundary
- The PR #3495 head `4456ce674f4eeb63aeebb7fc174166b199f70f16` has Build, six test shards, Debug/Release APK, Follow-up Persistence, Device Smoke, Orchestrator, Parallel Wave and G1 lock-sync checks registered.
- At the last exact-head check, all quality/build/smoke jobs were QUEUED; no result is PASS yet.
- Flutter/Dart are not available in the local execution container. GitHub Actions is the selected validation environment; no local test execution is claimed.

### Remaining acceptance gates
- Main v7 to canonical v19 schema migration and historical parity: NOT ACCEPTED.
- v19-to-v20 REV10 M2M migration on real file-backed Main-derived databases: NOT ACCEPTED.
- Task optional Center/Project/Category links and Task↔Tag persistence: NOT ACCEPTED.
- CenterStore, ProjectStore and Category/Tag consumer integration against the REV10 graph: NOT ACCEPTED.
- Full relational Backup/Restore, metadata parity and rollback across all entities: NOT ACCEPTED.
- Full page integration, typography audit, regression and device smoke on one final SHA: NOT ACCEPTED.
- Final acceptance remains NO-GO. Main, merge, release, deployment and production user data remain protected.
