
# AUTHORITATIVE LIVE UPDATE — ARVIN WAVE 5.48 — 2026-10-21

- **Main HEAD:** GitHub ref `main` re-read at `d9fb7a247037762216662a20fb32028ecc8a0f6b`.
- **Product PR #2833:** product-code HEAD before this docs-only commit was `4214101dd9a93542783fb97eb0d4a5cb34643950`; PR remains OPEN / DRAFT / UNMERGED with `mergeable=false`, base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Do not merge or rebase blindly.
- **CI PR #2868:** CI-only commit [52781290a159f1836ebe23d719a8856408c3e52f](https://github.com/mobinpda-lab/Arvin-clean/commit/52781290a159f1836ebe23d719a8856408c3e52f) is separate from product and documentation changes. It restores the nine-scenario matrix and adds Preflight plus per-runner checkout verification.
- **Build run [39530698487](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39530698487)** on PR event/head `d898a0d1bcbac5c463de7bdcdff906037ffd0dbd` ended FAILURE. Job `118995654319` (`quality (test-0)`) failed the literal `cancel-in-progress: true` contract; Job `118995654311` (`quality (test-2)`) failed the old artifact-name assertion and `EXACT_TARGET_SHA=$actual` assertion. Analyze, test shards 1/3/4/5 and both APK jobs succeeded, but overall Build failed.
- **Device Smoke run [39530698590](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39530698590)** on the same head ended SUCCESS for only seven scenarios. It omitted `task-lifecycle` and `checklist-evolution`; this is not complete nine-scenario evidence.
- **New candidate CI at this snapshot:** Build [39539888519](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39539888519) was `in_progress`; Device Smoke [39539888499](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39539888499) was `queued`. Re-read after terminal completion. This documentation commit does not alter code under test.
- **Queue preservation:** runs [37642397607](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37642397607), [37642397606](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37642397606) and [37642397605](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37642397605) remained queued on `d4efd86485113a711e0e0009dda266e051860ece`; none was cancelled. Status-filtered queries are point-in-time, not a full history inventory.
- **Exact-SHA Dispatch:** `BLOCKED — DISPATCH UNAVAILABLE`. The connected GitHub tool surface has no workflow-dispatch operation. PR-triggered CI is not Dispatch evidence.
- **Release:** `BLOCKED — RELEASE: NO-GO`. No current exact-SHA Dispatch, complete nine-scenario terminal result, physical-device Golden Flow, writable Calendar Provider lifecycle, or trusted APK certificate acceptance is claimed.


# V12.0 LIVE EXECUTION CHECKPOINT — 2026-10-19T22:17+03:30

- **Canonical command:** `docs/ARVIN_MASTER_EXECUTION_PROTOCOL.md`; V12.0 governing addendum committed at `eddcc9cb91b244408ae9e73e3635802dbe7d1ec7`. Historical protocol content preserved.
- **Repository access:** confirmed `mobinpda-lab/Arvin-clean` is public; GitHub connector reports read/write/admin permissions. A write was confirmed on the existing PR branch.
- **Working branch:** `wave-4-10/follow-up-reminder-contract`.
- **PR:** [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833), title `[DRAFT] Wave 4.12: Follow-up Reminder persistence and lifecycle`. Last fetched state: OPEN / DRAFT / UNMERGED. Base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- **Latest confirmed branch commit at this checkpoint:** `eddcc9cb91b244408ae9e73e3635802dbe7d1ec7` (master protocol V12.0 addendum). The PR-triggered orchestrator run returned by the latest Actions query is old: [39300092580](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092580), SHA `ee2239ca5d41037ec0de0cd94a67cc0c84eeacaf`, success for orchestrator wakeup only; it is not build or device validation of the new commit.
- **Exact-SHA / build / device validation for `eddcc9c`:** NOT RUN / UNKNOWN from evidence retrieved in this pass. No passing check status was returned for the new commit; the connected fetch exposed no direct workflow-dispatch action. Do not reuse earlier PR synthetic-merge or older-head runs as exact-head proof.
- **Release:** `BLOCKED — RELEASE: NO-GO`. PR #2833 remains draft and unmerged.
- **Known independent blockers from the latest PR checkpoint:** (1) Exact-SHA workflow dispatch/assertion is not proven for current head; (2) real Calendar Provider acceptance remains blocked until writable-provider CREATE → NO-OP → UPDATE → DELETE lifecycle is evidenced; (3) official Release signing remains blocked because main Release config was reported to use the debug signing config and no authorized release certificate/fingerprint is verified; (4) Reminder integration and Backup/Restore remain implemented but not verified against one fixed current SHA.
- **Scope of this run:** recovered live repo, PR and canonical docs; confirmed write permissions; updated the existing canonical master protocol on the existing PR branch; verified the resulting file content. No app code, tests, workflows, PR state, signing configuration, merge, tag or release was changed.
- **Next action:** inspect the current PR head and relevant workflow runs/jobs after the protocol commit; obtain exact-head Build and complete Device Smoke evidence; continue with the highest-value existing blocker without duplicating features or tests. Keep Calendar Provider and signing gates blocked until direct evidence/authorization exists.

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


## AUTHORITATIVE LIVE UPDATE — 2026-10-16 — Notebook pastel and cross-page visual audit

- Branch: `feat/product-canonical-navigation-reports-followup`; parent head before this documentation commit: `42fbc006c4d0b2cf8e09b312b67427b32f245b03`; PR [#2751](https://github.com/mobinpda-lab/Arvin-clean/pull/2751) remains open and unmerged.
- Notebook: `lib/notebook_page.dart` now has one horizontal ribbon for tag/category/project filters, a rounded shadowed search field, a pastel illustrated empty state with exact title «هنوز یادداشتی ثبت نشده است», helper text, and the existing floating create button. Regression tests were added in `test/notebook_page_test.dart`.
- Anti-regression: hard-coded hex colors in Home, Calendar, Reports, Notebook, and Task editor were routed through `ArvinColors`; Calendar obtains its declared font via `AppFonts.vazirharfFamily`. Follow-up card interactions use normal tap for parent Task editor and long press for follow-up actions; narrow date-ribbon count bubbles use scale-down to prevent overflow.
- Prior exact-head build `2d04631dd9d1939bd3feafa12aa7d68bec349b58` produced Debug and Release APK artifacts but multiple test shards failed. Affected tests were updated; exact-head validation is still required. Do not infer success from old runs.
- Current release status: **NO-GO / NOT VALIDATED** until the final resulting SHA has passing analyzer, all test shards with zero skipped tests, Debug/Release artifacts, all six Device Smoke lanes, Calendar Provider Acceptance, and artifact inspection.
- Font gap remains open: project bundles VazirHarf; Vazirmatn is not present in declared assets and is not claimed applied. Physical-device acceptance is still separate.



# WAVE 4.11 LIVE UPDATE — 2026-10-19 — Follow-up Reminder persistence slice

- **PR:** [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833), still OPEN / DRAFT / UNMERGED. Base: `fix/follow-up-record-authority-20261019`.
- **Observed failing baseline:** PR head `91d5412dad2f80aeffc464434f693583f4180be2`; Build run [39232215264](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39232215264) failed in Analyze and test shards 3/4 because the two new model tests were outside `main()` (analyzer errors at lines 197 and 214). Debug and Release APK jobs succeeded on that historical SHA, but this is not a passing Build gate.
- **Correction:** commit `44019c81b8ad394b7c4ce4496347004a79a519ad` moves the two tests inside `main()`. This is a source correction, not verified test evidence.
- **Implementation commits:** `2989741558cdc834787f38751469e91788cf42e7` reconciles Follow-up writes with the existing `Task.taskReminders` collection; `e83229579d36108786f11393ca622de85c13b693`, `f6d34abe1b435530e72cc3ef0c8e90746dda4e90`, and `dba7a12b55edb1ffc7981f5526a8c7c4330640c6` keep linked reminders on the established Follow-up notification identity to avoid duplicate delivery; `b4b14a2497c460b2bd8da1711b7a8663cb1c42d6` adds repository lifecycle tests; `9dc9d9f3b9156ab1095b722ca7dbc89bdaf7eeee` aligns the UI label with the product contract.
- **Persistence finding:** TaskStore stores TaskReminder data in the canonical Task JSON envelope `legacy_payload_json`; schema version 6 already has `follow_ups` and `follow_up_people`. No new SQL column/table migration was introduced for `followUpId`; persistence relies on the existing JSON envelope. The repository implementation now mirrors a timed Follow-up to a stable `TaskReminder` ID, updates the same ID on edit, and removes only the linked reminder when its time is cleared.
- **Important limitation:** this lifecycle slice has not yet been run through focused tests, full Analyze/test, Build, or Device Smoke on its latest head. The only returned CI evidence is for the older SHA above; no workflow run was returned for the subsequent commits during this check.
- **Release:** `BLOCKED — RELEASE: NO-GO`. Notification/calendar acceptance, Backup/Restore, full migration coverage, exact-SHA validation, official signing and other product gates remain open.
- **Next:** obtain CI evidence on the final current PR head; inspect and fix any resulting failures before expanding the contract.



## WAVE 4.11 IMPLEMENTATION DELTA — 2026-10-19

- Added idempotent FollowUpRepository.add: a repeated write with the same Follow-up ID updates the existing Follow-up instead of appending a duplicate. Commit: 937361328d56bae7b1831e8366f570658826cb15.
- Fixed a Calendar duplication path: FollowUpCalendarProjection now skips a linked TaskReminder mirror and preserves the existing Follow-up Calendar event identity. Added regression coverage in commit 1d820bf3e6f6eb4d5889a2bc4c2835c6e09d5f42; projection change commit a26189099c60985f88ea2500b55ae17c89af8ee3.
- Added an integration test for SQL reload plus canonical Backup/Restore preserving Task ID, Follow-up ID, linked Reminder ID/time/title, Person association, Waiting for Response, and unrelated Reminder. Commit: 2253ef62f404ef064b4bf85d40a16cbf880ed554.
- These commits extend the earlier repository and scheduler changes; they are not yet test-verified. The run previously launched on head 12ef171beef4533d12efe08f3bdacca5e2e03f36 was cancelled after further commits changed the branch. A new Build/Device Smoke run must finish on the final head after this documentation update.
- Remaining known gap: the existing Follow-up UI write coordinator reschedules notifications but does not yet provide evidence that the outbound Calendar sync path performs the complete create/no-op/update/delete lifecycle for this newly linked reminder. Calendar Provider acceptance is separately blocked by the stock emulator lacking a writable calendar.
- Release remains BLOCKED — RELEASE: NO-GO.



## WAVE 4.12 LIVE CHECKPOINT — 2026-10-19

- Live PR #2833 is OPEN/DRAFT/UNMERGED. Base SHA: 49910e585ee73afcf56a7f8d927b9c69e763c5c5. Head at this checkpoint before canonical status docs: d06062fb19c3f3ad54051f3a682f69be4146dd91. main remains d9fb7a247037762216662a20fb32028ecc8a0f6b.
- Build Run [39234124721](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124721) on d06062fb19c3f3ad54051f3a682f69be4146dd91: 9/9 jobs SUCCESS (Analyze, six test shards, Debug APK, Release APK). Artifacts: arvin-debug-apk ID 12178910414 and arvin-release-apk ID 12177339192; both metadata records name the same head SHA.
- Device Smoke Run [39234124429](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124429) was still non-terminal at the last poll: Home, Quick Capture, SQL Persistence, SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. No 7/7 claim.
- PR #2827 Run [39211789444](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211789444) has Verify exact requested revision SKIPPED in Device Smoke jobs; exact-SHA remains BLOCKED.
- PR #2824 head ccc9f9b122420ef999828088f70a7aa950c5b979; main's android/app/build.gradle.kts still uses debug signing for release. Official signing remains BLOCKED.
- PR #2831 Provider acceptance Run [39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224) failed due to lack of a writable Calendar Provider.
- Canonical docs ARVIN_GO_RELEASE_FINAL_STATUS.md and ARVIN_REQUIREMENT_TRACEABILITY_MATRIX.md were absent from both main and the Wave 4.11 branch at inspection. Created as canonical files on this PR branch in commits e2989ffa6b585368bfc4effaf4647ec53a792c46 and 0525f14a93f8d548e6b84cb70daa5d7e1177e6ed; no numbered duplicate was created.
- These docs commits change the head, so their CI must be checked separately; prior Build evidence does not transfer to the new head.
- Release remains BLOCKED — RELEASE: NO-GO.


## Wave 4.13 authoritative live checkpoint — 2026-10-19

- Candidate PR: [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833), Draft/Open/Unmerged. Head at the start of this checkpoint: `4567397be8374c82993271a12f552219a3727be1`; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. This checkpoint adds documentation commits, so the final new head requires fresh gates.
- Build [39235854952](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854952) completed SUCCESS: Analyze, test shards 0–5, Debug APK, Release APK (9/9 jobs). Important boundary: the PR-triggered workflow's `Verify exact requested revision` step was SKIPPED; the Build workflow checks out `github.sha` on PR events. This is successful PR integration-build evidence, **not exact-head checkout proof**.
- Artifacts: Debug [12178863114](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178863114), Release [12179281920](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179281920). GitHub-reported artifact ZIP SHA-256: Debug `30dc12ac9f4abdd498ad31255759752dd4b27b298e297c627d3388651b9f8447`; Release `8b941070eab4a517136631b7660c853989a410268c355867b03eb00589294f7e`. Extracted Release APK SHA-256: `6c6e38199c9d29ae26a4ff33e45082882ff05d0ee0bd8d276889148e78f2fabd`. This is file identity only, not certificate validation.
- Device Smoke [39235854812](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854812): Home and Quick Capture SUCCESS; SQL Persistence and SQL Migration IN_PROGRESS; People, Backup/Restore and Calendar QUEUED at latest poll. Not 7/7.
- Provider artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) from run [39203189292](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203189292): API 35 emulator has `com.android.providers.calendar/.CalendarProvider2`, but no writable calendar row (`accessLevel >= 500`) was found. Result is `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`; the test's harness “1 passed” is not Provider acceptance. Detailed finding recorded in [PR #2831 comment 6264972663](https://github.com/mobinpda-lab/Arvin-clean/pull/2831#issuecomment-6264972663).
- Exact-SHA remains BLOCKED: no connected action can invoke `workflow_dispatch`; PR #2827's exact-target path remains unproven. Official signing remains BLOCKED: release Gradle configuration uses the Debug signing config; no authorized keystore/approved fingerprint is available. The extracted Release APK SHA above does not change that.
- No merge, tag or release. Decision remains **BLOCKED — RELEASE: NO-GO**. New documentation commit changes candidate SHA; all required gates must be refreshed on the resulting head.


