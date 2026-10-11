# Arvin Problems and Open Risks

## P0 — Backup/Restore acceptance
- PR #2585 is open and unmerged.
- Although current inspected head's Build and six emulator smoke lanes passed, real physical-device/file-provider restore remains unverified.
- Failure rollback coverage must be reviewed at both existing restore entry points; do not confuse store-level rollback tests with end-to-end UI orchestration.
- Catalog values not assigned to Tasks must survive backup/restore.

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
