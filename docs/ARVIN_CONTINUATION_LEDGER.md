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
