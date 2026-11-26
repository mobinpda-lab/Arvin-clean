# R-202 Defect Register — REV11.34
**Repository:** mobinpda-lab/Arvin-clean (1331763954)
**PR:** #3495
**Branch:** recovery-02/main-based-integration
**Baseline SHA:** 9d58e92203a32a22f7bc67b92552afe19db3ac50
**Rule:** IMPLEMENTED, TESTED, VERIFIED, and ACCEPTED are separate states. A local or mocked test is not exact-SHA GitHub verification.
| ID | Defect / scope | IMPLEMENTED | TESTED | VERIFIED | ACCEPTED |
|---|---|---|---|---|---|
| TRACE-AGG-01 | Independent sequential suites, per-suite exit codes and complete logs | YES | TWA-01..06 PASS locally | Pending exact-SHA runner | NO |
| TRACE-AGG-02 | Aggregate failure propagation, always-upload, real Trace vs diagnostics, missing Trace fail-closed | YES | TWA-01..06 PASS locally | Pending exact-SHA runner | NO |
| CMD-20E-01 | Preserve raw Job status/conclusion and correctly normalize all supported states | YES | C20-01..12 PASS locally | Pending exact-SHA runner | NO |
| CMD-20E-02 | Separate workflow completion, collection completion and acceptance; preserve SHA/run/job/artifact provenance | YES | C20-13..14 PASS; collector mock PASS/NO-GO | Pending exact-SHA runner | NO |
| BUILD-01 | Center, Home and Backup product/widget test failures | NO — root cause not yet established | Baseline Build run 45372415634 | YES — actual failures observed | NO |
| BUILD-02 | Quality test shard cancellation and failure | NO — cancellation cause not yet established | Baseline Build run 45372415634 | YES — raw outcomes observed | NO |

## TRACE-AGG-01 — isolated suite execution
**Evidence:** Baseline Trace job 138369867655 produced Trace 0, Center 1, Home 1, Backup 1, Encrypted Backup 0, aggregate 1. REV11.34 adds a separate runner with fixed order and PIPESTATUS capture. TWA-01..06 exercise all-success, each independent suite failure, and mixed failures.
**Acceptance condition:** Every suite runs once in order; every real exit code and complete log is retained; aggregate is non-zero if any mandatory suite fails.

## TRACE-AGG-02 — artifact and aggregate integrity
**Evidence:** Baseline JSONL SHA-256 e626c616862445893b8a2fe22fa7ae97af7ada43506492b3cef21e331e79644e; artifact 14928130294. REV11.34 separates JSONL from suite logs, preserves REGRESSION_AGGREGATE_EXIT_CODE, uploads with always(), and marks missing JSONL MISSING without fabricating a file.
**Acceptance condition:** Artifact metadata and the real JSONL validate on the exact run SHA; missing Trace remains NO-GO; failed suite exit propagates.

## CMD-20E-01 — GitHub state fidelity
**Evidence:** The previous parser could collapse a missing conclusion to NOT TESTED. REV11.34 maps queued, in-progress, success, failure, cancelled, skipped, not-run, timed-out, action-required, neutral, stale, and unknown states explicitly. Raw status and raw conclusion remain separate fields.
**Acceptance condition:** Running + null conclusion is IN_PROGRESS; missing Job is NOT_RUN; unknown is never PASS; raw values and Job IDs remain in the output.

## CMD-20E-02 — complete, traceable acceptance summary
**Evidence:** Baseline 20-E run 45372415415 ended with EXTERNAL_RUNS_NOT_COMPLETE=1 after the 60-minute collector window, while Build run 45372415634 was still running. ProjectStore, Calendar restart, and cleanup were PASS in that evidence. REV11.34 extends collection wait to 345 minutes within a 360-minute job timeout and records exact repository/branch/SHA, run attempts, Job IDs, raw states, artifact IDs/digests, and provenance.
**Acceptance condition:** Build, Device Smoke, and Follow-up workflows are complete on the exact SHA; all required jobs/artifacts/evidence exist; regression_summary.json reports overall=PASS; the workflow's jq -e '.overall == "PASS"' gate succeeds.

## BUILD-01 — product test failures
**Observed on:** Build run 45372415634, Trace job 138369867655, SHA 9d58e92203a32a22f7bc67b92552afe19db3ac50.
- Center: four timeouts; suite exit code 1.
- Home: 18 failures; suite exit code 1.
- Backup: nine failures; suite exit code 1.
- Trace: exit code 0. Encrypted Backup: exit code 0.
- Recent commits ad915243, 811780d, and 9d58e92 already changed the tests to pump the zone owning the operation. The failures persisted. Do not repeat those edits or increase timeouts as a substitute for root-cause repair.
**Next investigation:** inspect TaskStorageLock zone ownership and the first incomplete Future/callback for each failing suite; retain the existing assertions.

