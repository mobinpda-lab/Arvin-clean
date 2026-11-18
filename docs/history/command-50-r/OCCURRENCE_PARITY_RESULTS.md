# COMMAND 50-R — Occurrence Parity Results

**Root cause:** CONFIRMED for the COMMAND 49 retry failure.
**Overall COMMAND 50 acceptance:** BLOCKED pending execution of the expanded matrix and evidence completion.

## GitHub Actions evidence

- Run: `44314123737`
- Job: `134835632144`
- Artifact: `14431997314`
- Artifact URL: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44314123737/artifacts/14431997314
- Test harness: `test/command49_v19_safety_test.dart`
- Failing call: second `G1DriftSchema.install(db)` after closing and reopening the first executor; test line 115.
- Stack: `OccurrenceSqlCodec.migrateLegacyEnvelopes`, `occurrence_sql_codec.dart:179`.

The first call to the historical installer completed: the test proceeded to snapshot the first database and reached the second installer invocation. The second call raised the parity error.

## Independent artifact inspection

The downloaded artifact contains `retry-primary.sqlite`, the original V7 fixture, the extended fixture and the full Flutter test log. The post-failure `retry-primary.sqlite` was opened and inspected independently.

Observed after the first successful installation and failed second invocation:
- The destination `task_occurrences` row exists for `command49-occurrence-task`.
- The row retains the expected generated ID, Task ID, scheduled timestamp and pending status.
- The corresponding legacy JSON envelope no longer contains `occurrenceHistory`.
- `recurrence_rules_migrated_v1` and `person_directory_seeded_v1` markers exist, proving execution proceeded beyond the Occurrence step during the first installation.
- The second call fails because the source history has already been retired while the SQL destination row remains.

This is not evidence of initial loss for the simple pending record. It is evidence of a non-idempotent parity check on a subsequent install.

## Other parity cases

| Case | Current disposition |
|---|---|
| Simple pending first transfer | PASS, physically observed |
| Same Task on second install after reopen | FAIL, physically observed |
| Explicit NULL optional JSON keys | Source-level mismatch proven; physical test pending |
| Unknown per-occurrence JSON keys | Source-level mismatch proven; physical test pending |
| Completed / cancelled / missed / skipped matrix | Enum and codec support inspected; physical matrix pending |
| Timestamp boundaries | Codec stores raw string; physical matrix pending |
| TaskStore after first install on same executor | COMMAND 50 harness authored; run evidence pending |
| TaskStore after process restart | Not yet physically tested independently of the retry failure |

## Important boundary

No historical Installer, Codec, Schema, user_version or immutable source fixture was changed. The expanded COMMAND 50 test and workflow are diagnostic-only. Their execution result has not yet been verified, so they are not counted as PASS evidence.
