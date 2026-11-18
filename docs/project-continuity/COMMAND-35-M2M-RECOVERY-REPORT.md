# COMMAND 35 — M2M Recovery Report
Priority: P0 data architecture
Status: BLOCKED — source reviewed, canonical integration not accepted.

## Schema lineage observed
- Main `lib/services/g1_drift_schema.dart`: version 7, blob `cd065ff25c680ed064e89068b3d063e737091025`.
- Canonical PR #3495 at audit baseline: version 8, blob `3d932bcaf27a5bd8f7ecb744ce9dcf8bb254246f`.
- PR #3384 head: version 19, blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
- PR #3463 head: version 20, blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`.

## M2M source inspected
PR #3463 adds `lib/services/g1_many_to_many_hierarchy_migration.dart`:
- Declares source schema version 19 and target version 20.
- Rejects a source version other than 19.
- Creates `center_projects` and `project_categories` junction tables.
- Adds optional `center_id`, `project_id`, `category_id` columns to Tasks.
- Migrates legacy `projects.center_id` and Task/project membership data with explicit missing-reference checks.
- Adds indexes and relationship guard triggers.
- Preserves legacy project relationship evidence and records exceptions rather than silently dropping invalid relationships.
- Includes dedicated lifecycle, historical parity, M2M acceptance and failure-recovery tests.

## Canonical comparison
At the exact audit baseline:
- Canonical schema is v8, not v19.
- The M2M migration source file is absent.
- `CenterStore` is absent.
- The M2M acceptance and migration test files are absent.
- Canonical `ProjectStore` is a materially different implementation and still uses `project_items` membership; it is not the #3463 blob.
- Canonical schema and source v20 schema are materially different.

## Safety decision
A direct v19→v20 migration cannot be applied to the current v8 Canonical database. The source migration explicitly accepts only v19. The v7 Main schema, v8 Canonical changes, v19 source and v20 M2M migration must be reconciled into an auditable sequential upgrade path before any production schema operation.

Required before acceptance:
1. Establish a real v8→v19 sequence, with every intermediate version represented by verified source migrations; do not fabricate no-op versions.
2. Audit the complete dependency closure of the v19 schema (including recurrence and occurrence codecs, Task/Project/Center stores and all model readers).
3. Adapt v20 migration to the canonical REV10 schema and current Store contracts.
4. Integrate M2M readers/writers into CenterStore, ProjectStore, TaskStore, Category/Tag and backup/restore.
5. Prove file-backed upgrade, reopen, foreign-key integrity, duplicate/orphan rejection, rollback, retry and legacy parity.
6. Run all acceptance suites on one exact final SHA.

## Historical CI
On #3463 SHA `812082964c649be7660c41213209ec34aea7167b`:
- Dedicated SQLite v20 Lifecycle and M2M Acceptance: SUCCESS (run 43629840018).
- SQLite Snapshot Evidence: SUCCESS (run 43629839832).
- Follow-up File Persistence: SUCCESS (run 43629839898).
- Build: FAILURE (run 43629839831).
- Device Smoke: CANCELLED (run 43629839877).

Dedicated M2M workflow success is useful evidence for the isolated historical candidate only. It does not certify integration into Canonical or the current v8 database.
No migration was executed or copied in this phase.
