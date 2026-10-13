# LIVE EVIDENCE OVERRIDE — 2026-10-12

- **PR #2619 current exact head** `387694b5d5b29ca5fb72fedead56ed91368ca460`: Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) completed PASS: Analyze, test shards 0–5, Debug APK and Release APK. Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) completed PASS: Home, Quick Capture, People, SQL Migration, SQL Persistence and Backup/Restore on Android Emulator. Automated exact-head gates are green. Remaining: path-by-path deletion/content migration review and physical-device acceptance; do not equate emulator smoke with real-phone proof.

This section records evidence whose SHA and scope are explicitly known. PR-head references in older entries are historical unless their SHA is rechecked live.

- Current `main` at last verified read: `cea76673d871ce52b84dacf69f355c4282802baa`.
- Main Build [38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086): PASS on that exact main SHA; Analyze, six test shards, Debug APK and Release APK succeeded.
- Main Device Smoke [38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043): PASS on that exact main SHA; all six emulator scenarios succeeded (Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore). This is emulator evidence, not physical-device acceptance.
- PR #2614 is a documentation-only memory consolidation, OPEN/DRAFT at last recheck. Its exact head and Build status must be queried live after every commit; prior-head runs do not validate a later head.
- Physical-device Calendar same-event/no-duplicate, real Android file-provider Backup/Restore and rollback, restored Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen review and explicit owner release approval remain NOT VERIFIED. Release is NO-GO; Issue #2102 remains OPEN.

---

# Arvin Evidence Map

## Latest live mainline checkpoint — 2026-10-11

This checkpoint supersedes older rows below wherever they conflict. Current `main` is `a6ced27660d34cd87dd8915aff68d3a7555fd57a` ([commit](https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a)). PR #2585 is MERGED at this SHA; PR #2587 is MERGED at `c57606c223a1d6141bd3d11e1a75cc5cda428470`. The latest Actions lookup for the exact main SHA returned no PR-associated runs and the combined status lookup returned no statuses; this does not establish a pass. Current-main Build/Device Smoke evidence must be recovered or rerun. Physical-device acceptance and owner release approval remain NOT VERIFIED.


Updated: 2026-10-11 (live exact-head Build passed; Device Smoke partially complete)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified.

