# Mission 202-R — Decision Log

## REV11.22 — 2026-11-24

### D-01 — Keep Product and Trace Writer failures separate
**Decision:** Do not let a diagnostic write failure replace or erase a Product exception. Preserve both original exception objects and both original Stack Trace objects when both paths fail.
**Implementation:** `ArvinTraceDualFailure` is used only for simultaneous Product and Writer failure. A trace-only failure remains the original Writer exception.
**Status:** IMPLEMENTED; runtime verification pending.

### D-02 — Failed END is not success
**Decision:** A failed END write must never produce a SUCCESS outcome. An ERROR diagnostic may be attempted; if terminal evidence cannot be persisted, keep the operation in the open-operation inventory.
**Status:** IMPLEMENTED; runtime verification pending.

### D-03 — Preserve Future-based caller compatibility
**Decision:** Do not invoke an already-started Future a second time. Preserve its result when only trace persistence fails, while exposing the writer failure through `compatibilityWriterFailures`.
**Status:** IMPLEMENTED; acceptance test added; runtime verification pending.

### D-04 — Validate the actual JSONL lifecycle
**Decision:** Metadata validation includes the canonical trace record fields and operation lifecycle, not only the metadata JSON envelope and digest.
**Status:** IMPLEMENTED in `scripts/mission_202r_metadata.py`; P01/P02 and N01–N16 tests added; runtime verification pending.

### D-05 — Preserve historical 189-R evidence
**Decision:** The new metadata generator is scoped to 202-R. Historical 189-R files and workflow evidence are not rewritten or relabeled.
**Status:** DOCUMENTED. Existing workflow's legacy `metadata.txt` label remains a separate historical compatibility surface and is not changed in REV11.22.

## Evidence status
IMPLEMENTED, TESTED, VERIFIED, and ACCEPTED are separate states. A test definition is not a test pass. A successful workflow must identify the exact source SHA. No merge, release, deployment, or production-data operation is authorized by this log.


## REV11.34 — R-202 Phase 1 + Phase 2 execution
**Date:** 2026-11-24 (1405-09-03)
**Authorized target:** PR #3495, branch recovery-02/main-based-integration
**Baseline / expected HEAD:** 9d58e92203a32a22f7bc67b92552afe19db3ac50
**Repository identity:** mobinpda-lab/Arvin-clean / 1331763954
**Write boundary:** main remains read-only. No merge, release, deployment, or production-data action is authorized.

### Checkpoint and historical continuity
- REV11.32 and REV11.33 report files were not found under docs/mission-202r, in PR #3495 comments, or in repository issue search. Their contents are not reconstructed or guessed.
- The anti-repeat IDs supplied by the mission owner remain preserved and were not deliberately re-run: TRC-01, TW-01..TW-05, MET-01, JSONL-01..JSONL-04, DEV-01, GOV-01, and PERSIST-01.
- Latest Git history was reviewed. The latest Center, Home, and Backup test commits already attempted to pump the owning FakeAsync zone (ad915243, 811780d, 9d58e92). The same suites still fail in the observed baseline run; REV11.34 does not repeat those edits.
- The baseline Build run was already active before this execution; its evidence was inspected, not manually re-triggered by REV11.34.

### Preserved exact-SHA evidence
- Build run 45372415634; Trace job 138369867655; Trace test suite exit 0; Center 1; Home 1; Backup 1; Encrypted Backup 0; aggregate exit 1.
- Trace test file test/services/arvin_async_trace_test.dart completed successfully; the metadata self-test reported 18 passing regression scenarios.
- Real Trace JSONL: arvin-async-trace.jsonl; SHA-256 e626c616862445893b8a2fe22fa7ae97af7ada43506492b3cef21e331e79644e.
- Trace artifact 14928130294, archive digest sha256:63a37db7c7e53b203a51bb74b795846934049b64ec24e599cbd3274da0ad5070.
- Center recorded four timeouts; Home recorded 18 failures; Backup recorded nine failures. These are retained as product/test blockers, not converted into workflow success.
- Build run outcome was FAILURE: quality shards 0, 1, and 2 were CANCELLED; shard 3 succeeded; shards 4 and 5 failed. The cancellation cause is not established.
- Debug artifact 14910761147, digest sha256:13687fb3ae040ec33a0208d5a945e996bc102f54e363c0cb6502ae8ce2414526.
- Release artifact 14909896837, digest sha256:e8dc88a01cf1b00f21a12b6b5f96658126b45702c525fcbefa8b531049d49da6.
- Device Smoke run 45372415557 and Follow-up File Persistence run 45372415272 completed successfully. Governance Validation run 45372415273 completed successfully.
- Baseline COMMAND 20-E run 45372415415 failed because its evidence collector ended with EXTERNAL_RUNS_NOT_COMPLETE=1 while the Build workflow was still running. Its collector window was 60 minutes. ProjectStore, Calendar process restart, and cleanup evidence in that run were PASS.
- Baseline COMMAND 20-E evidence artifact 14913835974, digest sha256:0eed58de97ee19e5a26b18720a326c162aa173a2fff241a25ab08b1b5342acd2.
- Baseline COMMAND 20-E phase artifact 14910796850, digest sha256:cb49e4a0f6073f37b806d5b0bce5d7fa47f92353812077c079de92403bcf804b.