## BUILD-02 — quality shard cancellation
**Observed on:** Build run 45372415634.
- quality (test-0), quality (test-1), and quality (test-2): CANCELLED.
- quality (test-3): SUCCESS.
- quality (test-4) and quality (test-5): FAILURE.
**Root cause:** UNKNOWN. Do not label cancelled jobs as not-run or successful. Inspect raw job timestamps/conclusions and workflow cancellation provenance before changing runner or timeout policy.

## Preserved evidence — not re-run in REV11.34
TRC-01, TW-01..TW-05, MET-01, JSONL-01..JSONL-04, DEV-01, GOV-01, and PERSIST-01 remain prior evidence references. No acceptance state is changed merely because these IDs are listed here.


## REV11.34.1 hosted-run correction
Build run 45441699404 / Trace job 138614289192 failed at TWA-01 because Bash parameter expansions were escaped literally in the committed scripts. The five product suites did not run in that job. Trace was correctly marked MISSING, and artifact 14944045844 was uploaded with digest 83801e0bf0c61b00a666d27bed63a620b3a0b091f9916852db0544a42161ad42. The 18 metadata self-tests passed but do not override the job failure. The four affected scripts have been corrected; new exact-SHA runner verification is pending.

## REV12.10 — TaskStorageLock early-completion defect
**Observed:** Build run `45686896437`, job `139461937688`, exact source SHA `67127f770e7f7c7064b59093dfeab55a392e9882`.
- The TaskStorageLock native-I/O regression failed with `Reentrant call to runAsync() denied` during the test's database-close step.
- The caller operation Future could resolve before the async work runner returned. This made the Future completion signal insufficient to guarantee that the runner boundary had ended.
- The same boundary was implicated in Center/Home/Backup widget synchronization failures; do not classify the remaining product/widget tests as fixed until the new exact-SHA run proves it.

| ID | Defect / scope | IMPLEMENTED | TESTED | VERIFIED | ACCEPTED |
|---|---|---|---|---|---|
| BUILD-03 | TaskStorageLock caller Future completes before async runner release | YES — `6a3ea09a0d9d564990604d5a375e1d643ea01cb6` | Regression added — `b12409a8f446e664ccace087b621de6ce5a8ad61`; hosted result pending | Pending run `45762850359` | NO |
| BUILD-01 | Center/Home/Backup UI timeouts | Partial common-boundary correction attempted; individual suite outcomes pending | Pending | Pending | NO |
| BUILD-02 | Quality shard cancellations/failures | NO | Prior evidence retained | Pending cause review | NO |

**Next:** inspect Build run 45762850359 and the TaskStorageLock, Center, Home, and Backup test logs independently. If any remain blocked, trace the first incomplete Future; do not raise timeouts or weaken assertions.


## REV12.24 — targeted storage diagnostics
| ID | Defect / scope | IMPLEMENTED | TESTED | VERIFIED | ACCEPTED |
|---|---|---|---|---|---|
| R202-LOCK-ZONE-01 | Caller-Zone microtask did not reliably observe Flutter runAsync cleanup in its real async Zone; sequential native cleanup could be rejected as reentrant | Candidate fix: root-Zone release barrier in `TaskStorageLock` | Existing NativeDatabase cleanup regression retained; exact-SHA rerun pending | Pending | NO |
| R202-TRACE-NAME-01 | TaskStorageLock discarded the supplied operationName and emitted a hard-coded owner label | YES — forwards operationName to trace | New operation-name regression added | Pending | NO |

**Acceptance boundary:** no Runner lifecycle defect is accepted until the NativeDatabase regression, runner failure boundaries, FIFO-after-exception, duplicate callback, and trace START/END/ERROR tests pass on one exact SHA. No acceptance inferred from Analyze/APK success.


## REV12.24 — lifecycle evidence update
| ID | Latest evidence | Candidate action | Status |
|---|---|---|---|
| R202-LOCK-ZONE-01 | SHA `404f369`, Job `140056965955`: NativeDatabase query completed but second `tester.runAsync` at test line 322 was rejected while Flutter pending-task cleanup remained active | D-12 changes release barrier from root microtask to root zero-duration event-loop turn | IN PROGRESS; regression pending |
| R202-TRACE-NAME-01 | SHA `404f369`, Job `140056965801`: operation-name regression passed | Keep forwarding caller operationName | VERIFIED on candidate SHA; not full acceptance |
| R202-HOME-LOAD-01 | Home load tests in Shards 0/1/2 fail to observe completion; first trace event is `task_store.load START` | Re-run after Runner barrier; do not alter widget completion assertions | BLOCKED / root cause pending |
| R202-BACKUP-01 | Backup and Restore tests time out; passphrase expected memory-only but actual null | Inspect post-barrier trace by individual backup stage | BLOCKED |
| R202-CALENDAR-01 | Device Smoke calendar still misses card key although unit projection tests pass | Inspect final calendar widget tree / selected date | BLOCKED |
| R202-QUICKCAPTURE-ENV-01 | Device Smoke Quick Capture job failed at Gradle assembleDebug before app launch | Inspect exact Gradle failure; distinguish infra from product regression | BLOCKED |