## WAVE 4.14 — TERMINAL CI CHECKPOINT — 2026-10-19

Candidate PR: [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833), branch `wave-4-10/follow-up-reminder-contract`. Candidate PR head at the run's source metadata: `77271d24f3ec132868689f17566a7a5e7953d78a`; base SHA last recorded: `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. The two runs below are terminal, but a new documentation commit after this checkpoint changes the candidate head again; the new head requires fresh CI.

### Terminal Build and Device Smoke evidence

- Build [39237043651](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39237043651): all 9 jobs completed successfully (Analyze, test shards 0–5, Debug APK, Release APK). However, the job log's checkout input is synthetic PR merge SHA `c8ddb21ae29ea102e55c02e5d092e783b60a177f`, and `Verify exact requested revision` was SKIPPED. This is successful PR-integration CI, not Exact-SHA proof.
- Device Smoke [39237043144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39237043144): all 7 lanes completed successfully: Home, Quick Capture, SQL Persistence, SQL Migration, People, Backup/Restore, Calendar. The Calendar lane is generic UI/device smoke and does not replace Provider acceptance.
- Build artifacts tied by GitHub run metadata to source head `77271d24f3ec132868689f17566a7a5e7953d78a`:
  - Debug `arvin-debug-apk`, ID [12180240134](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12180240134), GitHub ZIP digest `sha256:a1557fbb675536d23c6d763546acee2e7ba6afb841244b6d467b054e116a4092`.
  - Release `arvin-release-apk`, ID [12179209418](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179209418), GitHub ZIP digest `sha256:fa8e05857316696c45ab21c44538edbadb41d34eb6aadf70c088b41afa1b2ae2`.
- Device Smoke screenshot artifacts are named with checkout SHA `c8ddb21ae29ea102e55c02e5d092e783b60a177f`, confirming the synthetic merge checkout:
  - Home [12179422599](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179422599), digest `sha256:c762ee7799e8e7067bdfeb20bf6cfee930f1a15fe471121a9c6190d0645e069a`.
  - Quick Capture [12178699907](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178699907), digest `sha256:f68b9d6350534b0bce55817fe0e7b090fa811c066a6eaae1ffb5b11220012f32`.
  - Calendar [12180910145](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12180910145), digest `sha256:d0bf1df321c00583c9d1d82b01dc8a78a8c6dccbbf74a7ca3e23d33739c33212`.
  - People [12179689607](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179689607), digest `sha256:a7914fe44f116a5564f7517239862922b04468934e6bef0749de0f7f9f658d8c`.
  - Persian time picker [12178869660](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178869660), digest `sha256:56b658b6772d66adf0c8513b8171c7c6555d3762988b1f5aa410abd7453e0b0f`.
  - Only five artifacts were returned for the Smoke run; no artifact is claimed for each of the other lanes.

### Gates that remain open

- **Exact-SHA: BLOCKED.** PR-triggered checkout was `c8ddb21ae29ea102e55c02e5d092e783b60a177f`; assertion was skipped. Connected GitHub tools do not expose a workflow-dispatch action. PR [#2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827) remains Draft/open.
- **Calendar Provider acceptance: BLOCKED.** Provider diagnostic [39203189292](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203189292), artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149), records Android API 35 with `com.android.providers.calendar/.CalendarProvider2` present but no writable calendar row (`accessLevel >= 500`). Explicit result: `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`. No authorized alternate writable-provider environment is exposed; do not claim CREATE → NO-OP → UPDATE → DELETE acceptance. See [PR #2831](https://github.com/mobinpda-lab/Arvin-clean/pull/2831) and [evidence comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2831#issuecomment-6264972663).
- **Official signing: BLOCKED.** Current default-branch `android/app/build.gradle.kts` lines 34–37 use `signingConfigs.getByName("debug")` for Release. PR [#2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824) documents that an approved release credential and independently approved certificate fingerprint are not available through the connected interface. Artifact existence/build success does not prove signing; no official APK is declared.
- **Follow-up Reminder and remaining product contracts:** implementation exists, but lifecycle, notification reschedule/cancel, idempotency, backup/restore relations and integrated product acceptance remain `IMPLEMENTED_NOT_VERIFIED` until the relevant focused and integrated evidence is available for a fixed candidate SHA. Home, Calendar UX, Reports, People/migration, PDF/font licensing/embedding/RTL visual comparison and Golden Flow remain open where not explicitly evidenced.
- **Release decision:** `BLOCKED — RELEASE: NO-GO`. No merge, tag, or release.

### Next action

After this documentation batch lands, read the new PR head, obtain fresh Build and all seven Device Smoke lanes for that head, and continue exact-SHA/provider/signing paths only through authorized workflows. Do not transfer the run evidence above to a newer SHA.


## WAVE 4.15 LIVE EXECUTION CHECKPOINT — 2026-10-19

### Repository and candidate identity
- Default branch: `main`; live main HEAD observed during this checkpoint: `d9fb7a247037762216662a20fb32028ecc8a0f6b`.
- Follow-up implementation PR [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833) remains OPEN/DRAFT/UNMERGED; current head observed: `273944bb6504c7d51fa4b5f8b869a5519591f682`, base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- No merge, tag, release, or branch-protection bypass performed.

### Referenced Wave 4.14 runs — actual latest poll
- Build [39240952251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952251): terminal SUCCESS; all 9 jobs succeeded and Debug/Release APK artifacts exist (Debug artifact ID `12181028571`, Release artifact ID `12180934054`). This is a PR-triggered run for head `273944bb6504c7d51fa4b5f8b869a5519591f682`; `Verify exact requested revision` was SKIPPED in every job. Analyze ran successfully, tests ran successfully in shards, but this is NOT Exact-SHA acceptance.
- Device Smoke [39240952294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952294): six lanes SUCCESS (Home, Quick Capture, SQL Persistence, People, Backup/Restore, SQL Migration); Calendar lane was still IN_PROGRESS at this poll. Do not report 7/7 until the Calendar lane is terminal SUCCESS. Available screenshot artifacts are associated with the same PR head SHA; they do not prove Exact-SHA dispatch.
- Calendar Provider Acceptance [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995): terminal FAILURE on PR #2831 head `094c43f1f92de263d26950915b13df7380e69244` (not main or PR #2833 candidate). The exact-revision assertion PASSED for that provider-workflow head. Real Provider acceptance FAILED; diagnostic artifact [12182310078](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12182310078) was successfully published by the always-run evidence step. Provider failure remains a blocker; exact checkout does not convert failed CREATE/NO-OP/UPDATE/DELETE into acceptance.
- PRs [#2831](https://github.com/mobinpda-lab/Arvin-clean/pull/2831), [#2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827), and [#2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824) remain the relevant Draft workstreams for Provider, exact-SHA Device Smoke, and signing audit respectively; keep them unmerged until their acceptance gates are met.

### Release blockers reaffirmed from live source
- Exact-SHA: BLOCKED. The Build run's exact-revision assertions were skipped because it was a PR-triggered run; no authorized workflow_dispatch execution was performed in this checkpoint.
- Calendar Provider: BLOCKED. Provider acceptance failed despite publishing diagnostic evidence. Do not label it PASS or weaken the acceptance criteria.
- Official signing: BLOCKED. Live `main` `android/app/build.gradle.kts` configures Release with `signingConfigs.getByName("debug")`. An authorized release key and independently approved certificate fingerprint remain required. The available connector does not expose repository secrets/variables for inspection.
- Integrated product, migration/backup compatibility, PDF/font/RTL, and Golden Flow acceptance remain open until candidate-specific evidence is captured.

### Next actions
1. Poll Device Smoke run `39240952294` to terminal state, particularly `device-smoke (calendar)`; preserve its actual conclusion.
2. Continue implementation on existing PR #2833 and update canonical traceability/evidence documents incrementally; any new head requires new candidate-specific validation.
3. Use only an authorized exact-SHA workflow-dispatch path; do not count skipped assertions as success.
4. Continue provider environment investigation only through supported, reproducible CI configuration; retain diagnostic artifact and `RESULT=BLOCKED_NO_WRITABLE_CALENDAR_PROVIDER` when applicable.
5. Obtain owner-authorized release signing configuration and approved fingerprint before official APK qualification.

**Release decision: BLOCKED — RELEASE: NO-GO.**


## WAVE 4.16 — LIVE EXECUTION CHECKPOINT — 2026-10-19

- PR [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833) remains OPEN/DRAFT/UNMERGED; branch `wave-4-10/follow-up-reminder-contract`; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- New repository-level regression coverage added in `test/follow_up_repository_test.dart` for blank Follow-up title fallback, blank parent/title fallback, title-only edits preserving linked Reminder ID and scheduled time, and repeated updates avoiding duplicate linked Reminder records. Implementation commit: `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`.
- Build [39243365218](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365218) and Device Smoke [39243365263](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365263) were triggered for that code SHA. At checkpoint, Build was IN_PROGRESS and Device Smoke QUEUED/starting; neither is a test PASS yet. The documentation commit following this checkpoint will require the workflows to be rechecked against its new head.
- Prior Device Smoke [39240952294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952294) is terminal CANCELLED; six lanes succeeded and `device-smoke (calendar)` was CANCELLED. Therefore it is not 7/7 acceptance.
- Prior Build [39240952251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952251) is SUCCESS (9/9 jobs) for source metadata SHA `273944bb6504c7d51fa4b5f8b869a5519591f682`; exact revision assertions were SKIPPED. Artifact ZIP digests: Debug ID `12181028571`, `sha256:017b04a392cfbb3fe73cdeb53067b5053b557999b89e088ec2ac3574c9cd17cc`; Release ID `12180934054`, `sha256:def49ff62e32839a2ab8c836b100841e5d9ee7f86e54dae28c99792a8b3639a9`. Neither digest proves the APK's internal SHA-256 or official signature.
- Calendar Provider Run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) failed the real-provider acceptance; its exact-head assertion passed for PR #2831 SHA `094c43f1f92de263d26950915b13df7380e69244`. Diagnostics were published as Artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078). Logs explicitly report `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`; API 35 stock/default emulator exposes CalendarProvider2 but no writable calendar row. No authorized test account or alternate provider environment is exposed by the current integration. Record `RESULT=BLOCKED_NO_WRITABLE_CALENDAR_PROVIDER` for release acceptance; do not weaken criteria.
- Current Build workflow supports `workflow_dispatch` and checks `git rev-parse HEAD` against `target_sha`, but the connected GitHub action interface exposes no workflow-dispatch operation. Exact-SHA execution is therefore blocked pending authorized manual dispatch or another existing authorized runner.
- Live `main` Android Release configuration still uses Debug signing. Owner-authorized keystore and independently approved fingerprint are not available through this interface.
- Release remains **BLOCKED — RELEASE: NO-GO**. No merge, tag, or release was performed.


Wave 4.16 documentation batch commit: `d1dc44be39c118551374c6e5a1cc1330adc5134d`. This follow-up touch is intentionally a new PR-head commit so GitHub's normal PR synchronization can schedule candidate-specific validation; no test result is inferred from the earlier SHA.


## Wave 4.17 — Live continuation update (2026-10-19)

- Actual PR #2833 remains OPEN / DRAFT / UNMERGED. Base is `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`; head before the Wave 4.17 fix was `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7`.
- Build [39243593152](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593152) tests SHA `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7`; last inspected nonterminal: Analyze and shards test-1 through test-5 succeeded; test-0 and Debug/Release APK jobs remained in progress. This is not a final Build pass and does not validate later commits.
- Device Smoke [39243593281](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593281) targets that same old SHA; last inspected: Home and Quick Capture in progress; SQL Persistence, SQL Migration, People, Backup/Restore and Calendar queued. No 7/7 result.
- Lifecycle defect found in `FollowUpReminderDeliveryService.due`: unlike the alarm planner/projection, the due-delivery loop did not skip completed FollowUps, so a completed FollowUp with a past reminderDate could still produce a notification. Fixed by skipping completed FollowUps and adding a regression test in `test/follow_up_reminder_projection_test.dart`. Commit `9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b`. Test/build validation pending on the post-fix candidate.
- Existing repository tests exercise canonical TaskStore load after repository writes, stable linked Reminder ID/time, Person ID preservation, idempotent saves, scoped clearing, and generic title fallback. These tests are present but are not marked verified until their actual test shard completes successfully.
- Calendar Provider run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) concluded FAILURE on older SHA `094c43f1f92de263d26950915b13df7380e69244`; diagnostic artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078) remains available. The integration test requires a real writable calendar and does not fabricate CREATE/NO-OP/UPDATE/DELETE success. Provider acceptance remains BLOCKED.
- Exact-SHA workflow has a `target_sha` input and compares `git rev-parse HEAD` to it, but current connected GitHub actions do not expose an authorized workflow-dispatch operation. PR-triggered jobs do not execute the dispatch-only assertion.
- `main:android/app/build.gradle.kts` still configures Release with the debug signing config. Approved release credentials and independently approved certificate fingerprint are not available. No merge, tag or release is authorized.
- Release decision remains **BLOCKED — RELEASE: NO-GO**. Next action: obtain terminal CI evidence for the latest post-fix candidate, inspect any failed shard logs, then continue the real writable Calendar Provider investigation.


