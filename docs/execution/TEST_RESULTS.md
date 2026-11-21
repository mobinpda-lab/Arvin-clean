# Test Results — Evidence Snapshot
- Recorded: 2026-11-18
- Evidence SHA: `9d455fae7ae6fd3ba207709aa0348b3b48c66e97`
- Historical workflow snapshot; rerun before acceptance.

| Test/workflow | Run ID | Result | Notes |
|---|---:|---|---|
| Build workflow | 44261341325 | FAIL | Analyze, Debug APK and Release APK steps passed; test shards 1 and 2 failed |
| Follow-up File Persistence | 44261341299 | PASS | workflow snapshot |
| Device Smoke | 44261341320 | PASS | workflow snapshot |
| COMMAND 20-E | 44261341343 | FAIL | final evidence collection NO-GO |
| Flutter Analyze | within 44261341325 | PASS | not full acceptance |
| Debug APK | within 44261341325 | PASS | |
| Release APK Build | within 44261341325 | PASS | build only; no release/deploy |
| Test Shard 1 | within 44261341325 | FAIL | Drift fixture queried before QueryExecutor.ensureOpen() |
| Test Shard 2 | within 44261341325 | FAIL | person_directory_page_test.dart expected text missing |
| Other reported shards | within 44261341325 | PASS | review full artifact for exact test inventory |

## Not run or not proven
Historical Upgrade; Center M2M; Project M2M; ProjectExecution Independence; Category Sharing; Task Isolation; Task without Project/Center/Category; Tag Persistence from one source; Aggregate Reporting; Per-Center Reporting; No Duplicate Counting; independent Backup/Restore; Migration Failure Recovery; Migration Retry across all supported source fixtures.

## Acceptance
All required results must attach to one candidate SHA. Never combine PASS results from different SHAs or weaken/remove assertions to manufacture green CI.