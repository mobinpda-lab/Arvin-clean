# HANDOFF — 2026-11-28

- Repository: mobinpda-lab/Arvin-clean
- Branch: recovery-02/main-based-integration
- Candidate SHA at checkpoint: c51411fcb2019ad733c6fdcf700d94bfdee17a13
- Main: 45e4202b03a434459e4c021a04efa7e8396359db (read-only)
- PR #3495: OPEN / DRAFT / UNMERGED.
- Product acceptance: NOT ACCEPTED. Release: NO-GO.

## Verified source changes (verification still pending unless stated)
1. fff59f6b3c5bad6746e271ef42d2c505cce1b368: ProjectStore is sole writer of project_items; TaskStore's full Task rewrite no longer mutates the join table; deferred FK validation protects referenced Task identities. Trigger-guarded file-backed test added.
2. a48488ff89ec01d880548d267b66389c28c13d00: Project restore upserts matching Project IDs in place and guards deletion against Task/Center/Category edges; file-backed graph test added.
3. a420c89f06c598ed17b9def38efebd9108618c90: canonical insert helper reused for new Projects; deletion-block message generalized.

## Current exact-SHA workflows
- Build: 46116776194 — in progress.
- COMMAND 20-E: 46116776165 — storage-persistence in progress.
- Device Smoke: 46116776170 — in progress.
- Follow-up File Persistence: 46116776176 — SUCCESS.
- Governance Validation: 46116776167 — SUCCESS.
- Parent fff59f6... Device Smoke 46115088811 completed 7/7, but is not evidence for this SHA.

## Next actions — one lane, no duplication
1. Poll all current-SHA runs. Inspect exact failed/passed jobs and the two new ProjectStore regression assertions. Do not infer PASS from queued/in-progress or parent-SHA runs.
2. Resolve the async runner root cause from completed exact-SHA logs; keep timeouts and assertions intact.
3. Continue ARC-M2M-001: inventory every Project/Category consumer and find the single missing/approved project_categories owner before implementation. CenterStore already owns center_projects; do not create duplicate Center storage.
4. Continue D01–D05 data preservation and physical backup/restore acceptance on disposable file-backed databases; never experiment destructively on user DBs.
5. Update this handoff and registry after each meaningful commit; all final gates must match one exact SHA.

## Protected boundaries
- No writes to Main; no merge/release/deployment.
- No production database mutation, branch deletion, history rewrite or force push.
- No duplicate store/repository/registry/test inventory.
- Preserve IDs, unknown metadata, graph edges, reminders, follow-up history and backups.


## Live continuation checkpoint — 2026-11-28 — candidate c51411fcb2019ad733c6fdcf700d94bfdee17a13

- Main remains `45e4202b03a434459e4c021a04efa7e8396359db` (read-only).
- Canonical branch `recovery-02/main-based-integration`; PR #3495 remains OPEN / DRAFT / UNMERGED.
- Code candidate SHA before the documentation-only continuity commits: `c51411fcb2019ad733c6fdcf700d94bfdee17a13`.
- Six test-only commits were added on the authorized branch:
  - `f0100e423158e69f59ecb14a76c626300355187a` — real-clock bounded wait helper in `test/support/flutter_async_cleanup.dart`.
  - `39ac4139c1882f83a5a98045e90db1ca8baa2a3f` — Home widget test waits use the shared helper.
  - `d3ef28f99ca723323a15432cb987f18fdf5e7f86` — Center widget test waits use the shared helper.
  - `bd53ec261e8d3eb6d65af5f3d04fc2fc3270e48c` — Backup widget test waits use the shared helper.
  - `d4b4cdf4dc96f2226dc0d171737e478105b6725d` — TaskStorageLock test uses the shared wait and explicitly opens each NativeDatabase executor before SQL.
  - `c51411fcb2019ad733c6fdcf700d94bfdee17a13` — Home restore widget test installs the native async runner and resets it after DB teardown.
- No production source, schema, user data, assertions, test selection or timeout limit was changed. The 20-second wait is now based on a Zone.root wall-clock timer rather than 1,200 rapidly simulated frames.