## Wave 4.17 Calendar Provider CI hardening — 2026-10-19

- Inspection of the real diagnostic ZIP for [Run 39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995), artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078), found `CALENDAR_SEED_EXIT=127` and `/system/bin/sh: --bind: inaccessible or not found`. The seed URI contains query-string ampersands, but the remote `adb shell` command did not quote the full remote command; this caused the shell to parse ampersands as control operators. Provider package discovery confirmed `com.android.providers.calendar/.CalendarProvider2` is installed on API 35, but the query returned no calendar rows.
- The current candidate's provider workflow was also found to have two gate issues: its inline script did not attempt to seed a writable acceptance calendar, and the limitation marker path could exit successfully; artifact upload lacked `if: always()`. Corrected the workflow to quote the remote seed command, record seed/query diagnostics, fail closed unless the integration test emits the real PASS marker, and upload diagnostics even on failure. The pull-request target filter now includes the PR's verified integration base branch.
- This is a candidate CI/workflow correction, **not** proof that the provider accepts a writable calendar. The actual CREATE → NO-OP → UPDATE → DELETE sequence must pass on the new workflow run; otherwise the gate remains BLOCKED. The fix is not validated until its run and artifact are inspected.


## Wave 4.17 Calendar Provider runner compatibility correction — 2026-10-19

- New candidate run [39244544605](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244544605) failed before executing provider setup: the emulator runner invokes its script using `/usr/bin/sh`, which rejected Bash-only `set -o pipefail` (`set: Illegal option -o pipefail`). Because failure occurred before `mkdir -p`, the artifact step ran with `if: always()` but had no evidence directory to upload. This is an orchestration failure, not a Calendar Provider acceptance result.
- Corrected the script to POSIX-compatible `set -eu` and added a host-side evidence-directory initialization step before emulator boot. This makes minimal source SHA/started evidence available even if the emulator script fails before reaching its own setup. Artifact upload remains unconditional. Re-run and inspect its terminal result/artifact; writable provider and CREATE → NO-OP → UPDATE → DELETE remain unproven until the integration test emits PASS.


## Wave 4.17 Calendar Provider script isolation fix — 2026-10-19

- Run [39244802042](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244802042) failed after the shell-option issue was corrected. The actual emulator-runner contract executes each newline in its `script` input in a separate `/usr/bin/sh` process; therefore variables and control flow in the inline multiline script did not persist, and the test/output files were not produced. The artifact [12182643345](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244802042/artifacts/12182643345) retained the preinitialized evidence file but did not prove Provider acceptance.
- Replaced the inline multiline script with one invocation, `bash .github/scripts/calendar-provider-acceptance.sh`, so Bash variables, seed result, test result and fail-closed logic execute in a single process. Added the script to workflow path filters and records both actual checkout SHA and PR head SHA. Artifact upload remains `if: always()` with evidence initialized before emulator boot.
- This is a CI harness correction, not a pass. The next run must show seed diagnostics, writable calendar rows, and the real CREATE → NO-OP → UPDATE → DELETE acceptance marker. Otherwise Calendar Provider remains BLOCKED.


# WAVE 4.18 LIVE EXECUTION UPDATE — 2026-10-19

- PR #2833 is OPEN / DRAFT / UNMERGED. Base: `fix/follow-up-record-authority-20261019`; head branch: `wave-4-10/follow-up-reminder-contract`.
- Before the Wave 4.18 code fix, head was `95d1128b0a71e84da8a2fa356e7b484d26d42163`.
- Build [39245131077](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131077) completed SUCCESS, all 9 jobs; all six test shards, Analyze, Debug APK and Release APK passed. The exact-target assertion was SKIPPED in PR-triggered jobs.
- Device Smoke [39245131071](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131071) completed SUCCESS on the recorded integration revision; all seven lanes passed. This does not replace Provider Acceptance.
- Calendar Provider Acceptance [39245131251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251) FAILED at UPDATE with `PlatformException(calendar_write_failed, Android Calendar Provider update failed, ...)`. Diagnostic artifact [12183547745](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251/artifacts/12183547745), digest `sha256:7e78ac4527d476c06b90e336fd1b8c0df62914be780570d0a9b28902290f6391`.
- Root cause identified in `MainActivity.kt`: UPDATE used an event item URI plus an extra calendar-ID selection. Targeted fix verifies the event/calendar relationship first, then updates the exact item URI without selection.
- Fix commit: [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f). New exact-head CI evidence was not returned at the latest query. Treat the fix as IMPLEMENTED_NOT_VERIFIED.
- Follow-up repository/projection tests were observed passing in the prior Build logs, including completed Follow-up suppression, stable reminder identity, no duplicate reminder, clearing scoped to the intended reminder, and `nextFollowUp` alone not creating a Reminder. These results predate the Kotlin fix.
- Release remains BLOCKED — RELEASE: NO-GO. Exact-SHA dispatch, official signing, real Provider lifecycle PASS and new-head validation remain open.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

Next action: finish fresh Build, Provider and all seven Device Smoke lanes triggered by this test-coverage update; then bind the resulting evidence to the candidate SHA. Exact-SHA dispatch and official signing remain external authorization blockers.


## Wave 4.24 — live acceptance evidence and release gate checkpoint (2026-10-19)

### Revision identity and CI
- PR #2833 is OPEN / DRAFT / UNMERGED. Branch `wave-4-10/follow-up-reminder-contract`; source HEAD at evidence collection: `78dd233f855fdd433b098b861a9e3d33aee44539`; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- Build [39259685729](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685729): SUCCESS, 9/9 jobs (Analyze, test-0..test-5, APK Debug, APK Release); event `pull_request`; run head SHA `78dd233f855fdd433b098b861a9e3d33aee44539`. Every observed job skipped `Verify exact requested revision`, because it was not a `workflow_dispatch` event.
- Device Smoke [39259685756](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685756): SUCCESS, all 7 lanes: Home, Quick Capture, SQL Persistence, SQL Migration, People, Backup/Restore, Calendar. Run metadata binds it to source HEAD `78dd233f855fdd433b098b861a9e3d33aee44539`.
- Calendar Provider Acceptance [39259685716](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685716): SUCCESS on `78dd233f855fdd433b098b861a9e3d33aee44539`. Artifact [12189897161](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685716/artifacts/12189897161), archive ZIP digest `sha256:f5ca9a7b68a73c45ed338478a1832ce14fba3375eccf446345d7d961b3e8ecae`. Real-provider log: unrelated event IDs 1 and 2 preserved; CREATE produced event ID 3; NO-OP retained one event ID 3; UPDATE retained ID 3 and changed title; migration to destination calendar 2 produced event ID 4 and `CALENDAR_PROVIDER_DESTINATION_MIGRATION=PASS from=1 to=2`; DELETE logged `targetPresent=false calendarId=2`; final `CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=1`.
- Build artifact Release ID `12191485284`, archive digest `sha256:e469d28d238a2fa04d1ae30091cf981f4d532fb0f9885ee00f643a7279e20aa6`; Debug ID `12190236537`, archive digest `sha256:4ac84224418afd349e2eb724f6a03a7980a5efcfd0c482cc84ac3b8aabea0bba`. Both unexpired at verification. These digests are for artifact ZIP archives, NOT the extracted APK file SHA-256.
- Device Smoke artifact records were unexpired: Calendar ID `12191647845`, ZIP digest `sha256:28f9f0581df8932616bb48efbb07a98baa8799122b4d6b01d3f7fc5879d71a69`; People ID `12190801898`, `sha256:389b019feae859b77a0dc715330c26e4eeb8e505bc7029068c2be7741cc4a30e`; Persian time picker ID `12190421213`, `sha256:3443555b4e16abfc2a9591cec08aae830fe88581876c4d33f639c4e70056dcc7`; Home ID `12190271340`, `sha256:47f13af9d2b0bbd225705b84e5523bc215d22f4730d73573da411ab0d3905b40`; Quick Capture ID `12190121552`, `sha256:68d97f839a58af18211edd673e1d30373fd15f5fb384ea3b1016dd30fe5e3064`. All are ZIP digests, not APK hashes.
- These run/artifact results are valid only for source SHA `78dd233f855fdd433b098b861a9e3d33aee44539`. This documentation commit creates a new SHA and inherits no CI PASS automatically.