| Feature / gate | Evidence | Current status | Limitation / next proof |
|---|---|---|---|
| Mainline | [main commit 72a2f4c](https://github.com/mobinpda-lab/Arvin-clean/commit/72a2f4cc24df7a38eff9856ce403461615db5280) | Base snapshot previously confirmed; documentation-only PCTADP registration | Recheck live base/head before merge |
| Calendar linked-event edit | [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570); [commit 34a6cee](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128) | Merged; automated regression expects update=1/create=0 and stable external event ID | Physical-device same-event/no-duplicate proof remains NOT VERIFIED |
| Backup/restore reconciliation | [merged PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585); [main commit a6ced276](https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a) | MERGED to main; preserves portable data and adds rollback protection | Recover exact-main CI evidence and complete physical-device file-provider/round-trip/rollback acceptance |
| Catalog portability | [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Owner approved unused Category/Tag portability. Optional `categories`/`tags` remain backward-compatible in v1; merge is additive | Exact-head tests and physical file-provider/data-integrity acceptance required |
| Notes / Notebook checklists | [canonical Task model](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/models/task.dart); [Notebook repository](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/canonical_notebook_repository.dart); PR #2585 | Notes/checklists are canonical Task records; regression added for local-only note/checklist retention | Verify backup round-trip and late-failure rollback on exact head and physical device |
| Portable app settings | [AppSettingsService](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/app_settings_service.dart); [Daily Content preferences](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/daily_content_preferences_service.dart); PR #2585 | App settings, backup schedule and Daily Content preferences included in foreground and scheduled backups; missing legacy keys preserve local values; explicit nullable defaults serialize | Exact-head Analyze, six test shards and Debug APK passed; Release APK and Device Smoke still pending; confirm all supported portable settings in round-trip |
| Scheduled backup payload | [BackupBackgroundRunner](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/backup_background_runner.dart); [test](https://github.com/mobinpda-lab/Arvin-clean/blob/main/test/backup_background_runner_test.dart) | Payload now includes Tasks, Projects, portable settings/schedule, Daily Content preferences, Calendar links, Category and Tag catalogs | Exact-head Release APK and Device Smoke still in progress at latest check; no physical scheduled-backup proof |
| Restore rollback | [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Existing multi-store rollback retained; new settings validation happens before restore writes; snapshots include portable settings | Exact-head test shards passed; Device Smoke Backup/Restore queued; physical failed-restore recovery required |
| Calendar actions and recurrence | [merged PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587); [P0 #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | MERGED to main at c57606c; automated behavior was validated on prior PR head | Physical-device visibility, recurrence/checklist and provider behavior remain NOT VERIFIED |
| Memory documentation | [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) | OPEN / DRAFT; state checkpoint refreshed and problem register added on existing branch | Reconcile/rebase against current main; keep #2598/#2599/#2600 as one coherent documentation hierarchy; run exact-head Build after updates |
| Taxonomy architecture | [Canonical ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md); [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) | Project, Category and Tag are separate concepts; Category/Group is one concept; conformance audit remains OPEN | Finish code/UI/docs/persistence inventory; do not infer Category-to-Project relation without source evidence |
| Legacy TagStore | [tag_store.dart](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/services/tag_store.dart); [historical commit 3073cb8](https://github.com/mobinpda-lab/Arvin-clean/commit/3073cb8593ac80783c6cb4647640dc05390375a5) | LOW-CONFIDENCE LEGACY CANDIDATE: no current caller found; SQL migration derives tags from Task.tags | Preserve key/file absent evidence of shipped use |
| Physical Android backup/restore | No linked physical-device evidence | NOT VERIFIED | Test actual Android system file picker/provider, legacy restore, failed-restore recovery and before/after data integrity |
| Calendar identity/no duplicates after restore | No linked physical-device evidence | NOT VERIFIED | Record Task ID, external event ID and event count before/after edit/re-sync and restore |
| Golden Flow | No complete end-to-end evidence | NOT VERIFIED | Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release handover | No complete handover package evidenced | PENDING | Release notes, installation guide, user guide, known issues, architecture summary, evidence report and owner acceptance |

## Live recheck — 2026-10-11 13:40 Iran time

- Main is `72a2f4cc24df7a38eff9856ce403461615db5280`.
- PR #2585 head `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`: Build [38130522723](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522723) succeeded for Analyze, six test shards, Debug APK and Release APK.
- Device Smoke [38130522703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522703): Home, Quick Capture and SQL Persistence passed; SQL Migration and Backup/Restore are in progress; People queued. Full smoke is not yet complete.
- Physical-device file-picker/provider restore integrity, same-event Calendar edit, full Golden Flow and product-owner release acceptance remain unverified. No merge or release.

## Backup/restore owner contract — Issue #2580 / PR #2585

Owner-approved contract:
- Include Tasks, Notes/Notebook checklists, Projects, Calendar-link metadata, Category/Tag catalogs and all portable app settings.
- Restore validates the backup before writes, then reconciles by stable canonical IDs: matching records update; backup-only records add; local-only records remain unless the owner explicitly selects full replacement.
- Never match Tasks or Projects by title/date. Preserve history, checklist, repeat, follow-up, project membership and Calendar-link identity.
- Catalogs merge additively, retaining local-only Category/Tag entries.
- Only settings keys present in a backup update values. Omitted fields in legacy v1 backups must not reset current settings. Explicit nullable defaults in new backups are preserved.
- Include portable Daily Content preferences and backup schedule. Exclude secrets, passphrases and device-bound OS permissions/provider URIs.
- Snapshot current state and test rollback through the existing multi-store orchestration. Do not create a parallel restore engine.

Implementation checkpoint: PR #2585 current checkpoint head `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Exact-head Analyze SUCCESS; Build and Device Smoke not yet complete at this checkpoint. A prior head's Analyze failed on two unnecessary null assertions; the assertions were removed before the current head.

## Taxonomy audit checkpoint — Issue #2580
- `Task.category` and `Task.tags` are separate fields on the canonical Task model.
- `ProjectPlan.itemIds` references canonical Task IDs; the model itself does not declare Category ownership.
- `HomeGroup<Task>` is a presentation grouping abstraction, not a domain Group entity.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy.
- Classify uses of “group” as domain, user-facing wording, presentation grouping, generic technical term or historical document before edits.

## Release gate
All CI/emulator successes are automated evidence only. Physical-device/file-provider data integrity, Calendar provider identity/no-duplicate behavior, full Golden Flow and explicit owner acceptance remain unproven. Keep PR #2585 and #2587 unmerged until their respective acceptance gates are satisfied.

## Current blocking evidence gaps
- [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102): exact-current-main Build/Device Smoke evidence needs recovery or rerun; empty status lookup is not a pass.
- [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139): installed-device owner acceptance remains open.
- [#2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535): Calendar actions and scheduled recurrence need actual installed-APK acceptance.
- [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602): recorded test-shard failures and skipped Device Smoke; reconcile with #2595/#2591 before any form merge.
- See [ARVIN_PROBLEM_REGISTER.md](ARVIN_PROBLEM_REGISTER.md) for the prioritized current blocker register.

## Repeat Tracking Level Contract (RTLC) — 2026-10-11

| Feature / gate | Evidence | Current status | Limitation / next proof |
|---|---|---|---|
| Architecture decision | [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605) | ACCEPTED product direction | Does not prove implementation or release readiness |
| Existing tracking model | [recurrence.dart on main](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/models/recurrence.dart); [Task model](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/models/task.dart) | `RecurrenceTrackingLevel.normal/tracking` and JSON persistence exist; Task contains `occurrenceHistory` and `checklistOccurrences` | Confirm exact current source/test head before implementation; validate legacy JSON and backup/restore |
| Repeat management page/repository | [repeat page](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/task_recurrence_page.dart); [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | Some tracking cue, progress and history logic exists | Main Task Create/Edit, Home and Report Center integration not yet evidenced; metric semantics need validation |
| Create/Edit, Home, Report Center | [#2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593), [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605) | IN PROGRESS / NOT ACCEPTED | Exact-head tests, screenshots and device evidence required |
| Repeat tracking data safety | [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) | NOT VERIFIED end-to-end | Prove past history/checklist immutability and backup/restore round-trip |

No RTLC application code, tests, APK, screenshot, or device validation was produced by the initial audit. Do not interpret the existence of the enum or recurrence page as completion of the owner contract.



## Deep conversation audit addendum — 2026-10-11

| Feature / gate | Current evidence | Status | Missing acceptance |
|---|---|---|---|
| Universal Arvin Time Picker | [#2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589), [#2590](https://github.com/mobinpda-lab/Arvin-clean/pull/2590), [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591) | Accepted UX direction; rollout OPEN | Unified source audit, all surface migration, exact-minute/Persian-digit/RTL behavior, Cancel non-mutation, screenshots, physical-device interaction and exact-head CI |
| High-priority Task checklist | [Conversation decision history](ARVIN_CONVERSATION_DECISION_HISTORY.md), [repeat lifecycle #2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | Requirement recorded; delivery NOT VERIFIED | Checklist under full/edit Task form; generic Task use; daily 06:00 example; persistence/edit-reopen; independent recurring occurrence state |
| RTLC | [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | Accepted direction; implementation NOT ACCEPTED | Task form, Home cue, Report Center filter/metrics, history/checklist invariants, backup round-trip and device proof |
| Task-form combined head | [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591), [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595), [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602) | Conflicting/overlapping open branches; #2602 CI failed test shards and Smoke skipped | Choose canonical lane, repair root causes, run all test shards + Debug/Release + Device Smoke on final exact head |
| Conversation decision history | [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) | Added to memory branch, not main | Reconcile/rebase documentation PRs and verify history remains linked from execution state |


## Owner decision — 2026-10-11
- Root Task data contract: Option 1. Use the existing `Task.description` only; do not introduce an independent root `Task.note` field.
- Keep existing canonical Task data, Notebook and FollowUp note semantics, storage and backup/restore compatibility. Decision is accepted; implementation and test evidence are still pending.

## 2026-10-11 — Root Task text field correction
- Feature: Task form canonical text field.
- Decision: only root `Task.description`; no root `Task.note`. Scoped FollowUp.note remains.
- Code head: PR #2595 branch head `cc8180575bb50087283c43a444d54af05de9bc81`.
- Evidence: source read-back confirms root Task.note/controller/input removed; test includes legacy root-note ignored / description preserved assertion; backup and TaskStore test root-note assumptions removed.
- Validation: GitHub workflow runs queued at readback. Analyze, test shards, Debug/Release APK and device smoke are not yet verified. Status = IMPLEMENTED, VALIDATION PENDING.



## 2026-10-11 — Recurrence defaults
- Feature: Task repeat editor.
- Branch/PR: `fix/repeat-seven-default-date-time-20261011`, Draft PR #2606.
- Latest known commit: `323b5a6afddd7977450ead87467e5d9dac206b04`.
- Code change: date/time autofill on recurrence activation for unscheduled tasks; automatic reminder aligned; count defaults to 7 and remains editable.
- Test added: widget test for current local date/time, timed (not all-day) task, aligned reminder, active recurrence and count=7.
- Validation: exact latest-head Analyze/tests/build not yet verified; earlier-head CI was still running and is not evidence for latest commit. Device Smoke not accepted.


## 2026-10-11 — Calendar sync after edit
- Existing #2248 architecture gate remains open.
- Evidence: `FollowUpCalendarProjection.project` emits recurring instances only when visible range is supplied; main outbound sync passes no range. Recurrence reminder IDs include occurrence timestamp; edit-only sync uses linkedOnly matching by ID. This explains a concrete recurrence-edit failure mode; full device/provider root cause still needs validation.
- Status: ROOT CAUSE IDENTIFIED FOR RECURRING EDIT PATH; FIX BLOCKED pending stable identity contract review; no code fix or acceptance claim.

## 2026-10-11 — Pastel visual language expansion

| Surface | Implementation evidence | Tests / current status | Remaining proof |
|---|---|---|---|
| Home + Calendar | [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607), head `f526389e2058263af308f714bce49d7c4033000f` | Changes staged; exact-head Build [38158589426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589426) pending at last check | CI completion, narrow-device visual check and owner acceptance |
| Shared cards + form fields | Same PR: light/dark card and input themes | Exact-head Analyze/tests/build not yet confirmed | Check light/dark appearance, clipping, form affordances and small screens |
| Notebook | Same PR: note lavender/checklist green cards; tests added in `test/notebook_page_test.dart` | Test result pending | Owner/device visual check; existing inline checklist `[ ]` toggle defect is not covered as fixed |
| Report Center | Same PR: semantic status color cards; tests added in `test/report_center_page_test.dart` | Test result pending | Validate filters, preview/export and card readability |
| Next Action | Same PR: red/blue/amber cards; tests added in `test/task_next_action_page_test.dart` | Test result pending | Validate status mapping and same Task navigation |
| Device Smoke | [Run 38158589424](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589424) | Skipped | Physical Android acceptance still required |

## 2026-10-11 — Pastel UI validation follow-up

| Check | Evidence | Result | Next action |
|---|---|---|---|
| First Analyze attempt | [Run 38158589426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589426), job 114526628385 | Failed: Notebook test referenced helper functions before their local declarations | Test was moved after helper declarations in commit `571e5ed7c6751bcf56ba042a02ed6081e7023b0f`; verify new exact-head Analyze |
| New exact-head build | [Run 38158724999](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158724999), head `571e5ed7c6751bcf56ba042a02ed6081e7023b0f` | In progress at last check | Wait for Analyze, all test shards and Debug/Release APK results |
| Device Smoke | [Run 38158725094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158725094) | Skipped | Physical-device acceptance required |


## Report filter interaction validation — 2026-10-11

| Feature / gate | Evidence | Current status | Limitation / next proof |
|---|---|---|---|
| Report Center combined time + category filters | Failed run [38161588760](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38161588760); correction commit [9ae99714](https://github.com/mobinpda-lab/Arvin-clean/commit/9ae99714e3cc36fe73814b1c0af0c3611adff2d4) | Test correction committed; exact-head validation pending | Confirm the Apply control remains present after selections and the resulting report contains only the matching canonical Task. |
| Report filter accordion preserves selection | Failed run [38161588760](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38161588760); correction commit [9ae99714](https://github.com/mobinpda-lab/Arvin-clean/commit/9ae99714e3cc36fe73814b1c0af0c3611adff2d4) | Test correction committed; exact-head validation pending | Confirm category header tap hits the sheet, then selected FilterChip state survives collapse/reopen. |
| Persian report time picker | [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607), `lib/report_center_page.dart` at prior exact head | Source uses shared `showUniversalArvinTimePicker`; code integration verified by source inspection only | Exact-head CI, Persian digit/RTL behavior and physical Android validation still required. |
| PR #2607 exact-head CI | [Run 38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144) on commit `9ae99714e3cc36fe73814b1c0af0c3611adff2d4` | QUEUED at checkpoint; no pass/fail evidence yet | Inspect all jobs/shards and Device Smoke after run completes; PR remains Draft. |

No APK, device screenshot, physical-device result, merge or release was produced by this step. Automated source/test evidence is not owner acceptance.


## Report Center scroll helper correction — 2026-10-11

| Feature / gate | Evidence | Current status | Limitation / next proof |
|---|---|---|---|
| Report Center combined time/category filter interaction | Failed run [38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144) exposed test helper type mismatch (`ListView` supplied where `Scrollable` is required); correction [45caa5a3](https://github.com/mobinpda-lab/Arvin-clean/commit/45caa5a3d7c7b3b29264f0197d6affd2b1798df5) | Test correction committed; validation pending | Fresh exact-head tests must prove both filter application and accordion selection persistence. |
| Exact-head CI and Android smoke for commit `45caa5a3d7c7b3b29264f0197d6affd2b1798df5` | [Build #38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995); [Device Smoke #38163195983](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195983) | Build queued; Device Smoke in progress at checkpoint | Recheck final job conclusions and artifacts; automated smoke is not physical owner acceptance. |


## 2026-10-11 — Report filter exact-head CI follow-up

- PR #2607 test-only fix: commit `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439` updates the report filter accordion test to bring its header into view before collapse/reopen.
- Prior exact-head run #38163195995: Analyze and shards 0/1/2/3/5 passed; shard 4 failed due header tap outside modal sheet viewport; Debug/Release jobs were still running at the last job inspection. Do not treat the whole run as passed.
- New exact-head run #38163500776 is pending; evidence not yet available.
- Device Smoke #38163500919 is skipped because PR #2607 is Draft; no device smoke pass is evidenced.
- Release Closure #38163384915 failed at the policy gate because issue #2102 and PR #1901 remain open. This blocks publication.


## Repository-wide audit evidence — 2026-10-11
- Current main: a6ced27660d34cd87dd8915aff68d3a7555fd57a.
- Main inventory: recursive tree 740 paths; 21 workflows; 190 docs; 249 test/integration-test files; 1,248 branches; 19 open PRs; 1,096 open Issues.
- Open AUTO-FIX search count: 876; priority:core: 16; factory:blocked: 4; release-labelled: 3.
- PR #2607 exact head 7526dc186a26d099368fb288fdc7891ed57222ce: [Build #38163761104](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163761104) SUCCESS (Analyze, test-0..5, Debug APK, Release APK). [Device Smoke #38163760935](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163760935) SKIPPED due Draft condition.
- Main report filter source evidence: lib/report_center_page.dart calls showDatePicker at about line 249 and showTimePicker at about line 270. Current main has no corresponding Jalali picker test in test/report_center_page_test.dart; the branch adds it.
- Release gate evidence: [Release Closure #38164393875](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38164393875) FAILURE; [Final Head Release Validation #38164416537](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38164416537) SKIPPED. Issue #2102 and PR #1901 are open.
- Current Draft prereleases: v0.1.0-arvin-dd95132 and v0.1.0-arvin-33ed363, both carry APK/checksum/evidence assets but are marked unapproved Draft prereleases.
- Key records: #2531 release trigger isolation; #866 recovery-wave auto-close; #1139 owner acceptance ledger; #1324 SQL migration evidence; #2135 semantic versioning; #2248 calendar target identity; #2254/#2605 repeat contract; #2580 taxonomy conformance.
- Limitation: the first 300 recent commit API entries were sampled but not each historical diff reviewed; open Issues were inventoried by count/search and targeted high-priority reads rather than reading all 1,096 bodies.


## 2026-10-11 live audit checkpoint — workflow and release state
- Exact main SHA: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- Workflow source: `.github/workflows/release-closure.yml` still has `cancel-in-progress: true` and runs after successful `Arvin Production Orchestrator` completion; `.github/workflows/production-orchestrator.yml` also has a five-minute schedule and workflow_run triggers for Parallel Wave, Build and Device Smoke; `.github/workflows/factory-rest-promotion-bridge.yml` has its own five-minute schedule and the same worker/build/smoke workflow_run sources.
- Run evidence around 18:38–18:42 UTC: repeated Production Orchestrator / Production Loop / Promotion Bridge runs; multiple Release Closure failure/cancelled/skipped conclusions; Final Head Release Validation repeatedly skipped. This establishes churn, not a proven unique root cause. The cross-trigger graph still needs controlled attribution.
- PR #2531 patch proposes two exact changes: `cancel-in-progress: false` and a guard requiring a successful upstream orchestrator run whose own event is `workflow_dispatch`. It is OPEN/non-draft, not merged. Its exact-head CI/review must be checked before promotion.
- Release evidence: #2102 OPEN; #1901 OPEN; #1139 OPEN; both available prereleases are Draft and not release candidates. No physical-device acceptance is evidenced here.
- #866 is still OPEN; comments show AI-provider HTTP 429 cooldown/retry. #1324 remains OPEN for migration acceptance. Do not infer closure from code presence.
- Audit coverage boundary: 740 repository paths, 21 workflow files, 190 docs, 249 test/integration-test files, 1,248 branches, 19 open PRs, 1,096 open Issues; 876 open AUTO-FIX search results. These are inventory/search counts, not individually reviewed artifacts. Continue bounded passes over all PRs, issues, branches, commits, docs and workflows.


## PR #2531 exact-main refresh — 2026-10-11
- Existing PR #2531 branch was 18 commits behind main. Rebuilt its branch from exact main `a6ced27660d34cd87dd8915aff68d3a7555fd57a`, preserving only the original release-closure workflow and its focused test.
- New exact head: `4505c759a8338e91c596d9b031d16d29080a339c`; comparison: ahead 1, behind 0; changed files = 2.
- Exact-head checks at poll: 21 total, 6 completed, 9 in progress, 6 queued; Build #38165128162 and Device Smoke #38165128170 queued. Outcome pending.
- PR comment posted to explain the rebase, exact scope, and pending evidence. Not merged; no release side effect.


## Report Center exact-head evidence — 2026-10-11
- PR #2607 head commit: [8d3d60a1b321fa4ceb9f5da779a144d3705b9103](https://github.com/mobinpda-lab/Arvin-clean/commit/8d3d60a1b321fa4ceb9f5da779a144d3705b9103).
- Exact-head Build run [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767): Analyze PASS; quality shards 0–5 PASS; Debug APK PASS; Release APK PASS.
- Artifact `arvin-debug-apk` ID `11712403085`, SHA-256 `78566ec458aed40fa36cc43d58c1cd3fd94bb8be18f501d0b8010942bdd8893b`.
- Artifact `arvin-release-apk` ID `11712088044`, SHA-256 `ff8acc7c4a30e9178ca22d08eebc60b85b4789b4af9657740bd02069ca2de53c`.
- Device Smoke run [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708): SKIPPED because PR #2607 is Draft. No physical-device/small-screen RTL evidence is established by this run.
- PR #2607 and #2591 remain OPEN/Draft. Shared picker widget file is identical at both heads; `lib/main.dart` and `lib/report_center_page.dart` contain different PR-specific integration changes and need deliberate reconciliation.
- Release gate [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) remains OPEN/BLOCKED. CI success is not product-owner acceptance or release approval.


## Release-closure workflow correction merged — 2026-10-11
- PR [#2531](https://github.com/mobinpda-lab/Arvin-clean/pull/2531) merged as [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd).
- Change: `.github/workflows/release-closure.yml` now avoids cancelling an active closure run and guards workflow_run execution so only a successful upstream `workflow_dispatch` run can invoke closure; contract test updated accordingly.
- Exact PR-head evidence before merge: Build [38165128162](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38165128162) passed Analyze, six test shards and both APK builds; Device Smoke [38165128170](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38165128170) passed all six lanes.
- Current-main post-merge workflow confirmation is still pending. Issue #2102 remains OPEN/BLOCKED; merge does not authorize a release.


## Post-merge current-main gate — 2026-10-11
- Latest commit: [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd), merge of PR #2531.
- Verified on main: `.github/workflows/release-closure.yml` contains `cancel-in-progress: false` and the successful `workflow_dispatch` guard; corresponding contract test exists.
- Post-merge Build/Device Smoke status is **NOT ESTABLISHED**: connector returned no PR-triggered workflow runs for the merge SHA and combined status had zero checks. This is missing evidence, not pass/fail.
- PR #2607 exact head `8d3d60a1...`: Build [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) PASS (Analyze, shards 0–5, Debug/Release APK); Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) SKIPPED because Draft. This head predates the new main merge.
- PR #2591 remains Draft and stale-base; shared picker widget file identical across both PRs, integration files differ. Reconcile before merge.
- Issue #2102 remains OPEN/BLOCKED; physical-device Calendar sync and backup/restore acceptance, RTL review, Golden Flow and owner approval are still required.


## Device Smoke evidence recovery — 2026-10-11
- Run [38037275973](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38037275973): job API now reports all six lanes completed/success — Home, Backup/Restore, SQL migration, Quick Capture, People, SQL persistence.
- Artifacts actually listed: Home [11665410659](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/11665410659), People [11665011600](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/11665011600), Quick Capture [11664318029](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/11664318029). Backup/Restore artifact is missing from the listing, so its output/evidence must be recovered or marked unavailable; job success alone does not prove restore integrity.
- Calendar edit PR #2570 merged at [34a6cee9ae05ad1cf632960b96e98f2a5448e128](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128).
- Main release-closure workflow contains the merged `cancel-in-progress: false` and explicit successful `workflow_dispatch` guard. Combined-status lookup for merge commit `d8afc717eaf02d6d0bedf92e800c7f93209c97bd` returned no entries; do not claim current-main post-merge CI from this result.
- Release gate #2102 remains OPEN/BLOCKED and regression PR #1901 remains OPEN.


## Exact current-main validation — 2026-10-11
- Main SHA verified from `/branches/main`: [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd).
- Build [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381) PASS on exact main: Analyze, test shards 0–5, Debug APK, Release APK. Debug artifact 11712873761 SHA-256 `a6c6be99448d9160e2ddee09b8d6b03e198c9999fb8f48f6d31ec26a528806a5`; Release artifact 11712389980 SHA-256 `4c9b5deb4d84a8a097b42ca42594e1edf7b0e16657083fb91402ad8d5794f7a4`.
- Device Smoke [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) same SHA is not complete at checkpoint: Home/Quick Capture PASS, SQL migration/SQL persistence IN_PROGRESS, Backup/Restore/People QUEUED. Current artifacts: Home 11712218995 and Quick Capture 11713050656. No full-smoke PASS claim.
- Visual review of smoke screenshots: Home RTL captured view legible; People empty state/add action visible; Quick Capture has visibly truncated labels in compact three-column chips. Captures do not establish physical-device acceptance.
- Release Closure [38167799987](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167799987) failed closed at explicit product approval on prior SHA. No release authorized.
- Merged fixes already on main: Backup/Restore PR #2585 (merge SHA a6ced276...), Calendar edit-sync PR #2570 (34a6cee9...), Calendar-link backup/restore PR #2569 (598fe651...). Do not recreate them.
- Remaining acceptance gaps: current-main full Device Smoke, actual file-provider/device restore integrity, same-event/no-duplicate calendar verification, recurring occurrence coverage, physical-device RTL and full Golden Flow, owner approval.


## Device Smoke progress — exact main SHA (2026-10-11)
- Run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426), SHA `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`: Home, Quick Capture, SQL migration and SQL persistence PASS; Backup/Restore and People IN_PROGRESS. Run has not completed; no final smoke pass claim.


## Exact-main automated validation completed — 2026-10-11
- Main SHA `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`: Build run [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381) passed Analyze, six test shards and Debug/Release APK builds; Device Smoke [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) completed successfully across all six lanes: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore, People.
- APK evidence: Debug artifact 11712873761, SHA-256 `a6c6be99448d9160e2ddee09b8d6b03e198c9999fb8f48f6d31ec26a528806a5`; Release artifact 11712389980, SHA-256 `4c9b5deb4d84a8a097b42ca42594e1edf7b0e16657083fb91402ad8d5794f7a4`.
- Smoke artifacts: Home 11712218995; Quick Capture 11713050656; People 11713400184. No Backup/Restore artifact is listed. Lane success proves automation only, not real Android file-provider or physical-device data integrity.
- Remaining acceptance evidence: physical-device Calendar edit updates the same event without duplicates; real file-provider backup/restore round-trip, rollback and Calendar-link integrity; recurrence/occurrence/checklist golden flow; compact-screen RTL and Quick Capture label review; explicit owner approval. Release remains BLOCKED until these are reviewed and accepted.


## Live exact-main evidence recheck — 2026-10-11 (additive correction)

- Confirmed symbolic `main` is identical to `d8afc717eaf02d6d0bedf92e800c7f93209c97bd` using GitHub commit comparison.
- Build: [run 38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381). Analyze, all six test shards, Debug APK and Release APK: SUCCESS.
- Device Smoke: [run 38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426). Backup/Restore, Quick Capture, Home, People, SQL Migration and SQL Persistence: SUCCESS.
- Scope limitation: this is automated/emulator evidence. It does not prove physical-device same-event Calendar updates, real system file-provider Backup/Restore/rollback integrity, restored Calendar-link integrity, compact-screen RTL visual acceptance, full Repeat/Occurrence + Checklist Golden Flow, or owner release acceptance.
- No physical-device proof or owner acceptance is claimed. Keep release gate [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN.


## Live exact-main checkpoint — 2026-10-12
| Feature / gate | Exact evidence | Result | Status |
|---|---|---|---|
| Documentation cleanup | PR #2613 merged at `cea76673d871ce52b84dacf69f355c4282802baa`; PR-head Build #38169850276 and Device Smoke #38169850272 succeeded on head `55c3f829d7e443a6a4ae91de5e4b433965357400` | Documentation-only cleanup validated | Done for cleanup scope only |
| Current-main Build | [38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086), SHA `cea76673d871ce52b84dacf69f355c4282802baa` | Analyze passed; tests and APK builds not complete at last query; run state stale | Not accepted as pass |
| Current-main Device Smoke | [38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043), SHA `cea76673d871ce52b84dacf69f355c4282802baa` | Overall queued; two emulator lanes in progress and four queued at last query; run state stale | Not accepted as pass |
| Calendar event identity | Issue #2102; physical-device proof required | No current physical-device evidence | Blocked |
| Backup/Restore integrity | Issue #2102; real Android provider and link retention required | No current physical-device evidence | Blocked |
| Persian RTL / compact screen / golden flow | Issue #2102 | No current owner/device acceptance | Blocked |

A missing workflow log/BlobNotFound is not a success or failure result. Emulator evidence does not replace physical-device acceptance.


## Artifact recheck correction — 2026-10-12
| Feature / gate | Exact evidence | Result | Status |
|---|---|---|---|
| Main Debug APK artifact | Build run [38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086), artifact 11717311531, 92,487,308 bytes | Artifact exists and is non-expired; overall run remains reported in progress | Artifact available; workflow not accepted as passed |
| Main Release APK artifact | Build run [38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086), artifact 11716328109, 32,681,865 bytes | Artifact exists and is non-expired; overall run remains reported in progress | Artifact available; not a published/accepted release |
| Main Home screenshot | Device Smoke run [38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043), artifact 11717201884 | Artifact exists | Partial emulator evidence only |
| Main Quick Capture screenshot | Device Smoke run [38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043), artifact 11716972463 | Artifact exists | Partial emulator evidence only |
| Other Device Smoke lanes | Same run; no listed artifact for People, SQL persistence, Backup/Restore or SQL migration | Evidence incomplete | Not accepted |

Recorded on release gate Issue #2102 in comment [6114324441](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6114324441). Artifact existence must not be conflated with workflow conclusion, full smoke completion, physical-device acceptance or owner approval.


## 2026-10-13 — Follow-up/reminder audit evidence

| Area | Evidence | Result |
|---|---|---|
| Model | `lib/models/task.dart` on main SHA `18117aea2fa07b5a9a02e6021f41ff4faae120cc` | `FollowUp.reminderDate/nextFollowUp` are separate nullable DateTime values; no FollowUp all-day marker |
| Editor | `lib/follow_up_entry_page.dart` | Next Follow-up inherits history hour/minute; no clear-next; save does not create reminder |
| Calendar projection | `lib/services/follow_up_calendar_projection.dart` | FollowUp reminder omits `isAllDay`; Task due-date path alone applies date-only heuristic |
| Persistence | `lib/services/task_store.dart` | canonical Task JSON envelope is persisted; nested FollowUp fields travel in Task payload |
| Backup/restore | `lib/backup_manager.dart` | backup uses `Task.toJson()`; restore uses `Task.fromJson()` |
| Existing tests | `test/follow_up_reminder_model_test.dart`, `test/follow_up_entry_page_test.dart`, `test/follow_up_calendar_projection_test.dart` | JSON independence and reminder clear/edit covered; first-set bridge and FollowUp all-day behavior not established |
| Execution validation | Current assistant run | Read-only audit only; no Flutter test/analyze/build/device run |

PR #2650 is documentation-only and must be revalidated on its final exact head; no green check is claimed for a new post-audit commit.


## 2026-10-13 — Owner clarification evidence (Follow-up / Reminder)
- Source: explicit owner clarification in conversation on 2026-10-13.
- Accepted behavior: setting Next Follow-up does not automatically create a reminder. Only if the user explicitly wants/chooses a reminder for it, prefill reminder title from Task title and schedule from Next Follow-up; user may independently edit reminder title/date/time and request additional reminders.
- Independence invariant: no later propagation in either direction; reminders can remain without Next Follow-up; no silent overwrite/duplicates.
- Validation status: product contract clarified; implementation and app validation not yet proven. Keep release NO-GO.


## 2026-10-13 — Owner cardinality decision evidence
- Source: explicit owner clarification in conversation on 2026-10-13.
- Accepted contract: one Task can have multiple recorded Follow-up entries and multiple independent reminders. Each reminder and each history entry remains distinct; changes to one must not affect others.
- Reminder creation remains opt-in. If the user chooses a reminder for Next Follow-up, Task title and Next Follow-up date/time are initial suggestions only.
- Validation status: product contract recorded; code/model cardinality and app validation not yet proven.


## 2026-10-13 — Multiple independent Task reminders: evidence and gap
- Source: `lib/models/task.dart` on main, blob `3becbe89ffd378d8bdf19300211e76ba392760b0`: FollowUp has singular nullable `reminderDate` and `nextFollowUp`; Task reminder is also singular.
- Existing test: `test/follow_up_reminder_model_test.dart`, blob `2d232e913812e5dc6b8ff724bc9ca8dd11c5c290`, validates one FollowUp reminder JSON round-trip and legacy missing-reminder behavior only.
- Current exact-head docs CI for PR #2652 head `00ae93b2dba36093c4074624fe951efec51e2ab4`: Build run [38317606450](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38317606450) PASS (Analyze, test shards 0–5, Debug/Release APK); Device Smoke run [38317606458](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38317606458) PASS (Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore). This validates the documentation branch's CI only; it does not validate the unimplemented multi-reminder feature or physical-device acceptance.
- Gap tracker: Issue #2654. Proposal is not approved; no application code/schema changed.

## LIVE EVIDENCE OVERRIDE — 2026-10-13 — PR #2665 exact-head result

- **Validated pre-memory-update head:** `2987f5530749b6de6292ff3c86933d8f50b56578`.
- **Build:** [38368795309](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38368795309) — SUCCESS: Analyze, test shards 0–5, Debug APK, Release APK.
- **Device Smoke:** [38368795338](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38368795338) — SUCCESS: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore, People.
- **Evidence boundary:** this proves only the automated paths executed on that SHA. It is not evidence of physical-device acceptance, external Calendar provider same-event update/no-duplicate, real OS notification behavior, or release approval.
- **PR status:** #2665 remains open/unmerged. The documentation update itself creates a new head; re-run/verify exact-head gates before treating the new head as validated.
- **Release gate:** NO-GO until physical-device and provider acceptance plus owner approval are recorded.


## LIVE EVIDENCE OVERRIDE — 2026-10-13 — PR #2665 latest queried head

- **Checked head:** `be52a7457b6300cb917b7ab312c2ec4e27c607fa`.
- **Build:** [38370894374](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38370894374) — SUCCESS. Analyze, test shards 0–5, Debug APK, Release APK.
- **Device Smoke:** [38370894181](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38370894181) — SUCCESS. Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore, People.
- These are exact-head automated/emulator results for the queried SHA only. They do not prove physical-device acceptance, provider same-event update/no-duplicate, actual OS notification behavior, or release approval.
- The memory update itself creates a newer branch head; re-check exact-head Build and all six Device Smoke lanes before merge.


## 2026-10-13 — Multiple-reminder safe-integration evidence
- **Architecture decision document:** `docs/arvin-memory/ARVIN_MULTIPLE_REMINDER_ARCHITECTURE_DECISION.md`, integration branch `integration/task-multiple-reminders-safe-20261013`; commit `33ddb0f9467fd9a2d832c2e485eedf449da8eba3`.
- **Execution memory checkpoint:** `ARVIN_EXECUTION_STATE.md` updated on the integration branch; commit `a340845bc3651e6d0e65a3b64cf3f2e4627429fa`.
- **Branch comparison:** integration branch was checked against main `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`; it is 2 commits ahead, 0 behind, and currently contains documentation-only changes.
- **Implementation/test evidence:** NONE YET for multiple-reminder code on this branch. No migration, tests, builds, Calendar provider acceptance, or physical-device test have been run on this branch. Do not confuse earlier CI results from other PR heads with evidence for this branch.
- **Release gate:** NO-GO.
# EVIDENCE UPDATE — 2026-10-13 (empty current owner database)

| Evidence | Result | Scope / limitation |
|---|---|---|
| Owner statement in execution conversation | No information has been entered; database is raw/empty | Owner-reported current state; not an independent inspection of every installed DB or backup |
| Current owner-entered-data loss risk | No current owner-entered records identified by owner | Do not claim existing user records are at risk; still inspect destructive operations |
| Legacy Task reminder migration/model contract | OPEN | Compatibility blocker remains; empty database does not prove legacy JSON/backups never exist |
| Application code changed in this checkpoint | NONE | Documentation-only update |
| Exact-head CI / device acceptance | NOT ESTABLISHED by this documentation update | Must be collected on the final code SHA; physical-device acceptance remains separate |
| Release | NO-GO | No change to release gate |
