# Arvin Problems and Open Risks

## P0 — Restore rollback must cover taxonomy catalogs
- Found in PR #2585: after `mergeCatalogs`, both Home and BackupPage rollback restored Tasks, Projects, Calendar links and settings but did not remove newly added Category/Tag entries.
- A failure after the catalog stage could leave partial taxonomy state behind while the UI reported rollback.
- Proposed fix is now committed at [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354); exact-head CI pending.
- Acceptance: failure injection after catalog writes must restore pre-existing catalogs and remove only entries introduced by the failed restore.

## P0 — Backup/Restore acceptance
- PR #2585 remains open and unmerged.
- Physical-device/file-provider restore remains unverified.
- Validate catalog values not assigned to Tasks, Task assignments, Project membership, settings, recurrence/history, Calendar-link metadata and legacy backup behavior.

## P0 — Calendar event identity
- After restoring a Task with a Calendar link, edit/re-sync must update the same external event and must not create a duplicate.
- Need event IDs/count before and after, plus logs/screenshots and explicit pass/fail.

## P1 — Taxonomy consistency
- Issue #2580 remains open.
- Audit Project/Category/Tag model, stores, serialization, backup, UI, filters, search, reports, calendar, notebook, help, docs and tests.
- Correct historical wording carefully; do not create a Group entity or infer an unverified Category-to-Project foreign key.

## User-reported UX issue
- Calendar view reportedly lost the actions for registering a task in the phone calendar and editing it. Verify live code and acceptance before marking resolved.

## Evidence freshness risk
- Workflow evidence applies only to the exact commit tested. Recheck PR head before relying on prior successful runs.