### D-06 — Isolated sequential Trace regression suites
**Decision:** Run Trace, Center, Home, Backup, and Encrypted Backup sequentially, preserving their existing commands and order. Capture each real command exit code and complete log independently. Continue after an individual suite failure; aggregate must fail if any mandatory suite fails.
**Verification plan:** TWA-01 through TWA-06 cover all-success, each independent suite failure, and combined failures. No exit-0 masking is allowed.

### D-07 — Trace artifact integrity is fail-closed
**Decision:** Artifact upload runs with always(). Real JSONL is distinct from diagnostic logs. Missing Trace JSONL is recorded as MISSING; no synthetic or fabricated Trace artifact is created. Preserve the legacy Mission ID: 189-R label and the current 202-R identity separately.

### D-08 — Raw GitHub execution state is authoritative
**Decision:** Preserve raw Job status and conclusion separately from normalized state. A running Job with null conclusion is IN_PROGRESS; an absent Job is NOT_RUN; unknown values remain UNKNOWN. No unknown, missing, cancelled, skipped, neutral, stale, or incomplete state can become PASS.

### D-09 — Completion, collection, and acceptance are separate gates
**Decision:** Record workflow completion, evidence collection completion, and overall acceptance independently. Preserve repository ID, authorized branch, exact SHA, Workflow Run ID, run attempt, Job IDs, raw status/conclusion, artifact IDs/digests, and evidence provenance. Extend the evidence collector wait window to 345 minutes inside a 360-minute job timeout. Retain the exact enforcement expression jq -e '.overall == "PASS"'.

### REV11.34 implementation/test status
| Defect | IMPLEMENTED | TESTED | VERIFIED on exact GitHub SHA | ACCEPTED |
|---|---|---|---|---|
| TRACE-AGG-01 | YES | TWA-01..06 local PASS | Pending new runner | NO |
| TRACE-AGG-02 | YES | TWA-01..06 local PASS | Pending new runner | NO |
| CMD-20E-01 | YES | C20-01..12 local PASS | Pending new runner | NO |
| CMD-20E-02 | YES | C20-13..14 and mocked collector PASS/NO-GO | Pending new runner | NO |
| BUILD-01 | Not yet repaired | Baseline failures observed | YES — failure observed on baseline run | NO |
| BUILD-02 | Not yet repaired | Baseline cancellations/failures observed | YES — states recorded on baseline run | NO |

IMPLEMENTED, TESTED, VERIFIED, and ACCEPTED remain independent states. Local tests and mocked GitHub API fixtures are not substitutes for the new exact-SHA GitHub Actions result. Mission acceptance remains NO-GO until all mandatory gates pass.


## REV11.34.1 — first hosted-run correction
- Build run 45441699404, Trace job 138614289192, reached the TWA test step and failed at TWA-01 because shell parameter expansions were committed with literal escape backslashes.
- The actual five product test suites did not run in that job. The fail-closed path correctly marked Trace evidence MISSING; no JSONL was fabricated.
- Artifact upload still completed: artifact 14944045844, SHA-256 83801e0bf0c61b00a666d27bed63a620b3a0b091f9916852db0544a42161ad42.
- The 18 metadata self-tests passed, but they do not override the failed job.
- REV11.34.1 removes the literal escape characters from the TWA runner/test and COMMAND 20-E parser/test shell expansions. Exact-SHA GitHub verification is pending the corrective push.

## REV12.10 — TaskStorageLock completion-boundary repair
**Date:** 2026-11-26 (1405-09-05)
**PR:** #3495 — OPEN / DRAFT / UNMERGED
**Branch:** `recovery-02/main-based-integration`
**Code candidate:** `b12409a8f446e664ccace087b621de6ce5a8ad61`
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` (read-only)

### Verified initiating defect
Build run `45686896437`, job `139461937688`, exposed a direct lifecycle mismatch in `TaskStorageLock.synchronized`: the caller Future could complete when the storage action produced its result, before the injected async work runner had finished. The regression test `TaskStorageLock isolates native I/O and preserves trace context` then attempted to close its NativeDatabase through `tester.runAsync` and received `Reentrant call to runAsync() denied`. The UI test callbacks had the same early-completion boundary.

### Decision D-10
The Future returned by `TaskStorageLock.synchronized` must preserve the action's result/error and wait until the runner has completed before reporting completion to the caller. This keeps the lock's async boundary observable and prevents callers from starting a subsequent test-runner operation while the prior runner is still active. FIFO ordering and error/stack preservation remain required.

### Implementation
- Commit `6a3ea09a0d9d564990604d5a375e1d643ea01cb6`: wait for runner completion before completing the caller Future.
- Commit `b12409a8f446e664ccace087b621de6ce5a8ad61`: add `synchronized completes only after the work runner releases` regression.
- The repair does not alter Center, Home, Backup product logic, SQLite schema, or test assertions.

### Exact-SHA verification
- Build run `45762850359` — pending at documentation checkpoint.
- COMMAND 20-E run `45762850353` — pending.
- Device Smoke run `45762850367` — pending.
- Follow-up Persistence run `45762850458` — pending.
- No test is marked PASS until the corresponding exact-SHA job is complete and its log confirms the result.

**Disposition:** IMPLEMENTED; hosted verification pending; product acceptance NO-GO.