### Follow-up Reminder and notification
- Existing tests in `test/follow_up_repository_test.dart`, `test/follow_up_reminder_projection_test.dart`, `test/follow_up_reminder_model_test.dart`, `test/follow_up_reminder_delivery_service_test.dart`, `test/follow_up_reminder_runtime_contract_test.dart`, `test/services/follow_up_reminder_alarm_planner_test.dart`, and `test/integration_task_reminders_migration_backup_test.dart` passed as part of Build 39259685729 on `78dd233f855fdd433b098b861a9e3d33aee44539`.
- Coverage includes Persian title fallback, stable identity/time when title changes, deduplication, Task/Follow-up reminder independence, completed/archived/trashed suppression, legacy scheduler identity, alarm rescheduling/reboot wiring, and SQL plus canonical Backup/Restore. Test `Follow-up Reminder IDs and relation survive SQL plus canonical Backup/Restore` asserts stable Task, Follow-up and linked TaskReminder IDs, date/title, waiting-for-response, and Person ID.
- Notification scheduling/cancellation is implemented via existing AlarmManager scheduler (alarm ID 42002), reschedule and cancel paths, reboot rescheduling, background runner and persisted delivery state; tests prove code/runtime contracts, not real Android delivery/tap acceptance.
- Notification tap routing fix is included in this candidate: both existing notification services now encode Task ID plus optional Follow-up ID using `ReminderNotificationPayload`; `lib/main.dart` initializes the existing local-notification plugin with a response callback, resolves the canonical Task by ID, and opens `TaskDetailPage` while passing the Follow-up ID; `TaskDetailPage` highlights that Follow-up when present. Added `test/reminder_notification_payload_test.dart` for structured payload, task-only and legacy compatibility, and expanded `test/follow_up_reminder_runtime_contract_test.dart` for wiring. Status: IMPLEMENTED / IN_PROGRESS pending fresh CI and device-level tap acceptance; no device-level acceptance claim.
- Backup/Restore SQL evidence is focused automated integration coverage, not a single accepted Task → Follow-up → Person → Reminder → Calendar → parent Task → Report → Backup → Restore → Integrity journey. Full journey remains NOT VERIFIED.

### PDF, Exact-SHA, official signing
- PDF source `lib/services/task_report_pdf_renderer.dart` loads bundled VazirHarf regular/bold fonts and uses `pw.MultiPage` with RTL, header/footer and page numbering. However, `test/task_report_pdf_renderer_test.dart` injects Helvetica and only asserts `%PDF` bytes; no current candidate PDF Preview artifact was available for inspection. Embedded Persian font, shaping, visual RTL, clipping, tables, multi-page output and preview/export parity remain NOT VERIFIED.
- `.github/workflows/build.yml` has `workflow_dispatch.inputs.target_sha`; checkout uses that input and the job checks `git rev-parse HEAD` then prints `EXACT_TARGET_SHA`. Connected GitHub tools expose no dispatch action. Exact-SHA remains BLOCKED until an authorized owner dispatches the existing workflow with the chosen exact SHA and preserves assertion/run/artifact provenance.
- `android/app/build.gradle.kts` still configures Release with `signingConfigs.getByName("debug")`. No authorized release keystore or independently approved certificate fingerprint was provided. Official signing remains BLOCKED; no official APK, tag or release is authorized.
- **Release decision: `BLOCKED — RELEASE: NO-GO`.** Keep PR #2833 OPEN / DRAFT / UNMERGED. Do not tag or release. Owner dependencies: authorized target-SHA dispatch; release key and approved certificate fingerprint; PDF artifact/device visual review; device-level notification-tap acceptance; integrated product acceptance.

## Wave 4.25 — live GitHub verification checkpoint (2026-10-19)

- Live PR #2833 remains OPEN / DRAFT / UNMERGED. Source branch HEAD verified as `8e0e36eb4fda7bd45f45c463a1092d79c56f4e9`; base SHA `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- Current-head Build [39279795513](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795513), Device Smoke [39279795764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795764), and Calendar Provider Acceptance [39279795585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795585) are still returned by GitHub run metadata as `queued` with no conclusion. Do not mark Analyze, six test shards, Debug/Release build, any of seven device lanes, or Provider lifecycle PASS on the strength of these run summaries.
- Artifact API nevertheless reports artifacts linked by `workflow_run.head_sha=8e0e36eb4fda7bd45f45c463a1092d79c56f4e9`: Build Release artifact ID `12200766920`, archive digest `sha256:32621f1871b44231a98b1fc1f1c21592e6c9238c37f714421a4590b4ccb099f5`; Build Debug artifact ID `12198609222`, archive digest `sha256:5f46381a29cab192ac4ed07aa830f81d29a2fe9b3e38df844c2d55c099a8dc59`; Provider evidence artifact ID `12199769292`, archive digest `sha256:9e66a1ab0bfb7818af81b09a74d10fff08d5b25f5ce5787ec2ab5faa849a02f6`. Device Smoke artifacts linked to the same run: People ID `12201786697`, digest `sha256:7f5749ddb566d2261264c6ba5b69b9a7d3a51bd859839192be78b465aa9766ac`; Quick Capture ID `12200436029`, digest `sha256:a3f1fd398f8a49f3839d0e2246542f89dbbadb1da285fb022a0b2292b2aef251`; Home ID `12200371212`, digest `sha256:ee4016473c500ae44f94080316bc439291d940f0a2bcf1df41a18efdd7da5286`; Persian time picker ID `12199867439`, digest `sha256:9b259b150700d8a0d467d5e6761eb0fc3a7a1d9451261eb4c5f8f882c21676c1`. These digests identify artifact ZIP archives, not extracted APK bytes. The mismatch between queued run state and artifact presence is unresolved; treat all test/build outcomes as NOT VERIFIED until terminal job logs are available.
- Reminder payload and parent-Task routing changes in `8e0e36e` have not yet obtained verifiable terminal Build/test or device-tap acceptance. Existing notification service classes also call `initialize` without a tap callback; whether that reinitialization overrides the app callback must be checked against actual plugin behavior and tested, not assumed.
- Exact-SHA remains BLOCKED for this HEAD: `.github/workflows/build.yml` has a `workflow_dispatch.target_sha` checkout/assertion path, but connected GitHub actions expose no workflow-dispatch operation. Owner must dispatch the existing workflow with the exact current SHA and provide run logs showing checkout and `EXACT_TARGET_SHA`.
- PDF acceptance remains NOT VERIFIED: the existing renderer uses VazirHarf and `pw.MultiPage` with RTL, but the current test injects Helvetica and only checks PDF bytes. No visually reviewed multi-page PDF artifact is confirmed. Official Release signing remains BLOCKED because `android/app/build.gradle.kts` still uses `signingConfigs.getByName("debug")`; no authorized keystore or independently approved fingerprint was supplied.
- No source-code regression was confirmed from the queued workflow metadata alone; no unverified fix is being claimed. Next action is to restore/obtain terminal CI job evidence for this exact SHA, verify notification callback initialization behavior, then run focused tests and device-tap acceptance. Keep release `BLOCKED — RELEASE: NO-GO`.


## Wave 4.25 — live evidence reconciliation (2026-10-19; parent SHA 4875d93f03d3afb21f888a0873021b5b4abba943)

- PR #2833 remains OPEN / DRAFT / UNMERGED; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. This entry is tied to parent SHA 4875d93f03d3afb21f888a0873021b5b4abba943; this documentation commit creates a new candidate SHA and requires fresh validation.
- Historical baseline runs: Build [39279795513](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795513) has 9/9 jobs SUCCESS, but the exact-target assertion was SKIPPED. Its Release APK artifact is ID `12200766920` (ZIP digest `sha256:32621f1871b44231a98b1fc1f1c21592e6c9238c37f714421a4590b4ccb099f5`) and Debug artifact ID `12198609222` (ZIP digest `sha256:5f46381a29cab192ac4ed07aa830f81d29a2fe9b3e38df844c2d55c099a8dc59`). These belong to old source SHA `8e0e36eb4fda7bd45f45c463a1092d79c56f4e9`; ZIP digests are not extracted APK SHA-256 values.
- Historical Device Smoke [39279795764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795764) is not a full pass: Home, Quick Capture, SQL Persistence, SQL Migration and Backup/Restore are reported SUCCESS; Calendar is CANCELLED; People job API state remains inconsistent with its successful test log/artifact. Historical Calendar Provider [39279795585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795585) has direct log assertions for CREATE count=1 event 3, NO-OP same event 3, UPDATE same event 3, migration to calendar 2 creating event 4, DELETE target absent, unrelated events 1 and 2 preserved, and `CALENDAR_PROVIDER_ACCEPTANCE=PASS`. Run conclusion says success, but evidence is still for old SHA `8e0e36e`, not the current candidate.
- Fresh runs for candidate `4875d93f03d3afb21f888a0873021b5b4abba943`: Build [39282588754](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588754), Device Smoke [39282588770](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588770), and Provider [39282588748](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588748) have run/job metadata still showing QUEUED/IN_PROGRESS while job logs/artifacts exist. Treat this GitHub status/log inconsistency as unresolved and do not claim overall terminal PASS.
- Fresh Build logs include `No issues found!`; Debug APK artifact ID `12201152707` (ZIP digest `sha256:1113be566b8daa5c72dfd451ea27a753aed39f3ab0aa91ac879afc5e71cc8c61`) and Release APK artifact ID `12200834485` (ZIP digest `sha256:54ce12bfeedd4a14ee9c4fa1121181e07296aba69674313baf0b59e41e460016`) were uploaded. Six test-shard terminal conclusions are not returned by the run/job API; keep the complete Build gate NOT VERIFIED. Exact-target assertion was SKIPPED on this PR-triggered run.
- Fresh Device Smoke log evidence: Quick Capture test PASS (artifact IDs `12202885348`, ZIP digest `sha256:3f22ade766b1bbcaf24fe5971d3b297578f2f521310d48fea8f9e4d4055886f8` and Persian time-picker ID `12201182565`, ZIP digest `sha256:979bf6eb90c5b820c76e8ff163134378f8b28857b4df8b46bcb4c334dcf74fd6`); SQL Persistence PASS; SQL Migration PASS; Backup/Restore PASS; People PASS (artifact ID `12201378970`, ZIP digest `sha256:10642bf5a83451631b9bacadc82f6a169bbeb62d2f6e7962cc7d1d7a78c69b72`). Home failed before the smoke test because Android SDK system-image download reported `Error on ZipFile unknown archive`; this is an infrastructure failure, not evidence of an app assertion failure. Calendar lacks complete acceptance evidence; expected screenshot artifacts were not produced and the lane is NOT VERIFIED. Do not transfer these PR-run results to a later SHA.
- Fresh Provider log for run [39282588748](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588748) directly prints the same CREATE/NO-OP/UPDATE/DELETE and two-calendar migration assertions with `CALENDAR_PROVIDER_ACCEPTANCE=PASS`; artifact ID `12201482721`, ZIP digest `sha256:1b357462abbc2fdc9442e6a1272faa338d278a1887e8233226ff5237cb706503`. Because GitHub still reports the job/run QUEUED, classify formal Provider gate as IN_PROGRESS/NOT VERIFIED until terminal status reconciles, while retaining the direct test output as provisional evidence.
- Exact-SHA remains BLOCKED: existing `.github/workflows/build.yml` supports `workflow_dispatch.target_sha`, but no dispatch action is exposed in the connected GitHub tools. The PR-triggered run skipped `Verify exact requested revision`; the owner must dispatch the existing workflow for the final SHA and preserve `git rev-parse HEAD` / `EXACT_TARGET_SHA` logs.
- Reminder/notification tap, cold-start destination, deleted/missing record handling and full end-to-end product acceptance remain NOT VERIFIED. Existing service classes initialize local-notification plugins without a tap callback; inspect/test callback ownership rather than assuming it is a confirmed defect. PDF visual acceptance remains NOT VERIFIED: the current renderer uses VazirHarf and RTL MultiPage, but the existing test substitutes Helvetica and checks only PDF bytes; no reviewed multi-page PDF artifact exists. Release signing remains BLOCKED because `android/app/build.gradle.kts` still selects the Debug signing config for Release and no authorized keystore/approved fingerprint is available.
- Decision: `BLOCKED — RELEASE: NO-GO`. Keep PR Draft; no merge, tag or release. Next: reconcile/poll run/job conclusions, rerun only failed infrastructure lanes if GitHub permits, then dispatch exact SHA and complete notification-tap, PDF visual, and signing gates.


## Calendar Device Smoke follow-up-card lookup — 2026-10-19 (PR #2833)