### Evidence and limits
- Prior exact-SHA Build on `9a37b282bf2b2ef8218357c357b4927606efd349`, run `46117138055`: Analyze and Debug/Release APK jobs SUCCESS; all six quality shards FAILURE; trace JSONL evidence CANCELLED. The failing logs show Home/Center/Backup native work completing after the old FakeAsync frame-loop timeout, a missing `ensureOpen()` in the TaskStorageLock native test, and Home Restore running without the test Runner.
- One separate RTL swipe `pumpAndSettle` failure remains unclassified and must not be hidden by the helper repair.
- On the same prior SHA: Device Smoke `46117138005` SUCCESS (7/7); Governance `46117137988` SUCCESS; Follow-up File Persistence `46117138064` SUCCESS. COMMAND 20-E `46117137975`: storage-persistence SUCCESS; complete-evidence was still IN_PROGRESS at the last poll.
- For current SHA `c51411f...`, the commit-workflow query returned no associated runs. Therefore the new test changes are COMMITTED / NOT VERIFIED; no current-SHA Build, test, lint or device PASS is claimed.
- No local Flutter/Dart SDK is installed in this execution environment, and no workflow-dispatch action is exposed here. GitHub file writes succeeded, but they do not provide a test result.

### Remaining P0 / next execution
1. Obtain Build and targeted test evidence on exact SHA `c51411f...`; inspect whether the real-clock helper resolves the six-shard failure family without regressions.
2. Diagnose the independent RTL swipe `pumpAndSettle` failure.
3. Re-poll COMMAND 20-E and complete its evidence gate on a single final SHA.
4. Continue ARC-M2M-001 caller inventory for Project↔Category; do not create a duplicate Store before confirming no existing owner.
5. Continue D01–D05 migration, backup, restore and rollback acceptance on disposable file-backed databases only.

Product acceptance remains NOT ACCEPTED. Release remains NO-GO. No Main write, merge, release, deployment, destructive production DB operation, branch deletion, history rewrite or force push was performed.


## Superseding evidence poll — 2026-11-28 — prior code SHA 9a37b282bf2b2ef8218357c357b4927606efd349

- COMMAND 20-E run `46117137975` is now COMPLETED / FAILURE. Evidence collection itself is COMPLETED; overall verdict is NO-GO because the exact-SHA Build gate is not successful.
- COMMAND 20-E storage-persistence job `140893371704` SUCCESS. Its ProjectStore file-persistence, Calendar process-restart parity, and cleanup verification gates all report PASS.
- Device Smoke run `46117138005` SUCCESS across all seven scenarios. Follow-up File Persistence `46117138064` SUCCESS. Governance Validation `46117137988` SUCCESS.
- Build run `46117138055` has Analyze SUCCESS and Debug/Release APK jobs SUCCESS, but all six quality shards FAILED; its trace JSONL evidence job was CANCELLED and the workflow conclusion is CANCELLED. These are all evidence for SHA `9a37b282...` only.
- This poll supersedes the earlier note that COMMAND 20-E complete-evidence was still in progress. It does not alter the status of the later test-only candidate `c51411f...` or the current docs-inclusive branch tip; neither has current-SHA workflow evidence.

## Live continuation — 2026-11-28 — encrypted Backup trace remediation

- Canonical route: PR #3495 / `recovery-02/main-based-integration`; Main remains read-only at `45e4202b03a434459e4c021a04efa7e8396359db`.
- Latest code commit in this batch: `04264807bdbf43e4b92d322b89df8dd6afa1f058`. Trace privacy/test commits immediately before it: `c8a420de7e265c2f5421a6df243a39115688e1a7`, `5612b7942640a7872d0bdd51bd5809756bcaa918`.
- Existing Issue #3671 is the active P0. Its older candidate `7241842aced02eb6ee24ccaaf89af5c0b6d897fa` failed Build run `45025576717`: encrypted Backup confirmation test timed out after 10 minutes; the shard log reported 198 passed / 1 failed. The run had no per-shard trace artifact (only Debug/Release APK artifacts).
- Implemented: per-shard JSONL tracing in Build test jobs; exact-SHA/run/lane/outcome metadata; artifact upload with `always()`; exception messages removed from trace events while retaining exception type. No Backup behavior, test assertion, timeout or data path changed.
- Verification: NOT VERIFIED. No associated workflow run was returned for code SHA `0426480...` at poll time; no local Flutter/Dart SDK or workflow-dispatch action is available here. The older Device Smoke/Governance/Follow-up successes and COMMAND 20-E failure remain scoped to the older candidate.
- Root cause of Backup timeout: NOT VERIFIED. Do not change Backup internals until a trace artifact identifies the first START without END.
- Next exact action: obtain Build on the final docs-inclusive head; download `arvin-test-trace-test-0-<run_id>`; inspect operation sequence and correlation; repair only the first proven blocked stage; rerun encrypted Backup, negative-passphrase no-write, exactly-one-write, exception recovery, busy-state release and all six shards.
- Product acceptance: NOT ACCEPTED. Release: NO-GO. No Main write, merge, release, deployment or production database operation.
