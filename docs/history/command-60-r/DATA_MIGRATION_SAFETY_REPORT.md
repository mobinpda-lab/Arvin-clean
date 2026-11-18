# DATA MIGRATION SAFETY REPORT — INITIAL
**Status:** BLOCKED / NOT ACCEPTED

## Current schema separation
- Main schema: V7.
- Canonical branch G1 schema: V9.
- Historical PR #3384: V19 candidate.
- Historical PR #3463: V20 M2M candidate.
These are separate code lines. No complete sequential V7→V20 user-data migration is accepted.

## COMMAND 49-R
Occurrence migration parity mismatch:
`Bad state: Occurrence migration parity mismatch for Task command49-occurrence-task`.
Failure occurs in `OccurrenceSqlCodec.migrateLegacyEnvelopes`. Later retry/rollback/backup assertions did not complete; they are not PASS.

## COMMAND 50-R
Forensic workflow reproduced:
- second install after reopen failure;
- explicit NULL fidelity failure;
- unknown Occurrence state-field failure.
Rollback/source preservation checks passed in the forensic run, but that is not full migration acceptance.

## Current V8→V9 test issue
The baseline Build test-1 fails in `g1_drift_schema_test.dart`: executor operation before `QueryExecutor.ensureOpen()`. The separate rollback/retry test in that file passes. Diagnose test/database lifecycle; do not hide the failure.

## Safety conditions
No V19 installer changes, no V7 fixture edits, no real-user migration. Before any candidate migration: exact source-shape preconditions, full identity/relationship snapshot, explicit missing-vs-NULL-vs-value, unknown nested metadata, idempotent one/two/three runs, rollback injection, integrity/FK checks, backup and independent restore.
