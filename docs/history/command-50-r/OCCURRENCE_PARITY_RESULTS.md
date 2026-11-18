# COMMAND 50-R — Occurrence Parity Results

**Root cause:** CONFIRMED for the COMMAND 49 retry failure.
**Forensic COMMAND 50 result:** COMPLETE — the expanded physical matrix ran and the root cause was established. **V19 migration acceptance:** BLOCKED — the historical codec defects remain unresolved.

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
| Explicit NULL optional JSON keys | FAIL_CONFIRMED — physical fixture; original null keys retained after rollback |
| Unknown per-occurrence JSON keys | FAIL_CONFIRMED — physical fixture; unknown key retained after rollback |
| Completed / cancelled / missed / skipped matrix | PASS — physically migrated and read back |
| Timestamp boundaries | PASS — year 0001, year 9999, offset Occurrence timestamp; recurrence offset normalized to UTC |
| TaskStore after first install on same executor | PASS — physical TaskStore readback |
| TaskStore after process restart | NOT TESTED — TaskStore readback was performed on the migrated executor; a separate process-restart readback is outside this command's required matrix |

## Important boundary

No historical Installer, Codec, Schema, user_version or immutable source fixture was changed. The final COMMAND 50 test and workflow are diagnostic-only. Their physical execution is recorded above; no historical production source was changed.

## Final COMMAND 50 physical run

- Run: `44367002583` — SUCCESS (the diagnostic test assertions all passed).
- Job: `135024297667` — SUCCESS.
- Artifact: `14456982207` — [download artifact](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44367002583/artifacts/14456982207).
- Artifact SHA-256: `080d32fde09c0d2160ec121f1c3e5854606659ef8aa14e1ebd4f60c61f4f8260`.
- Executed historical V19 source: `310c0e20e3447c488c1e1c102c38bea5040708ca`.
- Immutable V7 fixture SHA-256: `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`.
- Final test harness commit: `5d5e63d9dbe95077a1e501e69576d299897cab11`.

The final log reports `All tests passed!` because the test expects and asserts the historical failures for retry, explicit NULL and unknown Occurrence fields. This does **not** mean the historical migration is safe to approve. The base transfer matrix, identity comparison, timezone behavior, TaskStore readback, rollback, preservation and integrity assertions passed; the three codec defects remain confirmed.
