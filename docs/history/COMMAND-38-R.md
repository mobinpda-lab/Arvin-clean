# COMMAND 38-R — Clean Foundation Implementation
- Recorded: 2026-11-18 | Decision: NO-GO — IMPLEMENTATION NOT ACCEPTED
- Repository: mobinpda-lab/Arvin-clean | Canonical PR: #3495
- Audited canonical HEAD: `9d455fae7ae6fd3ba207709aa0348b3b48c66e97`
- Main SHA observed: `45e4202b03a434459e4c021a04efa7e8396359db`
- PR #3495: OPEN, DRAFT, UNMERGED at audit time.
- No Main change, merge, release or deployment was performed by COMMAND 38-R.

## Workflow evidence
- PR #3495 had 204 commits and 168 changed files at audit time.
- Build run 44261341325: FAIL.
- Follow-up File Persistence run 44261341299: PASS.
- Device Smoke run 44261341320: PASS.
- COMMAND 20-E run 44261341343: FAIL.
- Build workflow: Analyze, Debug APK and Release APK steps passed; test shards 1 and 2 failed. Other reported shards passed.
- Shard 1: `g1_drift_schema_test.dart` attempted a query before `QueryExecutor.ensureOpen()`. This invalidates that migration test; it does not alone prove migration data loss.
- Shard 2: `person_directory_page_test.dart` failed to find expected text for person deletion. Investigate without weakening/removing assertions.
- COMMAND 20-E final evidence collection returned NO-GO despite intermediate ProjectStore file-persistence checks passing.
These are historical workflow snapshots, not current workflow status.

## Architecture findings
The v8→v9 migration changed:
- `lib/services/g1_drift_schema.dart`
- `lib/services/g1_rev10_hierarchy_v9_migration.dart`
- `test/services/g1_drift_schema_test.dart`

It added `centers`, `center_projects`, `categories`, `project_categories`, `arvin_migration_exceptions`, and Task columns `center_id`, `project_id`, `category_id`. Historical `project_items` and `taxonomy_categories` were not removed by this migration. Existing behavior included ID preservation, avoiding automatic selection for ambiguous memberships, FK constraints, transaction/rollback handling and retry-marker tests.

Critical gaps: no `project_executions`; competing Task/Project relation paths remain (`tasks.project_id` and `project_items`); final unified Store/Database Executor not proven; reporting and backup/restore not proven. The current v8→v9 migration is not a demonstrated full historical path from Main v7 through all historical versions.

## Backup/restore
Not accepted. Independent SQLite restore, complete relation preservation, row-count reconciliation, post-restore FK validation and corruption/recovery tests were not proven.

## Acceptance snapshot at audited SHA
- PASS: Flutter Analyze; Debug APK; Release APK Build; Device Smoke; Follow-up File Persistence; reported passing test shards.
- FAIL: test shards 1 and 2; COMMAND 20-E final result.
- BLOCKED/NOT PROVEN: complete historical upgrade; ProjectExecution isolation; aggregate/per-Center reporting; no-duplicate counting; independent backup/restore; full Store consolidation.
All evidence must be rerun on one candidate SHA before acceptance.

## Next actions
1. Complete v7–v20 history and prove a real SQLite upgrade route.
2. Approve final schema and relationship ownership before implementation.
3. Add ProjectExecution and eliminate duplicate semantic ownership only after lossless migration proof.
4. Consolidate stores on one Database Executor.
5. Implement reports and backup/restore.
6. Repair test fixtures and person-directory failure without weakening tests.
7. Run all 21 acceptance checks on one SHA.