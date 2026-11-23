# COMMAND 32 — Data Safety Report
Code checkpoint: `687341469152035053f6325b671c4bad9dab8c96`

## Safety boundaries
- Main not changed.
- No merge, release, deployment, production database access or user-data migration.
- Schema v8 is code-only, additive and nullable.
- No existing SQL table/column dropped.
- No Task, Follow-up, Person, Project or Calendar user record deleted.
- No force push or history rewrite.

## A01
Time preservation and explicit false serialization implemented. Widget/model tests passed on checkpoint SHA. DST/date-boundary cases remain to be tested.

## A02
Unknown Follow-up JSON fields are preserved through model and SQL extension_json. JSON round-trip and file-backed close/reopen tests passed on checkpoint SHA. Full Backup/Restore, repeated save cycles, migration from actual v7 fixture, idempotency and rollback remain required.

## A03
Restore no longer rejects historical Follow-up person IDs solely because the active directory omits them. The new restore test passed. Full file-backed save→backup→restore→report proof remains required. No automatic merge introduced.

## W01
KVM permission mutation removed; expressions corrected; Main merge-base check added. Workflow execution remains unproven; current label-trigger workflow is not present on Main, and the observed run had no executable job. Do not treat W01 as accepted.

## H01
Commit `6873414` waits for SharedPreferences disk flush and captures the app-private XML before force-stop. The workflow's Analyze and ProjectStore file-backed steps passed; actual fresh-process Stage B is still running at last observation. No user preferences were changed; only test keys are used.

No-loss acceptance remains NOT ACCEPTED until all remaining file-backed, migration, Backup/Restore, restart and regression tests pass on one exact code SHA.
