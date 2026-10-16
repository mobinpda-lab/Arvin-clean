# AUTHORITATIVE LIVE UPDATE — 2026-10-16 — Calendar test correction

- Calendar PR [#2735](https://github.com/mobinpda-lab/Arvin-clean/pull/2735) has advanced to latest SHA `81b646a4bf3f8a85925ad7ffe58fc810e162122d`. The prior PR-triggered Build for SHA `9839f9197c0b6b54b67086d75561eb8ff799453f` exposed one real test mismatch in `canonical_calendar_launcher_test.dart`: the test expected edit/register actions to be visible before long-press. The test was corrected to the approved tap/edit and long-press/action-sheet contract. Build [38815436407](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38815436407) and Device Smoke [38815436228](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38815436228) for SHA `81b646a4bf3f8a85925ad7ffe58fc810e162122d` are not yet producing job results; no green claim.
- PR #2695 latest SHA remains `44810fcf5bb96db8c028a1574889e3f2d45af75f`; Build [38814903662](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814903662) and Device Smoke [38814903585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814903585) are running/queued.
- PR #2738 Build [38814485299](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485299) is terminal success: all 9 jobs succeeded and Debug/Release artifacts were produced (92,553,535 and 32,374,532 bytes). All six test shards passed, including the new no-resurrection test. Device Smoke [38814485268](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485268) is still running with Home failed at SDK image setup (`unknown archive`), Quick Capture passed, SQL migration and SQL persistence running, backup/restore and people queued. Rerun is blocked until the overall workflow finishes.
- Exact-head: these are `pull_request` runs and skip the build's `Verify exact requested revision` step. No matching `workflow_dispatch` Build for these latest code SHAs has been observed. Keep exact-head gate **BLOCKED/PENDING**.
- Release remains **NO-GO**; no physical-device acceptance has occurred.

---

# AUTHORITATIVE LIVE UPDATE — 2026-10-16 — CI poll and exact-head gate

This is the latest observation and supersedes the initial status block below wherever the latest SHAs/statuses differ.

## Latest PR heads
- Calendar PR [#2735](https://github.com/mobinpda-lab/Arvin-clean/pull/2735): SHA `9839f9197c0b6b54b67086d75561eb8ff799453f`. Build run [38814870044](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814870044): test/analyze jobs were still queued or running, with no reported failures at the poll. Device Smoke [38814870125](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814870125): two lanes running, four queued.
- Person/report PR [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695): SHA `44810fcf5bb96db8c028a1574889e3f2d45af75f`. Build [38814903662](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814903662): one job running, eight queued. Device Smoke [38814903585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814903585): all six lanes queued. PR remains stacked on unmerged #2666.
- Migration tombstone PR [#2738](https://github.com/mobinpda-lab/Arvin-clean/pull/2738): SHA `5ba5432e07633fd03ad66721eee37bcad8ba4004`. Build [38814485299](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485299): Analyze + all six test shards passed; the new deleted-reminder regression and both requested migration test files are visibly marked passed in logs. Debug APK artifact `arvin-debug-apk` exists (92,553,535 bytes); Release APK job was still running at the poll. Device Smoke [38814485268](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485268): Quick Capture passed; Home failed before emulator boot because Android SDK image download reported `unknown archive`; SQL persistence and SQL migration were running, two lanes queued. This is not a green six-lane result. Rerun of Home is not yet available because the workflow is still running.

## Exact-head validation gate
- The Build runs listed above were started by `pull_request`; workflow step “Verify exact requested revision” is skipped for this event by design. Therefore these runs are useful CI evidence but **not exact-head validation**.
- A search of recent `workflow_dispatch` Build runs found no exact-target run for the three latest SHAs. The dispatcher workflow is scheduled every six hours/manual only; no direct workflow-dispatch write action is available in this execution connection. Exact-head validation is therefore **BLOCKED/PENDING**, not PASS.
- Do not merge or release. After the current PR runs finish, retry the Home emulator-infrastructure failure where possible and wait for the default-branch recovery dispatcher to produce exact-target Build runs.

## Release decision
**Release: NO-GO.** No physical-device owner acceptance has been performed in this wave; stacked Person branch and dangling-Person projection policy still need reconciliation.

---

# AUTHORITATIVE LIVE UPDATE — 2026-10-16 — Consolidation & Correction Wave

This entry supersedes older status lines where they conflict. Historical evidence remains historical and must not be reused as current-head proof.

## Repository checkpoint
- Repository: `mobinpda-lab/Arvin-clean`
- Main checkpoint: `693e7c53221b8c36128b1dec05105d083f205790`
- Release: **NO-GO**. Do not merge/release from pending, queued, old-head, or synthetic-merge-only evidence.

## Atomic work lanes and current evidence
- Calendar interaction PR [#2735](https://github.com/mobinpda-lab/Arvin-clean/pull/2735), branch `fix/calendar-item-tap-longpress-behavior`, latest code SHA `da71b3ce0183b015edef6f878dc7ee1c1f191294`. Code now routes Task tap to the edit callback, prevents Task cards falling back to accordion expansion, opens a long-press action sheet, and requires confirmation before deletion. Regression tests cover tap, long-press, device-calendar registration and confirmed deletion. Build run [38814524530](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814524530) and Device Smoke [38814524472](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814524472) were queued/pending at this checkpoint; no green claim.
- Person/waiting/report PR [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695), branch `integration/person-directory-safe-port-20261014-v2`, latest SHA `c13e8f3313bf3d26f07618da40352767914d31c4`. The explicit `FollowUp.waitingForResponse` flag is authoritative; Report Center now uses a shared `PersonFollowUpReportProjection` implementation and has a regression test. Build [38814369144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814369144) and Device Smoke [38814369104](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814369104) were pending/in progress. Earlier successful evidence on SHA `93202e9e24e33bff31daaf933b2c4fb1417dfb46` is stale for the new commits.
- **Person branch integration risk:** PR #2695 is stacked on `integration/task-multiple-reminders-safe-20261013`; parent PR #2666 remains open and unmerged. Do not retarget, rebase or merge blindly. The projection file in the stacked branch must be reconciled with the existing same-named projection on current main before integration. The new UI path intentionally displays dangling Person IDs as “شخص حذف‌شده”; current main's existing projection defaults to excluding dangling references, so this semantic difference requires explicit review.
- Migration tombstone regression PR [#2738](https://github.com/mobinpda-lab/Arvin-clean/pull/2738), branch `test/reminder-migration-tombstone-20261016`, SHA `5ba5432e07633fd03ad66721eee37bcad8ba4004`. Added a test that a deleted Option B legacy reminder remains deleted after SQL reload and canonical backup/restore while preserving `legacyTaskReminderMigrationVersion: 1`. Build [38814485299](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485299) and Device Smoke [38814485268](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485268) were still in progress; no pass claim.

## Data and validation rules
- `test/task_store_sql_runtime_migration_test.dart` and `test/integration_task_reminders_migration_backup_test.dart` are part of the current-main test suite. The latter previously covered Option B migration, SQL, backup/restore, stable identity and prior-delivery suppression but did not explicitly assert that a deleted migrated reminder cannot reappear; PR #2738 adds that missing regression.
- Recheck all three latest SHAs after Actions become terminal. Confirm Analyze, all six test shards, Debug/Release APK and all six Device Smoke lanes. Inspect test logs for the named migration and report tests; a run created or queued is not a pass.
- Physical-device acceptance remains separate. No release-ready statement is authorized.

## Next actions
1. Poll exact latest-head Build and Device Smoke for #2735, #2695 and #2738; fix only confirmed failures.
2. Resolve the projection dangling-reference policy and reconcile #2695 with current main/parent #2666.
3. Record terminal evidence for the exact resulting SHA; retain Release **NO-GO** until integration, data integrity and product acceptance gates are closed.

---

# AUTHORITATIVE LIVE UPDATE — 2026-10-14 — Exact-head CI recovery correction

This entry supersedes prior claims that the exact-head recovery root cause was wholly unknown.

- **Root cause found in dispatcher logic:** ordinary `pull_request` Build runs were eligible to satisfy the “exact-head” check solely because GitHub run metadata matched the PR head SHA. However, the Build workflow checks out `github.sha` for a pull request, which is the synthetic PR merge ref; the metadata alone did not prove the PR head SHA itself was checked out.
- **Correction committed:** [`af3e3724ae08a956bb91fcbd82174ec23a2d2066`](https://github.com/mobinpda-lab/Arvin-clean/commit/af3e3724ae08a956bb91fcbd82174ec23a2d2066) changes the dispatcher to count only `workflow_dispatch` runs whose run head SHA and run-name target SHA both match the current PR head. The dispatched Build independently asserts `git rev-parse HEAD == inputs.target_sha` in each quality and APK job.
- **Expected effect:** a green synthetic-merge PR run or historical run can no longer suppress recovery of a missing exact-head Build.
- **Validation:** the correction is implemented but not yet proven until Build and all six Device Smoke lanes complete on the final PR head and the dispatcher is observed operating in GitHub Actions.
- **Current PR:** [#2699](https://github.com/mobinpda-lab/Arvin-clean/pull/2699), open and unmerged. Do not merge or release based on implementation alone.
- **Next action:** record this checkpoint, then inspect terminal exact-head Build and six-lane Device Smoke results for the final resulting SHA. After integration through an approved path, run the dispatcher against a controlled same-repository PR with no exact-head Build and verify its logs and resulting checkout SHA. Product release remains NO-GO pending all product and physical-device gates.

---

# AUTHORITATIVE LIVE UPDATE — 2026-10-14 — CI recovery work

This addendum is the newest live checkpoint and supersedes conflicting older status lines below. It was prepared against parent commit `718e8cf730305e98aee3f9b12f4c239a80a06190`; the memory commit itself will create a new PR head, so all CI evidence must be refreshed for that resulting SHA.

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main` at `de795419be2c39775119af8eaa37c53744820d93`.
- Current focus: PR [#2699](https://github.com/mobinpda-lab/Arvin-clean/pull/2699), “ci: recover missing exact-head PR builds automatically”. The PR is open, targets main, and contains only CI workflow changes plus this memory checkpoint; no application code is changed.
- Recovery design: scheduled/manual dispatcher checks open same-repository PR heads, asks Arvin Build to run when exact-head evidence is absent or stale, and never merges/releases. Build accepts optional `target_sha`, pins checkout to it for workflow_dispatch, records it in the run name, and asserts the checked-out revision in the quality matrix and both APK jobs. Dispatcher requires run head SHA and declared target SHA to agree, and uses the latest exact-head result rather than any historical green run.
- Evidence immediately before this memory checkpoint: Arvin Build run [38514863822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38514863822) was pending and Device Smoke [38514863806](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38514863806) was pending for parent SHA `718e8cf730305e98aee3f9b12f4c239a80a06190`. These are not terminal results and do not validate the new memory commit.
- Person PR [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695) exact heads `6d01c603...` and `0432e3a...` returned zero Actions runs when queried. The underlying cause of the missing runs is **not yet proven**; do not assert a token-suppression or permissions cause without evidence.
- Current bottleneck: validate the recovery PR on its final exact head, then after an approved merge exercise the dispatcher against a controlled PR with missing exact-head Build evidence. Compare requested SHA, run metadata, checkout assertion and terminal result. Do not infer success from workflow creation or queued status.
- Next action: refresh PR #2699 head and terminal Build/Device Smoke checks; inspect any failures; only then consider merge. After merge, prove the dispatcher works in GitHub Actions. Keep product release NO-GO until the integrated app gates and physical/data-integrity acceptance are complete.

---

# AUTHORITATIVE CONTINUATION — 2026-10-14 (Person integration repair attempt)

This entry supersedes earlier live-status claims where they conflict; older entries remain as history. Refresh exact-head CI before any merge/readiness decision.

- **Main:** `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`.
- **Validated parent feature PR:** [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666), exact head `ad762774009e5b5c7ee341146a8160c52e2b9bb2`, mergeable=true, open/unmerged. Build [38507091410](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091410), six-lane Device Smoke [38507091345](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091345), and Calendar Provider Acceptance [38507091333](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091333) succeeded on that exact head. This is emulator/CI evidence, not physical-device acceptance; PR explicitly says do not merge until every required gate passes.
- **Person integration PR:** [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695), draft, open/unmerged, current head `0432e3a7874ce5bc0f798345e232a480dc3d65b3`, base branch `integration/task-multiple-reminders-safe-20261013`, mergeable=false. Its recorded Build at prior head `07c7f9005b7331f07468e20d13b3939c990bd9fd` failed all six test shards while Analyze and Debug/Release APK passed.
- **Repair attempt committed on PR #2695 branch:** `e57df8e` makes Person-directory loading conditional on the waiting-response workflow to prevent an indefinite progress animation in ordinary Follow-up forms; `0432e3a` ensures legacy result text alone does not activate structured waiting state; `d2de8f2` updates service tests for the canonical structured contract; `c169b1c` updates waiting-list fixtures and seeds a Person for the active waiting editor test; `dc5a9a5` makes report filter widget tests scroll lazy controls into view; `a612dde` requires at least one Person ID for active waiting reports.
- **Validation status for repair attempt:** the Actions wrapper returned no PR-triggered workflow runs for the exact current head `0432e3a...` at latest poll. These code changes are **unvalidated**. A PR comment records the request to trigger exact-head Build and Device Smoke. Do not claim the fixes work until terminal CI evidence exists.
- **Current bottleneck:** CI is not visible for the latest Person repair head; PR #2695 remains non-mergeable and its base relationship is behind/divergent from the latest parent PR head `ad762774...`. Do not rebase/merge blindly; preserve all Task/Follow-up/reminder and backup contracts.
- **Next action:** obtain/trigger full exact-head Build, all six test shards, Debug/Release APK, Calendar Provider Acceptance and six Device Smoke lanes for the repaired branch; inspect failures. Only after green results, reconcile the branch against the exact current #2666 head and rerun all gates on the final resulting SHA. Complete standalone Person backup/restore/report acceptance and physical-device validation. Release remains **NO-GO**.

---

# AUTHORITATIVE CONTINUATION — 2026-10-14 (live recheck after v9 execution)

This addendum supersedes older live-status claims below where they conflict. Older checkpoints are retained as history. Evidence is commit-specific; refresh before promotion.

- **Repository:** `mobinpda-lab/Arvin-clean`; default branch `main`.
- **Latest observed main:** [`3f4b72999dca68afb31c9ad1c2c48b60dd8410a2d`](https://github.com/mobinpda-lab/Arvin-clean/commit/3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d). Commit fixes Calendar projection so `nextFollowUp` remains an internal action, not a notification or outbound Calendar sync.
- **Completed exact-head validation for reminder integration:** PR [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666), head `ad762774009e5b5c7ee341146a8160c52e2b9bb2), base matches latest main `3f4b729...`, currently open/unmerged and GitHub reports mergeable=true. Build run [38507091410](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091410) SUCCESS (Analyze, all six test shards, Debug/Release APK); Device Smoke [38507091345](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091345) SUCCESS (Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore); Calendar Provider Acceptance [38507091333](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091333) SUCCESS. These are CI/emulator/provider acceptance results, not physical-device acceptance. PR #2666 explicitly retains physical-device/backup-and-calendar-link integrity promotion gates; do not merge or release until its own stated gates and review policy are satisfied.
- **Person integration remains blocked:** PR [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695), head `07c7f9005b7331f07468e20d13b3939c990bd9fd`, is Draft, unmerged, and GitHub reports mergeable=false. Build [38506153872](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38506153872) FAILED: Analyze and Debug/Release APK passed, but test shards 0–5 failed. Logs show Follow-up editor save/prefill/back/reminder-preservation regressions; waiting-response list/report failures; and a mismatch between legacy result-only waiting fixtures and the structured `waitingForResponse + personIds` contract. No tests were deleted or weakened. Triage and bounded repair instructions recorded in [auto-fix issue #2697](https://github.com/mobinpda-lab/Arvin-clean/issues/2697), comment [6160480176](https://github.com/mobinpda-lab/Arvin-clean/issues/2697#issuecomment-6160480176).
- **Person persistence slice:** PR [#2696](https://github.com/mobinpda-lab/Arvin-clean/pull/2696), head `94f47f5c70558c6ff250ec1989bdcde761d04df5), is Draft and unmergeable; Build [38506510367](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38506510367) SUCCESS, but this slice is intentionally incomplete (no Settings UI, portable backup integration, structured Person IDs, or Person-specific reports). Green Build is not acceptance of the whole Person feature.
- **Heavily diverged Person PR:** [#2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681) remains unmergeable. Do not merge it or cherry-pick it wholesale; reconcile only reviewed, validated changes against the canonical integration branch.
- **Deliverable-plan PR:** [#2698](https://github.com/mobinpda-lab/Arvin-clean/pull/2698), head `fab9f677fb04aa01f588fee2073397acf7cf39c4), open/unmerged, mergeable=true. Build run [38508165928](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38508165928) is still IN_PROGRESS (Analyze passed; tests and APK jobs not terminal at latest poll). Device Smoke [38508165923](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38508165923) has Quick Capture and Home IN_PROGRESS; SQL Persistence, People, SQL Migration and Backup/Restore QUEUED. Updating this state file will change the PR head and require checking exact-head runs again.
- **Current bottleneck:** Person integration's broad Follow-up/editor/waiting/report test failures and non-mergeable stacked branches. Keep PR #2695 draft. Do not conflate green PR #2666 core integration CI with completion of the Person feature.
- **Next action:** repair PR #2695 against the structured Follow-up/Person contract without weakening tests; synchronize/rebase only through reviewed commits; rerun Analyze, all test shards, Debug/Release APK, Calendar Provider Acceptance, and all six Device Smoke lanes on the resulting exact head. Then complete Person-directory backup/restore/report acceptance and physical-device validation. Release remains **NO-GO**.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (reminder-model gate and CI poll)

This checkpoint supersedes live-status statements below where conflicting; preserve older entries as history.

- **Repo:** `mobinpda-lab/Arvin-clean`; current observed main/base checkpoint for PR #2652: `8136c929237c321f2e879a80f067970c31cb0100`.
- **PR #2652:** open, unmerged; title “docs(arvin): clarify multiple follow-ups and independent reminders”; branch `docs/owner-clarification-reminder-seed-20261013`; latest pre-this-state-update head `ca0b80a6c4275d44054c4ad9eb2b72d5f9832392`. Updating this state file creates a newer head; query that exact SHA's CI before treating it as validated.
- **Completed:** re-polled Build run [38317606450](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38317606450): Analyze, test shards 0–5, Debug APK and Release APK all SUCCESS. Device Smoke run [38317606458](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38317606458): Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore all SUCCESS. These are evidence for pre-update head `00ae93b2dba36093c4074624fe951efec51e2ab4`, not for later documentation commits or the unimplemented feature.
- **Persistent gap:** Issue [#2654](https://github.com/mobinpda-lab/Arvin-clean/issues/2654) tracks multiple independent Task-level reminders. Source `lib/models/task.dart` has a singular Task reminder and singular FollowUp reminder field per FollowUp. Existing test `test/follow_up_reminder_model_test.dart` proves only one FollowUp reminder JSON round-trip and legacy missing-field handling.
- **Decision gate:** an architecture proposal was added to PR #2652: candidate is a stable-ID `TaskReminder` collection embedded in canonical Task, with editable title/schedule and explicit date-only/all-day metadata, using existing Calendar/notification engines. **PROPOSAL ONLY, NOT APPROVED.** Legacy `Task.reminderDate` and `FollowUp.reminderDate` compatibility, old backup decoding, duplicate prevention, and all-day-vs-midnight semantics must be decided before implementation. No application code or schema migration changed.
- **Memory updated in this branch:** Decision Log, Project Knowledge, Problem Register, Evidence Map; source evidence and limitations recorded. Issue #2635 contains the owner's opt-in reminder contract.
- **Release:** NO-GO. Emulator smoke is not physical-device acceptance. No feature code was changed or validated in this continuation.
- **Next action:** obtain owner/architecture approval for the proposed compatibility semantics, then implement the model on a dedicated branch with legacy JSON, SQL, backup/restore, independent edit/delete, notification and stable Calendar identity tests. Keep PR #2652 unmerged until its latest exact-head checks finish.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner reminder cardinality audit)

This entry supersedes stale live-status wording below where it conflicts; historical entries remain for audit.

- **Repository/main:** `mobinpda-lab/Arvin-clean`; observed current main checkpoint `8136c929237c321f2e879a80f067970c31cb0100`.
- **Docs PR:** [#2652](https://github.com/mobinpda-lab/Arvin-clean/pull/2652), branch `docs/owner-clarification-reminder-seed-20261013`, pre-update head `2b1f89e51aa7f42bca10d92352e49d6c73c7fd83`, base `8136c929237c321f2e879a80f067970c31cb0100`. PR title corrected to “docs(arvin): clarify multiple follow-ups and independent reminders”; it remains open/unmerged. This state update creates a new head; re-check all exact-head runs.
- **Current pre-update CI:** Build run [38316746472](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38316746472): Analyze, six test shards, and Debug APK SUCCESS; Release APK still IN_PROGRESS. Device Smoke [38316746569](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38316746569): Home SUCCESS; Quick Capture and SQL Persistence IN_PROGRESS; People, SQL Migration and Backup/Restore QUEUED. These results apply only to the pre-update SHA; not release evidence.
- **Source audit:** main `lib/models/task.dart` currently supports one `Task.reminderDate` and one optional `FollowUp.reminderDate` per FollowUp record. Multiple FollowUp records can each carry a reminder, but there is no collection for multiple Task-level reminders that exist independently of FollowUp records. `nextFollowUp` and `reminderDate` remain separate nullable fields. The editor’s `_pickNext()` derives hour/minute from the recorded FollowUp timestamp; there is no date-only marker for either FollowUp field, and the Calendar projection does not pass FollowUp all-day state.
- **Recorded owner contract:** [Issue #2635](https://github.com/mobinpda-lab/Arvin-clean/issues/2635) now has a 2026-10-13 clarification: setting `nextFollowUp` does not create a reminder; reminder creation is opt-in; seeded Task title/date-time are independently editable; no normalization, overwrite, or duplicate creation.
- **New explicit model gap:** [Issue #2654](https://github.com/mobinpda-lab/Arvin-clean/issues/2654) records the requirement for multiple independent Task-level reminders, current cardinality limits, compatibility requirements, and acceptance tests. This is an architecture/persistence/backup/Calendar identity gate. **Do not implement a schema migration until the canonical representation and legacy-field compatibility are documented.**
- **No application code changed in this continuation.** No Flutter analyze/test/build/device run was executed by the assistant; GitHub Actions status above is separate CI evidence. Release remains **NO-GO**.
- **Next action:** complete the canonical model/compatibility design for #2654, including explicit all-day metadata and treatment of legacy singular fields; then implement on a dedicated branch with JSON, SQL persistence, backup/restore, independent edit/delete, Calendar identity and exact-head CI/device-smoke tests. Keep PR #2652 unmerged until its new exact-head checks finish.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (post-audit live state)

This entry supersedes older live-status wording below. Historical checkpoints remain for audit.

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; observed main SHA `18117aea2fa07b5a9a02e6021f41ff4faae120cc`.
- PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) remains OPEN and unmerged; base SHA matches the observed main checkpoint; branch `docs/decision-follow-up-vs-reminder-20261012`; latest pre-checkpoint head `bd1e73e94395f9ed4fee6ea20b96b4fca2291a0e`. Branch compare: 13 commits ahead, 0 behind; GitHub reports mergeable=true. This is documentation-only and must not be merged without exact-head validation.
- **Exact-head CI evidence for pre-checkpoint SHA `bd1e73e...`:** Build [38305322486](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322486) PENDING; Device Smoke [38305322504](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322504) PENDING; G1 lock sync [38305322539](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322539) IN PROGRESS; PR Wakeup [38305322472](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322472) IN PROGRESS; Production Loop [38305322668](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322668) SUCCESS; Orchestrator [38305322659](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322659) SUCCESS; Parallel Wave [38305323414](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305323414) SKIPPED. These statuses apply only to `bd1e73e...`. This execution-state update creates a newer commit; re-check the resulting exact SHA and do not reuse these results as its validation.
- **Completed this run — read-only source compatibility audit and memory recording:** confirmed that FollowUp has separate nullable `nextFollowUp` and `reminderDate` values but no explicit all-day metadata; the editor does not create the initial reminder when Next Follow-up is first set, inherits the history time, and lacks a clear-next action in the inspected path; FollowUp Calendar projection omits `isAllDay`. SQL storage uses the canonical Task JSON envelope; backup uses `Task.toJson()` and restore uses `Task.fromJson()`. Findings were recorded across execution state, decision log, project knowledge, problem register, evidence map, and the follow-up/reminder addendum on this branch.
- **Owner/data gates remain:** (1) define what happens when a reminder already exists at first activation of Next Follow-up; (2) approve a backward-compatible all-day representation that distinguishes date-only from intentional midnight for both independently editable fields. Do not overwrite/duplicate existing reminders, infer all-day from midnight, or silently normalize legacy fields.
- **No application code changed.** No Flutter analyze/test/build/device validation was run in this source-audit step. Release remains **NO-GO**.
- **Next action:** poll exact-head Build and all six Device Smoke lanes for the resulting latest commit; continue safe compatibility analysis. Implementation remains blocked on the two owner/data decisions above.

---



# AUTHORITATIVE CONTINUATION — 2026-10-13 (follow-up/reminder compatibility audit)

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; live main SHA observed: `18117aea2fa07b5a9a02e6021f41ff4faae120cc`. PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) is OPEN, unmerged, base SHA matches this main checkpoint, head `aa3dabf145b7ee7c8042978e58901de769da6634`; exact-head Build was IN_PROGRESS and Device Smoke QUEUED at this poll. A documentation update creates a new head, so check runs again on the resulting exact SHA.
- **Completed read-only compatibility audit:** `FollowUp` stores nullable `reminderDate` and `nextFollowUp` separately, but has no explicit all-day metadata for either. `Task.allDay` applies to Task due-date only. `FollowUp.toJson/fromJson` serializes these fields as ISO strings and does not encode date-only intent separately.
- **Canonical persistence and backup path:** the SQL Task store writes the full canonical Task envelope as JSON; canonical backup serializes via `Task.toJson()`, and restore reconstructs through `Task.fromJson()`. The existing `FollowUp` fields therefore travel through the canonical Task payload, but a new all-day flag must be represented in the model/JSON and covered by SQL envelope + backup/restore round-trip tests. Existing date-only values already serialized at midnight cannot be reliably distinguished from intentional midnight times retroactively.
- **Calendar path:** `FollowUpCalendarProjection` currently omits `isAllDay` for FollowUp reminder projections (default false). The date-only heuristic is applied to Task due dates only. `CalendarReminder`, sync revision and `SystemCalendarBridge` already carry all-day state; the missing semantics originate earlier in the FollowUp model/editor/projection.
- **Editor path:** `FollowUpEntryPage._pickNext()` inherits hour/minute from the recorded Follow-up `dateTime`; it does not offer a date-only choice or clear-next action in the inspected code. Saving `nextFollowUp` currently does not create an initial `reminderDate`. Existing tests cover JSON round-trip, independent reminder edit/clear, and date-only Task due dates, but no verified regression coverage for first-set creation, clear-next independence, or date-only FollowUp reminder projection.
- **Data safety:** do not infer all-day from midnight, overwrite a pre-existing reminder, or silently normalize legacy `nextFollowUp` into `reminderDate`. The existing-reminder first-activation behavior is still an owner decision. A separate persisted all-day marker for Next Follow-up and Reminder is the safer candidate because each can independently be date-only or timed, but this is a model/backup compatibility change and must be specified before implementation.
- **This run:** source/docs audit only; no app code changed and no Flutter analyze/test/build/device validation was executed. Release remains **NO-GO**.
- **Next action:** owner decision on first activation when a reminder already exists; then agree on backward-compatible all-day representation. Safe work may continue after recording these gates; do not merge this PR without exact-head validation.
# AUTHORITATIVE CONTINUATION — 2026-10-12 (Device Smoke completion and source-level compatibility audit)

This newest entry supersedes conflicting earlier live-status statements below. Historical checkpoints remain for audit. Verified through GitHub at the time of this update.

- **Latest observed main commit:** `326afaa276b04650a86a811b18560eb4e20ed5cd`. Older checkpoint references to `ddcf96955f3a62081d7ab24f922d8031c44e6202` are historical branch-base information, not the latest main SHA.
- **PR #2639 pre-memory-update CI evidence:** Build [38255658613](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38255658613) passed Analyze, all six test shards, Debug APK and Release APK on SHA `104111cb79e1669a529d4c9daf53536796683c68`.
- **PR #2639 Device Smoke completed:** [run 38255658812](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38255658812) is now terminal SUCCESS on that same SHA. All six lanes passed: Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore. Artifacts verified at final poll include Home, Quick Capture and People. This is automated Android-emulator evidence only, not physical-device acceptance.
- **Content-level compatibility findings are recorded and verified** in [Issue #2102 comment 6125444112](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6125444112): PR #2636 normalizes legacy `nextFollowUp` into `reminderDate` and clears the old field on save; its tests demonstrate the new normalization but do not prove all downstream/backup compatibility or owner approval. PR #2595 removes Quick Add description/category/tag entry from the compact interface and no longer assigns those values when constructing its draft; the reviewed tests do not establish compatibility/preservation of data entered through the previous Quick Add UI.
- **Integration remains blocked on product/data gates:** do not merge #2636 until explicit owner decision and compatibility coverage for legacy reads/writes, downstream consumers and backup/restore. Do not integrate #2595 until the intended Quick Add field contract and preservation regression tests are settled. The overlapping #2591/#2595/#2602/#2607 UI/time-picker work must not be independently merged.
- **Release remains NO-GO:** physical-device Calendar same-event update/no-duplicate evidence, real-device Backup/Restore and Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen visual acceptance and explicit owner approval are still required.
- **Next actions:** because this memory-only update changes the PR #2639 head, re-check the resulting exact-head Build and Device Smoke; do not reuse the prior SHA's green status as evidence for the new commit. Continue from the existing compatibility gates without duplicating already completed audits or starting unnecessary duplicate runs.

---

# AUTHORITATIVE CONTINUATION — 2026-10-12 (live re-poll after compact UI CI)

This section supersedes any older status statement below where it conflicts. Historical material is preserved for audit. Last verified against GitHub Actions and PR metadata during this continuation.

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; last verified main checkpoint remains `ddcf96955f3a62081d7ab24f922d8031c44e6202` for the compact UI branch's base. Do not assume a newer main SHA without refreshing it.
- **PR #2627 — compact task density:** OPEN, non-draft, mergeable, head `91b949f2417d3ca5aa5a7868ef7d7a2434858d67`, base `ddcf96955f3a62081d7ab24f922d8031c44e6202`. Exact-head Build [38227563489](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563489) passed Analyze, test shards 0–5, Debug APK and Release APK.
- **PR #2627 Device Smoke** [38227563488](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563488) remains IN PROGRESS at the latest poll. Home, Quick Capture, SQL Persistence and SQL Migration are SUCCESS; Backup/Restore and People are IN PROGRESS. The currently listed artifacts are Home and Quick Capture only. Do not treat the run as complete until all six lanes finish; inspect final artifacts and results.
- **Documentation PR #2626:** OPEN, mergeable, head `3c5a26a2481305c5b8a542f3c5b977e1fcbfd6b0`, base `ddcf96955f3a62081d7ab24f922d8031c44e6202`. Its Build [38228374059](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38228374059) currently has Analyze and all six test shards passing; Debug/Release APK jobs are still IN PROGRESS. Device Smoke [38228373999](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38228373999) is not complete: Home and Quick Capture are IN PROGRESS; People, SQL Persistence, SQL Migration and Backup/Restore are QUEUED. This checkpoint update will cause another CI cycle on the documentation branch; verify the resulting exact-head runs before considering merge.
- **PR #2619 cleanup:** OPEN and currently reports `mergeable=false`, head last recorded as `387694b5d5b29ca5fb72fedead56ed91368ca460`. Do not merge blindly. Continue path-by-path review and reconcile the branch against current main, then require exact-head Build and all six Device Smoke lanes.
- **Actions recorded during this continuation:** posted fresh status comments to PR #2627 and Issue #2102; comments record the incomplete Device Smoke state and preserve the no-premature-merge/release gate.
- **UX requirement:** compact task cards/rows should apply consistently beyond Home/Calendar to Reports, Next Action, Notebook, search/results and other lists where appropriate. Current PR #2627 specifically implements Home card progressive disclosure and compact Calendar reminder rows; it does not yet prove coverage across every listed surface. Treat broad compact-density coverage and Persian RTL/compact-screen screenshot review as open acceptance items.
- **Decision:** keep PR #2627 unmerged until six smoke lanes complete and visual acceptance is recorded. Do not infer physical-device acceptance from emulator results. Release remains **NO-GO** until physical-device Calendar same-event update/no-duplicate behavior, real Android file-provider Backup/Restore with Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen visual acceptance, and explicit product-owner approval are evidenced.
- **Next actions:** (1) poll exact-head #2627 Device Smoke and review all six lanes/artifacts; (2) poll exact-head #2626 Build and Device Smoke after this documentation update; (3) do compact RTL visual acceptance; (4) reconcile #2619 against main without losing canonical backup/data semantics; (5) continue dependency-aware integration of overlapping UI PRs #2591/#2595/#2602/#2607. Do not add meaningless commits to manufacture CI and do not merge overlapping drafts independently.

---

# AUTHORITATIVE LIVE CONTINUATION — 2026-10-12 (verified after PR #2625 merge)

This is the first section to read on every continuation. Historical notes below are retained for audit and are superseded wherever they conflict with this checkpoint. Recheck live GitHub before every write or readiness decision.

- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Current main checkpoint: `ddcf96955f3a62081d7ab24f922d8031c44e6202` (PR #2625 merged).
- **Completed — execution-memory refresh:** PR [#2625](https://github.com/mobinpda-lab/Arvin-clean/pull/2625) merged at `ddcf96955f3a62081d7ab24f922d8031c44e6202`. Exact-head Build [38224390186](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38224390186) passed Analyze, test shards 0–5, Debug APK and Release APK. Exact-head emulator Device Smoke [38224390103](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38224390103) passed all six lanes: Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore. This is emulator evidence, not physical-device acceptance.
- **Owner UX direction — compact task density (2026-10-12):** reduce task card/row vertical height wherever practical, especially Home and Calendar, and consistently in Reports, Next Action, Notebook, search/results and all task lists. Prefer compact rows; keep title and essential status/date visible; hide/collapse descriptions, checklist previews, tags and secondary metadata by default, reveal full information on tap/expand/detail. Preserve data, touch target usability, legibility, accessibility, Persian RTL and compact-screen responsiveness. Add regression tests for collapsed defaults and full-content expansion, then perform screenshot/physical-device visual review. This is presentation-only; do not change Task persistence, recurrence, Calendar identity/sync or backup semantics. Requirement recorded on [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607) and [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102).
- **PR #2627 — compact task density implementation:** OPEN, non-draft, current head `91b949f2417d3ca5aa5a7868ef7d7a2434858d67` (base `ddcf96955f3a62081d7ab24f922d8031c44e6202`). Home task titles are single-line/ellipsized; Task description, follow-up preview, checklist progress, taxonomy and priority detail are hidden by default and available via per-task disclosure; due date remains visible. Calendar reminder rows use dense layout and one-line clamped date/time summaries. Initial exact-head Build [38226230568](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38226230568) failed one regression test because expanded cards did not render `Task.description` (176 passed, 1 failed); Analyze, Debug/Release APK and the other five test shards passed. The defect was fixed in commit `91b949f2417d3ca5aa5a7868ef7d7a2434858d67` by rendering non-empty Task description only while expanded. Corrected exact-head Build [38227563489](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563489) now PASSES Analyze, all six test shards, Debug APK and Release APK. Device Smoke [38227563488](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563488) remains in progress: Home and Quick Capture passed; SQL Persistence and SQL Migration were running; People and Backup/Restore were queued at last poll. Keep unmerged until all six emulator lanes pass and Persian RTL/compact-screen visual review is recorded.
- **PR #2607 — broad pastel/compact UI:** OPEN/DRAFT, head `8d3d60a1b321fa4ceb9f5da779a144d3705b9103`, merge conflicts reported. Build [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) passed on that head; Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) was skipped because the PR is Draft. Do not merge independently. Reconcile with #2591/#2595/#2602 into one integration head; include the compact-density requirement and test collapsed/expanded content.
- **PR #2602 — Task Editor taxonomy/progressive disclosure:** OPEN/DRAFT at `1ddea0c9e6481dbf944f70f4faceb91499908c80`; no exact-head workflow run/status was returned in the latest checks. BLOCKED pending an authorized workflow trigger and verified exact-head results. Do not manufacture CI evidence with a meaningless commit or weakened tests.
- **PR #2619 — cleanup:** OPEN, unmerged; head `387694b5d5b29ca5fb72fedead56ed91368ca460`; latest metadata reports `mergeable=false`. Its Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) and six-lane emulator Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) passed on that head. Reconcile with current main, review every deletion/migration and rerun exact-head validation before merge.
- **Architecture invariants:** Task remains the sole source of truth; Quick Add and Full Form edit the same Task identity; Category = Group; Checklist and Repeat belong to Task; Repeat creates no copied root Tasks and past history remains immutable; Calendar is a projection and updates the same external event by stable Task/event identity; Home and Reports do not own parallel storage. Keep root `Task.description` as the sole root Task text field; do not add root `Task.note` or alter schema/migration/backup without explicit approval.
- **Integration rule:** do not merge overlapping #2591, #2595, #2602 and #2607 independently. Reconcile to one canonical integration branch, then require exact-head Analyze, all six test shards, Debug/Release APK, relevant emulator smoke and review.
- **Release status: NO-GO.** Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN until physical-device evidence covers Calendar same-event update/no duplicates, Android file-provider Backup/Restore and restored Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen acceptance, and explicit owner approval.
- **Next action:** reconcile overlapping UI work into one tested integration head that implements compact task density; separately reconcile and review #2619; resolve #2602's missing exact-head CI through an authorized trigger. Do not claim physical-device acceptance based on emulator tests.

## Execution status

- **Completed:** #2625 exact-head Build and all six emulator smoke lanes; merged.
- **In progress:** UI integration, compact card/row density and progressive disclosure; PR #2627 exact-head revalidation after the description-display fix.
- **Blocked:** #2602 exact-head CI evidence; #2619 base/conflict reconciliation and path review; physical-device acceptance and Persian RTL/compact-screen visual review.
- **Current bottleneck:** overlapping UI PRs, #2627 revalidation still running, and unresolved #2602 CI evidence.
- **Next checkpoint:** confirm #2627 Build and all six emulator smoke lanes on the corrected exact head, then reconcile overlapping UI PRs into one integration head.

---

# LIVE RECHECK ADDENDUM — 2026-10-12 (latest GitHub verification)

This addendum supersedes earlier workflow-status wording below where it conflicts. It is on the proposed documentation branch only until PR #2621 is reviewed and merged.

- Current `main` observed SHA: `a4dae51e93d9b3dcbc55ded366280e59183f16bc`. Exact-main Build [38202955720](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955720) passed Analyze, test shards 0–5, Debug APK and Release APK; exact-main emulator Device Smoke [38202955719](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955719) passed all six lanes (Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore).
- PR #2619 cleanup exact head `387694b5d5b29ca5fb72fedead56ed91368ca460`: Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) and all six emulator lanes in Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) passed. Maintainer path-by-path review and physical-device acceptance remain outstanding; do not merge solely on CI.
- PR #2621 live-state documentation head before this addendum: `62d16314809b70914d21efaffccca436c969258d`. Build [38218042934](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38218042934) passed Analyze, test shards 0–5, Debug APK and Release APK. Device Smoke [38218042946](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38218042946) passed all six emulator lanes. This evidence validates that prior PR head only; revalidate the new head after this addendum.
- PR #2602 remains OPEN/DRAFT at head `1ddea0c9e6481dbf944f70f4faceb91499908c80`; live queries returned no exact-head workflow runs or commit statuses. The latest three test-harness corrections therefore remain unvalidated. Do not merge.
- PR #2591 has a prior exact-head Build pass but no verified physical-device acceptance; #2595 lacks current exact-head validation; #2607 remains overlapping and reports merge conflicts. Do not merge #2591/#2595/#2602/#2607 independently. Next code action is a dependency-aware, single integration head followed by exact-head Build + all six emulator lanes.
- Owner-provided visual references remain tracked in [#2623](https://github.com/mobinpda-lab/Arvin-clean/issues/2623) and [#2624](https://github.com/mobinpda-lab/Arvin-clean/issues/2624). Their visual contracts and the pastel visual decision are documented, but the issue bodies still do not prove that the original image binaries are committed to GitHub or that runtime UI has passed screenshot comparison.
- Release remains **NO-GO** until real-phone evidence covers Calendar same-event update/no duplicates, Android file-provider Backup/Restore and restored Calendar-link integrity, installed-app golden flow, Persian RTL/compact-screen acceptance, and explicit product-owner approval. Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) open.

# LIVE CONTINUATION OVERRIDE — 2026-10-12 (verified)

This is the latest continuation checkpoint in this proposed change. It becomes authoritative on `main` only after review and merge. Refresh GitHub before every write or readiness decision.

- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`; last observed main SHA: `a4dae51e93d9b3dcbc55ded366280e59183f16bc`.
- **Current main validation:** Build [38202955720](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955720) passed Analyze, test shards 0–5, Debug APK and Release APK; Device Smoke [38202955719](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955719) passed Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore emulator lanes on that main checkpoint.
- **PR #2619 — cleanup:** open, unmerged, mergeable; current head `387694b5d5b29ca5fb72fedead56ed91368ca460`. Exact-head Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) completed successfully: Analyze, test shards 0–5, Debug APK and Release APK all PASS. Exact-head Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) completed successfully: Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore all PASS on Android Emulator. This closes automated validation for the current cleanup head only; path-by-path deletion/content-migration review and physical-device acceptance remain separate gates. Do not merge until maintainer review is complete.
- **PR #2620 — consolidated project report:** open, ready for review, unmerged. Exact-head Build [38211356787](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38211356787) passed Analyze, all six test shards, Debug APK and Release APK. Device Smoke [38211356834](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38211356834) was skipped for this documentation-only change, as expected.
- **PR #2618 — prior state refresh:** its branch conflicts with current main and must not be merged as-is. This PR is a clean replacement based on current main; after merge, read the file back at the merge SHA to confirm the live checkpoint persisted.
- **Overlapping product changes:** #2591 Universal Time Picker has Build success on exact head `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 Task Form does not have exact-head Build evidence in the latest query; #2602 exact head `1ddea0c9e6481dbf944f70f4faceb91499908c80` has no workflow runs returned; #2607 Build succeeded on exact head `8d3d60a1b321fa4ceb9f5da779a144d3705b9103` but PR metadata reports merge conflicts. Do not merge these overlapping branches independently. Reconcile them into one integration head and validate that exact SHA.
- Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN and Release **NO-GO** until real-phone evidence covers Calendar update-same-event/no duplicates, Android file-provider Backup/Restore and restored Calendar-link integrity, installed-app golden flow, Persian RTL/compact-screen acceptance, and explicit owner approval.
- No installation or manual testing is requested from the owner yet. Continue repository inspection, code/test integration, automated validation and documentation first. Ask for phone installation only after one integrated candidate has passed available automated gates; then provide the exact APK, install steps and short acceptance checklist.
- **Next action:** complete path-by-path review of #2619 deletions and migrated canonical content; recheck whether any stale references remain. In parallel, continue reconciling #2591/#2595/#2602/#2607 into one integration head without adding root `Task.note`. The #2621 memory-refresh branch had Build PASS on pre-refresh head `ab8a10fd6be03a991ab1710ef6ad3cd6b69cc1a8` (run [38214238032](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38214238032)); its Device Smoke [38214238051](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38214238051) was still in progress at last poll (Home, Quick Capture and SQL Persistence passed; SQL Migration and Backup/Restore running; People queued). This memory update creates a new head, so recheck exact-head CI before treating the refreshed memory branch as validated.

---

# ARVIN EXECUTION STATE — LIVE CHECKPOINT
**Checkpoint:** 2026-10-12 (UTC)
**Repository:** `mobinpda-lab/Arvin-clean`
**Branch:** `main`
**Last observed main SHA:** `a4dae51e93d9b3dcbc55ded366280e59183f16bc`
**Overall state:** IN PROGRESS — RELEASE BLOCKED

> This checkpoint supersedes older live-status and CI claims below. The changes in this PR are proposed until reviewed and merged.

## Last completed step
1. Read the v8 execution command and reviewed the existing memory drafts in PRs #2600 and #2608.
2. Rechecked current `main`, release-gate Issue #2102, open PRs and exact-main workflow runs.
3. Confirmed all required `docs/arvin-memory/ARVIN_*.md` memory files are **absent from current main**. They exist only in open documentation branches/PRs; therefore the v8 “read execution state first” path is currently not available on main.
4. Confirmed cleanup PR #2613 is merged; current main is `cea76673d871ce52b84dacf69f355c4282802baa`.
5. Started a documentation-only consolidation branch from this exact main commit to restore the canonical memory package without direct writes to main.

## Current exact-main validation
- Build: [run 38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086), exact SHA `cea76673d871ce52b84dacf69f355c4282802baa`. Fresh API query confirms overall conclusion `success`; Analyze, all six test shards, Debug APK and Release APK jobs are completed successfully. Non-expired artifacts: Debug APK 11717311531 (92,487,308 bytes), Release APK 11716328109 (32,681,865 bytes). This is exact-main CI evidence, not physical-device acceptance or release approval.
- Device Smoke: [run 38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043), exact SHA `cea76673d871ce52b84dacf69f355c4282802baa`. Latest live job query confirms all six scenarios completed successfully: Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore. This is automated Android-emulator evidence only; it does not prove physical-device acceptance. Earlier `BlobNotFound` log retrieval is superseded by the completed job conclusions and must not be reported as a current test failure.
- Recover/inspect the existing runs and artifacts before triggering duplicate workflows. If recovery is impossible, document the failure and start one controlled fresh validation batch only after checking workflow state.

## Completed
- PR #2613 merged at `cea76673d871ce52b84dacf69f355c4282802baa`: documentation cleanup only; no product code/schema/migration changed.
- PR-head CI and emulator smoke passed for #2613 head `55c3f829d7e443a6a4ae91de5e4b433965357400`; this is not physical-device acceptance.
- Live checkpoints recorded on Issue #2102 in comments [6114272356](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6114272356) and [6114324441](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6114324441); the latter captures the partial APK/screenshot artifact evidence.

## In progress
- Restore the required project-memory package to main through a reviewed documentation-only PR. The required files currently live in overlapping draft PRs #2600 and #2608; do not merge either stale branch blindly.
- Exact-main Build and all six Device Smoke emulator scenarios are confirmed successful. Physical-device acceptance remains outstanding; do not equate emulator CI with installed-device evidence.
- Reconcile shared implementation files in #2591, #2595, #2602 and #2607 before integration. Their diffs overlap in Task Editor, Quick Capture, main routing, Report Center and Universal Arvin Time Picker.
- Preserve the report-filter owner requirements and Persian/Jalali time controls; implementation/combined-head acceptance is still open.

## Blocked / release gates
- Physical-device Calendar same-event update/no-duplicate proof.
- Real Android system file-provider Backup/Restore, rollback and restored Calendar-link integrity.
- Golden-flow installed-device acceptance: Task create/edit, Date/Time, Checklist, Repeat/Occurrence, permissions, keyboard/scroll/error states.
- Persian RTL, typography and compact-screen visual acceptance.
- Explicit owner approval after reviewing evidence.
- The `Task.note` vs `Task.description` data-contract issue remains owner-decision sensitive; do not add a root `Task.note`, alter schema, migration or backup semantics without an explicit decision. Existing recorded direction says root `Task.description` remains canonical.

## Next action
Finish the documentation consolidation PR only after its exact-head Build completes successfully and its checkpoint remains coherent. The exact-main Device Smoke run is complete with all six emulator scenarios passing; next, preserve this updated evidence, then continue reconciling overlapping code PRs into a single tested integration sequence. Do not publish an APK as a release or claim Release Ready.

## Current bottleneck
Project memory is not present on main and PR #2614 exact-head Build is still running. Exact-main Build and all six emulator smoke scenarios pass, while release acceptance still lacks physical-device proof and explicit owner approval.

## Product invariants
- Task is the sole source of truth; Quick Add and Full Form must preserve the same Task ID.
- Category and Group are synonyms; do not create a separate Group entity/store.
- Checklist belongs to Task; Repeat is a Task capability and must not create copied Task records.
- Repeat chain: Task → Repeat Definition → Occurrence → Execution State → History; past immutable, future adjustable.
- Calendar is a projection; update by Task ID / External Event ID, never by title/date matching.
- Tracking does not replace CRM; Home has no independent storage; Report is a read-only consumer.
- Preserve user data, stable IDs, Persian RTL and VazirHarf v34.003.
- Mark work complete only with relevant code, tests, build, validation and evidence.

---

## Historical checkpoints (not current status)
The material below is retained to preserve earlier audit findings and evidence links. Its dates, branch heads, run statuses and next-action statements are historical; the live checkpoint above always wins.

# LIVE CONTINUATION CHECKPOINT — 2026-10-11 18:27 Iran time

This checkpoint supersedes older PR-head snapshots and "Next action" entries below. Refresh all live GitHub state before future operations.

## Latest completed step
- Re-read this execution state first, then refreshed live PR #2591/#2595/#2600/#2601/#2602 and accepted RTLC issue #2605.
- Compared patches for #2591, #2595 and #2602 to identify shared files and data-contract risk. All three are still OPEN; #2591 and #2595/#2602 are Draft, #2595 is stacked on #2591. PR #2600 remains OPEN/DRAFT. Current reported heads: #2591 `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 `0786a2e067594d92b35c6a3028c633e8abc9bb3d`; #2600 `0413c5a7b862d4e0718f67a2587ec8dc36b04429`; #2601 `b832aeb6e0f55c78db0b1814adc0d5bd63447c23`; #2602 `15c40a81ec7e45fe690de40ebbd9cf005e57af80`. Refresh before relying on them.
- Verified current main `a6ced27660d34cd87dd8915aff68d3a7555fd57a` and read `lib/models/task.dart`: canonical root Task has `description`, but no root `note`; it already has Notebook item-kind and scoped note concepts.
- Found a new unapproved data-contract change in #2595: adds root `Task.note`, modifies Task serialization/deserialization and TaskStore known keys, and changes backup/restore test expectations. Command v8 lists Task Description but does not authorize a second root field. This is a data/architecture gate, so do not silently approve it or propagate it.
- Posted review comments on #2595 and #2602 to keep both Draft and reconcile the overlapping form lane; comments: https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110326453 and https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6110326886.
- Recorded the finding in `ARVIN_PROBLEM_REGISTER.md` (commit `4fa06f3f2feb3e368ef55116320e76ad235ee216`) and `ARVIN_DECISION_LOG.md` (commit `53a35664b40b1ab64ba9a8642663013056953fe3`) on the existing documentation branch. GitHub Read/Write access was used; no app code, main, APK, merge, or release was changed.

## Current status
- **Completed:** Cross-PR overlap/data-contract audit; comments posted; data-risk gate recorded in memory.
- **In Progress:** Universal time picker rollout and Task form reconciliation; RTLC integration remains accepted direction but not implemented/accepted; product and release evidence.
- **Blocked:** Approval of root `Task.note` vs existing `description` semantics and legacy data/backup mapping requires explicit product-owner decision. This is the stop condition defined by Command v8 (data risk/architecture change).
- **Current bottleneck:** Several Task Editor PRs overlap and #2595 introduces an unapproved Task data-contract change; #2602 previously failed three test shards and Device Smoke was skipped.
- **Next action:** Ask owner whether a separate root Task Note is intended in addition to Description. Until decided, continue only safe read-only patch/CI evidence work and documentation reconciliation; do not merge #2595/#2602 or propagate `Task.note`. After decision, consolidate to one canonical form/time-picker branch, fix test root causes without weakening tests, then integrate RTLC once and run exact-head CI + Device Smoke + physical-device acceptance.

---

## Documentation audit writeback — 2026-10-11

- Conversation-decision history was added at `docs/arvin-memory/ARVIN_CONVERSATION_DECISION_HISTORY.md`, commit `cef2a03e7d4f0dd73cbefad796e0393c8723267d`; read-back verified time-picker and checklist requirements are present.
- `ARVIN_PROBLEM_REGISTER.md` addendum committed at `abfe3d719eed8ec134c26fd82ba8d432bd83e315`; `ARVIN_EVIDENCE_MAP.md` addendum committed at `7933bf44f36fdfed1da9b4e918acd0218a28bbb6`.
- PR #2600 audit comment posted: https://github.com/mobinpda-lab/Arvin-clean/pull/2600#issuecomment-6109981897.
- Current memory branch has been updated but is still not main; re-fetch current head before any later write. No application code, APK, merge or release change was made.

# DEEP CONVERSATION AUDIT CHECKPOINT — 2026-10-11 (supersedes stale next-action notes below)

## Owner request
The owner explicitly asked for a meticulous review of this conversation so no requirement, prior finding, or dependency is missed. This checkpoint records that audit and corrects earlier stale notes below; use live GitHub before every subsequent action.

## GitHub Read/Write and live repository reality
- Read/Write access verified in this run. All writes are limited to the existing documentation branch `docs/arvin-autonomous-memory-20261011`; no write to `main`, no app code edit, no APK build, and no release/merge performed.
- Latest main commit confirmed by commit search: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. `main` does not yet contain this `docs/arvin-memory/` checkpoint.
- PR #2600 is OPEN/DRAFT, branch `docs/arvin-autonomous-memory-20261011`, head `40963f0fe54ba8d34375c1c6c7fc62c01f27b627`, base SHA `72a2f4cc24df7a38eff9856ce403461615db5280` (stale versus main). Do not merge until rebase/reconciliation and validation.
- Documentation PRs #2598 (`32860ad0a07778d210ba1dac4caf2dc68effccc5`), #2599 (`bd03c61749f4cf093f25251330a54ca773f48c7f`) and #2600 overlap and are all based on old main `72a2f4c...`. Reconcile into one consistent authority hierarchy; do not create competing status/roadmap/memory sources.
- #2590 is OPEN (not merged), head `1810e454a20e29eec837be9ac446e222795d79f8`; #2591 is OPEN/DRAFT, head `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 is OPEN/DRAFT, head `0786a2e067594d92b35c6a3028c633e8abc9bb3d`, stacked on #2591; #2602 is OPEN/DRAFT, head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`; #2601 is OPEN, head `b832aeb6e0f55c78db0b1814adc0d5bd63447c23`. Each still has stale base `72a2f4c...` except #2595's base is the earlier #2591 head `0c43dfbe3c0f7188cea6e03614300be81271e158`.
- Latest recorded #2602 CI: Build #38139809938 passed Analyze and Debug/Release APK jobs but failed three test shards; Device Smoke #38139809930 was skipped. Failures include missing repeat control keys, automatic/manual reminder behavior, date-only All-Day persistence, custom Clock Dial test, and taxonomy row width 99.33px vs >270px expectation. Do not merge or weaken tests.
- RTLC decision #2605 is OPEN and explicitly accepted as product direction, not implemented/accepted. Existing `RecurrenceTrackingLevel` JSON field and history/checklist foundations must be reused; keep `followUpEnabled` distinct.
- Release gate #2102 and owner acceptance ledger #1139 remain open. Main-head workflow/status lookup previously returned no PR-associated runs/statuses; that is missing evidence, not a pass. Physical-device acceptance and owner release approval remain unverified.

## Audit findings: important items that must not be lost
1. **Universal time picker (P0 product consistency):** #2589 is accepted UX direction, implementation PR #2591 and docs PR #2590 remain open. Audit all direct/custom time pickers and passive time formatting, including Home filters, Backup Schedule, Follow-up, Reports, Task Editor and Quick Capture. Preserve canonical Task times, reminder/follow-up/repeat/calendar/backup behavior; Persian digits, RTL, 24-hour dial, exact-minute entry, contextual title, cancel/save safety, and real-device proof are required. Existing audit says six direct `showTimePicker` call sites remained on main; recheck current source before action.
2. **Task form overlap and acceptance:** #2595 and #2602 touch the same form; #2595 depends on #2591. Choose one canonical branch only after comparing live diffs/heads. Keep quick entry minimal and Full Form editing the same Task; do not duplicate Tasks. Progressive disclosure must not hide or break date/time, All-Day, reminder, repeat, priority or checklist.
3. **Repeat Tracking Level (RTLC):** after Repeat, selector «نوع پیگیری» → «عادی» default / «مهم و قابل پیگیری»; use existing `recurrence.trackingLevel`. Then separately audit Home's restrained cue and Report Center filters/metrics. Preserve Task ID, occurrence history immutability, per-occurrence checklist isolation, and backup compatibility. Do not conflate with Follow-up.
4. **Calendar installed-app regression:** owner reported missing «ویرایش» and «ثبت در تقویم گوشی», and recurrence showing only current day rather than planned days (up to seven). #2587 and #2570 are merged in current mainline, but this is code status only; #2535 and #1139 remain acceptance gates. Test action visibility, all scheduled dates, stable linked-event update/no duplicates on physical device.
5. **Backup/restore P0:** #2585 is merged at current main SHA, and #2587 is merged at `c57606c...`. Still unverified: physical Android system file-picker/provider, export/restore round-trip, late-stage rollback, preservation of IDs/relations/settings/notebook checklists/catalogs/calendar links, and before/after integrity.
6. **Reports:** #2385 remains open. Extend existing canonical report/filter/print/share/PDF paths; do not create a second report model/engine. RTLC report filtering/metrics are an additional acceptance gate.
7. **Taxonomy:** Project, Category, Tag are canonical; Category = Group synonym, no fourth Group entity/store. Verify actual schema; do not infer a Project foreign key. RTL selector order and width must be genuinely usable at target phone viewport.
8. **Visual/product contract:** preserve Persian RTL and VazirHarf v34.003 (do not replace with Vazirmatn), approved palette (#4A4CAB, #E9EAFF, #F8F8FB, #FDFDFE, #232433, #80829C), Home's four axes Time/Project/Category/Tag, no obsolete stats cards/title/dropdown, clock + calendar icons side-by-side in every create/edit form, and approved reminder widget/lock-screen actions. Color-only changes do not satisfy redesign acceptance.
9. **Checklist requirement:** checklist remains part of Task. The owner requested a high-priority checklist directly under the full/edit Task form, generic for all Tasks (example: daily school checklist active at 06:00 with کیف/خوراکی/لباس). Recurrence occurrence state must remain independent; do not create a separate checklist subsystem.
10. **Release handover:** before final handover, require release notes, installation guide, user guide, known issues, architecture summary and evidence report, tied to an exact candidate artifact and explicit owner acceptance.

## Completed audit step
Compared the current Command v8 against the existing memory documents, decision records, live issues and overlapping PR state. Found that earlier snapshots contain contradictory/stale claims and that the conversation decision-history file is not present on this memory branch. The new decision-history document is being added on this existing branch to close that memory gap; it is an index of decisions, not implementation evidence.

## Next action
1. Read back the new conversation decision-history file and this updated state from this exact branch.
2. Comment on #2600 with the audited gaps and stale-base/documentation hierarchy.
3. Select one canonical task-form implementation lane after diff/test comparison; repair #2602 root causes without weakening tests, then integrate RTLC once.
4. Recover/run exact-current-main Build + Device Smoke evidence; continue physical-device and owner acceptance gates.
5. Reconcile/rebase docs PRs before any merge. Do not claim final/release-ready until product evidence and owner acceptance exist.

---

# LIVE CONTINUATION CHECKPOINT — 2026-10-11

This section supersedes conflicting older snapshots below. The detailed earlier notes are historical context and must not be treated as current status without rechecking.

## Startup result
- Repository: `mobinpda-lab/Arvin-clean`; branch checked: `main`.
- Current main SHA: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` — https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a
- GitHub access: Read/Write verified; this checkpoint update is being committed only to the existing documentation branch for PR #2600, not directly to main.
- PR #2585 backup/restore safety is MERGED at `a6ced276...`.
- PR #2587 Calendar collapsed-card actions/recurrence is MERGED at `c57606c223a1d6141bd3d11e1a75cc5cda428470`.
- The main-head Actions wrapper returned no PR-associated workflow runs and combined status returned no statuses for `a6ced276...`; this is **no current-head CI evidence from those lookups**, not proof that no workflow exists or ever ran.
- PR #2600 (this memory branch) remains OPEN/DRAFT and is based on old main `72a2f4cc...`; it must be rebased/reconciled against current main before merge.
- PR #2598 (AMPOP/governance), #2599 (repository audit), and #2600 (memory) are three overlapping OPEN/DRAFT documentation PRs based on the old main. Keep them unmerged until they form one consistent hierarchy and avoid competing status/roadmap/memory copies.
- PR #2601 integrated APK candidate remains OPEN and is based on old main; it is not a release artifact accepted for delivery.
- PR #2602 task-editor changes remain OPEN/DRAFT. The latest recorded Build passed Analyze and APK builds but failed three test shards; Device Smoke was skipped. Do not merge. Fix repeat/reminder reachability, date/time behavior and RTL taxonomy layout; reconcile overlap with PR #2595.
- PR #2595 overlaps task form changes and is stacked on PR #2591 shared time picker. Keep one canonical implementation and validate the final combined head. PR #2591 still lacks verified physical-device acceptance.
- Owner acceptance/release blockers remain in #1139 and #2102; Calendar installed-device recurrence/actions in #2535; advanced Report Center in #2385; taxonomy conformance audit in #2580; repeat/checklist lifecycle acceptance in #2254.
- Physical Android-device acceptance, exact-current-main Build/Device Smoke evidence, complete Golden Flow, full restore round-trip/rollback proof, and final owner acceptance remain NOT VERIFIED.

## Last completed step
Re-read the requested Autonomous Delivery & Evolution Command against live GitHub, read the memory state/evidence map on the existing PR #2600 branch, checked the main commit history, and refreshed PR/issue state. Confirmed that the six-file memory set is incomplete on this branch: `ARVIN_PROBLEM_REGISTER.md` is missing.

## Next action
1. Complete the existing memory branch with a problem register and this live checkpoint.
2. Read back both changes and verify exact commit/file paths.
3. Comment on PR #2600 with the stale-base and documentation-hierarchy blockers.
4. Continue with the highest-priority product gate: recover exact-current-main CI/Device Smoke evidence and reconcile the task-editor PR overlap; do not claim release readiness.

## Current bottleneck
Release evidence and owner acceptance, not lack of another architecture or another workflow. Do not create a new factory or parallel implementation.



Updated: 2026-10-11 (live GitHub recheck; exact-head Build passed, Device Smoke partially complete)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified by live operations.
Authority: live GitHub refs, source, tests and workflow evidence.

## Live recheck — 2026-10-11 13:40 Iran time

- Re-read this state and evidence map on the existing memory branch; confirmed PR #2600 is the intended documentation-only continuation path. The file is not yet on `main`.
- Main remains `72a2f4cc24df7a38eff9856ce403461615db5280`.
- PR #2585 exact head checked: `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Build run [38130522723](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522723) is complete and successful: Analyze, all six test shards, Debug APK and Release APK.
- Device Smoke run [38130522703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522703) is still in progress. Home, Quick Capture and SQL Persistence passed; SQL Migration and Backup/Restore are in progress; People is queued. Do not call the full smoke suite passed.
- No physical-device or actual Android system file-picker/provider acceptance was found. Release remains blocked; PR #2585 and #2587 remain unmerged.
- The live Build/Smoke runs above supersede the older pending status recorded below where they conflict.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.** No physical-device acceptance has been provided.

## Last completed step
- Read this state and `ARVIN_EVIDENCE_MAP.md` first, then rechecked PR #2585, Issue #2580, the relevant backup/settings/task/notebook sources, and current-head Actions.
- Owner approval for standalone Category/Tag portability was already recorded in PR #2585 and Issue #2580. The later owner-approved expansion requires notes/notebook checklists and portable app settings, stable-ID reconciliation, preservation of local-only records, omitted-key safety for legacy settings, and rollback across stores.
- Implemented in the existing branch `fix-backup-taxonomy-catalogs-20261010`, without a parallel restore engine:
  - `ArvinBackupManager.reconcileTasksById`: matching Task IDs update, backup-only Tasks add, local-only Tasks remain.
  - Project reconciliation uses stable Project IDs and preserves memberships for local-only Tasks.
  - Settings merge only applies supplied keys, including nested Calendar, backup schedule and Daily Content preferences. Explicit nullable defaults are serialized; older backups that omit a key do not reset it.
  - Daily Content preferences are included in foreground and scheduled backup payloads and validated before restore writes.
  - Scheduled backups now include Calendar-link metadata and canonical Category/Tag catalogs in addition to Tasks, Projects and portable settings.
  - Added tests for Task/Project reconciliation, local-only Notebook/checklist retention, partial legacy settings, explicit nullable settings and scheduled-backup payload contents.
- Current code PR #2585 head: `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Exact-head Analyze and all six test shards are SUCCESS; Debug APK is SUCCESS; Release APK is still IN_PROGRESS. Device Smoke: Home and Quick Capture are SUCCESS; SQL Migration and SQL Persistence are IN_PROGRESS; Backup/Restore and People are QUEUED. These are emulator/CI results, not physical-device acceptance. Previous exact heads exposed stale settings/replace-only test expectations; these were updated to the approved ID-reconciliation contract before the current head.
- PR #2585 remains OPEN / NOT MERGED. CI and emulator results do not prove real Android system file-picker/provider acceptance.
- Main base observed for PR #2585: `72a2f4cc24df7a38eff9856ce403461615db5280` (documentation-only PCTADP decision registration).
- Calendar linked-event edit [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) is merged at [`34a6cee`](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128); physical-device proof remains absent.
- Calendar action visibility/recurrence [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587) remains OPEN / NOT MERGED at `4442ce450e4295e500a9db6d5dc5b4d9657b3770`; historical exact-head Build #38089112669 and Device Smoke #38089112675 succeeded across emulator lanes. Physical-device acceptance remains absent.
- Memory documentation [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) remains OPEN / DRAFT; this state refresh is on its existing documentation branch.

## Current GitHub reality
- [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) remains open for the repository-wide Project/Category/Tag ontology audit. Owner approval for unused Category/Tag portability is recorded.
- [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) is the sole implementation path for backup/restore changes. Current head `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`; exact-head Analyze and all six test shards succeeded, Debug APK succeeded, Release APK and four Device Smoke lanes remain pending/in progress at the latest live check.
- Existing canonical storage remains authoritative: Tasks/Notebook items use TaskStore; Projects use ProjectStore; Category/Tag catalogs use TaskStore; Calendar-link identity uses ExternalCalendarLinkStore. No duplicate storage or restore engine was added.
- Notes and Notebook checklists are canonical Task records; backup paths load the full TaskStore rather than a filtered Home projection.
- Portable settings currently include AppSettingsService values, backup schedule and Daily Content preferences. Device-bound folder/provider URIs, secrets and transient encryption passphrases are not portable settings.
- Catalog merge remains additive and backward-compatible; formatVersion remains 1 and older backups may omit optional catalog/settings fields.

## Taxonomy audit findings (partial)
- `lib/models/task.dart`: `Task.category` and `Task.tags` are separate.
- `lib/models/goal_project.dart`: Project membership stores canonical Task IDs in `itemIds`; this model does not declare a Category relation.
- `lib/home/grouping/home_grouping_service.dart`: `HomeGroup<Task>` is a presentation grouping abstraction, not proof of a fourth domain entity.
- `lib/services/task_store.dart`: canonical Category catalog uses SQL `taxonomy_categories`; canonical Tag catalog uses SQL `tags`.
- `lib/services/tag_store.dart` defines legacy SharedPreferences key `arvin.tags`, but current search found no caller; migration derives SQL Tag rows from `Task.tags`, not `arvin.tags`. Keep this as a low-confidence legacy candidate and do not delete/migrate it without evidence it was populated by a shipped path.
- Source review confirmed the original backup gap for unused standalone Category/Tag catalog entries. The existing PR now serializes these catalog values and merges them additively with regression coverage. Exact-head tests are still pending.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy. Do not mass-replace “group”; classify domain, user-facing, presentation, generic technical and historical uses first.

## In progress
1. Complete exact-head Build for PR #2585: Analyze, all six test shards, Debug APK and Release APK.
2. Complete exact-head Android Device Smoke; inspect any failing shard/job and repair safely before claiming success.
3. Verify backup/restore round-trip with legacy v1 backups, unused + assigned catalogs, settings, notes/checklists, stable-ID reconciliation and late-stage rollback.
4. Complete physical Android system file-picker/provider and before/after data-integrity acceptance; emulator smoke is not a substitute.
5. Continue the repository-wide Project/Category/Tag audit and keep PR #2585 and #2587 open until physical acceptance is evidenced.

## Blocked / unproven
- Exact-head Release APK and Device Smoke for `5f59d7c7edb12217a2aa3f7a139a042676dc0e76` are still running/queued at the latest live check.
- Physical Android file-picker/provider backup and restore, failed-restore recovery and real data-integrity acceptance.
- Physical-device Calendar same-ID edit/no-duplicate behavior, action visibility, recurrence/checklist acceptance.
- Full Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- Full taxonomy conformance inventory and final release handover/owner acceptance.

## Next actions
- Poll exact-head Actions for `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`; use only evidence attached to that exact head. If Release APK and Device Smoke settle, refresh this checkpoint and the evidence map.
- If any job fails, inspect its log, fix the root cause in the same PR, and rerun validation on the new head.
- Update the evidence map after Build/Smoke settles, then continue physical-device acceptance and remaining taxonomy audit.
- Keep PRs open/unmerged; never claim release readiness from CI alone.

## Risk rules
Task remains the source of truth for Tasks and Notebook items; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Never claim user/device acceptance without direct evidence.

## LIVE CONTINUATION CHECKPOINT — 2026-10-11 (Command v8 + RTLC)

This section supersedes earlier next-action text where it conflicts. Do not restart analysis; continue from this checkpoint after a live recheck.

### Latest verified repository state
- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Latest main commit returned by GitHub commit search: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` (`fix(backup): preserve portable user data with safe restore`). The preceding mainline commit found was `c57606c223a1d6141bd3d11e1a75cc5cda428470` for Calendar collapsed-card actions/recurrence.
- GitHub Read/Write access is active. This update is restricted to the existing documentation branch for PR #2600; no direct main write is intended.
- Memory files are not present at the corresponding paths on main yet; the current memory branch is `docs/arvin-autonomous-memory-20261011`, PR #2600 OPEN/DRAFT, head `b285719410d380aa1f5d0df7c625493c243a3b12`, base SHA `72a2f4cc24df7a38eff9856ce403461615db5280`. This stale base must be reconciled before merge.
- Overlapping documentation PRs #2598/#2599/#2600 must be consolidated/reconciled before merge; do not merge stale documentation blindly.

### Latest completed step
- Read the owner-provided Autonomous Delivery & Evolution Command v8.
- Located the existing persistent-memory branch/PR rather than creating a parallel memory system.
- Registered the accepted Repeat Tracking Level Contract as [Decision Issue #2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), and recorded the decision against existing repeat work #2254 and Task editor work #2593.
- Read-only source audit confirmed that `RecurrenceTrackingLevel { normal, tracking }` already exists in `lib/models/recurrence.dart`, persists within the existing `Task.recurrence` JSON, and defaults to normal for older JSON. `Task` already carries `occurrenceHistory` and `checklistOccurrences`; recurrence repository/page and tests cover some tracking/progress behavior. Do not rebuild these.
- Source search did not find direct tracking-level integration in `lib/task_editor_dialog.dart`, `lib/report_center_page.dart` or Home. This is an integration audit target, not proof that no indirect path exists.
- Explicitly preserve the distinction between Follow-up and Repeat tracking: `followUpEnabled` must not be used as a substitute for `recurrence.trackingLevel`.
- Audit comments were recorded on #2605 and #2254. No application code, schema, database, engine or APK changed in this step; no tests/build/device validation were run for RTLC.

### Current completed / in progress / blocked
- COMPLETED: RTLC product decision registration; first-pass source audit; existing model and persistence support identified.
- IN PROGRESS: update this memory PR with the latest continuation checkpoint and RTLC decision/knowledge/problem/evidence records.
- BLOCKED / NOT VERIFIED: tracking-level integration in full Task Create/Edit, Home cue, Report Center filter and validated missed/remaining/upcoming metrics; full occurrence-history/checklist immutability tests; RTLC backup/restore round-trip; screenshots and physical-device acceptance.
- RELEASE BLOCKED: exact-current-main CI/device evidence and physical-device/owner acceptance remain required. Main-head status lookup is not sufficient to claim a pass.

### Next action — ordered
1. Read back and verify the memory-branch documentation commits and comment on PR #2600 about stale base/documentation hierarchy.
2. Inspect current PR #2591/#2595/#2602 heads and overlap; do not launch conflicting edits or merge failing/stale branches.
3. Continue RTLC with focused integration of the existing `recurrence.trackingLevel` into Task Create/Edit after Repeat, defaulting to «عادی». Keep Follow-up separate. Add/adjust tests for selection and JSON round-trip before widening to Home and Report Center.
4. Derive missed/remaining/upcoming metrics from canonical repeat/history projections; if definitions or model semantics are insufficient, document the exact gap before any protected model/engine/storage change.
5. Validate exact-head tests/build, backup/restore compatibility, screenshots and device behavior. Do not claim done until evidence and owner acceptance exist.

### Current bottleneck
Product acceptance and proof on the current exact head—not another parallel architecture or factory. Keep Task as source of truth, Repeat as Task behavior, occurrence checklist state independent, past history immutable and future settings adjustable.

## Fresh CI checkpoint — PR #2602 exact head (2026-10-11)
- Checked workflow run [#38139809938](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809938) for PR #2602 head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`: Debug and Release APK jobs passed, but overall Build failed because three quality test shards failed. Device Smoke [#38139809930](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809930) was skipped.
- Confirmed failures: repeat lifecycle control key missing; recurrence RollBox key missing; automatic/manual reminder tests failed; date-only All-Day persistence failed; custom due-time Clock Dial test failed; RTL taxonomy row width expected >270 px but actual 99.33 px.
- Recorded exact evidence in PR #2602 comment [#6109904220](https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6109904220). Do not merge or weaken tests; fix reachability/date-time/layout root causes and rerun all shards + Device Smoke.



## OWNER DECISION UPDATE — 2026-10-11

### Completed: Task Description vs Note decision
- Owner selected **Option 1**: retain only the existing root Task `description`; do not add a separate root `Task.note`.
- This supersedes the earlier “Blocked: ask owner” next-action text in historical checkpoints. The product decision is resolved; implementation cleanup and validation remain outstanding.
- Required follow-through: comment on #2595 and #2602; remove/revert root `Task.note` plus serialization/TaskStore/backup changes that exist only to support it; preserve existing Notebook/FollowUp note behavior; run exact-head tests/build and inspect backup/restore compatibility. Do not weaken tests or merge/release without evidence.
- GitHub Read/Write access used for recording this decision. App code has not yet been changed by this decision-recording step.

## OWNER DECISION — 2026-10-11 (supersedes earlier decision gate)
- Owner selected Option 1: keep the existing root `Task.description` as the only root Task text field; do not add a root `Task.note`.
- This resolves the prior owner-decision gate. Scoped `FollowUp.note` and Notebook note/checklist concepts remain unchanged; this decision does not authorize deleting or migrating those scoped fields.
- Required implementation on the canonical Task-form lane: remove only the newly introduced root `Task.note` from the Task model, JSON serialization/deserialization, TaskStore known-key handling, editor UI/state, and backup/restore test changes. Preserve legacy payload safety and existing Description values; add/retain regression tests proving legacy JSON and backup/restore round-trip still work without a second root field.
- PR #2595 must remain Draft until this correction and exact-head Analyze, all test shards, Debug/Release APK and relevant device smoke are verified. PR #2602 must not reintroduce the root field and its previously failing test shards must be fixed at root cause; never weaken assertions.
- Current execution result: decision resolved and documented; implementation patch not yet applied or validated in this step. No merge, main write, APK build, or release occurred.


## LIVE CONTINUATION — 2026-10-11, root Task text field correction
- Owner decision: root `Task.description` only; no root `Task.note`. This supersedes the earlier decision gate.
- Applied a focused correction to the existing PR #2595 branch `feat/task-form-simple-first-20261011`: removed the root field from `Task` construction/model JSON, removed Task Editor's duplicate note controller/input, removed the TaskStore root known-key addition, updated backup/restore and TaskStore contract tests, and added a regression test that a legacy root `note` key is ignored while `description` is preserved. FollowUp.note and nested FollowUp persistence were retained.
- Latest branch head observed: `cc8180575bb50087283c43a444d54af05de9bc81`. GitHub workflow runs associated with this exact head were queued at last check (ARVIN Orchestrator PR Wakeup, ARVIN Production Loop, ARVIN Orchestrator). Therefore code is changed, but Analyze/tests/build/device validation are **PENDING**, not passed.
- Read-back checks: Task class has no root note field; Task Editor has no note controller or root note input; Task contract regression test is present; TaskStore known Task keys no longer add root note. No merge, main write, APK build, or release occurred.
- Next action: inspect workflow/job status for exact head `cc8180575bb50087283c43a444d54af05de9bc81`; fix any real failures without weakening assertions. Recheck PR #2602 for the same forbidden root field and resolve its previously failing shards separately. Keep #2595/#2602 Draft until evidence passes.


## Validation read-back correction — 2026-10-11
- Exact latest code head remains `cc8180575bb50087283c43a444d54af05de9bc81` for the Task Description-only correction.
- Associated runs `38150519178` (PR Wakeup), `38150519183` (Production Loop), and `38150519223` (Orchestrator) completed successfully, but they are orchestration jobs only. Combined commit status returned no statuses. This is **not** Analyze/test/build evidence; product validation remains pending.
- Read-only inspection of current `main/lib/notebook_page.dart` confirms Notebook notes are handled through the Notebook repository/editor and `description`; that code was not changed. `FollowUp.note` remains in its own nested model and storage.
- PR #2595 progress comment posted: https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110488803.



## OWNER FIELD REPORT — 2026-10-11: recurrence and calendar edit sync
- Owner reported: repeating Tasks are not generating the expected 7 occurrences; when recurrence is enabled, today's local date and current local time must be filled automatically but remain editable; automatic Calendar sync still fails after Task edits.
- Reused existing contracts/issues #2535 (P0 recurrence/calendar acceptance), #2254 (recurrence lifecycle/count architecture), and #2248 (Task↔Event identity/auto-sync architecture gate). No parallel Task, occurrence store, or Calendar engine is authorized.
- Safe editor implementation started in Draft PR #2606, branch `fix/repeat-seven-default-date-time-20261011`: selecting a repeat frequency fills current local date/time when missing, leaves the date/time form controls editable, keeps automatic reminder aligned, defaults occurrence count to 7, and allows count edits. Added widget regression coverage. Latest commit after assertion correction: `323b5a6afddd7977450ead87467e5d9dac206b04`.
- Validation status: CI for an earlier head was still running when checked; that evidence does not validate latest head. Need exact-head analyze/test shards/Debug+Release APK. Device Smoke was skipped on earlier run. No merge or main write.
- Calendar root cause evidence from current main: recurrence projection only enumerates occurrences when both `visibleFrom` and `visibleTo` are provided, but normal outbound sync calls `calendarProjection.project(snapshot)` without a range. Additionally recurrence event IDs include the scheduled timestamp; after date/time edit the ID changes, while the edit-only path uses `linkedOnly: true`, so it can fail to match the prior external link. These are recorded against #2248; identity changes are blocked pending the independent architecture review. Do not claim Calendar sync fixed.
- Next: validate PR #2606 exact head; then resolve #2248 identity contract safely (stable per-occurrence identity, past occurrence immutability, target calendar move/no duplicate, and failure diagnostics) before code changes.

## LIVE CONTINUATION CHECKPOINT — 2026-10-11 (Command v8 execution)

### Latest completed step
- Re-read this state file from the existing memory branch before acting. The file is not yet on main; PR #2600 remains the delivery path for memory docs and must be reconciled with overlapping docs PRs before merge.
- Refreshed PR #2606 exact-head CI for `323b5a6afddd7977450ead87467e5d9dac206b04`: Build run [38151948139](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38151948139) passed Analyze, all six test shards, Debug APK and Release APK. Device Smoke [38151948178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38151948178) was skipped. This is automated validation for repeat-editor defaults, not device/calendar-provider acceptance; PR #2606 stays Draft.
- Owner decision confirmed: root Task has `description` only; no root `Task.note`. Scoped FollowUp/Notebook note semantics remain unchanged. Refresh actual PR heads before relying on prior snapshots.
- Recorded latest owner contracts in existing owners: Calendar sync field scope and Done/Archive boundary [#2248](https://github.com/mobinpda-lab/Arvin-clean/pull/2248#issuecomment-6111402411); existing Reports icon only needs bottom-nav placement [#2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385#issuecomment-6111105369); Notebook toolbar/checklist defects [#850](https://github.com/mobinpda-lab/Arvin-clean/issues/850#issuecomment-6111078741) and [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111079224).
- Calendar sync scope: title, date, time, description, recurrence details and reminder only. Marking Done or moving to Archive alone must not trigger calendar sync. Preserve Task↔external event identity; never match by title/date or create duplicates.
- Report Center correction: move/reuse the existing Reports icon in bottom navigation and route to the existing Report Center; no new icon/engine/page.
- Notebook defect remains pending: RTL toolbar labels must be fully visible; checklist must be a real compact interactive checkbox, not literal `[ ]`; tapping toggles and state persists via canonical Task.checklist/Notebook storage.
- No main-branch write, merge, APK handover, physical-device validation or release occurred in this continuation step.

### Current status / next action
- **Completed:** GitHub Read/Write used; exact-head #2606 automated CI checked; latest owner contracts recorded on existing GitHub owners.
- **In Progress:** #2606 awaits Android/provider regression; Task form PRs #2591/#2595/#2602 overlap and require live head/diff reconciliation; Notebook fix and bottom-nav Reports placement require code changes and evidence.
- **Blocked:** Physical-device acceptance, full Calendar provider/two-way/no-duplicate acceptance, restore/file-provider round-trip, Golden Flow and explicit release-owner approval remain unproven.
- **Next action:** Refresh live heads/statuses. Continue canonical branches; prioritize data/calendar correctness and exact-head evidence, fix Notebook rendering/toggle in its existing path, and move the existing Report Center entry to bottom navigation without a second report path. Keep CI evidence distinct from device/owner acceptance.

## 2026-10-11 — Pastel visual language expansion

- Owner requested extending the Home/Calendar pastel look across all Arvin sections, explicitly including Notebook and Reports.
- Extended existing PR [#2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607) instead of creating a parallel branch/system. New title: `feat(ui): extend pastel visual language across Arvin`.
- Current PR head at checkpoint: `f526389e2058263af308f714bce49d7c4033000f`.
- Changes on the PR branch: shared light/dark CardTheme with rounded borders/subtle shadows/compact vertical spacing; rounded filled light/dark form fields; Notebook note cards lavender and checklist cards soft green; Report Center cards green when complete, red when overdue, amber for follow-up and blue for planned; Next Action cards red/blue/amber by reason. Calendar/Home visual refinements remain in the same PR.
- Regression coverage added for report status colors, Notebook note/checklist colors and Next Action status colors. Existing Task/Notebook storage paths are retained.
- GitHub Read/Write used. PR metadata updated; owner scope/guardrails added to the existing acceptance ledger [#1139 comment](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111556987).
- Exact-head CI for `f526389e2058263af308f714bce49d7c4033000f`: Build run [38158589426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589426) was pending/queued at last check; Device Smoke [38158589424](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589424) was skipped. Orchestrator success is not code/test/build proof.
- PR #2607 remains Draft and unmerged. No physical-device screenshot/visual acceptance is available. The separate Notebook inline checklist `[ ]` toggle bug is NOT fixed by this visual pass and remains open.

### Next action
- Refresh exact-head CI. Fix any Analyze/test/build failures without weakening tests. Review all affected screens at narrow phone widths and RTL, then request owner/device acceptance. Keep the PR Draft until evidence and owner acceptance are complete.

## 2026-10-11 — Pastel UI validation follow-up
- First exact-head Analyze on `f526389e2058263af308f714bce49d7c4033000f` failed because the new Notebook pastel-card test was placed before local helpers `repositoryAt` and `pumpNotebook` (Analyze run [38158589426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589426), job 114526628385).
- Corrected the test placement in commit `571e5ed7c6751bcf56ba042a02ed6081e7023b0f` so helper declarations precede the test. This is a test-order fix, not a weakening of assertions.
- Latest PR head refreshed via GitHub: `571e5ed7c6751bcf56ba042a02ed6081e7023b0f`. New Build run [38158724999](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158724999) is running; exact-head Analyze/tests/APK results are not yet final. Device Smoke [38158725094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158725094) skipped.
- Keep PR #2607 Draft. Next: inspect the new Analyze/test/build conclusions, repair root causes if needed, and only then arrange installed Android visual review.

## Report filter extension — 2026-10-11
- Owner reported the Report Center date filter still showed the Gregorian calendar and requested a compact, pastel, multi-select filter experience.
- Product implementation is in progress on PR #2607 / branch feat/calendar-pastel-compact-cards-20261011: switched report date selection to the existing Jalali picker; converted filter sections to expandable roll boxes; added multi-select status and Tracking filters; added canonical Notebook title/description, kind and created/updated date filtering; added regression tests.
- GitHub Read/Write: read current branch sources and memory docs; wrote application/test changes on the feature branch and appended the decision to Decision Log, Project Knowledge and User Experience Log on docs/arvin-autonomous-memory-20261011. No merge to main.
- Validation status: not yet verified for this exact head. Run Analyze, focused and full tests, Debug/Release APK, then Android small-screen RTL visual checks. Device Smoke and owner acceptance remain required.
- Explicit boundaries: no separate Note-to-Task relation exists in the current canonical model; external phone-calendar-only events are not confirmed Report Center inputs. Do not claim either capability.


## LIVE CONTINUATION CHECKPOINT — 2026-10-11 18:06 UTC / PR #2607

- Re-read the current execution checkpoint before continuing. Audited PR #2607 exact head and workflow failures for Report Center filter tests.
- Current application PR: #2607 remains OPEN/DRAFT, head `9ae99714e3cc36fe73814b1c0af0c3611adff2d4`, based on current main `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- Exact failure evidence from previous run #38161588760: shard 2 failed because `report-filter-apply` was absent at test line 111 after prior interactions; shard 4 showed the category header's tap offset hit the modal barrier at test line 173, then `Bad state: No element` at line 180.
- Safe test-only correction committed to the PR branch: replace `ensureVisible` with `scrollUntilVisible` using the filter sheet ListView, and scroll the Apply button into view before tapping. Commit: https://github.com/mobinpda-lab/Arvin-clean/commit/9ae99714e3cc36fe73814b1c0af0c3611adff2d4.
- Exact-head Build workflow `38162419144` is QUEUED at checkpoint time: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144. No pass/fail result exists yet. Do not treat this as validated.
- Correction to prior note: Report Center `_pickTime` already uses `showUniversalArvinTimePicker`, and the test checks `universal-time-selected-value`. The earlier claim that the generic Flutter time picker remained in Report Center was stale and has been corrected in the existing PR comment.
- Completed this step: root failure evidence extracted; test-only correction committed; PR comment updated; memory checkpoint being recorded.
- In progress: exact-head CI result, especially shards 2 and 4; if still failing, inspect fresh logs and fix the actual UI/test root cause without weakening assertions.
- Blocked: merge/release acceptance until exact-head Analyze, all test shards, Debug/Release builds, Device Smoke, small-screen Android RTL visual validation, and owner acceptance are complete. No APK/device evidence has been produced by this step.
- GitHub Read/Write access verified. No write to `main`, no merge, no release, and no claim of successful validation.

### Next action
1. Poll workflow run #38162419144 and inspect all test shard conclusions.
2. If tests pass, review complete workflow result and confirm Device Smoke status; do not confuse skipped smoke with device acceptance.
3. If either test still fails, extract the new exact stack trace and diagnose before editing again.
4. Update the problem register and evidence map only with this commit and confirmed CI results; keep PR #2607 Draft until the complete acceptance gate passes.


## CONTINUATION — Report filter test fix follow-up — 2026-10-11

- Re-read the execution state and refreshed PR #2607 / exact-head CI before acting. GitHub Read/Write access verified.
- New exact-head result for prior test correction commit `9ae99714e3cc36fe73814b1c0af0c3611adff2d4`: [Build run #38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144) FAILED. Analyze, Debug APK, Release APK and test shards 0, 1, 3, 5 passed; test shards 2 and 4 failed; Device Smoke run #38162419065 was skipped.
- Extracted fresh logs for both failed shards. The failure was caused by the test helper argument, not the product widget: `scrollUntilVisible` requires a `Scrollable` finder but the previous test-only fix passed `find.byType(ListView)`, yielding `type 'ListView' is not a subtype of type 'Scrollable'` at test lines 104 and 178.
- Safe follow-up correction committed to the same PR branch: replace all five scrollable targets in `test/report_center_page_test.dart` with `find.byType(Scrollable).last`. Commit: [45caa5a3](https://github.com/mobinpda-lab/Arvin-clean/commit/45caa5a3d7c7b3b29264f0197d6affd2b1798df5). No production code or data contract changed.
- New exact-head Actions batch: [Arvin Build #38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995), [Device Smoke #38163195983](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195983), plus orchestrator/parallel automation. At checkpoint, Build and several automation runs were queued; Device Smoke was in progress. No validation result for commit `45caa5a...` yet.
- Completed: failure root cause precisely identified and corrected; new CI batch observed; no test assertions weakened.
- In progress: verify exact-head test shards and build results; inspect Device Smoke after it completes.
- Blocked: PR #2607 must remain Draft until exact-head Analyze, all test shards, Debug/Release builds, Device Smoke and owner/physical-device UX acceptance are all confirmed. No merge, release, APK handover or physical-device validation claim.

### Next action
Poll run #38163195995 and #38163195983. If tests still fail, inspect fresh logs before another edit. If all automated checks pass, review smoke artifacts/results and then request the owner to verify Persian RTL, compact filter layout, date/time and selected-filter retention on a real small-screen Android device.


## CI status refresh — 2026-10-11

- After the previous checkpoint, refreshed exact-head run states for commit `45caa5a3d7c7b3b29264f0197d6affd2b1798df5`.
- Build run [#38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995) remains IN_PROGRESS; all six test shards plus Analyze and Debug/Release APK jobs are still running at this refresh. No test/build conclusion is available yet.
- Device Smoke run [#38163195983](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195983) concluded SKIPPED, not passed. Physical-device visual acceptance remains unverified.
- The orchestration/parallel/production-loop/G1-lock-sync runs completed successfully; these do not substitute for Build tests or Device Smoke.
- Current state remains BLOCKED on exact-head Build and Device Smoke/owner validation. PR #2607 remains Draft. Next action: poll Build #38163195995, inspect shards 2 and 4 especially, and determine why Device Smoke is skipped before release decisions.


## CONTINUATION — Device Smoke skip root cause — 2026-10-11

- GitHub Read/Write access verified. Re-read the latest execution checkpoint before continuing.
- Exact-head Build run [#38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995), commit `45caa5a3d7c7b3b29264f0197d6affd2b1798df5`, is still IN_PROGRESS. Analyze has succeeded; all six test shards and Debug/Release APK jobs are still running. No final build/test result is available yet.
- Investigated Device Smoke skip instead of treating it as a pass. Workflow `.github/workflows/device-smoke.yml` defines job condition `github.event_name != 'pull_request' || github.event.pull_request.draft == false`. Because PR #2607 remains Draft, the PR-triggered Device Smoke job is intentionally skipped. This is workflow gating, not evidence that the smoke tests passed or failed.
- PR #2607 remains OPEN/DRAFT. Do not change Draft status automatically because that is a review/owner-facing product workflow decision. No merge or release.
- Completed: identified the exact reason Device Smoke was skipped; confirmed Analyze success and current unresolved test/build jobs.
- Blocked: full automated acceptance pending; Device Smoke evidence unavailable for this draft PR; physical-device/owner visual acceptance not completed.
- Next action: poll Build #38163195995 until terminal. If all jobs pass, obtain Device Smoke evidence through an authorized non-draft/manual run path without implying physical-device acceptance; if any job fails, inspect that exact job's logs before changing code. Keep PR Draft until acceptance criteria are met.


## CONTINUATION — Report filter regression follow-up — 2026-10-11

- GitHub Read/Write verified; continued from the last checkpoint and checked live PR #2607, exact-head Build jobs, recent workflow runs and the report-filter test source.
- Exact-head run [#38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995) advanced: Analyze and test shards 0, 1, 2, 3 and 5 passed; test shard 4 failed. The failure is in `test/report_center_page_test.dart`, test “report filter sections collapse and expand without losing selections”: after scrolling to the selected category chip, the test taps the section header while it is outside the bottom-sheet viewport (hit test lands on the modal barrier). This is a test interaction/scroll-position issue; no evidence yet indicates a production filter logic defect.
- Applied a focused test-only correction in commit [`c2a1b2ff`](https://github.com/mobinpda-lab/Arvin-clean/commit/c2a1b2ff57465e0e0b393b1e6d28fa010dadc439): re-find the Category section header and call `tester.ensureVisible` before collapsing and reopening it. No production code, Task model, persistence, or data contract changed.
- Fresh exact-head Build run [#38163500776](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163500776) is PENDING for head `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439`; no pass/fail result yet. Device Smoke [#38163500919](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163500919) is SKIPPED because PR #2607 is Draft and the workflow condition excludes Draft PRs.
- Release closure run [#38163384915](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163384915) failed by design at its release gate: issue #2102 remains open, and PR #1901 remains open. This is a release-blocking condition, not a build failure; no issue/PR was closed automatically.
- Completed: diagnosed the latest shard-4 failure from the exact job log, applied a narrow test-only fix, and recorded why Device Smoke is skipped.
- In progress: validate the new exact-head Build run.
- Blocked: PR #2607 remains Draft; Device Smoke/physical-device and owner UX validation are outstanding; release gate #2102 and P0/P1 regression lane #1901 are still open.
- Next action: inspect run #38163500776 after completion. If any tests fail, read that job's fresh logs before changing anything. Do not merge or release based on orchestration success.


### Release containment verification — 2026-10-11

- Verified repository releases after Release Closure #38163384915 ran. Two Arvin prerelease records (`v0.1.0-arvin-dd95132` and `v0.1.0-arvin-33ed363`) are now Draft prereleases; their tags/assets were preserved. The workflow appended an explicit “UNAPPROVED — NOT A RELEASE CANDIDATE” notice while issue #2102 remains open. This is reversible containment, not a release approval.
- Exact-head Build #38163500776 remains IN_PROGRESS at latest poll; no terminal result is available. Device Smoke #38163500919 remains SKIPPED due to the PR Draft condition.
- Keep publication blocked until issue #2102 is closed after evidence and owner acceptance, and P0/P1 regression PR #1901 is resolved. Do not publish or close these gates automatically.


### Poll checkpoint — 2026-10-11 18:24 UTC

- Re-read this execution state and rechecked live PR #2607, exact-head Build #38163500776, Device Smoke #38163500919, release gate issue #2102, and regression PR #1901.
- Build #38163500776 is still IN_PROGRESS on commit `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439`. Analyze is SUCCESS; Debug/Release APK and test shards 0–5 remain IN_PROGRESS. A log request for running shard 4 returned NOT_FOUND, so no new test outcome can be inferred.
- Device Smoke #38163500919 is SKIPPED due to Draft PR gating. The available GitHub tool set has no workflow-dispatch action, so I did not claim to launch a manual smoke run. Do not mark this as passed.
- Issue #2102 and PR #1901 remain OPEN. Main is still `a6ced27660d34cd87dd8915aff68d3a7555fd57a`; no release/merge or owner-facing PR state change performed.
- Next action remains: poll the exact-head Build run for terminal results; inspect fresh failed-job logs once available. Device Smoke requires an authorized non-Draft/manual path; physical-device and owner acceptance remain outstanding.


### Exact-head test diagnosis and follow-up — 2026-10-11 18:26 UTC

- Build #38163500776 on `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439` progressed far enough to expose a fresh shard-4 failure in `test/report_center_page_test.dart`, test `report filter sections collapse and expand without losing selections`. The log reports 181 tests passed and 1 failed.
- Root cause is now concrete: after collapsing the filter section, the test immediately called `tester.widget<FilterChip>(categoryChip)` at line 206. The collapsed `ExpansionTile` unmounts its child subtree, so the finder has no mounted element (`Bad state: No element`). This is a test assertion/lifecycle assumption, not evidence of a production report-filter failure.
- Applied a narrow test-only correction: remove the invalid assertion while collapsed and verify the selected chip after reopening, when it is mounted again. No production source, Task model, storage, or architecture changed.
- Commit: [`7526dc186a26d099368fb288fdc7891ed57222ce`](https://github.com/mobinpda-lab/Arvin-clean/commit/7526dc186a26d099368fb288fdc7891ed57222ce).
- Exact-head Build run #38163761104 is PENDING for the new commit. Device Smoke #38163760935 is SKIPPED because PR #2607 remains Draft. This correction is not validated until the new run reaches terminal success.
- PR #2607 remains OPEN/Draft. Release gate issue #2102 and regression PR #1901 remain open; no merge, release, or Draft-state change was made.
- Next action: inspect exact-head Build #38163761104 and its shard-4 result; if it fails, read the new log before making any further change. Device Smoke, physical-device checks, and owner acceptance remain required.


### Continuation poll — 2026-10-11 18:27 UTC

- Re-read execution state and polled exact-head Build #38163761104 for commit `7526dc186a26d099368fb288fdc7891ed57222ce`.
- Current state: Build IN_PROGRESS; `quality (analyze)` SUCCESS; test shards 0–5 and Debug/Release APK jobs still IN_PROGRESS. No terminal conclusion is available yet.
- PR #2607 is still OPEN/Draft at the expected head. Issue #2102 and regression PR #1901 remain OPEN. Main remains `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- No new code change made during this poll because there is no new failure evidence. Device Smoke remains skipped under Draft gating; physical-device validation and owner acceptance remain outstanding.
- Next action: continue polling this exact run and inspect logs only after a job reports failure.


### Continuation checkpoint — report-filter implementation rechecked (2026-10-11 18:28 UTC)

- Re-read this state and re-inspected PR #2607 branch source and tests to avoid repeating the prior diagnosis.
- Confirmed production file is `lib/report_center_page.dart` (not a nested `lib/features/reports/... ` path). The report time selector calls `showUniversalArvinTimePicker`; filter sections are implemented with `ExpansionTile`; tests assert the Jalali picker opens and Flutter's Gregorian `CalendarDatePicker` does not appear, and assert the shared Persian-digit time picker is used.
- Exact-head Build #38163761104 remains IN_PROGRESS in the available run response; Analyze is SUCCESS, other test shards and Debug/Release APK jobs are still marked IN_PROGRESS. Attempt to fetch running shard-4 logs returned NOT_FOUND, so no further conclusion can be drawn from that request.
- PR #2607 remains OPEN/Draft. Device Smoke is skipped due to Draft gate. Release issue #2102 and P0/P1 device-regression PR #1901 remain open.
- No additional code change was made without a fresh failing result. Next action: poll exact-head run #38163761104 again; once a job completes, inspect its result/log before any further change. Device/RTL small-screen validation and owner acceptance remain outstanding.


### Repository-wide audit checkpoint — 2026-10-11 18:35 UTC
- Current main SHA checked: a6ced27660d34cd87dd8915aff68d3a7555fd57a. GitHub Read/Write verified. This checkpoint records findings on the existing memory PR branch only; no app code or main changes.
- Inventory: 740 main-tree paths, 190 docs, 249 test/integration-test files, 21 workflows, 1,248 branches, 19 open PRs, 1,096 open Issues; 876 open AUTO-FIX search results, 16 priority:core, 4 factory:blocked and 3 release-labelled issues.
- Current main SHA Actions query reached 1,535 workflow runs, dominated by repeated Release Closure / Final Head Release Validation orchestration events. Recent release closures repeatedly fail/cancel; current run #38164393875 failed and Final Head Release Validation #38164416537 was skipped.
- PR #2607 exact head 7526dc186a26d099368fb288fdc7891ed57222ce Build #38163761104 is SUCCESS across Analyze, six test shards, Debug and Release APK. Device Smoke #38163760935 is SKIPPED because PR remains Draft. Do not claim device acceptance.
- Confirmed on main: lib/report_center_page.dart still uses showDatePicker and showTimePicker. Persian/Jalali date and shared Persian-digit time picker exist only on the unmerged #2607/#2591 work.
- Current release blockers: Issue #2102 open; PR #1901 open; owner acceptance ledger #1139 still has unchecked phone/tablet acceptance. Two prereleases remain Draft/unapproved.
- Main docs drift: ARVIN_STATUS references PR #135/v49.0 while the current operating package is v49.1; scorecards use August baselines; the v49.1 package references AMPOP v5 which is not on main (introduced by unmerged #2598). The owner Command v8 is now preserved in this branch as ARVIN_AUTONOMOUS_DELIVERY_EVOLUTION_COMMAND_V8.md.
- Documentation branches #2598/#2599/#2600/#2601 share old merge base 72a2f4cc24df7a38eff9856ce403461615db5280 and are behind current main; #2598 and #2599 both change docs/ARVIN_STATUS.md. PR #2600 contains 13 memory files after this audit (11 pre-audit files plus the exact Command v8 and repository-wide audit records); memory is not yet on main.
- Task Note: Issue #2593/PR #2594 accepts optional Task Note distinct from Description, but current PR #2595 source does not expose a root Task.note field or editor input even though its PR body claims it is implemented. Treat this as a contract/implementation mismatch and correct the PR description after verifying the final intended implementation.
- SQL migration: main TaskStore uses SQL/Drift and a one-time legacy SharedPreferences migration path. Issue #1324 remains open with September evidence; revalidate current main instead of relying on old issue text.
- Next: (1) reconcile existing release-loop fix PR #2531 against current main; (2) consolidate/rebase documentation PRs and memory; (3) coordinate #2591/#2607 and #2593/#2594/#2595/#2602; (4) refresh exact-main evidence and owner acceptance; (5) continue historical issue/branch/commit passes. This is an initial deep-audit checkpoint, not a claim that every old commit and all 1,096 issues were individually read.


## Deep audit continuation — live workflow-loop evidence (2026-10-11 18:43 UTC)
- Re-read this state first. Live main is still `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. GitHub Read/Write access confirmed.
- Rechecked current main workflow definitions and current exact-main runs. In a short interval around 18:38–18:42 UTC, main received repeated `Arvin Production Orchestrator`, `ARVIN Production Loop`, and `Factory REST Promotion Bridge` runs; several release-closure runs were cancelled/skipped/failing, and Final Head Release Validation was repeatedly skipped. This is active orchestration churn, not proof of product progress.
- Current main `.github/workflows/release-closure.yml` still has `cancel-in-progress: true` and triggers after every completed `Arvin Production Orchestrator`; its job runs on any successful orchestrator completion. Non-draft PR #2531 already proposes `cancel-in-progress: false` plus restricting the workflow_run source to a successful `workflow_dispatch` orchestrator run. The patch is narrowly scoped and matches the observed trigger-isolation problem, but must not be treated as integrated until its exact-head tests/build and review gates pass.
- Main `.github/workflows/production-orchestrator.yml` is triggered by Parallel Wave, Build, Device Smoke and a five-minute schedule; it also dispatches the production loop on failed gates and can dispatch itself after successful merge. Main `factory-rest-promotion-bridge.yml` also runs on schedule and on Parallel Wave/Build/Device Smoke completion. Keep these distinct from the release closure gate; audit cross-trigger causality before changing more than one workflow.
- Release gate remains BLOCKED: Issue #2102 OPEN, PR #1901 OPEN, owner acceptance ledger #1139 OPEN with unchecked installed-device acceptance. The two available prereleases remain Draft/unapproved. No release, merge, issue closure, or app-code change was made in this checkpoint.
- Product acceptance reminders: #1139 includes Home + → Quick Entry directly, sequential one-task persistence, same draft identity into Full Form, tablet text contrast, and more installed-device requirements; #845 remains a durable missed-requirements checklist. #866 remains open for premature Recovery Wave auto-close; its comments show repeated AI provider HTTP 429 cooldown/retry events, which are infrastructure pressure rather than product-failure evidence. #1324 remains open for lossless SQL migration acceptance.
- Next: inspect exact checks/jobs on PR #2531 and current trigger-chain run graph; then consolidate memory/docs branches and continue targeted historical PR/Issue/commit audit. Do not mass-close AUTO-FIX issues or delete branches.


## Existing release-loop PR rebased onto exact current main — 2026-10-11 18:46 UTC
- Continued from the live audit; did not create a duplicate PR. Existing PR #2531 was 18 commits behind main, so its existing branch was rebuilt from current main while retaining only its original two-file scope.
- New head: `4505c759a8338e91c596d9b031d16d29080a339c`; current base: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`; comparison is now ahead 1 / behind 0 with only `.github/workflows/release-closure.yml` and `test/release_closure_product_gate_test.dart`.
- Change is narrowly limited to release trigger isolation and a matching regression assertion. PR conversation records the rebase and warns that exact-head CI is pending.
- At latest poll, 21 checks exist: 6 completed, 9 in progress, 6 queued; Build #38165128162 and Device Smoke #38165128170 are queued. No failures observed yet. Do not merge until exact-head Build and Device Smoke complete successfully and the PR's required checks are satisfied.
- No main change or release occurred. Keep issue #2102 and PR #1901 open until actual product/device acceptance is complete.


## Live continuation update — Report Center validation (2026-10-11)

- Re-read this execution state from the existing memory branch before continuing; no new memory branch or duplicate issue was created.
- Reviewed PR #2607 current reported head `0ef03757ee869a49f7d36cfcad05f2d09751a31c` and its Build run [38160581498](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38160581498).
- Exact-head Build evidence: Analyze succeeded; Debug APK and Release APK builds succeeded and artifacts were uploaded; test shards 0, 1, 3, and 4 succeeded; test shards 2 and 5 failed. Therefore Build is NOT green and PR #2607 remains unaccepted. Device Smoke was skipped because the PR is Draft; no device acceptance is implied.
- Retrieved failure log for shard 2: `test/report_center_page_test.dart`, test “Report Center combines time and category filters and opens that exact report scope” failed at line 107 with `Bad state: No element` from `WidgetController.ensureVisible`. This is likely a test/widget target mismatch after filter UI restructuring; inspect the exact widget tree and intended user path before changing the test. Do not weaken the assertion or treat the test as flaky without evidence.
- PR #2607 adds the Report Filter & Memory Extension: Jalali date-range picker, expandable roll-box filter sections, multi-select Project/Category/Tag/Status/Tracking, and canonical Task-backed Notebook note/checklist/date filters. The decision file was read back from the PR head. These changes are on a PR branch, not accepted on main.
- Remaining Report Center gate: resolve shard failures on the current head; re-run Analyze, all test shards and APKs on the resulting exact head; run Android Device Smoke and small-screen RTL visual acceptance; reconcile shared time picker with existing Draft PR #2591 rather than adding a second picker. Current `_pickTime` still uses Flutter `showTimePicker`, so Persian/Jalali date selection alone does not satisfy the universal Persian 24-hour time-picker requirement.
- Data/architecture boundary remains: Report Center consumes canonical Task/Notebook records; no separate report store or invented Note-to-Task relation. External phone-calendar-only events are not proven report inputs.
- Release gate #2102 remains OPEN/BLOCKED. No merge, publication, or Release Ready claim was made.

**Completed this continuation:** revalidated memory, fetched exact-head CI jobs/artifacts, inspected the failing shard log, and recorded the new evidence here. **Next action:** inspect `test/report_center_page_test.dart` around line 107 and the current Report Center filter widget on PR #2607; correct the actual target/behavior mismatch, then rerun the affected shard before full exact-head validation.


## Superseding live correction — Report Center test follow-up (2026-10-11)

This entry supersedes the immediately preceding Report Center next-action note where later branch commits had already moved beyond the inspected SHA.

- PR #2607 evolved after Build run #38160581498. Its earlier shard-2 failure was in `report_center_page_test.dart` line 107: fixed-offset drag scrolled past a lazily built category section, making `ensureVisible` fail with `Bad state: No element`. Subsequent test-only commits corrected the scroll strategy.
- Latest observed run before this update: [Build #38163500776](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163500776) on the then-current branch failed only quality test shard 4; Analyze and shards 0, 1, 2, 5 succeeded. Debug/Release APK jobs were cancelled when newer commits superseded that run. Device Smoke was not run because the PR is Draft.
- Shard-4 failure: test `report filter sections collapse and expand without losing selections`, line 206, `Bad state: No element`. Root cause in test interaction: after collapsing, the category section may be outside the lazy ListView's built range; calling `ensureVisible(categoryHeader)` cannot find it. Do not alter production behavior or weaken the persistence assertion to mask this.
- **Fix committed to the existing PR branch** `feat/calendar-pastel-compact-cards-20261011`: commit [8d3d60a1b321fa4ceb9f5da779a144d3705b9103](https://github.com/mobinpda-lab/Arvin-clean/commit/8d3d60a1b321fa4ceb9f5da779a144d3705b9103). The test now scrolls the category section back into the lazy ListView's viewport before reopening it, then retains the selection assertion. No production code, model, storage, or architecture was changed by this fix.
- Workflow lookup immediately after this commit returned no associated run/status yet; this is **missing validation**, not a pass. Re-check exact-head CI shortly. Required: Analyze, all test shards, Debug/Release APKs, Android Device Smoke, small-screen RTL visual review, and owner acceptance. Keep PR #2607 Draft and release blocked until these gates pass.
- **Correction to prior time-picker note:** the earlier claim that current PR #2607 still used generic Flutter `showTimePicker` was true for head `0ef03757ee869a49f7d36cfcad05f2d09751a31c` but became stale after later commits. PR comments confirm the current branch reuses `showUniversalArvinTimePicker` and includes a regression test. However, the shared picker source is also changed in PR #2607 and is byte-identical to the implementation in PR #2591; reconcile that overlapping path before merging so only one canonical implementation remains.

**Current status:** Report Center test-only fix committed; exact-head validation pending. **Next action:** query workflow runs for the new head; if no run appears, inspect the PR's current run state before considering any rerun. No merge, release, or acceptance claim.


## Exact-head validation restarted — Report Center (2026-10-11)

- After the test-only fix commit `8d3d60a1b321fa4ceb9f5da779a144d3705b9103`, the PR-triggered Build run [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) appeared for that exact commit.
- Live job snapshot: Analyze, all six test shards and Debug/Release APK jobs were in progress or queued at the time checked. No artifacts had been uploaded yet. This is **pending**, not a pass.
- Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) was skipped because PR #2607 remains Draft; that does not validate UI/device behavior.
- Continue monitoring this existing run; do not trigger duplicate CI. If the test shard 4 failure is resolved, wait for every remaining shard and both APK jobs to finish successfully on the same head. Then request/run Device Smoke and perform small-screen RTL/physical-device review. Shared time picker source overlap with PR #2591 still needs reconciliation before any merge.
- Release gate #2102 remains open; no merge, publish, or Release Ready claim.


## Exact-head validation result — Report Center (2026-10-11)

- Rechecked PR #2607 head commit `8d3d60a1b321fa4ceb9f5da779a144d3705b9103` and Build run [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767).
- **PASS on this exact head:** Analyze, all six quality test shards (0–5), Debug APK build, and Release APK build. Both APK artifacts were uploaded:
  - `arvin-debug-apk`, artifact ID `11712403085`, SHA-256 `78566ec458aed40fa36cc43d58c1cd3fd94bb8be18f501d0b8010942bdd8893b`.
  - `arvin-release-apk`, artifact ID `11712088044`, SHA-256 `ff8acc7c4a30e9178ca22d08eebc60b85b4789b4af9657740bd02069ca2de53c`.
- Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) remains `skipped` because PR #2607 is Draft. This is not a device acceptance pass; installed-device, small-screen Persian/RTL visual review, and owner acceptance remain outstanding.
- Current PR states rechecked: #2607 remains open/Draft; #2591 remains open/Draft. Release gate issue #2102 remains OPEN/BLOCKED.
- Compared shared file blob SHAs at exact PR heads. `lib/widgets/universal_arvin_time_picker.dart` is byte-identical on #2607 and #2591 (blob `caacc5539c5f2304a1a060f5e3610a25987a6619`). `lib/main.dart` and `lib/report_center_page.dart` differ because each PR carries additional integration changes. Reconcile these overlapping integration paths before merge; do not blindly merge either PR.
- No production-code change or merge was made in this continuation. The prior test-only fix remains validated by the passing exact-head CI above.
- **Next action:** use the successful APK artifacts for installed-device acceptance through an authorized device path; if device access is unavailable in this session, keep that gate explicitly blocked. Continue reviewing the overlapping #2607/#2591 patches and release gate #2102 without changing Draft state or claiming Release Ready.


## Release-closure workflow correction merged — 2026-10-11

- Reviewed and merged PR [#2531](https://github.com/mobinpda-lab/Arvin-clean/pull/2531) after exact-head checks passed. Merge commit: [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd).
- Scope was limited to `.github/workflows/release-closure.yml` and `test/release_closure_product_gate_test.dart`: stop cancelling an active release-closure run, and only allow workflow_run-triggered closure when the successful upstream Production Orchestrator was explicitly started via `workflow_dispatch`.
- Exact-head Build #38165128162 passed Analyze, all six test shards, Debug APK and Release APK. Device Smoke #38165128170 passed all six lanes (backup-restore, home, SQL migration, quick-capture, SQL persistence, people). This validates that PR head only; it does not replace current-main post-merge validation or full owner acceptance.
- PR #2531 is merged. Issue #2102 remains OPEN/BLOCKED. No release was published; the #2102 approval gate remains intact.
- Report Center PR #2607 remains OPEN/Draft with exact-head Build #38166678767 green; Device Smoke #38166678708 skipped because Draft. PR #2591 remains OPEN/Draft; shared picker source is identical, but `lib/main.dart` and `lib/report_center_page.dart` integrations differ and must be reconciled.
- **Next action:** verify post-merge workflow behavior on main, then continue P0 issue #2102 evidence recovery and Report Center device/RTL acceptance. Do not claim Release Ready until current-main P0/P1 evidence and owner approval are complete.


## Continuation checkpoint — post-merge release gate and main head (2026-10-11)

- Re-read this execution state and evidence map before acting. Latest repository commit found is [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd), the merge commit for PR #2531; previous main head was `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- Re-read `.github/workflows/release-closure.yml` on `main`: cancellation is disabled for the release-closure concurrency group, and workflow_run closure is guarded to require a successful upstream `workflow_dispatch` run. The matching contract test is present on main. This verifies merged file content, **not** a post-merge runtime execution.
- The current connector's commit-workflow lookup returns no runs for merge commit `d8afc717...` because it only exposes PR-triggered runs; do not interpret this as a pass. Combined status endpoint returned no status checks for the merge commit. Post-merge Build/Device Smoke evidence is therefore still missing.
- PR #2607 remains OPEN/Draft at `8d3d60a1...`, base SHA `a6ced276...`; exact-head Build [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) passed Analyze, all six shards, and Debug/Release APKs. Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) was skipped because Draft. The validation head predates merge commit d8afc717 and needs refreshed integration evidence before merge.
- PR #2591 remains OPEN/Draft at `eae0394163a958223b79fc3b7aa914f79b664b8a`; its base is stale relative to current main. The shared time-picker widget blob is identical across #2607/#2591, but `lib/main.dart` and `lib/report_center_page.dart` integration changes differ. Rebase/reconcile existing PRs; do not merge blindly or duplicate the shared picker.
- Issue [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) remains OPEN/BLOCKED. Existing evidence still requires real-device Android proof for Calendar same-event/no-duplicate sync, system file-provider backup/restore integrity, link retention, Home RTL/compact-screen review, full Golden Flow, and explicit product-owner acceptance.
- Version on main is `1.0.1+2`; no release publication or Release Ready claim is supported.
- **Next action:** obtain fresh current-main Build and Device Smoke evidence through an authorized workflow path; then refresh/reconcile the existing product PRs and collect physical-device acceptance. If workflow dispatch access is not exposed, record the limitation and keep release blocked. No app source change made in this checkpoint.


## P0 evidence recovery — Device Smoke and Calendar lane (2026-10-11)

- Rechecked the previously stale Device Smoke run [38037275973](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38037275973) rather than launching duplicate CI. The job API now reports all six lanes completed/success: Home (114175727462), Backup/Restore (114175727752), SQL migration (114175727913), Quick Capture (114175728065), People (114175728105), SQL persistence (114175752538).
- Artifacts available from that run: Home `11665410659`, People `11665011600`, Quick Capture `11664318029`. No Backup/Restore artifact is listed despite its successful job result. Automated lane success is recorded; backup evidence review/data-integrity acceptance is not.
- Calendar edit PR #2570 is already merged at `34a6cee9ae05ad1cf632960b96e98f2a5448e128`; do not duplicate the implementation.
- Added a factual checkpoint comment to release gate [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) (comment ID `6112823569`) documenting lane results and missing Backup/Restore artifact.
- Post-merge status check lookup for current main merge commit `d8afc717eaf02d6d0bedf92e800c7f93209c97bd` returned no status entries; this connector response is insufficient to claim current-main CI passed. The merged workflow file and contract test are present on main, but current-main workflow execution is still unverified.
- Release gate #2102 remains OPEN/BLOCKED; PR #1901 remains OPEN. Physical-device/product-owner acceptance remains outstanding.
- **Next action:** review available Home/People/Quick Capture artifacts; recover or explicitly document missing Backup/Restore artifact; obtain exact-current-main validation and validate same-event Calendar edit plus restore link integrity. Keep the release gate closed until P0/P1 evidence and owner acceptance are complete.


## Exact current-main Build confirmed; Device Smoke queued — 2026-10-11

- Queried GitHub's actual `main` branch and Actions API. Current `main` is `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`.
- Exact-main Build [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381) completed successfully: Analyze, all six test shards, Debug APK, Release APK. Artifacts: Debug `11712873761`, SHA-256 `a6c6be99448d9160e2ddee09b8d6b03e198c9999fb8f48f6d31ec26a528806a5`; Release `11712389980`, SHA-256 `4c9b5deb4d84a8a097b42ca42594e1edf7b0e16657083fb91402ad8d5794f7a4`.
- Exact-main Device Smoke [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) has been created for the same SHA but is not complete: Home and Quick Capture passed; SQL migration and SQL persistence are in progress; Backup/Restore and People are queued. Artifacts currently available: Home `11712218995`, Quick Capture `11713050656`. Do not call the full smoke pass yet.
- Downloaded and visually inspected available smoke screenshots. Home screenshot is legible in RTL at the captured viewport; People screenshot shows an empty state and add-person action; Quick Capture screenshot shows truncated labels in the narrow three-column selection chips (P2 UX observation). These are automation/emulator artifacts; physical-device acceptance remains unproven.
- Release Closure [38167799987](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167799987) failed closed at the explicit product-release approval step on the prior SHA. This is not authorization to bypass the gate.
- PR #2585 (Backup/Restore) is already merged at `a6ced27660d34cd87dd8915aff68d3a7555fd57a`; Calendar sync #2570 and Calendar-link backup/restore #2569 are also already merged. Do not duplicate those implementations.
- PR #2607 remains Draft and its Build pass is on a head predating current main; PR #2591 remains Draft and its base is stale. Refresh/reconcile rather than merge blindly.
- **Next action:** monitor exact-main Device Smoke #38167835426 to completion, inspect Backup/Restore result/artifact and People screenshot; then refresh/reconcile PR #2607/#2591 integration. Release remains blocked on physical-device Calendar/Backup-Restore, recurrence, RTL, Golden Flow and explicit owner acceptance.


## Device Smoke progress correction — exact main SHA (2026-10-11)

- Rechecked run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) on `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`.
- SQL migration and SQL persistence have now completed successfully. Home and Quick Capture remain successful.
- Backup/Restore and People have moved from queued to in progress. Full run is still `in_progress`; neither lane is yet accepted and neither artifact is listed at this checkpoint.
- Continue waiting on this exact run; do not start duplicate Device Smoke. Release gate remains open/blocked.


## Exact-main Device Smoke completed — 2026-10-11

- Re-polled existing Device Smoke run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) on exact main SHA `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`. Overall run completed with conclusion **success** at 2026-10-11T19:37:33Z.
- All six lanes passed: Backup/Restore (job 114553994598), Quick Capture (114553994694), Home (114553994728), People (114553994755), SQL Migration (114553994767), SQL Persistence (114553994778).
- Artifacts available: People screenshot bundle 11713400184 (12,418 bytes), Quick Capture 11713050656 (37,135 bytes), Home 11712218995 (31,109 bytes). **No Backup/Restore artifact is listed**; passing lane is not a substitute for reviewing a restore artifact or real-device/file-provider acceptance.
- Together with exact-main Build [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381), Analyze, six quality test shards, Debug APK and Release APK all pass on the same SHA. Debug SHA-256: `a6c6be99448d9160e2ddee09b8d6b03e198c9999fb8f48f6d31ec26a528806a5`; Release SHA-256: `4c9b5deb4d84a8a097b42ca42594e1edf7b0e16657083fb91402ad8d5794f7a4`.
- This closes the **current-main automated Build + Device Smoke evidence** step only. It does not close product release acceptance: physical-device same-event Calendar update/no-duplicate proof, real Android file-provider Backup/Restore and restored-link integrity, recurrence/Checklist/Golden Flow, compact-screen RTL visual acceptance, Quick Capture clipped-label UX follow-up, and explicit owner approval remain outstanding. Release Closure approval gate stays intact; no release authorized.
- **Completed:** exact-main Build and all six Device Smoke lanes validated. **In progress/blocked:** product/device acceptance and owner approval. **Next:** inspect the newly available People artifact; continue existing PR reconciliation without duplicate implementations.


# LIVE CONTINUATION ADDENDUM — 2026-10-11 (revalidated after checkpoint)

## CHECK — branch and evidence revalidation
- A GitHub compare of `d8afc717eaf02d6d0bedf92e800c7f93209c97bd` against `main` returned `identical`; current main is therefore confirmed at that exact SHA for this check.
- Exact-main Build run [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381): Analyze, test shards 0–5, Debug APK and Release APK all completed successfully.
- Exact-main Device Smoke run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426): Backup/Restore, Quick Capture, Home, People, SQL Migration and SQL Persistence all completed successfully.
- Combined commit status API returned an empty status list; it is not used as a substitute for the explicit completed workflow-job results above.
- Current PR metadata rechecked: #2591, #2595, #2600, #2607 and #2608 remain OPEN / DRAFT. No merge occurred.

## Latest completed step
- Re-read this file before acting.
- Confirmed current main by comparing the recorded SHA with the symbolic `main` ref.
- Revalidated all Build and Device Smoke jobs on that exact main SHA.
- Rechecked live PR state and preserved the prior Task Note data-contract gate.
- Added a new live evidence checkpoint and PR-overlap audit in [ARVIN_LIVE_CHECKPOINT_2026-10-11.md](https://github.com/mobinpda-lab/Arvin-clean/blob/docs/arvin-autonomous-memory-20261011/docs/arvin-memory/ARVIN_LIVE_CHECKPOINT_2026-10-11.md), with verified read-back.

## Decisions / guardrails
- The green automated mainline runs are accepted as evidence only for the paths they exercised. They do not prove physical-device Calendar provider identity, real-file Backup/Restore integrity, full golden-flow acceptance, visual acceptance, or product-owner release approval.
- Do not merge #2591, #2595 or #2607 independently: their changed-file lists overlap in the shared time picker, main routing, report filter, Quick Capture and Task Editor paths. Reconcile one integrated head, then run full exact-head validation.
- Do not add or propagate root `Task.note` until the product owner explicitly decides whether it is distinct from `Task.description`; legacy serialization, SQL envelope, backup/restore and migration consequences must be specified and tested.
- Documentation PRs #2600 and #2608 overlap in memory/requirements scope. Reconcile against current main into one authority hierarchy; do not merge stale-base documentation blindly.
- No application code, main branch, schema, migration, APK publication, merge or release was changed in this execution.

## Current status
- **Completed:** current-main Build + six-lane Device Smoke revalidated; PR states rechecked; checkpoint recorded and read back.
- **In Progress:** safe consolidation plan for shared time-picker/report-filter/task-form changes; documentation hierarchy reconciliation; real-device/product acceptance.
- **Blocked:** Task Note data-contract change pending explicit owner decision; final release pending physical-device evidence and explicit owner acceptance.
- **Current bottleneck:** overlapping draft PRs plus missing physical-device/user-data acceptance. The mainline automated baseline is green, so do not rerun it without a new commit or evidence-driven reason.
- **Next action:** compare and reconcile the live PR diffs into one integration sequence without merging overlapping drafts independently; continue collecting non-destructive device acceptance evidence; update the release gate only from actual evidence. Keep #2102 open and fail-closed.


## LIVE CONTINUATION ADDENDUM — 2026-10-12 (CI routing validation)

### CHECK — exact current evidence
- Re-read this execution state before acting. Current main SHA at this checkpoint: `326afaa276b04650a86a811b18560eb4e20ed5cd`.
- CI-routing fix PR [#2639](https://github.com/mobinpda-lab/Arvin-clean/pull/2639) is open, unmerged, base `main`, head `433a741beb277572d2b4cdf6ef9838149e63a134`; one-line workflow diff removes the pull-request base-branch restriction while retaining main/master-only push triggers.
- Exact-head Build [38254855655](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855655): Analyze, test shards 0–5, Debug APK passed; Release APK was still in progress at latest poll. Overall result is not final.
- Exact-head Device Smoke [38254855466](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855466): Quick Capture and Home passed; SQL Persistence and SQL Migration were in progress; People and Backup/Restore were queued. Overall result is not final.
- Latest re-poll did not show completion; do not create duplicate runs or call the build/smoke green.
- Task-form PR [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595) remains open/draft on stacked base `feat/universal-arvin-time-picker-implementation-20261011`, head `a5d4581997084179f525de4f274ad00d5305ac1a`, mergeability false. The owner has not explicitly approved the previously proposed integration of #2591/#2595/#2602/#2607; no retarget, rebase, or merge is authorized.
- Release listing still contains only draft prereleases; release closure remains NO-GO. Automated mainline green runs do not replace physical-device Calendar same-event update/no-duplicate evidence, real file-provider Backup/Restore/link-integrity evidence, recurrence/checklist golden flow, compact RTL acceptance, and explicit owner approval.

### Completed in this continuation
- Revalidated project memory, current main, open PR inventory, release listing, and exact-head Build/Device Smoke jobs.
- Added an evidence checkpoint comment to PR #2639 (comment ID `6125186798`) with exact run IDs, status and guardrails.

### Current status
- **Completed:** CI routing fix is proposed; Analyze, all six test shards, Debug APK, Home and Quick Capture passed on its exact head.
- **In Progress:** Release APK and remaining Device Smoke lanes.
- **Blocked:** Final CI conclusion; Task-form stack integration awaiting explicit owner approval; release awaiting physical-device evidence and explicit owner acceptance.
- **Current bottleneck:** Exact-head validation has not finished; overlapping task-form changes must not be merged independently.
- **Next action:** Poll existing runs [38254855655](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855655) and [38254855466](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855466), fix only evidence-backed failures, and update this state with final job outcomes. Do not merge PRs or release APKs without required authorization and acceptance evidence.


---

# LIVE EXECUTION CHECKPOINT — 2026-10-12 (follow-up decision + CI acceleration)

This checkpoint supersedes earlier status statements where they conflict. Refresh GitHub before the next write.

- **Completed:** PR #2631 merged at `d136dfc5c3c64a4e1dc0dae20e1a928dd154e66e`. FollowUp Calendar projection now requires an explicitly configured `FollowUp.reminderDate`; it no longer projects follow-up history/date alone. Exact-head Build, Calendar Provider Acceptance and all six Device Smoke lanes passed on dependency head `e815a8f1daa312da7bf6bf1188cf94a3b541e380`.
- **Completed:** PR #2639 merged at `3550e754bdf5019b1a9192e4384d5ed4c947c680`. Stacked pull requests can now receive Build workflow validation; exact-head Build and Device Smoke passed before merge.
- **Owner decision:** `nextFollowUp` and `reminderDate` are independent. Never migrate/clear `nextFollowUp` to simplify UI. Keep separate next-action and reminder controls. Calendar may project an explicit reminder only, without mutating either field. Decision is documented in PR #2642 and the dedicated decision document on a review branch.
- **Correction in progress:** PR #2636 originally proposed a compatibility mapping that collapsed the two fields. Commented on PR #2636 and Issue #2635; updated PR description, FollowUp editor to preserve both values, regression tests and decision log. Current proposed head: `6d970acec8f2d26464f746525861f5b3f341ce67`.
- **Validation status for PR #2636:** exact-head Build and Device Smoke are queued; Calendar Provider Acceptance is in progress. Do not merge until all gates finish and the branch is reconciled with latest main. Earlier run `38238251976` failed multiple calendar widget tests due to a 1 px vertical overflow at `lib/calendar_page.dart:501`, plus a follow-up action expectation failure; those results are historical and not proof about the corrected head.
- **Current bottleneck:** verify PR #2636 on its exact current head and reconcile it with the merged PR #2631/main. The branch currently reports mergeable=false after main advanced; do not merge blindly.
- **Release:** NO-GO until physical-device same-event Calendar update/no-duplicate, real Android file-provider Backup/Restore and Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen visual acceptance, and explicit owner approval are evidenced.
- **Next action:** poll exact-head PR #2636 Build, Calendar Provider Acceptance and all six Device Smoke lanes; then reconcile branch/base conflicts and rerun on the final head. Continue only from this checkpoint; do not repeat already completed CI-routing/projection work.


## Owner execution command — Follow-up, Quick Entry and Checklist (2026-10-12)

- Canonical owner contract recorded in `docs/arvin-memory/ARVIN_FOLLOW_UP_AND_QUICK_ENTRY_DECISION.md` on documentation PR [#2643](https://github.com/mobinpda-lab/Arvin-clean/pull/2643); exact-head validation for the updated docs commit is running. Do not claim the document is merged until GitHub confirms it.
- Existing implementation lane [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595) already owns `lib/task_editor_dialog.dart`, `lib/quick_capture_dialog.dart` and their tests; avoid creating a parallel implementation PR. Added the new contract to that lane and Calendar PR #2636 for reconciliation.
- Required code changes remain **not yet verified complete**: remove auto-generated follow-up timestamp controls from Full Task Form while retaining «کار پیگیری‌دار»; preserve stored Task.followUpDate and FollowUp.nextFollowUp without copying/clearing; add compact Quick Entry «دارای پیگیری» and «دارای چک‌لیست» toggles that activate the canonical Roll Boxes; keep Checklist Task-owned; and make Calendar show explicit reminder first or nextFollowUp as an action item when no reminder exists, without scheduling a system notification from nextFollowUp alone.
- Existing #2595 is stacked and currently reports mergeable=false; do not merge or rebase blindly. Reconcile with its shared Universal Time Picker parent and existing overlapping Task-form drafts, then run exact-head Analyze, all test shards, Debug/Release APK, and relevant Calendar/Device Smoke.
- **Release remains NO-GO** until exact-head automated gates, physical-device Calendar update/no-duplicate behavior, real Backup/Restore and link-integrity evidence, RTL/compact-screen visual acceptance, and explicit owner approval are all recorded.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner clarified reminder initialization)

- **Live PR correction:** PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) is MERGED, not open. GitHub reports merge commit `8136c929237c321f2e879a80f067970c31cb0100`. Earlier text in this file describing #2650 as open is historical and superseded by this checkpoint.
- **New owner-confirmed product contract:** setting Next Follow-up does not automatically create a reminder. Create a reminder for it only if the user explicitly wants/chooses it. When chosen, prefill reminder title from the Task title and reminder date/time from Next Follow-up. The user can independently edit reminder title/date/time and may ask for additional reminders. This is initial-value convenience only, not a live binding.
- **Independence:** reminder is independent of previous/next follow-up and recorded Follow-up history. Later Next Follow-up edit/delete must not move/delete reminders; reminder edit/delete must not change Next Follow-up. Reminder can remain without Next Follow-up.
- **Collision/data-safety guard:** do not silently overwrite an existing reminder or create duplicates. Preserve existing data and require explicit user intent where an additional reminder is requested. Date-only/all-day intent is independently supported for Next Follow-up and reminders; never infer it from midnight alone.
- **Recorded to canonical memory:** follow-up concept decision, decision log, project knowledge, problem register and evidence map are being updated in this branch. This records the product contract only; it does not mean application code has been changed or validated.
- **Implementation gaps remain:** source audit found no first-set reminder creation bridge, no explicit Follow-up all-day metadata in the inspected model, and Follow-up Calendar projection does not set all-day explicitly. Need regression coverage across UI, model JSON, SQL envelope, backup/restore and Calendar event identity/no-duplicate behavior.
- **Validation:** no Flutter analyze/test/build/device run was performed as part of this documentation update. Release remains **NO-GO** until exact-head automation and required device/owner acceptance are proven.
- **Next action:** implement safely against canonical Task/FollowUp paths; test opt-in reminder creation and prefill, multiple reminders, independent edits/deletes, collision handling, date-only/all-day semantics, persistence/backup round-trip and same-event calendar updates. Recheck exact-head CI after the documentation PR is opened.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (multiple Follow-ups and reminders)

- **New owner-confirmed cardinality:** one Task may have multiple recorded Follow-up entries and multiple independent reminders. There is no one-per-Task limit.
- Each recorded Follow-up remains a distinct history entry. Each reminder remains a distinct, independently editable/deletable item with its own title and schedule. Editing/deleting one must not mutate other reminders, Follow-up history or Next Follow-up.
- Next Follow-up is still the separate next-action value. Setting it does not automatically create a reminder. If the user explicitly chooses to create a reminder for it, prefill Task title and Next Follow-up date/time as initial values only.
- **Implementation status:** this cardinality contract is now documented; the current implementation's support for multiple independently identified reminders and Follow-up entries has not been verified by this documentation update. Audit the canonical model/editor/storage/backup and Calendar identity paths; no parallel store.
- Required regression coverage: create/edit/delete one among several entries; preserve remaining entries and history; independently edit reminder title/date/time; reminder-only and multiple-reminder cases; JSON/SQL/backup-restore round-trip; Calendar same-event updates without duplicate creation; date-only/all-day semantics for each item.
- No app code or Flutter validation was performed in this documentation step. Release remains **NO-GO**.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (Calendar projection separation CI completed)

This checkpoint continues the current projection-separation PR; it does not restart prior audits. It supersedes older live status for PR #2665 where conflicting.

- **Repository:** `mobinpda-lab/Arvin-clean`.
- **PR #2665:** [fix(calendar): separate internal follow-up projection](https://github.com/mobinpda-lab/Arvin-clean/pull/2665), branch `fix/calendar-internal-followup-projection-20261013`, open/unmerged. Before this memory update, head was `1628048eacfd20ecd73e7938fddb79a8306c6b8c`; GitHub reported mergeable=true.
- **Completed — exact queried-head automation:** Build run [38364976764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38364976764) SUCCESS: Analyze, test shards 0–5, Debug APK and Release APK passed. Device Smoke run [38364976751](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38364976751) SUCCESS: Home, Quick Capture, People, SQL Migration, SQL Persistence and Backup/Restore all passed. These are automated/emulator results, not physical-device acceptance.
- **Implementation submitted:** separate read-only `FollowUpInternalCalendarProjection` reads canonical `FollowUp.nextFollowUp` and is combined with the existing calendar projection only at the internal calendar display boundary. Outbound sync remains wired to `FollowUpCalendarProjection`; the new follow-up-action entries are not passed into that outbound-sync call path. Regression tests cover internal-only visibility, separation when a Reminder exists, no canonical Task mutation, and independence of `nextFollowUp` from `reminderDate`.
- **Memory recorded:** decision details and the successful CI/emulator checkpoint are appended to `docs/arvin-memory/ARVIN_CALENDAR_PROJECTION_SEPARATION_DECISION.md` on this PR branch.
- **Still blocked:** PR review/merge; Calendar Provider Acceptance for CREATE → UPDATE same event/no duplicate; actual OS notification delivery/reschedule/cancel; physical-device installed-flow evidence; real file-provider Backup/Restore and Calendar-link integrity; multiple independent Task-level reminders (separate PR #2655); Persian RTL/compact-screen visual acceptance; explicit owner release approval.
- **Release:** **NO-GO**. Green CI does not establish physical-device or external-provider behavior and does not clear the separate multi-reminder gate.
- **Next action:** because this execution-state update itself creates another PR commit, query the resulting exact head and its Build + all six Device Smoke lanes. If green, review the diff and required provider/device gates; do not merge solely because GitHub says mergeable=true.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (projection test failure corrected; revalidation pending)

- Current reviewed implementation commit before this checkpoint: `683cf2a66f43282c1150d6d2f8674aeff86f8ba1`.
- Build run [38367352703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38367352703) surfaced one real regression-test failure in shard 4: `test/follow_up_internal_calendar_projection_test.dart`, test `changing nextFollowUp does not mutate existing reminderDate`, failed with `Bad state: No element`. Root cause: the newly added display-precedence rule correctly returns no internal Follow-up fallback when a Reminder exists, while the old test still expected a fallback item.
- **Correction committed:** `83d7ee4be40228ceeab7644219aa4ae82a56a974` updates that test to assert both contracts: an existing Reminder wins internal Calendar display, and `nextFollowUp` remains independently editable and visible when no Reminder exists. No production code changed in this correction.
- Earlier poll on head `683cf2a...`: Analyze PASS; test shards 0,1,2,3,5 PASS; shard 4 FAIL; Debug APK PASS; Release APK still running. Device Smoke: Home and Quick Capture PASS; SQL Migration and SQL Persistence running; People and Backup/Restore queued. These results are historical and must not be treated as validation of the corrected head.
- **Current state after correction:** new commit triggers fresh exact-head validation. Re-query the PR head and Build/Device Smoke workflows; require all test shards, both APK builds and all six smoke lanes to pass before considering merge.
- PR #2665 remains open/unmerged. No physical-device or external Calendar Provider Acceptance evidence exists. Multi-reminder PR #2655 remains open and non-mergeable.
- Release remains **NO-GO**.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (PR #2665 exact-head CI and device smoke completed)

This checkpoint supersedes earlier live status for PR #2665 where conflicting; preserve older entries as history.

- **Repository / lane:** `mobinpda-lab/Arvin-clean`; PR [#2665](https://github.com/mobinpda-lab/Arvin-clean/pull/2665), branch `fix/calendar-internal-followup-projection-20261013`, remains OPEN and UNMERGED. GitHub reported mergeable=true at this poll. Do not treat mergeability as approval or release readiness.
- **Exact validated code head before this memory-only update:** `2987f5530749b6de6292ff3c86933d8f50b56578`.
- **Build evidence:** [run 38368795309](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38368795309) completed SUCCESS on that exact head. Analyze, test shards 0–5, Debug APK and Release APK all passed.
- **Device Smoke evidence:** [run 38368795338](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38368795338) completed with all six lanes SUCCESS on that exact head: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore, and People.
- **Scope limitation:** these are GitHub automated/emulator gates. They do not establish physical-device acceptance, external Calendar provider CREATE→UPDATE/no-duplicate behavior, actual OS notification delivery/reschedule/cancel, or final owner approval.
- **Current implementation:** internal Calendar follow-up action projection remains separate from outbound Calendar sync. When a Task has an explicit Reminder, internal Calendar suppresses the fallback nextFollowUp action for that same Task; nextFollowUp and reminderDate remain independent canonical fields. PR #2665 is still unmerged.
- **Other open gate:** PR [#2655](https://github.com/mobinpda-lab/Arvin-clean/pull/2655) for multiple independent Task reminders remains non-mergeable at last known check; reconcile its base safely and validate exact head before integration. Issue [#2654](https://github.com/mobinpda-lab/Arvin-clean/issues/2654) remains the requirements tracker.
- **Release status:** **NO-GO** pending physical-device/product acceptance and explicit owner approval. Automated smoke is not a real-phone test.
- **Completed in this continuation:** re-polled the exact-head Build and all six Device Smoke jobs; all were successful. This new memory commit changes the PR head, so all exact-head gates must be queried again before merge.
- **Next action:** validate the resulting new PR head's Build and Device Smoke; review PR #2665 diff and provider/device gates. Then continue safe reconciliation of #2655 and the existing Calendar contract. Do not merge or publish a release solely because CI is green.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (latest-head CI poll)

- Repository: `mobinpda-lab/Arvin-clean`; PR [#2665](https://github.com/mobinpda-lab/Arvin-clean/pull/2665), branch `fix/calendar-internal-followup-projection-20261013`, remains OPEN and UNMERGED; GitHub reports mergeable=true. Current checked head: `be52a7457b6300cb917b7ab312c2ec4e27c607fa`; base checkpoint `ee73adbc61c4baea82caeb9932969fd293922162`.
- **Completed — exact-head Build:** run [38370894374](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38370894374) SUCCESS on the checked head. Analyze, test shards 0–5, Debug APK and Release APK all completed successfully.
- **Completed — exact-head Device Smoke:** run [38370894181](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38370894181) SUCCESS on the checked head. All six lanes passed: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore and People.
- Scope remains limited to CI/emulator validation. No physical-device acceptance or external Calendar Provider Acceptance is evidenced by these runs.
- **Safe next step:** inspect/reconcile PR #2655's 58-ahead/2-behind divergence against current main without blind merge/rebase. Its Task model, editor, Calendar inbound/outbound, backup and reminder scheduling changes overlap newer main and require path-by-path compatibility review.
- Release remains **NO-GO** pending multi-reminder integration, provider CREATE→UPDATE/no-duplicate evidence, real-device notification and backup/restore validation, Persian RTL/compact UX acceptance, and owner approval.
- This memory write creates a new PR head; re-query Build and all six Device Smoke lanes for that resulting exact head before any merge/readiness decision.

# AUTHORITATIVE CONTINUATION — 2026-10-14 (PR CI recovery dispatcher exact-head validation)

This checkpoint supersedes earlier live status for PR #2699, while retaining older entries as history.

- **Repository:** `mobinpda-lab/Arvin-clean`.
- **PR:** [#2699 — ci: recover missing exact-head PR builds automatically](https://github.com/mobinpda-lab/Arvin-clean/pull/2699), branch `fix/ci-exact-head-recovery-dispatcher-20261014`, target `main`. At this checkpoint it is OPEN, non-draft, unmerged; GitHub reports mergeable=true.
- **Validated head before this memory-only update:** `b1e7b50c87ac21c7e50926cc88fb8db7ed551229`.
- **Build:** [run #38515272044](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38515272044) completed SUCCESS on that exact SHA; Analyze, test shards 0–5, Debug APK and Release APK passed.
- **Device Smoke:** [run #38515272058](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38515272058) completed SUCCESS on that exact SHA. All six lanes passed: Home, Quick Capture, SQL Migration, SQL Persistence, People, and Backup/Restore. The Backup/Restore lane completed successfully; no failure was observed.
- **Evidence limitation:** these are GitHub CI/emulator results. They do not prove acceptance on a physical phone or external Calendar/notification providers.
- **Dispatcher review:** the workflow scans open PRs, limits work to same-repository branches updated within 14 days, caps dispatches at three per run, avoids active/green/recent exact-head runs, passes `target_sha`, and logs requested SHA metadata. Permissions are `actions: write`, `pull-requests: read`, `contents: read`; it does not merge or release. PR review submissions and inline review threads were empty at this checkpoint.
- **Current bottleneck:** operational acceptance is still incomplete. PR acceptance requires a dispatcher run to log decisions and dispatch Build for a controlled PR lacking exact-head evidence, then compare the resulting Build SHA with the current PR head. The available GitHub connector exposes no workflow-dispatch action, so that controlled run could not be triggered from this session. Do not claim this acceptance item passed.
- **No merge or release:** remain NO-GO. Do not merge solely because the PR is mergeable or Build/Device Smoke are green. The dispatcher’s after-merge proof and broader product gates remain open.
- **Recorded evidence:** the terminal CI checkpoint and gate status were posted to [PR #2699 comments](https://github.com/mobinpda-lab/Arvin-clean/pull/2699).
- **Next action:** obtain a permitted manual/scheduled dispatcher run after this workflow is integrated through an independently justified review path, using a controlled same-repository PR with no exact-head Build evidence; verify logs, requested SHA, resulting run metadata, checked-out SHA and terminal result. Separately continue the existing product integration and physical-device/provider acceptance gates. This memory-only commit changes the PR head, so re-query Build and all six Device Smoke lanes for the new exact head before considering any further gate decision.


# AUTHORITATIVE LIVE UPDATE — 2026-10-14 — Latest-head CI terminal results

- Latest PR head checked: `db60759072b53ef215f07ce28ef69803cdfe0c3b` on PR [#2699](https://github.com/mobinpda-lab/Arvin-clean/pull/2699); PR remains open and unmerged.
- **Arvin Build passed:** [run 38517351542](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38517351542), event `pull_request`, conclusion `success`. Analyze, all six test shards (`test-0` through `test-5`), Debug APK, and Release APK jobs all completed successfully.
- **Device Smoke passed:** [run 38517351453](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38517351453), event `pull_request`, conclusion `success`. All six lanes passed: Home, Quick Capture, SQL Migration, SQL Persistence, People, Backup/Restore.
- These are terminal CI/emulator results for the listed PR head metadata. They do **not** prove physical-device acceptance, nor do they exercise the new dispatcher: both runs were triggered by `pull_request`, not `workflow_dispatch`.
- **Completed:** current-head Build and six-lane smoke evidence collected; this closes the immediate CI pending item for this head.
- **Still blocked:** end-to-end dispatcher validation remains outstanding. The connected GitHub toolset has no workflow-dispatch operation, and the dispatcher only becomes operational after integration on the default branch. Do not merge solely to test it without satisfying review and required gates.
- **Current bottleneck:** prove dispatcher dispatches a controlled same-repository PR missing exact-head evidence, and confirm requested SHA = checked-out SHA = accepted run SHA. Physical-device and full product release gates also remain open.
- **Next action:** safely establish a supported dispatch path and test the dispatcher after approved integration; separately complete remaining product acceptance and physical-device evidence. Release remains NO-GO.


# AUTHORITATIVE LIVE RECHECK — 2026-10-14 — Autonomous continuation

This addendum records the latest observed GitHub state and supersedes conflicting live-status claims above. Evidence is SHA-specific.

- **Observed default branch:** `main` at `de795419be2c39775119af8eaa37c53744820d93`. This differs from the older main SHA recorded in prior checkpoints; use the live branch SHA for future promotion decisions.
- **Recovery dispatcher PR #2699:** open, non-draft, unmerged, GitHub reports mergeable=true; head `379f4e645662c5c0d911fe168d27aa44e69ba9ab` before this memory update. Arvin Build [38519665323](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38519665323) SUCCESS and Device Smoke [38519665528](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38519665528) SUCCESS on that head; all six smoke lanes are terminal-success. This does not prove the workflow_dispatch recovery path works operationally. The dispatcher workflow file is absent from `main` at this recheck, and the available GitHub connector exposes no workflow-dispatch action. Do not merge solely to bypass this limitation; normal review and post-merge controlled acceptance remain required.
- **Person PR #2695:** open, Draft, unmerged, mergeable=false; current head `6d01c603edf897f813ceb94d15bc7d36b5c058c2`, base branch `integration/task-multiple-reminders-safe-20261013` at `ad762774009e5b5c7ee341146a8160c52e2b9bb2`. The exact-head Actions run query and check-runs query both returned zero results. Do not treat runs on older SHAs or PR #2699 as evidence for Person code. The recorded repair checkpoint `0432e3a...` does not match the current live PR head; verify branch contents and obtain exact-head CI before changing or integrating code.
- **Release blockers:** Issues [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) and [#1901](https://github.com/mobinpda-lab/Arvin-clean/issues/1901) remain open. Recent Release Closure and Final Head Release Validation runs on `de795419...` were skipped, not passed. Physical-device acceptance, integrated Person backup/restore/report validation, and release-gate closure remain outstanding.
- **Work performed in this continuation:** re-read execution state and evidence map, queried live default branch, both PRs, Actions runs/jobs, exact-head runs/checks, and release blockers. No application code changed; no tests were weakened; no merge or release performed.
- **Current bottleneck:** no exact-head validation for Person PR #2695 and no operational proof of the recovery dispatcher.
- **Next action:** record the live evidence in the evidence map; then poll CI for the new memory-update head of PR #2699. Continue to keep both PRs unmerged until their specific acceptance gates are satisfied. Release remains **NO-GO**.


# AUTHORITATIVE LIVE UPDATE — 2026-10-14 — Recovery dispatch correctness repair

- **Newly identified implementation flaw:** dispatching Arvin Build on each target PR branch can select that branch's older `.github/workflows/build.yml`, which may not declare `target_sha` or include the exact-checkout assertion. Also, if recovery dispatches are moved to the default branch, the Build run's `head_sha` identifies the workflow ref, not the requested target commit; filtering by `run.head_sha === target_sha` would reject valid runs. Multiple recovery runs on `main` would also collide under the old shared concurrency group.
- **Correction implemented on PR #2699 branch:** dispatcher now resolves the repository default branch and dispatches Build against that workflow ref while passing the exact target SHA; it finds target runs by the explicit run name and default-branch `workflow_dispatch` metadata. The Build workflow checks out `inputs.target_sha` and asserts the actual checkout in every quality and APK lane. Recovery concurrency is now keyed by target SHA to avoid cancelling other targets.
- **Validation status:** implementation only; CI is being triggered by these commits and must finish on the final resulting head. Operational dispatcher acceptance remains unproven until the workflow is on default branch and a controlled dispatch completes with exact checkout assertions. Do not merge solely to bypass a gate.
- **Person PR #2695:** still requires exact-head CI; the current live head `6d01c603edf897f813ceb94d15bc7d36b5c058c2` previously returned zero runs/checks. No app code changed in this correction.
- **Next action:** inspect the final PR #2699 head, wait for terminal Build and six-lane Device Smoke, then review job logs for YAML/runtime errors. Keep Person and release gates open until their own evidence is available.


# AUTHORITATIVE LIVE UPDATE — 2026-10-14 — Person exact-head validation recheck

- **PR #2699 recovery dispatcher:** merged into main. Its final PR head `555541a5426b02e483bf2168fcc78a57ddc8c3a6` has terminal-success Build [38523576951](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38523576951) and six-lane Device Smoke [38523577094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38523577094). These validate the PR head's CI/device-smoke lanes, but do not by themselves prove controlled dispatch against a separate target SHA. Keep operational dispatch acceptance open until such a run is evidenced.
- **Person PR #2695:** live head `93202e9e24e33bff31daaf933b2c4fb1417dfb46`, base `integration/task-multiple-reminders-safe-20261013` at `ad762774009e5b5c7ee341146a8160c52e2b9bb2`; Draft, unmerged, mergeable=true. Exact-head Build [38579471120](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38579471120) passed analyze, six test shards, Debug APK and Release APK. Exact-head Device Smoke [38579471201](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38579471201) passed all six lanes: quick-capture, home, people, SQL persistence, SQL migration, backup/restore.
- The current Person PR head scopes the `حذف شخص` title assertion to its AlertDialog; the current exact-head CI passes. Do not revive closed, diverged PR #2715.
- **Remaining blockers:** physical-device acceptance; integrated Person + Follow-up + report + backup/restore acceptance; controlled end-to-end recovery-dispatch proof. Release issues #2102 and #1901 remain open. Release remains **NO-GO**.
- **Current bottleneck:** product/data-integrity and physical-device acceptance, plus controlled dispatcher proof. Do not merge Person PR or publish a release solely on CI success.
- **Next action:** inspect PR #2695 changed files and test coverage against owner contracts; verify backup/restore round-trip and referential integrity for Person IDs and Task/FollowUp preservation; then complete physical-device acceptance. Separately prove dispatcher operation on a known target SHA.


# AUTHORITATIVE CONTINUATION OVERRIDE — 2026-10-15 — Option B implementation candidate

This entry supersedes older statements that the owner decision is pending or that automatic migration is prohibited.

- **Owner decision:** Option B — migrate non-null legacy Task.reminderDate into canonical TaskReminder on Task JSON decode with stable ID legacy-task-reminder, explicit isLegacyTaskReminder metadata, and persisted legacyTaskReminderMigrationVersion.
- **Owner-reported data state:** current app database is empty and Arvin has not yet been populated with real user data. Do not generalize this to all backups, fixtures, test databases or other installations.
- **Completed in this execution:** candidate migration logic, Calendar identity preservation, scheduler-key preservation, inbound Calendar edit/delete reconciliation, editor preservation and regression tests have been added on the current-main-based feature branch.
- **Not yet validated:** exact-head CI, SQL save/reload, actual backup/restore round-trip, Calendar Provider Acceptance, Device Smoke and physical-device behavior. No DONE claim.
- **Current bottleneck:** terminal validation of the current branch and verification that all integration gates pass.
- **Next actions:** Analyze; all test shards; Debug/Release APK; six Device Smoke lanes; Calendar Provider Acceptance; inspect failures; then complete physical-device and integrated backup/restore acceptance.
- **Release:** NO-GO.
- **Decision source:** https://github.com/mobinpda-lab/Arvin-clean/issues/2654#issuecomment-6178475884


# AUTHORITATIVE LIVE VALIDATION UPDATE — 2026-10-15 — PR #2719 exact-head CI

- **Exact candidate head:** `396cf7e70ac3cd88463436d471a6e624533fb181`; PR #2719 remains Draft/open and unmerged: https://github.com/mobinpda-lab/Arvin-clean/pull/2719.
- **Build:** terminal SUCCESS, https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38695156447. Analyze, test-0 through test-5, Debug APK, and Release APK all completed successfully on this exact SHA.
- **Device Smoke:** six emulator lanes completed SUCCESS (quick-capture, home, people, SQL persistence, SQL migration, backup/restore): https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38695105201.
- **Calendar Provider Acceptance:** terminal SUCCESS: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38695105183.
- **Correction to previous pending wording:** these CI gates are no longer pending for SHA above. This is emulator/CI evidence, not physical-device evidence, and does not independently establish the complete integrated Person + Follow-up + multi-reminder + report + backup/restore acceptance scenario.
- **Completed:** reviewed PR metadata and diff; verified exact-head check-runs and terminal jobs; recorded evidence here.
- **Current bottleneck:** integrated data-integrity/acceptance proof and physical-device validation; also verify controlled recovery-dispatch behavior. Keep PR #2719 unmerged until review confirms migration idempotence/rollback and end-to-end acceptance; release remains **NO-GO**.
- **Next action:** perform focused code review of migration rollback/retry, SQL and backup/restore round-trip, reminder delete isolation and alarm reschedule/restart behavior; then record results and request physical-device validation.


# AUTHORITATIVE LIVE UPDATE — 2026-10-15 — Multi-reminder integration and internal APK artifact work

- **Target branch:** `feat/task-multiple-reminders-option-b-20261015`; parent checkpoint before this change: `59f833ec0a07a711f333fa14b86b271be194688f`.
- **Verified parent CI evidence:** Build, six-lane Device Smoke and Calendar Provider Acceptance were terminal-success on parent SHA `59f833ec0a07a711f333fa14b86b271be194688f` (see PR #2719 runs recorded above). These results do not validate the new integration test or workflow changes in this commit.
- **Changes in this commit:** add a CI integration test that exercises legacy Task reminder migration, two independent reminders, SQL save/reload, canonical backup document encode/decode, Task-ID reconciliation, Person relation retention, Calendar Event ID retention, duplicate prevention and delivered-alarm suppression. The delivery projection now keeps the legacy scheduler identity and does not separately deliver the retained singular field after migration.
- **Workflow correction:** Release Closure may start after any successful Arvin Production Orchestrator completion, rather than requiring that upstream workflow to have been manually dispatched. It uploads the versioned Release APK and checksum/evidence as a workflow artifact before enforcing the product-release approval gate. Final Head Validation consumes the workflow artifact; an unsuccessful closure can still run the internal-artifact verification path and upload its evidence, but remains fail-closed for release validation.
- **Truthful gate status:** the new test and workflow edits are **PENDING exact-head CI** until GitHub Actions completes for the resulting commit. Do not mark G4/G6/G7 passed from test-file presence alone. The existing successful parent CI is not evidence for this new head.
- **Release remains NO-GO:** Issue #2102, regression PR #1901, physical-device acceptance and product-owner approval remain independent release gates.
- **Next action:** inspect exact-head Build, Device Smoke, Calendar Provider Acceptance, Release Closure and Final Head Validation results. Fix failures at root cause; only then update gate states with run links and the exact resulting SHA.


# AUTHORITATIVE LIVE VALIDATION UPDATE — 2026-10-15 — PR #2719 exact-head artifacts and CI gates

- **Validated source SHA:** `f403d45554720cf8e74c5a08466e119032d45464`; branch `feat/task-multiple-reminders-option-b-20261015`; PR [#2719](https://github.com/mobinpda-lab/Arvin-clean/pull/2719).
- **Arvin Build:** [run 38736428278](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428278) completed `success` on the exact SHA. Analyze, test shards 0–5, Debug APK and Release APK all passed.
- **Release APK artifact:** `arvin-release-apk`, artifact ID `11974502379`; APK file `app-release.apk`, size **70,842,341 bytes**; APK SHA-256 `c516b41a636de66bad3f31c3223dcd35d65ad5a5ca4ac83d20f500f34d0e8001`. Artifact ZIP size **32,738,515 bytes**; ZIP SHA-256 `624cdd3eba5f3245a9d4feaa2c1c014de71d1d32b8a15a945d4ebd2ffe68ff65`. [Download artifact](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428278/artifacts/11974502379).
- **Debug APK artifact:** `arvin-debug-apk`, artifact ID `11973952423`; APK file `app-debug.apk`, size **176,168,410 bytes**; APK SHA-256 `c3da85a153de3af27287cb5a8ea858e4971cf782f182168012729eedea26540b`. Artifact ZIP size **92,520,155 bytes**; ZIP SHA-256 `1140b88ff3c7bafb2d33abea401125d6ce0a35c5a310b08891ba4b8c6270c624`. [Download artifact](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428278/artifacts/11973952423).
- **Device Smoke:** [run 38736428389](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428389) completed `success` on the exact SHA. All six suites passed: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore and People.
- **Additional exact-head automated checks:** [Calendar Provider Acceptance run 38736428061](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428061), [Parallel Wave / contract run 38736428103](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428103), [Orchestrator run 38736428237](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428237), [Production Loop run 38736428302](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428302) and [Orchestrator PR Wakeup run 38736428344](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38736428344) all completed `success`.
- **Requested automated gate record on SHA `f403d45554720cf8e74c5a08466e119032d45464`:** G4 = PASS; G6 = PASS; G7 = PASS; G11 = PASS; G12 = PASS. Evidence is the exact-head Build, six-lane Device Smoke, Calendar Provider Acceptance, and the APK file hashes recorded above. These statuses mean the cited automated checks passed; they do not claim physical-device acceptance or product release approval.
- **Merge/release distinction:** this evidence closes the automated checks for the validated SHA. The act of recording this update creates a new PR head, so re-run/verify Build and all six Device Smoke suites on the resulting head before declaring PR #2719 merge-ready. Product release remains **NO-GO** until the separately recorded physical-device, integrated product acceptance and owner/release gates are satisfied.


# AUTHORITATIVE LIVE UPDATE — 2026-10-15 — PR #2725 terminal validation

- Exact PR head validated: `ba2306cfc66ad982f8e8ab73b838a4a8d6ed6b55`.
- Arvin Build run [38752957837](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38752957837): `completed / success`; all six test shards, analysis, Debug APK and Release APK succeeded.
- Device Smoke run [38752957813](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38752957813): `completed / success`; all six lanes succeeded: home, quick-capture, people, sql-migration, sql-persistence, backup-restore. Latest updated at `2026-10-15T14:51:41Z`.
- PR [#2725](https://github.com/mobinpda-lab/Arvin-clean/pull/2725) was observed open, mergeable, head matching the validated SHA, and not yet merged at the time of this checkpoint. Merge must be recorded only after GitHub confirms it.
- CI/emulator evidence is not physical-device acceptance. Keep product release claims limited to the evidence above.


# AUTHORITATIVE LIVE UPDATE — 2026-10-16 — Consolidation wave CI re-poll

- **Calendar PR #2735 exact PR head:** `81b646a4bf3f8a85925ad7ffe58fc810e162122d`. Build run [38815436407](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38815436407) terminal success: all 9 jobs passed (Analyze, six test shards, Debug APK and Release APK). Device Smoke run [38815436228](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38815436228) terminal success: all six lanes passed (home, quick-capture, sql-migration, sql-persistence, backup-restore, people). This is PR-event CI evidence, not exact-head dispatcher evidence and not physical-device acceptance.
- **Person/report PR #2695 exact PR head:** `44810fcf5bb96db8c028a1574889e3f2d45af75f`. Build run [38814903662](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814903662) terminal success: all 9 jobs passed. Device Smoke [38814903585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814903585): five lanes passed; original quick-capture failed, then only that job was rerun as job `116812638100`, which was still in progress at the latest poll (Cache Gradle step). Do not mark 6/6 green yet. PR remains stacked on #2666. Code review confirms branch projection API/policy differs from main projection: main excludes dangling Person IDs; branch adds `includeDanglingPeople` and multi-person selection. Reconcile deliberately before merge; no blind merge/rebase.
- **Reminder migration test PR #2738 exact PR head:** `5ba5432e07633fd03ad66721eee37bcad8ba4004`. Build run [38814485299](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485299) terminal success: all 9 jobs passed, including migration/backup regression and APK outputs. Device Smoke [38814485268](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38814485268): five lanes passed; original Home failure was retried as job `116812610529`, still in progress at the latest poll (Cache Gradle step). Do not mark 6/6 green yet.
- **Exact-head validation:** PR-triggered runs above are not the workflow_dispatch exact-target validation. The repository dispatcher exists on main and runs on a six-hour schedule; no direct workflow-dispatch write action was available in this execution channel, and no exact-target run for these three SHAs has been verified yet.
- **Release remains NO-GO** until all retry lanes are terminal-success, exact-head Build is verified on the current requested SHA(s), integration risks are resolved, and physical-device acceptance is recorded.
