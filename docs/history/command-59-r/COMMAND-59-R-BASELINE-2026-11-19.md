# COMMAND 59-R — Live Baseline and P0 Blockers
**Observed:** 2026-11-19 01:14 Asia/Tehran
**Repository:** mobinpda-lab/Arvin-clean
**Canonical PR:** #3495 (OPEN / DRAFT / UNMERGED)
**Canonical branch:** recovery-02/main-based-integration
**Baseline Main SHA:** 45e4202b03a434459e4c021a04efa7e8396359db
**Baseline canonical SHA:** 010cdfa016cd3884b9bea7eaf18b068620d4e980

## 1. Safety
This checkpoint is documentation-only. No application source, schema, historical installer, V7 fixture, or user data was changed. No migration was executed. Main was not modified. No merge, release, deployment, or branch deletion occurred.

## 2. Live Git references
- Main: 45e4202b03a434459e4c021a04efa7e8396359db (protected).
- Canonical branch: 010cdfa016cd3884b9bea7eaf18b068620d4e980.
- Compare main...canonical: 317 commits ahead, 0 behind; 239 changed files (168 added, 55 modified, 16 removed).
- PR #3495: OPEN / DRAFT / UNMERGED; base Main SHA above; head canonical SHA above; 317 commits; 239 changed files.
- PR #3384: OPEN / DRAFT / UNMERGED; branch feature/command-07-a-sqlite-contract-remediation; head 310c0e20e3447c488c1e1c102c38bea5040708ca.
- PR #3463: OPEN / DRAFT / UNMERGED; branch rev10-m2m-v19-test-expansion; head 812082964c649be7660c41213209ec34aea7167b; based on PR #3384 head.

## 3. Schema lineage — critical unresolved architecture issue
The live source files report different schema generations:
- Main: G1DriftSchema.version = 7 (blob cd065ff25c680ed064e89068b3d063e737091025).
- Canonical PR #3495 branch: version = 9 (blob 3bd140f9a07b54c1e4a1dff26d64f965b437ec52).
- PR #3384 branch: version = 19 (blob 9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21).
- PR #3463 branch: version = 20 (blob b03b90efac9f3c5cbef3b1b649385cdf6369ca62).

The canonical PR #3495 branch is currently a V9 lineage, not a V19 or V20 implementation. The V19 and V20 candidates are stacked on a non-Main branch chain. The repository's own docs/execution/PENDING_WORK.md explicitly lists the V9 lineage ambiguity and proof of Main V7 upgrade route as unresolved. Therefore, do not describe V7→V19→V20 as an accepted continuous path and do not transplant V19/V20 schema code into the V9 canonical branch without an approved migration registry and exact source-to-source DDL/data-transfer proof.

## 4. Exact-SHA Build evidence
Canonical SHA 010cdfa016cd3884b9bea7eaf18b068620d4e980:
- Build run 44369547769: FAILURE.
- Debug APK job 135032385364: SUCCESS.
- Release APK build job 135032384887: SUCCESS.
- Analyze job 135032385745: FAILURE.
- Test shards 0–5: FAILURE.
- Follow-up File Persistence run 44369547817: SUCCESS (this does not imply overall persistence/backup acceptance).
- Device Smoke run 44369547884: FAILURE.
- COMMAND 20-E run 44369547914: FAILURE.

A separate dispatcher run 44393185882 targeted the same canonical SHA in its run name and also failed Analyze and all six test shards; Debug and Release APK build jobs passed. Its workflow execution branch was Main and must not be mistaken for a push run on the canonical branch.

Analyze log for job 135116031993 reports that test/command50_occurrence_forensic_test.dart imports package:arvin/services/occurrence_sql_codec.dart, but that file is absent from the canonical branch. The same missing file causes undefined OccurrenceSqlCodec symbols and test compilation failures. More fundamentally, that forensic test asserts G1DriftSchema.version == 19 while the canonical branch schema is version 9. This is a test/lineage integration defect, not a reason to alter the V9 schema version or weaken the test. The forensic test must execute against the exact V19 source candidate in an isolated, explicit V19 test harness.

## 5. V19 Occurrence safety evidence
Historical V19 source is available on PR #3384. Its Occurrence codec removes occurrenceHistory and checklistOccurrences from legacy_payload_json after transfer. The COMMAND 51-R second-install run 44377193111 failed:
- Job 135059371989: "second install failed".
- Exact failure: StateError: Occurrence migration parity mismatch for Task c50-matrix-a.

The independent COMMAND 50-R evidence and proposal docs record additional parity defects:
- Explicit NULL keys are not reconstructed on readback.
- Unknown Occurrence state fields have no opaque destination payload.
- First-install success does not prove repeat-install safety.

The repair proposal at docs/proposals/V19_OCCURRENCE_IDEMPOTENCY_REPAIR_PROPOSAL.md is explicitly NOT APPROVED / NOT IMPLEMENTED. Preserve the historical installer and codec; implement any approved correction only as a forward, isolated candidate after architecture review. Do not run against real user databases.

## 6. Device and product blockers
On Device Smoke run 44369547884, six lanes passed: SQL Migration, SQL Persistence, People, Home, Backup/Restore, Quick Capture. Calendar failed. This is not full Device Smoke acceptance.
COMMAND 20-E run 44369547914 failed its storage-persistence lane and complete-evidence gate.
Issue #2102 remains OPEN as a release gate. Issue #1901 remains OPEN with P0/P1 real-device regressions including Calendar, Home, typography, taxonomy, Notebook and Quick Add. These user-observed defects require exact device evidence and cannot be closed by APK build success.

## 7. Required next sequence
1. Freeze schema/lineage decisions until a source-level V7→V9→V19→V20 migration registry is documented and independently reviewed; identify whether V9 is an actual required hop or an unrelated branch lineage.
2. Keep PR #3495 as the only canonical product-development route; do not merge or retarget PR #3384/#3463.
3. Re-home COMMAND 50/49 forensic tests into a version-pinned V19 harness with exact V19 schema, codec and recurrence dependencies; do not bind them to canonical V9 G1DriftSchema.
4. Reproduce V19 first/second/third install, NULL presence, unknown-field round-trip, TaskStore readback, rollback, reopen and independent restore on separate disposable copies of the immutable V7 fixture.
5. Diagnose COMMAND 49 safety test null assertion using its exact log and fixture preconditions; do not suppress the test.
6. Fix Calendar and COMMAND 20-E using the existing canonical storage/provider path; do not introduce parallel stores or engines.
7. Rerun Analyze, all six test shards, Build, persistence, Device Smoke and COMMAND 20-E against one final exact candidate SHA. Real-device acceptance remains a separate required gate.

## 8. Decision
**COMMAND 59-R status: BASELINE AUDIT COMPLETE; IMPLEMENTATION GATE BLOCKED.**
The highest-risk blocker is unresolved schema lineage plus a proven V19 second-install Occurrence failure. No migration, schema transplant, test deletion, test weakening, merge, release or deployment is authorized by this checkpoint.