- **Symptom:** `integration_test/calendar_card_interaction_test.dart` failed at the follow-up card lookup because the expected reminder-card key was not found.
- **Production Key contract confirmed:** `lib/calendar_page.dart` builds the row key as `ValueKey('reminder-card-${item.id}')`; `lib/services/follow_up_calendar_projection.dart` constructs the projected ID as `followup:${task.id}:${followUp.id}`. Therefore the test key `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up` matches production. No production behavior or build-system settings changed.
- **Seed finding:** the integration test explicitly persists Task ID `calendar-smoke-task` with Follow-up ID `calendar-smoke-follow-up` and a non-null `reminderDate`. This reduces, but does not alone eliminate, a seed/projection issue.
- **Test action:** wait (bounded to 15 seconds) for production calendar-ready anchors `calendar-month-year-header` and `calendar-view-mode-control`; use bounded `scrollUntilVisible` within `calendar-selected-day-list` before asserting the same exact card key. Existing editor, Persian time-picker, long-press completion, and SQLite assertions are retained.
- **Evidence/status:** PR [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833). **Pending CI rerun** for the commit containing this entry. Do not classify as resolved until the Calendar Device Smoke lane passes on that commit SHA.


## Wave 4.37 — final reconciliation of existing Device Smoke and Calendar Provider evidence (2026-10-19)

### Source revision and scope
- PR #2833: https://github.com/mobinpda-lab/Arvin-clean/pull/2833
- Device Smoke run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553
- Run metadata `head_sha`: `ee2239ca5d41037ec0de0cd94a67cc0c84eeacaf`.
- The actual repository checkout in the seven Device Smoke job logs is synthetic PR merge commit `4852fa1069862dc397717652823028f585053285`, merging PR head `ee2239ca5d41037ec0de0cd94a67cc0c84eeacaf` into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are distinct identities. The run is valid integration evidence for that merge checkout, not proof of the standalone exact-head assertion.
- Job states are terminal: all seven jobs have `status=completed`, `conclusion=success`. No lane was cancelled, skipped, or failed at job level.
- The earlier 404 BlobNotFound while retrieving Calendar logs was transient/access-to-log retrieval trouble, not a product failure. The later log retrieval succeeded and contains test completion plus uploaded screenshot evidence.

### Seven-lane Device Smoke ledger
| Requirement/lane | Existing test or behavior | Verified source / checkout | Run and Job | Evidence | Status | Next action |
|---|---|---|---|---|---|---|
| Home | Existing Android Home smoke | PR head `ee2239ca5d41037ec0de0cd94a67cc0c84eeacaf`; checkout merge `4852fa1069862dc397717652823028f585053285` | Run `39300092553`; Job `118222713386` | [Home artifact 12211916540](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553/artifacts/12211916540), not expired | PASS | Reuse evidence; no rerun required for this tested merge |
| Quick Capture | Existing Android Quick Capture smoke | Same run checkout | Run `39300092553`; Job `118222713328` | [Quick Capture artifact 12210501483](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553/artifacts/12210501483), not expired; Persian time-picker artifact `12212245974` | PASS | Reuse evidence |
| SQL Persistence | Existing SQL persistence integration smoke; log says all tests passed | Same run checkout | Run `39300092553`; Job `118222713333` | [Run/job logs](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553) | PASS | Reuse evidence |
| SQL Migration | Existing legacy-to-canonical SQL migration smoke; log says all tests passed | Same run checkout | Run `39300092553`; Job `118222713304` | [Run/job logs](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553) | PASS | Reuse evidence |
| People | Existing Android People smoke; log says all tests passed | Same run checkout | Run `39300092553`; Job `118222713427` | [People artifact 12211712598](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553/artifacts/12211712598), not expired | PASS | Reuse evidence |
| Backup/Restore | Existing portable-backup round-trip test; log says Task and Calendar-link metadata round-trip and all tests passed | Same run checkout | Run `39300092553`; Job `118222712968` | [Run/job logs](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553) | PASS for automated smoke only | Keep real-file-provider/owner-device restore and rollback acceptance separate; do not infer them from this smoke |
| Calendar | Existing `integration_test/calendar_card_interaction_test.dart`; log confirms seeded SQLite record, Follow-up editor opened, Persian time picker rendered, long-press completion persisted `completed=true`, no Flutter framework exception, and `All tests passed` | Same run checkout; tested merge includes prior test-only Scrollable finder correction | Run `39300092553`; Job `118222713216` | [Calendar screenshot artifact 12211918196](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092553/artifacts/12211918196), not expired; SHA-256 ZIP digest `c560d572465df5f56cbf8a7960886345515103c2acf829ecc6df2acc28a333c2` | PASS | Reuse evidence; no code change or repeated test is warranted for this tested checkout |

### Calendar Provider Acceptance — independent gate
- Run: [39300092611](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092611)
- Job: `118222713369`, `android-calendar-provider`, terminal `completed / success`.
- Run metadata head SHA: `ee2239ca5d41037ec0de0cd94a67cc0c84eeacaf`; checkout in the job log is merge commit `4852fa1069862dc397717652823028f585053285`.
- Log assertions: `CALENDAR_PROVIDER_DESTINATION_MIGRATION=PASS from=1 to=2`; `PROVIDER_QUERY_DELETE targetPresent=false calendarId=2`; unrelated event IDs 1 and 2 remain present; `CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=1`; `1 test passed`.
- Artifact: [12212001868](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39300092611/artifacts/12212001868), not expired; ZIP digest `sha256:8fe24ef95afc10926c97b849d6de5d1fadaf9e0c3c3583485eae43167dda4563`.
- Status: PASS for this automated writable-provider acceptance run. This is separate from Calendar Device Smoke and does not establish physical-device acceptance.

### Revision and release qualification
- Commit `ee2239ca5d41037ec0de0cd94a67cc0c84eeacaf` fixes the Calendar test's scrollable finder by finding the descendant `Scrollable` inside the selected-day list and passing that finder to `scrollUntilVisible`. The passing Calendar log is the first verified result for that correction in the existing Device Smoke workflow; no new implementation or test was added in Wave 4.37.
- No code or test changes were made in Wave 4.37. Documentation reconciliation only.
- Exact-SHA gate remains BLOCKED because the run checks out synthetic merge SHA `4852fa1...` and the PR-triggered Build skipped `Verify exact requested revision`. The repository owner must use the existing authorized `workflow_dispatch.target_sha` path for the final candidate and retain `git rev-parse HEAD` plus `EXACT_TARGET_SHA` assertion output.
- Official release signing remains BLOCKED: current `android/app/build.gradle.kts` selects the Debug signing config for Release; authorized keystore/signing credentials and independently approved certificate fingerprint are still required.
- Notification tap/cold-start/deduplication/deleted Follow-up behavior, reviewed multi-page Persian PDF output, full Golden Flow, real file-provider restore/rollback, physical-device acceptance and final owner approval remain NOT VERIFIED.
- Release decision remains `BLOCKED — RELEASE: NO-GO`. Keep PR #2833 open and Draft; do not merge, tag or publish an official APK until mandatory gates pass on a properly verified release candidate.



## Wave 4.38 — terminal CI reconciliation (2026-10-19)

- **PR/current source head at run:** 1d3895af33dc8c01b062e2da68e1a8205d14ffa2; PR #2833 remains OPEN / DRAFT / UNMERGED. Base fix/follow-up-record-authority-20261019 at 49910e585ee73afcf56a7f8d927b9c69e763c5c5.
- **Build:** [Run 39308371898](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371898), all 9 jobs SUCCESS (Analyze, test shards 0–5, Debug APK and Release APK). Job 118252409261 built app-release.apk and uploaded artifact [12215506637](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371898/artifacts/12215506637), GitHub ZIP digest sha256:1a80b2a36136369113b8aaf00eb257a0cce204275cb807fdfea339822a18a6f2. Debug artifact [12214683792](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371898/artifacts/12214683792), ZIP digest sha256:7f17b789e4e1a1f3c57ff2d2740a4f96fd11a31cd5514f37e884e0c9ed9035d3. These are archive digests, not APK file SHA-256 values.
- **Checkout identity:** Build release Job checked out synthetic merge commit a369a3456fbd8ddce4368729f9c5297a3f70d78f; Calendar Provider and Device Smoke logs checked out refs/remotes/pull/2833/merge. The run metadata head is the PR head above, but none of these runs is an Exact-SHA workflow_dispatch execution.
- **Device Smoke:** [Run 39308371890](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371890), all 7 lanes SUCCESS: Home Job 118251309851, Quick Capture 118251309759, SQL Persistence 118251309226, SQL Migration 118251309511, People 118251309672, Backup/Restore 118251309567, Calendar 118251309836. Evidence artifacts: Home [12214363685](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371890/artifacts/12214363685), Quick Capture [12215486002](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371890/artifacts/12215486002), People [12216330167](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371890/artifacts/12216330167), Persian time picker [12215381051](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371890/artifacts/12215381051), Calendar [12214939829](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371890/artifacts/12214939829). Emulator smoke is not physical-device acceptance.
- **Calendar Provider:** [Run 39308371798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371798), Job 118251224093 SUCCESS. Log explicitly records CALENDAR_PROVIDER_DESTINATION_MIGRATION=PASS from=1 to=2 and CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=1. Artifact [12214803297](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371798/artifacts/12214803297), ZIP digest sha256:288607988d9a73340b50de286615997de751805354ea9ef6e829d8d9cbfe7baa.
- **Exact-SHA:** BLOCKED / OWNER ACTION REQUIRED. Workflow .github/workflows/build.yml has workflow_dispatch.target_sha and checks git rev-parse HEAD == TARGET_SHA, but the available GitHub connector in this session exposes no workflow-dispatch operation. Owner must run the existing Arvin Build workflow with target_sha=1d3895af33dc8c01b062e2da68e1a8205d14ffa2 and preserve successful assertion logs from all quality and APK jobs. PR CI is not a substitute.
- **Official signing:** BLOCKED. android/app/build.gradle.kts configures Release with signingConfigs.getByName("debug"). The APK artifact is not official-release evidence. Obtain the authorized keystore/configuration through the approved secret path and an independently confirmed owner fingerprint; then run apksigner verify --verbose --print-certs, compare the certificate fingerprint, and calculate SHA-256 of the extracted APK file separately from the ZIP digest. No APK file SHA or certificate verification is claimed here.
- **Remaining product/owner gates:** notification tap/cold-start/deduplication/cancel/deleted-follow-up behavior, visually reviewed multi-page Persian PDF, the full Task-to-restore Golden Flow and integrity comparison, physical-device acceptance, and owner approval remain NEEDS_VALIDATION or BLOCKED_OWNER_ACTION. Existing tests and passing emulator lanes are preserved; no duplicate run was started merely for this report.
- **Decision:** keep PR Draft and unmerged. BLOCKED — RELEASE: NO-GO; no official tag or APK release.


## Wave 4.39 — live PR CI and APK artifact reconciliation (2026-10-19)

