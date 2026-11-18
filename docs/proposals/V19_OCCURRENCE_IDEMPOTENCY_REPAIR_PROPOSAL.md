# Proposal — V19 Occurrence Migration Idempotency and Parity Repair

**Type:** Independent proposal only
**Status:** NOT APPROVED / NOT IMPLEMENTED
**Evidence origin:** COMMAND 50-R
**Historical source:** `310c0e20e3447c488c1e1c102c38bea5040708ca`
**Affected historical component:** `lib/services/occurrence_sql_codec.dart`

## Confirmed defect

After a successful first transfer, `migrateLegacyEnvelopes` removes `occurrenceHistory` and `checklistOccurrences` from the legacy envelope. On a later installer run it still processes the Task, creates empty expected maps, reads the existing normalized SQL rows, and fails parity against those empty maps.

The first transfer of the simple pending test record succeeded. The failure is the repeated invocation after source retirement.

## Proposal boundaries

- Do not amend or rewrite the historical V19 commit.
- Do not patch the historical Installer or Codec as part of COMMAND 50-R.
- Do not change schema, user_version, fixture, or production data under this proposal.
- Implement only in a separately approved forward migration/candidate after review.

## Candidate design requirements

1. Distinguish three states explicitly: legacy Occurrence keys present; legacy keys absent and destination rows absent; legacy keys absent and destination rows already present.
2. When legacy keys are absent but destination rows exist, validate destination row identity, uniqueness, Task ownership, status, ordinal and checklist relations as already-migrated data. Do not compare those rows with an artificial empty source map.
3. When legacy keys are absent and destination rows are absent, treat the Task as having no migrated Occurrence history.
4. When legacy keys are present, transfer every record, verify by stable Task ID plus scheduled timestamp, and only then mark the Task migrated and retire the old keys.
5. Preserve explicit-null presence if it is part of the historical data contract, or explicitly define and test null/absent equivalence before using normalized comparison.
6. Preserve unknown per-occurrence fields in an opaque compatibility payload or retain the source envelope until a later, separately accepted retirement gate. Never silently discard them.
7. Make migration state transactional and independently test process restart, retry, rollback, backup restore and TaskStore readback.

## Required future acceptance

- First install and second install produce identical full SQL snapshots.
- A close/reopen between installs does not change behavior.
- Pending, completed, cancelled, missed and skipped statuses retain exact values.
- Explicit NULL and absent keys have separately asserted semantics.
- Unknown Task-level and Occurrence-level fields remain recoverable.
- Multiple Occurrences per Task and multiple Tasks retain identity and ordering.
- TaskStore readback equals the accepted canonical representation.
- All tests run on disposable file-backed copies of the immutable V7 fixture.

**Decision:** This proposal records a repair direction only. It does not authorize implementation, V20, merge, release or deployment.
