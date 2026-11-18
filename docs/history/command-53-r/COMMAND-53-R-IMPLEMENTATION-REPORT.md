# COMMAND 53-R — Safe Occurrence Migration Implementation Report

**Disposition: BLOCKED — implementation not started; no acceptance claim.**
**Priority:** CRITICAL / P0
**Candidate branch:** `test/command-53-r-safe-occurrence-migration`
**Parent ref:** `investigation/command-52-r-root-cause`
**Protected resources:** Main, historical V19 source/installer, original V7 fixture, migration history, PR #3495.

## Execution performed
- Confirmed repository `mobinpda-lab/Arvin-clean` is accessible and public.
- Confirmed the named investigation branch exists.
- Created this independent candidate branch from the investigation branch.
- Confirmed PR #3495 remains represented as OPEN / DRAFT / UNMERGED in its latest available governance record; it was not modified.
- Read the existing COMMAND 50 forensic proposal, source analysis, codec analysis, parity results, test harness and workflow.

## Verified technical facts
1. The forensic record pins historical V19 source to `310c0e20e3447c488c1e1c102c38bea5040708ca`.
2. The immutable V7 fixture source is `f211326e7615f1c907494232dd3aec8d4732c83c`, with recorded SHA-256 `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`.
3. Historical V19 codec defect: after the first successful transfer retires legacy occurrence keys, a later run compares retained SQL rows with artificial empty source maps.
4. Historical readback omits explicit-null optional keys and does not round-trip unknown occurrence-state keys.
5. The investigation branch's current `lib/services/g1_drift_schema.dart` reports schema version **9**, and its tree does not contain `lib/services/occurrence_sql_codec.dart`. The existing COMMAND 50 harness is a diagnostic harness that checks out the historical V19 commit separately; it is not an implementation of the repair.

## Stop reason
A safe forward implementation cannot be inferred by editing the current schema-v9 source as though it were the historical V19 installer. The candidate branch lacks the V19 codec/runtime dependency closure, and the exact COMMAND 52 implementation handoff/patch specification was not found at the attempted report paths. Editing or replacing the historical installer/codec would violate the explicit preservation boundary. No isolated forward-migration adapter with proven compatibility has yet been designed or executed.

## Actions deliberately NOT performed
- No change to Main, PR #3495, historical V19 installer/codec, V7 fixture, or prior migration history.
- No migration code, schema change, fixture mutation, or test weakening.
- No merge, release, deployment, V20 work, or production database operation.
- No test PASS, rollback PASS, restore PASS, or data-preservation acceptance is claimed.

## Required next gate
Recover and verify the exact COMMAND 52 root-cause handoff and the candidate's intended V19 execution/dependency boundary. Then implement a separately versioned forward repair (not a historical rewrite), with a disposable fixture copy and exact-source CI. The receipt, key-presence metadata and opaque unknown-field representation must be included in one atomic transaction and independently verified after restart, backup/restore and TaskStore readback.

**Final status: COMMAND 53-R NOT ACCEPTED. V19 NO-GO remains. V20 PROHIBITED.**