- **PR/source head at audit:** [PR #2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833) is OPEN / DRAFT / UNMERGED. Source head `1f13ac39ef55f3d555aca358ba7a975d9828f206`; base `49910e585ee73afcf56a7f8d927b9c69e763c5c5` (`fix/follow-up-record-authority-20261019`). Branch `wave-4-10/follow-up-reminder-contract` was verified at this head before this evidence-only documentation commit.
- **Build on audited head:** [Run 39313298073](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39313298073), event `pull_request`, conclusion SUCCESS. Analyze, six test shards, Debug APK and Release APK all passed. Exact-revision verification steps were SKIPPED because this is not `workflow_dispatch`. Release Job 118268207010 checked out synthetic PR merge commit `3aae3d59d5e12afb6c06ef858df2a79321374be2` (merge of source head `1f13ac39...` into base `49910e585...`), not the source head alone.
- **Current PR Release artifact:** [Artifact 12215903929](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39313298073/artifacts/12215903929), ZIP SHA-256 `13ac97caffde6e7afb6e30d85bf82c39b4373d24506637317ea777e628132496`; extracted `app-release.apk` SHA-256 `e9b2af30f2621221a07ae4ac29c03c41b4db4232576e1c24fca945e1c4f44ada`. Artifact is associated with the synthetic merge checkout above and is **not** an officially signed release.
- **Device Smoke:** [Run 39313298217](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39313298217), event `pull_request`, SUCCESS. All seven lanes passed: Home Job 118268210184; Quick Capture 118268210119; SQL Persistence 118268210076; SQL Migration 118268209900; People 118268210177; Backup/Restore 118268210256; Calendar 118268210168. Logs checked out merge commit `3aae3d59d5e12afb6c06ef858df2a79321374be2`. Emulator evidence is not physical-device acceptance.
- **Calendar Provider:** [Run 39313298133](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39313298133), event `pull_request`, SUCCESS; Job 118268207069. Log reports create/no-op/update/delete acceptance and `CALENDAR_PROVIDER_DESTINATION_MIGRATION=PASS from=1 to=2`, `CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=1`. Artifact [12216993383](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39313298133/artifacts/12216993383), ZIP digest `sha256:5fdb81d02d208414496f7c856bbebaa6ca37c3a96a09f308ceb353d0a2cd5eaf`. Checkout was synthetic merge commit `3aae3d59...`.
- **Historical APK re-verified from GitHub:** [Build Run 39308371898](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371898), event `pull_request`, source head `1d3895af33dc8c01b062e2da68e1a8205d14ffa2`; Release artifact [12215506637](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39308371898/artifacts/12215506637) is available and not expired. Downloaded ZIP SHA-256 recomputed as `1a80b2a36136369113b8aaf00eb257a0cce204275cb807fdfea339822a18a6f2`; extracted `app-release.apk` SHA-256 recomputed as `67c692378366ac8b50df0418b9279188fd40eba9535bfcb96101ecec01e24c71`. Historical Release Job checkout was synthetic merge SHA `a369a3456fbd8ddce4368729f9c5297a3f70d78f`. Do not attribute this historical APK to the current source head.
- **Exact-SHA:** BLOCKED — OWNER ACTION REQUIRED. Existing `.github/workflows/build.yml` accepts `workflow_dispatch.target_sha` and asserts `git rev-parse HEAD == TARGET_SHA`, but no dispatch/write operation is exposed by the current GitHub connector. Owner must manually run the existing **Arvin Build** workflow against the then-current PR source head, not a stale SHA, and verify `EXACT_TARGET_SHA` plus successful assertion in Analyze, all six test shards, and both APK jobs. PR runs are not substitutes.
- **Official signing:** BLOCKED. `android/app/build.gradle.kts` still sets Release signing to `signingConfigs.getByName("debug")`. Neither the historical APK nor the current PR artifact is official-release evidence. Require owner-provided authorized signing configuration through a secure channel, independently confirmed expected certificate fingerprint, `apksigner verify --verbose --print-certs`, fingerprint comparison, and a separately recorded APK file SHA-256.
- **Product acceptance gates:** notification tap/cold-start/payload restoration/deduplication/deleted Follow-up and cancel behavior; real multi-page Persian PDF with embedded official font and visual review; end-to-end Task → Checklist → Reminder → Follow-up → Person → Calendar → Notification → Report → Backup → Restore → Restart → Integrity; physical-device acceptance; and owner release approval remain NOT VERIFIED / BLOCKED. Emulator lanes and component tests do not close these gates.
- **Release decision:** retain PR #2833 OPEN / DRAFT / UNMERGED. `BLOCKED — RELEASE: NO-GO`; no merge, official tag, or release publication.

## Wave 4.42 — Secure Android Release signing implementation (2026-10-20)

- Live PR #2833 at the start of Wave 4.42: OPEN / DRAFT / UNMERGED; source branch `wave-4-10/follow-up-reminder-contract`; prior source HEAD `df6f03a0d946a49669a4917d8842f9d96c0b85e8`; base branch `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Reconcile the live PR again after the Wave 4.42 commits; do not treat the initial HEAD as the final candidate.
- Confirmed at the inspected branch revision: `android/app/build.gradle.kts` selected `signingConfigs.getByName("debug")` for the Release variant. `android/key.properties` was not present. The build workflow already supports `workflow_dispatch.target_sha` and logs `EXACT_TARGET_SHA` after comparing it to `git rev-parse HEAD`.
- Implementation commits on the existing PR branch: Gradle fail-closed signing config `2ab94473ae61b6d1d99565e889116e55d101acb1`; existing Build workflow kept exact-SHA validation and labels its Release-variant artifact as development-only (`e106bacfb88953230e59a912a7183a16aa0281c0`); canonical release signing/verification integrated into the existing `.github/workflows/release-closure.yml` (`347be0f79890acb92e601f7ed6d6bad2eea6756f`); legacy ungated `.github/workflows/release.yml` disabled (`556f9912840ec588e509ea1809d4da30677d5896`); signing-material ignore rules `015edef211ff9a0c45050359ce6e9ff6d5fca15a`. These changes do not constitute a signed APK or release.
- Gradle now uses `ARVIN_OFFICIAL_RELEASE=true` to select `arvinProduction`, requires keystore path/password/alias/private-key password, and enables v2/v3 signing. Without the explicit official flag, the existing Release-variant build remains Debug-key-signed for development only; the workflow labels that artifact as non-official. Official mode has no Debug fallback.
- The official signing path is the pre-existing `Arvin Release Closure` workflow, not `Arvin Build`: it only runs automatically after successful Device Smoke on pushed `main`, or by manual dispatch from `refs/heads/main` with `target_sha` equal to the current main tip. It verifies checkout SHA, requires the five secrets, signs with the production key, requires `apksigner` v2/v3 and the independent certificate fingerprint match before creating the internal artifact or reaching product-release gates, records APK SHA-256 and provenance, and attempts cleanup with `if: always()`. Existing releases are not treated as complete unless their release body contains the verified-signature/fingerprint markers, so historical Debug-signed artifacts cannot bypass the new check. The existing `Arvin Build` retains `workflow_dispatch.target_sha` exact-SHA validation and labels its ordinary Debug-key-signed Release-variant artifact as non-official.
- Required repository Actions Secrets: `ARVIN_RELEASE_KEYSTORE_BASE64`, `ARVIN_RELEASE_STORE_PASSWORD`, `ARVIN_RELEASE_KEY_ALIAS`, `ARVIN_RELEASE_KEY_PASSWORD`, `ARVIN_RELEASE_CERT_SHA256`. Connected tools cannot inspect repository secret values/presence or dispatch workflows; availability remains UNKNOWN until the owner adds secrets and executes the authorized path.
- Provenance in the release-closure workflow records workflow name/event, requested target and checked-out SHA, run/job IDs, source PR HEAD/merge/base-at-validation where applicable, exact APK filename/checksum, certificate fingerprint, and v2/v3 outcomes. The existing Draft PR #2824 (`audit/verify-apk-signature-workflow`) was inspected; its historical fixed APK checksum and separate audit workflow are not used as a substitute for verifying the APK built in the current release job. The existing tag-only `release.yml` bypass was disabled by commit `556f9912840ec588e509ea1809d4da30677d5896`.
- Validation status: GitHub file writes are confirmed, but no terminal validation result has been observed. Build run [39324997907](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39324997907) is PENDING for parent PR head `e9ee7370e11c3e41f2696a0a2a4146cbb7455fcd`; earlier run [39324835300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39324835300) was pending/in progress on an earlier Wave 4.42 head and is not current-head proof. The Build workflow now includes release-workflow YAML syntax and Gradle fail-closed checks, but their terminal results are not yet available. No official dispatch, `apksigner` output, APK checksum, artifact ID, or fingerprint match has been observed. Do not call the mechanism validated or claim that a signed APK exists.
- Exact-SHA remains BLOCKED until an authorized owner dispatches the existing workflow against the trusted `main` tip with `target_sha` equal to that exact SHA. This guard intentionally excludes PR-controlled code from production secrets.
- Release decision remains `BLOCKED — RELEASE: NO-GO`. No merge, tag, publication, or release approval.


## Wave 4.50 — Repeat Checklist Evolution (2026-10-20)

- **Contract:** checklist template edits preserve all occurrence snapshots before the effective local calendar day. For a recurring Task, stored checklist snapshots on the effective day and later are rebuilt from the changed template with all items unchecked. Existing occurrence keys, Task identity, and independent `occurrenceHistory` lifecycle state (`completed`, `cancelled`, etc.) must remain unchanged.
- **Code audit on PR #2833 head `f492f03a579bce9032520d2b5534f63a4eec46d5`:** `TaskEditApplyService.apply` updates `Task.checklist` but does not rebuild `checklistOccurrences`; `TaskRecurrenceRepository.checklistForOccurrence` returns an existing stored snapshot before consulting the template. This is a confirmed implementation gap, not a runtime acceptance result.
- **Occurrence identity:** the current model uses ISO-8601 scheduled datetime strings as `checklistOccurrences` keys; Checklist Items are strings without independent item IDs. Malformed legacy keys are conservatively preserved because their date boundary cannot be established safely.
- **Live CI before Wave 4.50 changes:** Build run [39374346739](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346739) completed success, but `Verify exact requested revision` was skipped and checkout was synthetic merge SHA `046c832656469f0c17da88c5885fa11dc023a797`; it is not exact-head evidence for `f492f03a579bce9032520d2b5534f63a4eec46d5`. Device Smoke run [39374346710](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346710) was queued at the latest poll. Do not commit to this branch while its `cancel-in-progress: true` Device Smoke concurrency group is active/queued.
- **Acceptance status:** checklist regression, canonical-storage reload, real process restart, repeat idempotency, and backup/restore remain **NOT RUN / NOT PROVEN** until the new source SHA has terminal test evidence. No real seven-day Task or physical-device data was created by this audit.
- **Release:** `BLOCKED — RELEASE: NO-GO`. No merge, tag, or release authorized.


## Wave 4.50 — additional live gate reconciliation (2026-10-20 05:39 UTC)

- **Build:** Run [39374346739](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346739) is `completed/success`; its Release APK job and test jobs skipped `Verify exact requested revision`. Job log checkout was synthetic merge SHA `046c832656469f0c17da88c5885fa11dc023a797`, not the PR head SHA. Artifacts include Debug APK ID `12242608232` and non-official Release APK ID `12242917172`; neither establishes official signing or exact-head acceptance.
- **Calendar Provider:** Run [39374346742](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346742) completed success on the same synthetic merge checkout. Job log directly records CREATE count 1, UPDATE, destination-calendar migration PASS, and DELETE target absent. This is valid provider-lifecycle evidence for that checkout only and is unrelated to Checklist acceptance.
- **Device Smoke:** Run [39374346710](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346710) remains non-terminal. As of this checkpoint, Home, Quick Capture, SQL Persistence and SQL Migration jobs succeeded; Backup/Restore and Task Lifecycle were in progress; People and Calendar were queued. The workflow concurrency is `group: arvin-device-smoke-${{ github.event.pull_request.number || github.ref_name }}` with `cancel-in-progress: true`; do not move PR #2833 head while this run is active.
- **Independent release gates:** Live `main` `android/app/build.gradle.kts` blob `aaeea7506885814cc4c4a65ac6559872a80146a8` still sets Release `signingConfig = signingConfigs.getByName("debug")`. Official signing is BLOCKED. Exact-SHA remains BLOCKED because the successful PR Build did not execute its exact-requested-revision assertion; no exact target-SHA dispatch result is available here.
- **Checklist acceptance:** No dedicated seven-occurrence checklist fixture, real app-process restart of checklist state, or checklist backup/restore result exists for this pre-fix checkout. The source gap above remains open until the patch is committed and new exact-source tests are terminal.
- **Release:** `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.


## Wave 4.50 — legacy release path audit

- Live `main` workflow `.github/workflows/release.yml` (blob `c5f45b9b1d66db22a585b0637a24537aeb95d098`) still has `contents: write` and invokes `softprops/action-gh-release@v2` with caller-provided `inputs.version`. The fail-closed replacement exists only in draft PR #2817 head `5b5d83e75499cd3b890c06835d1c90220c2b65de`; it is not merged. This legacy mainline path is an independent release-governance blocker.
- Do not run or promote the legacy release workflow. Keep PR #2817 draft/unmerged until its hardening and independent owner approval are reviewed. **RELEASE: NO-GO.**

## ARVIN WAVE 5.11 — live checkpoint (2026-10-20)
Status: **IN PROGRESS — BLOCKED — RELEASE: NO-GO**. This note records implementation and evidence boundaries; it does not claim acceptance.
- Live PR #2833 is OPEN / DRAFT / UNMERGED. Current source branch: `wave-4-10/follow-up-reminder-contract`; observed PR head after Wave 5.11 code/test commits: `08f610f5442aa9c822e0645458d0ef438f7321ef`. Base reported by PR metadata: `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Re-read live metadata before any further push.
- Repository read/push permissions: PASS. Direct Workflow Dispatch: BLOCKED; this connector does not expose a workflow_dispatch operation. Exact-SHA and local Flutter/Android execution are not available through the current execution surface.
- Wave 5.11 commits on the PR source branch: shared occurrence editor `8f1efd1de21c0954fa14bd66ce5a487814dec891`; Repeat integration `2780e8902a4fddf444c2135f537b821e32d3e73a`; Task Details integration `7eb93299cb425597aab1ebb227e898c32793b327`; guard against repeating-task template mutation `ba206df93f57846179291be81efbffdc0f6b0023`; widget test `f8fabc8aba08aa54ce146851e17853326880c794`; Jalali date display `202639c132a50ea3b0025b82b68562e395c55f61`; test Jalali selector `08f610f5442aa9c822e0645458d0ef438f7321ef`.
- The shared editor uses the existing TaskRecurrenceRepository/TaskStore. Repeat and Task Details now present the same occurrence-scoped component. The legacy detail callback refuses to mutate the generic template for a recurring Task. This is code-level integration only; not yet runtime-validated.
- No workflow run or status check was returned for current head `08f610f5442aa9c822e0645458d0ef438f7321ef`; Analyze, tests, APK builds and device gates remain NOT RUN / NOT PROVEN for this head.
- Prior run `39422835185` for revision `4dded4d7618d8c83fc3757f913ac2a87e15e777b` ended FAILURE: Test shards failed compiling `test/task_recurrence_page_test.dart` (syntax/argument errors). It is not evidence of current-head validation. Prior Device Smoke `39422835130` completed SUCCESS, but does not prove Checklist occurrence acceptance.
- Seven-occurrence A/B/C → A/B/D acceptance, lifecycle preservation, repeat idempotency, local-day/timezone boundaries, actual Android process restart, real backup/restore, exact-SHA, official APK signing, Calendar Provider, notification cold-start, Persian PDF, Golden Flow and P0/P1 regressions remain open.
- Design reference only: Joplin Repeating To-Dos separates recurrence configuration from scheduling, but completion can reopen a to-do and reset subtasks; Arvin must not copy that behavior without explicit compatibility. TimeJot documents device backup limitations separately from daily export/import; this informs test design only, not Arvin acceptance. References: https://joplinapp.org/plugins/plugin/com.github.TheScriptingGuy.joplin-plugin-repeating-todos/ ; https://github.com/TheScriptingGuy/Joplin-Repeating-Todos-Plugin ; https://timejot.app/help/ ; https://timejot.app/changelog/ .
- Release remains **BLOCKED — RELEASE: NO-GO**. No merge, tag, or release.


## Wave 5.14 — Live execution checkpoint
**Checkpoint timestamp:** 2026-10-20 13:42 UTC / ۱۴۰۵/۰۷/۲۸، حدود ساعت ۱۷:۱۲ ایران  
**Repository:** `mobinpda-lab/Arvin-clean`  
**PR:** #2833 — OPEN / DRAFT / UNMERGED  
**Branch:** `wave-4-10/follow-up-reminder-contract`  
**Base branch / SHA:** `fix/follow-up-record-authority-20261019` / `49910e585ee73afcf56a7f8d927b9c69e763c5c5`  
**HEAD before this documentation-only commit:** `b15b0c09ec718459b3702e63b2c38701f0291293`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Verified changes
- `c16d234ec132d627566869a174f60e00c413d28c`: canonical occurrence Checklist saves now propagate the updated Task to Detail and Home state; expanded the Android acceptance test to create a past-anchored daily recurrence and save seven occurrence checklists through the UI.
- `c7a60da3268669dde159b85e6a53f2176e67959a`: fixed the three Analyze findings surfaced by the exact-SHA run.
- `0b42e588426cc07cea5d4d3563081f3dfbb09160`: aligned the seven occurrence tick pattern with the existing restart-verifier contract.
- `b15b0c09ec718459b3702e63b2c38701f0291293`: stores the accepted Task ID and full canonical-store snapshot outside TaskStore; the restart verifier compares Task identity, every Task JSON field, record count, checklist snapshots, history, and relationships. Fixed the creator/verifier fixture-prefix mismatch.
- The seven Wave 5.11 commits were rechecked against this source HEAD: each is an ancestor (`behind_by=0`); no divergence was found.

### CI checkpoint — do not promote stale evidence
- Build Run [39431510949](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39431510949), exact target `c16d234...`: exact-checkout gate succeeded; six Test shards and Debug/Release APK jobs passed, but Analyze failed on three findings. Run conclusion: FAILURE. Its Release artifact is debug-key signed, not official.
- Build Run [39431989516](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39431989516), exact target `c7a60da...`: Analyze and all six Test shards passed; Release APK job failed while downloading NDK with `Error on ZipFile unknown archive`; Debug APK was still IN PROGRESS at this checkpoint. This is an environment/toolchain failure, not evidence of a product-code failure.
- Build Run [39432344723](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432344723), target `0b42e588...`: queued; it is not the current source HEAD.
- The recovery-dispatcher rerun is queued. No exact-SHA Build result for `b15b0c0...` was confirmed at this checkpoint.
- Device Smoke Run [39416899883](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899883) checked out stale PR head commit `6d78b1cba4d0ec829fe26325c9233cd30100d766`, which predates the Wave 5.11 source commits. Checklist Evolution was CANCELLED; Task Lifecycle was still running at this checkpoint. It is not current-HEAD acceptance evidence.
- Calendar Provider Run [39416899861](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899861) passed CREATE / NO-OP / UPDATE / DELETE / destination migration on that same stale PR head commit only. Artifact ID: `12262580173`.

### Release/security state
No Merge, Tag, official APK publication, or security-PR promotion. PR #2817 remains OPEN/DRAFT; PR #1901 remains OPEN; Issue #2102 remains OPEN. Exact current-head Build, current-head Device Smoke, real SAF Backup/Restore of the accepted Task, official signing/fingerprint verification, and `apksigner verify --verbose --print-certs` remain unverified.


### Post-checkpoint run creation correction
After the preceding checkpoint, GitHub created Build Run [39432745217](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217) with exact target `b15b0c09ec718459b3702e63b2c38701f0291293`; it was QUEUED, not completed. The docs-only commit `49f69caf16968bf0d22291cabb9f06011de002d0` then became the live PR HEAD. No exact-SHA Build result for `49f69caf...` was confirmed. Recovery Dispatcher job `118663216037` was queued to process the live PR head. Keep both statuses distinct.


## Wave 5.14 final documentation checkpoint — 2026-10-20 13:47 UTC
Immediately before this documentation-only append, live PR HEAD was `7828b825d8e9fb50b0fe0b41a239c140454b3dd0`; base SHA remained `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Build Run `39432745217` for prior source SHA `b15b0c0...` was QUEUED, and Run `39432344723` for `0b42e588...` was IN PROGRESS. Recovery Dispatcher job `118663216037` was QUEUED; no exact-SHA result for the live HEAD was confirmed. Treat these as separate revisions and do not convert any queued/in-progress run into PASS. The resulting documentation-only HEAD also requires its own exact-SHA Build if exact revision closure is claimed.


### Revision identity correction — 2026-10-20
The GitHub Actions API identifies Runs 39416899830 and 39416899883 as `pull_request` events on branch `wave-4-10/follow-up-reminder-contract`, with `head_sha=6d78b1cba4d0ec829fe26325c9233cd30100d766`. That commit has one parent (`2219b92b59435e23abc0725a4d331d8796adce2c`); it is an old PR source commit, not a synthetic merge commit. It was 23 commits behind source HEAD `266b2a58...` at the time of this correction. The old run results remain stale for current-head acceptance.


## Post-run evidence update — 2026-10-20 13:55 UTC
- Build Run [39432745217](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217) completed SUCCESS on exact source target `b15b0c09ec718459b3702e63b2c38701f0291293`. Every Job's `Verify exact requested revision` step passed. Analyze, Test shards 0–5, Debug APK, and Release-variant APK all passed.
- Job IDs: Analyze `118661728356`; Test-0 `118661728445`; Test-1 `118661728687`; Test-2 `118661728428`; Test-3 `118661728375`; Test-4 `118661728381`; Test-5 `118661728619`; APK Debug `118661728193`; APK Release-variant `118661728559`.
- Release-variant artifact: [Run 39432745217 / artifact 12269333049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217/artifacts/12269333049). Downloaded APK SHA-256: `0e13c02e50d1f6871758fe47d82cf4921da15b87b9aabbb6d77970c280b032a2`; uploaded artifact ZIP SHA-256 from the Job log: `c26189789f50da7cec6bd8b086d726ce369b54013f3e260554edf235f29761e6`. This is a non-official Release-variant artifact using Debug signing because `ARVIN_OFFICIAL_RELEASE` was not enabled; do not publish it.
- Important workflow provenance: this Run was dispatched by the default-branch recovery dispatcher, so its workflow definition came from main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`, while its source checkout was exact target `b15b0c0...`. The PR branch's `.github/workflows/build.yml` contains an additional fail-closed signing test and non-official artifact naming not present in the main workflow version. Therefore the branch's own workflow definition still needs a manual branch-selected Build dispatch with `target_sha` equal to the live PR HEAD.
- At this update, Run [39433741028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39433741028) for previous docs HEAD `266b2a58...` was still QUEUED. The Recovery Dispatcher job `118667403566` was QUEUED to scan live PR heads. No terminal Build result for the then-live docs HEAD `bfc499fc...` was confirmed.
- The code/source validation at `b15b0c0...` is PASS; current-head Device Smoke, Calendar Provider, official SAF Backup/Restore, official signing/fingerprint/apksigner, and release approval remain open.


## Wave 5.17 — live execution checkpoint (2026-10-20)

### Live revision and execution safety
- PR #2833 was re-read from GitHub: OPEN / DRAFT / UNMERGED; source branch wave-4-10/follow-up-reminder-contract; HEAD 036dc407d54aea5fd7f7ed1fa54adf924651647f; base fix/follow-up-record-authority-20261019 at 49910e585ee73afcf56a7f8d927b9c69e763c5c5.
- Commit 036dc407d54aea5fd7f7ed1fa54adf924651647f has direct parent bfc499fcc6fd037d209d01bc67d56ebaf16acfe1.
- GitHub Actions API query for runs on exact HEAD returned zero runs. Branch-filtered history shows the latest Build/Device Smoke pair is from older source SHA 6d78b1cba4d0ec829fe26325c9233cd30100d766; Build run [39416899830](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899830) succeeded, while Device Smoke [39416899883](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899883) was cancelled. Neither proves current HEAD.
- Branch-scoped Actions API filters returned zero queued and zero in-progress runs immediately before this documentation update. The unfiltered status summary was inconsistent, so no global claim that every repository run is inactive is made.
- Workflow contracts read from the PR branch: Build triggers on PR opened/synchronize/reopened and supports workflow_dispatch.target_sha; exact-SHA assertion only runs for a non-empty target SHA. Build and Device Smoke use cancel-in-progress: true. Device Smoke covers task lifecycle, checklist evolution, SQL persistence/migration, Backup/Restore and calendar. Calendar Provider Acceptance is path-filtered on PRs targeting main or fix/follow-up-record-authority-20261019. The recovery dispatcher is scheduled every six hours and can dispatch Build with target_sha, but this session has no direct workflow-dispatch action.
- Wave 5.11 ancestry check: compare API reports 938bb05cf7e6337ad244a3cca16e482a242aea22 as merge-base/ancestor of this HEAD (588 commits ahead, 0 behind). This proves ancestry for that commit only; it does not independently prove the complete seven-commit Wave 5.11 set or each parent link.

### Wave 5.17 execution result
- GitHub read access: PASS. Push capability is tested by the single atomic documentation commit for this checkpoint; no code fix is claimed.
- No Flutter/ADB device environment is exposed in this execution session. Analyze, unit/widget tests, integration tests, emulator runs, seven-Occurrence UI acceptance, process/PID Restart, and real Backup/Restore were not executed here. Keep those gates BLOCKED/NOT RUN, not PASS.
- Current source-code behavior remains unaccepted until exact-head CI and behavioral tests provide evidence. Release remains BLOCKED — RELEASE: NO-GO.


## Wave 5.21 — live GitHub checkpoint (2026-10-20)

- Live PR #2833 re-read before this documentation commit: OPEN / DRAFT / UNMERGED; branch `wave-4-10/follow-up-reminder-contract`; source HEAD `3ce1d46b80d4842890b6759583dbf685deaeafde`; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Parent of source HEAD: `036dc407d54aea5fd7f7ed1fa54adf924651647f`. Repository connector reports admin/push capability, but its exposed Actions tools do not include direct workflow_dispatch. No active or queued run was returned by branch-scoped Actions queries immediately before this checkpoint.
- Exact-source Build Run [39445690981](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39445690981) completed SUCCESS on target `3ce1d46b80d4842890b6759583dbf685deaeafde`. All 9 jobs succeeded; all 9 logs contain `EXACT_TARGET_SHA=3ce1d46b80d4842890b6759583dbf685deaeafde`; Analyze reported `No issues found!`; six test shards succeeded; Debug and Release APK build/upload steps succeeded. This validates build/test/artifact creation only, not UI acceptance, provider lifecycle, official signature or release approval.
- Current-head Device Smoke was NOT FOUND. Latest PR-branch Device Smoke result returned by branch history was Run [39416899883](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899883), cancelled on older source SHA `6d78b1cba4d0ec829fe26325c9233cd30100d766`. It is not current-head evidence. The Device Smoke workflow has nine matrix scenarios and `cancel-in-progress: true`; direct dispatch remains unavailable from this connector. No run was launched by this session.
- Calendar Provider workflow exists and supports workflow_dispatch, but no current-head lifecycle evidence was found. Prior green PR-triggered Provider runs are not accepted as CREATE → NO-OP → UPDATE → transfer → DELETE proof without reviewing exact artifact contents and writable-provider results.
- No Wave 5.20 execution record was found in issue search or recent branch commit history; do not assume it ran.
- Seven-occurrence UI acceptance, same-task Restart/PID comparison, real Backup/Restore, Jalali boundary tests, Notification tap/cold-start, PDF multi-page Persian, Golden Flow/P0/P1 and official APK certificate verification remain NOT RUN / BLOCKED / NOT VERIFIED as appropriate. No Task ID or seven real occurrence keys were captured. No code fix, merge, tag or release was performed.
- Next safe action: owner-authorized CLI dispatch after rechecking active runs; verify checkout SHA from logs. Use `gh auth status`, `gh run list --repo mobinpda-lab/Arvin-clean --workflow device-smoke.yml --limit 20 --json databaseId,headSha,status,conclusion,url,displayTitle`, then dispatch only if no useful active run exists. Since workflow lacks `target_sha`, record actual checkout SHA, not only the PR branch name.
- Release decision remains **BLOCKED — RELEASE: NO-GO**.


## Wave 5.21 — Calendar Provider artifact inspection (2026-10-20)

- Inspected GitHub artifact [12262580173](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899861/artifacts/12262580173) from Calendar Provider run [39416899861](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899861). Artifact contains `result.txt`, `environment.txt`, and `test-output.txt`.
- Artifact says `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; `test-output.txt` records CREATE event ID 3, NO-OP retaining event ID 3, UPDATE retaining event ID 3, migration from calendar ID 1 to destination calendar ID 2 (new event ID 4), DELETE leaving target absent, and unrelated sentinel events retained in both calendars. Job log confirms `CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=1`.
- Provenance boundary: `environment.txt` records checkout/synthetic merge SHA `2494062c1a1219276a3d97c799d1996990506716` and PR head SHA `6d78b1cba4d0ec829fe26325c9233cd30100d766`. This is real writable-provider evidence for that older PR integration revision, not the current Wave 5.21 documentation head. Current-head Calendar Provider remains NOT VERIFIED until rerun against the final SHA.
- At the start of this update, PR #2833 HEAD was `4316fb59d39a5a3277147d9e973f9842c6f758b4`; this documentation commit will change HEAD again. The current final SHA must receive fresh Build and Device Smoke evidence; no run is assumed to start from an API ref update.


## Wave 5.22 — Canonical product-concept reference (2026-10-20)

- Canonical product vocabulary and behavioral contract: [ARVIN_PRODUCT_CONCEPTS.md](../product/ARVIN_PRODUCT_CONCEPTS.md). This reference separates code-confirmed behavior, intended invariants, open product decisions, and unverified acceptance.
- Live code anchors reviewed for this documentation update: `Task` / `TaskReminder` / `FollowUp` in `lib/models/task.dart`; recurrence enum/rule in `lib/models/recurrence.dart`; `TaskStore`; `TaskRecurrenceRepository`; `TaskEditApplyService`; `OccurrenceChecklistEditor`; and `PersianDateFormatter`. The current model has recurrence and occurrence state on the existing Task; no parallel recurrence engine or storage was introduced.
- Product-concept document added on the existing PR branch. The five memory-document links and final GitHub read-back are pending until all edits complete; this is not yet the completed governance gate.
- Open decisions include checklist item identity for rename/reorder/delete, canonical occurrence key/timezone semantics, missed-occurrence policy, precedence of Task.followUpDate vs FollowUp.nextFollowUp, notification tap/Snooze behavior, and restore conflict policy.
- Documentation-only change: no production code, schema, recurrence, checklist, notification, calendar, or signing configuration changed. Product acceptance remains NOT VERIFIED where current-head empirical evidence is missing.
- Release remains **BLOCKED — RELEASE: NO-GO**. No merge, tag or release.

## Wave 5.35 — Live evidence checkpoint (2026-10-20)

- **Live PR state (GitHub API, 2026-10-20):** PR #2833 OPEN / DRAFT / UNMERGED. Head `16c567290ec8fd41c56c323613a41fbc92c39d5f`; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- **Exact-SHA Build:** BLOCKED / NOT RUN. Runs filtered by target SHA returned `total_count=0`. PR Build [39416899830](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899830) passed 9/9 jobs, but event SHA was `6d78b1cba4d0ec829fe26325c9233cd30100d766`, actual checkout was synthetic merge `2494062c1a1219276a3d97c799d1996990506716`, and exact-revision step was SKIPPED.
- **Device Smoke:** [39416899883](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899883) attempt 2 concluded CANCELLED. Seven scenarios succeeded; `task-lifecycle` and `checklist-evolution` were cancelled. Logs show `The operation was canceled` during the smoke step but do not establish the initiating cause. Actual checkout was synthetic merge SHA `2494062c1a1219276a3d97c799d1996990506716`, not target SHA.
- **Execution capability:** connected GitHub APIs permit read/write, but no workflow-dispatch action is exposed in the available tool surface; no dispatch was sent. No physical Android device or authorized device-control channel was available. Same-Task Checklist, restart PID, and real backup/restore acceptance are BLOCKED — DEVICE EXECUTION REQUIRED.
- **Artifacts:** Build ZIP artifacts [12261968911](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12261968911) and [12262350247](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12262350247) have GitHub-reported archive digests, not extracted APK hashes. APK signature certificate/fingerprint acceptance remains NOT VERIFIED.
- **Release:** BLOCKED — RELEASE: NO-GO. No merge, tag, or release.


## Wave 5.36 — Exact-SHA CI checkpoint (2026-10-20)

- PR #2833 was re-read from GitHub: OPEN / DRAFT / UNMERGED; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Starting head `9a438b6d5f165631a1381ca6082b0ef251149021` was confirmed before workflow edits.
- Updated Build workflow: `.github/workflows/build.yml` now requires `target_sha` for `workflow_dispatch`, checks out the supplied SHA, and logs `EXPECTED_CHECKOUT_SHA` plus `ACTUAL_CHECKOUT_SHA` in both quality and APK jobs. Dispatch mismatch fails the job. Commit [4b0f916](https://github.com/mobinpda-lab/Arvin-clean/commit/4b0f91620e0d865ea7e3cb029dc5ca57ac41b950).
- Updated Device Smoke workflow: `.github/workflows/device-smoke.yml` now requires `target_sha` for `workflow_dispatch`, checks out that revision for each of the nine scenario jobs, and logs/asserts expected vs actual SHA. Commit [d4c90a4](https://github.com/mobinpda-lab/Arvin-clean/commit/d4c90a461c6b876f246f62d33817d93cebfdbe17).
- Both workflow files were read back from GitHub. The latest target candidate at this checkpoint is `d4c90a461c6b876f246f62d33817d93cebfdbe17` (subject to the following documentation commit). Exact-SHA run query for this candidate returned `total_count=0`; no active or queued branch runs were returned by the status-filtered queries.
- **Dispatch limitation:** the connected GitHub tool surface exposes repository writes and Actions reads but no workflow-dispatch operation; no `workflow_dispatch` was executed. GitHub CLI authentication status cannot be verified from this environment. PR-triggered run evidence is not a substitute for exact-SHA dispatch evidence.
- **Product gates:** no physical-device control session, same-Task Checklist before/after storage snapshots, PID restart evidence, or same-Task backup/restore transcript was available. Those gates remain `BLOCKED — DEVICE EXECUTION REQUIRED`. APK certificate/fingerprint and remaining product regressions are not accepted by this workflow change.
- **Decision:** no merge, tag, or release. **BLOCKED — RELEASE: NO-GO.**


## WAVE 5.53 — evidence update (2026-10-21)

- Live default branch `main`: `d9fb7a247037762216662a20fb32028ecc8a0f6b`. CI PR #2868 remains OPEN / DRAFT / UNMERGED; head branch `fix/exact-sha-dispatch-contract-20261021`, head SHA `315923c1cbf6bfb8f661949a4fca18e304ae51ea`, base `main` at `d9fb7a247037762216662a20fb32028ecc8a0f6b`. Product PR #2833 remains OPEN / DRAFT / UNMERGED; head branch `wave-4-10/follow-up-reminder-contract`, head SHA last reported by PR metadata `992699f87715db3642dfbc56ab3def32800e5104`. No PR was merged.
- Historical Build [39543365234](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39543365234), Job [119035976068](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39543365234/job/119035976068), failed in `test/device_smoke_workflow_contract_test.dart`: test `Build and Device Smoke enforce exact-SHA controls per runner job`, assertion at line 263 expected `officialReleaseRequested` in `android/app/build.gradle.kts`; 196 tests passed and 1 failed. The command was `flutter test --total-shards 6 --shard-index 4`. This is a missing-security-control assertion in the checked-out run revision, not a reason to weaken the test.
- The current CI PR head's `android/app/build.gradle.kts` contains an explicit `ARVIN_OFFICIAL_RELEASE=true` gate, nonblank validation for store file/password/key alias/key password, a dedicated `arvinProduction` signing config for explicit official builds, and a Debug signing path for non-production builds. This code-level inspection is not independent proof that any APK is officially signed; no approved certificate fingerprint has been verified.
- Current Build run [39547647963](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39547647963), associated with CI PR head `315923c1cbf6bfb8f661949a4fca18e304ae51ea`, finished successfully: Analyze, `test-0` through `test-5`, Debug Build and Release Build all passed. This was a pull_request event, not an Exact-SHA Dispatch.
- Current Device Smoke run [39547648453](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39547648453) had successful main emulator steps for `home`, `quick-capture`, `sql-persistence`, `sql-migration`, `backup-restore`, `people`, and `calendar`. The main steps for `task-lifecycle` and `checklist-evolution` were `SKIPPED`; their acceptance remains BLOCKED. Calendar smoke does not prove independent Calendar Provider lifecycle acceptance.
- Exact-SHA Dispatch remains `BLOCKED — DISPATCH UNAVAILABLE`: the connected GitHub tools expose no workflow_dispatch action. PR CI must not be represented as exact-SHA dispatch evidence. APK signature verification and independent certificate fingerprint matching remain `NOT VERIFIED`. Release remains `BLOCKED — RELEASE: NO-GO`.
- Product capability rule: code existence and successful unit/device smoke are distinct from acceptance. Preserve Task/Repeat/Occurrence, Checklist history, SQL persistence/migration, Restart, Backup/Restore, notifications, Calendar Provider, Persian PDF/RTL, Golden Flow and P0/P1 regressions; do not infer removal from missing evidence. Unknown acceptance and product trade-offs remain **نیازمند تصمیم مبین**.
