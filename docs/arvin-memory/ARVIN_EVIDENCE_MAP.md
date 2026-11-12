## 2026-10-14 — CI recovery dispatcher evidence

| Feature / Gate | SHA / Run | Result | Evidence / limitation |
|---|---|---|---|
| Recovery dispatcher implementation | PR #2699; parent before memory checkpoint `718e8cf730305e98aee3f9b12f4c239a80a06190` | Pending validation | [PR #2699](https://github.com/mobinpda-lab/Arvin-clean/pull/2699) |
| Arvin Build | Run [38514863822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38514863822), parent SHA `718e8cf730305e98aee3f9b12f4c239a80a06190` | Pending at last poll | Not terminal; does not validate the next commit |
| Device Smoke | Run [38514863806](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38514863806), parent SHA `718e8cf730305e98aee3f9b12f4c239a80a06190` | Pending at last poll | Emulator/CI evidence only; not physical-device acceptance |
| Person PR exact-head runs | `6d01c603...`, `0432e3a...` | No runs returned | Absence confirmed in Actions query; cause not proven |
| Main Build / Device Smoke | `de795419be2c39775119af8eaa37c53744820d93` | Previously successful | Main-only evidence; not Person PR validation |
| Release Closure / Final Head Validation | Runs [38512839311](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38512839311), [38512853231](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38512853231) | Skipped | Release remains NO-GO |

**Evidence rule:** refresh all rows against the final integrated SHA. Pending, queued, skipped and older SHA results are not passes.

---

# LIVE EVIDENCE UPDATE — 2026-10-14 — Person integration repair

- **Parent multiple-reminder integration:** PR #2666 head `ad762774009e5b5c7ee341146a8160c52e2b9bb2`; Build [38507091410](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091410) SUCCESS, Device Smoke [38507091345](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091345) SUCCESS across all six lanes, Calendar Provider Acceptance [38507091333](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38507091333) SUCCESS. CI/emulator evidence only; no physical-device acceptance.
- **Person integration prior head:** `07c7f9005b7331f07468e20d13b3939c990bd9fd`; Build [38506153872](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38506153872) FAILED test shards 0–5; Analyze, Debug APK and Release APK SUCCESS.
- **Person repair head:** `0432e3a7874ce5bc0f798345e232a480dc3d65b3`; changes recorded in PR #2695 commits `e57df8e`, `d2de8f2`, `c169b1c`, `dc5a9a5`, `a612dde`, `0432e3a`. Exact-head Build/Device Smoke: **NO RUN RETURNED at latest poll; validation unknown, not passed**.
- **Plan PR:** PR #2698 head `6c4e99b29e6d27f3458b5e84a608175311ab08c5`; Build [38508441738](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38508441738) Analyze + all six test shards SUCCESS, Debug/Release APK IN_PROGRESS at last poll; Device Smoke [38508441722](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38508441722) QUEUED. Evidence applies only to that head; this evidence-map update creates a newer head.
- **Release:** NO-GO. No evidence here proves physical-device behavior, final Person backup/restore integrity, or final integrated feature acceptance.

---

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


## 2026-10-14 — Latest-head terminal CI evidence

| Feature / Gate | SHA / Run | Result | Evidence / limitation |
|---|---|---|---|
| Arvin Build | `db60759072b53ef215f07ce28ef69803cdfe0c3b`; [run 38517351542](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38517351542) | PASS | Analyze, six test shards, Debug APK, Release APK all successful; event was `pull_request`, so this is not dispatcher-path proof |
| Device Smoke | same SHA; [run 38517351453](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38517351453) | PASS | Home, Quick Capture, SQL Migration, SQL Persistence, People, Backup/Restore all successful; CI/emulator evidence only, not physical-device validation |
| Recovery dispatcher end-to-end | PR #2699 | BLOCKED / NOT YET PROVEN | Must observe a real `workflow_dispatch` on a controlled same-repository PR lacking exact-head evidence and verify requested SHA equals checked-out SHA |
| Release acceptance | Current product | NO-GO | Physical-device validation and remaining product acceptance gates are still outstanding |


## 2026-10-14 — Fresh autonomous live recheck

| Feature / Gate | SHA / Run | Result | Evidence / limitation |
|---|---|---|---|
| Default branch snapshot | `main` — `de795419be2c39775119af8eaa37c53744820d93` | Observed | Live branch API; supersedes older main SHA for current-state decisions |
| Recovery dispatcher Build | PR #2699 head `379f4e645662c5c0d911fe168d27aa44e69ba9ab`; [run 38519665323](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38519665323) | PASS | Analyze, six test shards and Debug/Release APK; event is ordinary PR CI, not workflow_dispatch proof |
| Recovery dispatcher Device Smoke | Same PR head; [run 38519665528](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38519665528) | PASS | All six lanes: Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore; emulator/CI evidence only |
| Dispatcher operational acceptance | PR #2699 | NOT PROVEN | Workflow file absent on main; no controlled workflow_dispatch execution verified |
| Person feature exact-head CI | PR #2695 head `6d01c603edf897f813ceb94d15bc7d36b5c058c2` | NO RUNS / NO CHECKS | Live Actions and check-runs queries both returned zero; old SHA results do not validate this head |
| Release closure | `de795419...`; runs [38521172475](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38521172475) and [38521176998](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38521176998) | SKIPPED | Skipped is not pass; issues #2102 and #1901 remain open |
| Physical-device / integrated Person acceptance | Current product | OPEN | CI/emulator evidence does not replace real-device and data-integrity acceptance |

**Decision:** keep PR #2695 Draft and both PRs unmerged; no release. Recheck all evidence against the final resulting SHA after any update.


## 2026-10-14 — Recovery dispatch correctness fix (pending validation)

| Feature / Gate | Change | Result | Evidence / limitation |
|---|---|---|---|
| Dispatcher workflow selection | Dispatch Build using the default branch workflow definition and pass the exact target SHA | IMPLEMENTED / CI PENDING | PR #2699; avoids relying on stale workflow inputs in the target PR branch |
| Exact target evidence | Match default-branch workflow_dispatch run by target-SHA run name; Build jobs assert checked-out SHA | IMPLEMENTED / CI PENDING | Workflow code now distinguishes workflow-ref SHA from requested target SHA |
| Recovery concurrency | Key Build concurrency by target SHA | IMPLEMENTED / CI PENDING | Prevents separate recovery targets on main from cancelling one another |
| Operational dispatcher acceptance | Controlled dispatch with terminal successful Build and verified exact checkout | OPEN | Requires reviewed activation on default branch; not proven by ordinary PR CI |
| Person feature validation | PR #2695 current head `6d01c603edf897f813ceb94d15bc7d36b5c058c2` | NO RUNS / OPEN | Separate feature; recovery workflow changes do not validate it |


## 2026-10-14 — Live exact-head validation recheck

| Feature / Gate | Exact evidence | Result | Limitation / next action |
|---|---|---|---|
| Recovery dispatcher PR CI | PR #2699 head `555541a5426b02e483bf2168fcc78a57ddc8c3a6`; Build [38523576951](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38523576951) | SUCCESS | PR merged; controlled dispatch for a distinct target SHA still needed |
| Recovery dispatcher device smoke | [38523577094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38523577094), six lanes | SUCCESS | Does not prove controlled dispatch of a target branch |
| Person exact-head Build | PR #2695 head `93202e9e24e33bff31daaf933b2c4fb1417dfb46`; Build [38579471120](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38579471120) | SUCCESS | Analyze, six test shards, Debug APK and Release APK passed; review product acceptance and data-integrity coverage |
| Person exact-head smoke | [38579471201](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38579471201) | SUCCESS | All six lanes passed, including People, SQL persistence/migration and backup/restore; physical-device validation remains open |
| Person delete-title test assertion | `test/person_directory_page_test.dart` at current PR #2695 head | CORRECTED / CI PASS | Assertion scoped to AlertDialog; do not reuse closed divergent PR #2715 |
| Physical device and release closure | Product acceptance; issues #2102 and #1901 | OPEN / NO-GO | Verify real-device behavior, integrated flow and backup/restore integrity before release |


## 2026-10-15 — Legacy Task reminder migration candidate
| Area | Evidence | Result | Remaining proof |
|---|---|---|---|
| Owner decision | Issue #2654 comment 6178475884 | Option B selected | Decision recorded |
| Model migration | lib/models/task.dart on current-main-based feature branch | Candidate stable ID + version marker + timestamp preservation | Exact-head tests; SQL and backup/restore |
| Calendar identity | lib/services/follow_up_calendar_projection.dart and calendar_inbound_sync_service.dart | Candidate preserves task-reminder:<taskId> and edits/deletes migrated record | Calendar Provider Acceptance/no duplicates |
| Scheduler identity | lib/services/follow_up_reminder_projection.dart | Candidate preserves existing delivery key | Alarm/restart/reschedule regression |
| Current-head validation | No terminal results observed yet | NOT VALIDATED | Analyze, all tests, Debug/Release, six smoke lanes, Calendar provider |
| Physical-device/release | No new device evidence | OPEN / NO-GO | Real-device acceptance and owner release approval |


## 2026-10-15 — PR #2719 exact-head validation (SHA `396cf7e70ac3cd88463436d471a6e624533fb181`)
| Area | Evidence | Result | Remaining proof |
|---|---|---|---|
| Analyze + six test shards + Debug/Release APK | [Build run 38695156447](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38695156447) | SUCCESS on exact PR head | Review test coverage and inspect any relevant annotations |
| Device Smoke: quick-capture, home, people, SQL persistence, SQL migration, backup/restore | [Device Smoke run 38695105201](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38695105201) | All six emulator lanes SUCCESS | Physical-device acceptance; integrated flow and referential integrity |
| Calendar Provider Acceptance | [Run 38695105183](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38695105183) | SUCCESS | Validate no duplicate legacy event in real environment / user device |
| PR disposition | [PR #2719](https://github.com/mobinpda-lab/Arvin-clean/pull/2719) | Draft/open/unmerged | Review migration rollback/retry and full acceptance before merge |
| Release gate | Issues [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) and [#1901](https://github.com/mobinpda-lab/Arvin-clean/issues/1901) | OPEN / NO-GO | Integrated product acceptance and physical-device evidence |


## 2026-10-15 — Terminal CI evidence for PR #2725

- Build: [run 38752957837](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38752957837) = `success` for head `ba2306cfc66ad982f8e8ab73b838a4a8d6ed6b55`; analyzer, six test shards, Debug and Release APK jobs passed.
- Device Smoke: [run 38752957813](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38752957813) = `success`; home, quick-capture, people, SQL migration, SQL persistence and backup/restore all passed.
- PR #2725 is the standalone People directory / Follow-up person-link backup fix and references Issue #2682. These checks establish CI/emulator success only, not physical-device acceptance.


## 2026-10-16 — Notebook pastel and cross-page visual audit (PR #2751)

| Area | Implementation / evidence | Result | Remaining proof |
|---|---|---|---|
| Notebook filters/search/empty state | `lib/notebook_page.dart`; `test/notebook_page_test.dart` | Implemented in current PR branch | Exact-head tests and visual artifact |
| Palette and typography audit | Reviewed Home, Calendar, Reports, Notebook, Follow-up office, and Task editor; no raw `Color(0x...)` or raw `fontFamily: '...'` remained in those files at the audit checkpoint | Static scan passed | Analyzer + widget tests on final SHA |
| Calendar follow-up interaction | `lib/calendar_page.dart`; regression tests updated to require long press for follow-up actions and keep short tap for parent Task | Implemented, awaiting exact-head test result | All test shards green; inspect device screenshots |
| Prior exact-head Build | Run [38859380955](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38859380955), SHA `2d04631dd9d1939bd3feafa12aa7d68bec349b58` | Debug/Release APK jobs succeeded; multiple test shards failed | Re-run on final SHA; old success is not release evidence |
| Final head Build / Device Smoke / Calendar Provider | Runs are regenerated when the branch head changes | Pending validation | All six device-smoke lanes, Calendar Provider Acceptance, artifacts and screenshot review |
| Font / physical device | VazirHarf declared; Vazirmatn asset not found in project assets; no new physical-device evidence | OPEN / NO-GO | Add licensed font asset if Vazirmatn is mandatory; separate physical-device acceptance |


## WAVE 0 — LIVE GITHUB EVIDENCE SNAPSHOT — 2026-11-11

All evidence below is ref-specific. This documentation snapshot did not dispatch, rerun, cancel or modify any workflow.

### Repository and PRs
- Default branch: `main`; base commit: `45e4202b03a434459e4c021a04efa7e8396359db`.
- #3380: OPEN / DRAFT / UNMERGED; head `33a8fb14a9979d0d86775cb5457970c7e445077b`.
- #3382: OPEN / DRAFT / UNMERGED; head `adee525e94fa2daec617255d57f9cfb65e3efe66`.
- #3384: OPEN / DRAFT / UNMERGED; head `c8996bae351d9aede87a251d57141456b945d0a8`; 12 commits, six changed files.
- #3384 changed files at audit: `lib/models/task.dart`, `lib/services/g1_drift_schema.dart`, `test/model_task_unified_item_test.dart`, `test/services/g1_drift_schema_test.dart`, `test/services/sql_task_migration_writer_test.dart`, `test/task_store_reminder_persistence_test.dart`.

### Exact-head Actions
- [Build 43076778275](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076778275) on `c8996bae...`: COMPLETED / FAILURE.
  - Analyze: PASS; Visual: PASS.
  - Test shard 0: 234 passed / 14 failed.
  - Test shard 1: 197 passed / 6 failed.
  - Test shard 2: 301 passed / 26 failed.
  - Test shard 3: 151 passed / 11 failed.
  - Test shard 4: 243 passed / 11 failed.
  - Test shard 5: 186 passed / 11 failed.
  - Total: 1,312 passed / 79 failed / 1,391 total.
  - Debug, Staging and Release APK jobs: SUCCESS. Build conclusion remains FAILURE due to test shards.
- [Follow-up File Persistence 43076778148](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076778148): COMPLETED / SUCCESS; this workflow is not a replacement for the full SQLite migration suite.
- [Device Smoke 43076778211](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076778211): PENDING; zero jobs and no device artifacts available at audit time.
- Main orchestration: [43079261584](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43079261584) and [43079306186](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43079306186) SUCCESS on main SHA `45e4202b...`; these are orchestration/queue evidence only. Main Release Closure and Final Head validation were SKIPPED (for example runs 43076793035 and 43076806994). No new Build or Device Smoke was run by this WAVE.

### SQLite regression evidence
- D01: `test/services/g1_drift_completed_at_migration_test.dart` fails because `follow_up_enabled` remains present after migration. The new migration path visible in the PR addresses `task_reminders.is_legacy_task_reminder`, not this legacy Task column.
- D02: `test/services/task_migration_reader_test.dart` fails with expected `followUpEnabled: null` but actual key absent. Because the source input lacks that key, the expectation conflicts with the required Missing/Explicit-NULL distinction.
- D03: `test/services/sql_task_migration_writer_test.dart` fails at approximately line 481: expected preservation condition `true`, actual `false` for `futureFollowUpField` after close/reopen.
- Additional observed failures include a schema metadata expectation mismatch involving `reminderDate`, a Follow-up person UI finder failure, and a Task detail widget error (`ListView` is not a subtype of `Scrollable`).
- Individual idempotency and rollback/recovery tests passed in the inspected suite, but this does not establish full regression acceptance. Five-round serialization, complete Backup/Restore, and Migration Recovery remain NOT VERIFIED.
- A database-level Person-link close/reopen test passed; UI-level Person-related tests failed. Overall Person relation acceptance remains NOT VERIFIED.

### Evidence limits
- No result from this snapshot may be attributed to a SHA other than the one explicitly listed.
- APK artifact digests were recorded in the preceding SQLite audit; this WAVE did not create or download new artifacts.
- A green orchestration run, a successful narrow persistence workflow, an APK build, or a pending Device Smoke run does not establish SQLite data-integrity acceptance.


## COMMAND 07-A.2.24 evidence addendum — 2026-11-12

- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3384 exact head: `cbf7d241e588c6b4b6051dea5bb3d309a8c3cb05`.
- Build run 43202151547 = failure; SQLite Snapshot 43202151552 = success; Follow-up File Persistence 43202151499 = success; Device Smoke 43202151481 = queued; Draft Review APK 43202151478 = skipped.
- No exact-SHA APK artifact digest, five-weight APK inspection, PDF font resource inspection, or device visual acceptance is established by this addendum.
- Ruleset `main-protection` is active but currently has zero required approving reviews and `require_code_owner_review=false`; bypass actors list is empty and current user can bypass is `never`. CODEOWNERS has been added to the docs branch but effective enforcement is not yet enabled.
- Historical evidence must not be transferred between SHAs.


## COMMAND 07-A.2.25 — exact-ref evidence addendum (2026-11-12)

Canonical typography contract: [`docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md`](../architecture/ARVIN_TYPOGRAPHY_CONTRACT.md).

| Ref / Run | Exact SHA | Result | Evidence boundary |
|---|---|---|---|
| PR #3384 latest observed head | `2ac3580985a23e6ac5342d49c33343c8b4f01816` | OPEN / DRAFT | 80 commits, 60 files; no merge |
| Build `43217473284` | `2ac3580985a23e6ac5342d49c33343c8b4f01816` | PENDING | No test/build outcome yet |
| Device Smoke `43217473090` | `2ac3580985a23e6ac5342d49c33343c8b4f01816` | QUEUED | Seven lanes not yet run |
| SQLite Snapshot `43217473138` | `2ac3580985a23e6ac5342d49c33343c8b4f01816` | QUEUED | No new A-D result yet |
| Follow-up File Persistence `43217473064` | `2ac3580985a23e6ac5342d49c33343c8b4f01816` | QUEUED | No new persistence result yet |
| SQLite Snapshot `43212724352` | `e94105443e7516ed38eda6feaaee125d92fabaf4` | SUCCESS | A-D snapshot and five close/reopen cycles; not current-head evidence |
| Build `43212724211` | `e94105443e7516ed38eda6feaaee125d92fabaf4` | FAILURE | Analyze and test compilation errors from stale VazirHarf identifiers; APK builds failed before font audit |
| Follow-up File Persistence `43212724255` | `e94105443e7516ed38eda6feaaee125d92fabaf4` | FAILURE | File-backed repository test passed; Alarm Overlay diagnostic failed at compile time |

Never transfer successful evidence from `e941054...` to `2ac358...`. The five-weight font SHA-256 inventory is in typography contract §16 and applies to candidate branch assets only. The active Ruleset still has zero required approvals and does not require CODEOWNER review.


## COMMAND 07-A.2.25 — post-documentation HEAD refresh (2026-11-12)

- PR #3384 latest observed HEAD is now `318c9d7651299ecd0d1bfcda2653c52be87fb81f` (86 commits, 62 changed files), OPEN / DRAFT / UNMERGED. This SHA advanced after synchronizing the six existing `docs/project-continuity/` records; it supersedes the earlier 2ac358... checkpoint for current branch identity only.
- A fresh `actions/runs?head_sha=318c9d7651299ecd0d1bfcda2653c52be87fb81f` query returned no workflow runs at the time of this refresh. All Build/Device/SQLite/Persistence results on 2ac358... or older SHAs are historical and do not validate 318c9d....
- PR #3388 remains OPEN / DRAFT / UNMERGED; current observed HEAD `93f65ad4c42a2f9565a92b49058e68ff8b4eb3d7`.
- The five Vazirmatn binary SHA-256 values in typography contract §16 remain tied to the unchanged font blobs listed there; they do not establish APK inclusion or release readiness.
- Next action: wait for or trigger exact-head validation on 318c9d... using the repository's supported CI path, then inspect Build, SQLite Snapshot, Follow-up Persistence and all seven Device Smoke lanes. Do not reuse prior run outcomes.

Release remains NO-GO. Merge, release and deployment remain unauthorized.


## COMMAND 07-A.2.26 — exact-head checkpoint (2026-11-12)

Product candidate SHA: `b78488c0347e1a97a7a25f56c914a48761d44a25` on `feature/command-07-a-sqlite-contract-remediation`; PR #3384 OPEN / DRAFT / UNMERGED (87 commits, 62 files at last observed refresh). This supersedes 318c9d for current product validation only.

- Commit `b78488c0347e1a97a7a25f56c914a48761d44a25` corrected the PDF test's stale VazirHarf description/sample to Vazirmatn; assertions were preserved.
- All five actual TTF OpenType name tables report Version 33.003. Source repository: `rastikerdar/vazirmatn`; bundled license: SIL OFL 1.1. Exact upstream commit/tag and source-to-binary reproducibility remain pending. SHA-256 values remain in typography contract §16.
- Follow-up Persistence run `43219196583` is SUCCESS on this exact SHA. Both file-backed Repository Persistence and Alarm Overlay close/reopen diagnostic passed. The latter exercised Snooze, disposing the first overlay/SQLite connection, reopening the same file, loading the overlay again, tapping Complete and observing notification cancellation.
- Build `43219196600`: PENDING, no jobs allocated at last poll. SQLite A-D five-cycle run `43219196466`: QUEUED. Device Smoke run `43219196537`: QUEUED. Production Loop `43219196556`: SUCCESS. Orchestrator `43219196378`: SUCCESS.
- Existing schema tests cover Missing / explicit NULL / FALSE / TRUE metadata, retired-column absence, FK constraints and malformed-source migration preservation. The exact-head SQLite workflow is not yet complete; D01-D05 are not accepted as a whole. Snapshot A-D does not independently prove all triggers/indexes, backup/restore or forced interruption/recovery.
- Earlier SHA results are historical and must not be promoted to this candidate SHA.

Release remains NO-GO. No merge, release or deployment is authorized.


## COMMAND 07-A.2.28 — exact-SHA evidence addendum (2026-11-12)

**Current candidate SHA:** `a6d2d58d87530bfa184c93220cc329b819aca809` on `feature/command-07-a-sqlite-contract-remediation`.

| Run / Ref | SHA | Observed result | Evidence boundary |
|---|---|---|---|
| Build `43223035750` | `a6d2d58d87530bfa184c93220cc329b819aca809` | PENDING | No jobs allocated at last poll |
| Device Smoke `43223035920` | same | QUEUED | Seven scenario jobs not yet executed |
| SQLite Snapshot `43223035907` | same | QUEUED | No new snapshot result yet |
| Follow-up Persistence `43223035880` | same | QUEUED | No new file-backed result yet |
| Build `43219196600` | `b78488c0347e1a97a7a25f56c914a48761d44a25` | FAILURE | Analyze and six shards failed; Debug/Release font purge failed; Visual passed. Historical only |
| SQLite Snapshot `43219196466` | `b78488c...` | SUCCESS | Five real Close/Reopen cycles and A-D snapshot comparison. Historical only |
| Follow-up Persistence `43219196583` | `b78488c...` | SUCCESS | File-backed Follow-up and Alarm Overlay close/reopen scenario. Historical only |

### Upstream font provenance
- Upstream: `rastikerdar/vazirmatn`, commit `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7`.
- Light: `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42`, 122,920 bytes.
- Regular: `64e4a8189557a17b63fd7a77794207483e592972`, 122,752 bytes.
- Medium: `1e08dd54d90a4879451ef0f80fe0d8068fb7462f`, 122,656 bytes.
- SemiBold: `6b3842aca6055c8258404b1758133b81c961a13f`, 122,920 bytes.
- Bold: `efa9b095da01d299310bdcae293e24e657fe6da9`, 123,036 bytes.
- Bundled OFL license blob: `be66b3824e9772e75141e631695c5256f105fb57`, identical to upstream.

The blob identity comparison is byte-for-byte provenance, not APK/PDF acceptance. Do not promote any historical PASS to the current SHA.


## COMMAND 07-A.2.28.1 — exact-head SQLite success addendum (2026-11-12)

| Run / Job | Exact SHA | Result | Evidence |
|---|---|---|---|
| SQLite Snapshot `43223035907` / `131199160903` | `a6d2d58d87530bfa184c93220cc329b819aca809` | SUCCESS | Five Save/Close/Reopen/Verify cycles; A-D comparison; unknown future fields, multiple Reminder states/order, Follow-up order and Person links retained; FK check empty and FK enforcement enabled |
| SQLite Snapshot Artifact `13946956406` | same | AVAILABLE | JSON SHA-256 `0d828bfb57417da75570f39186e55c4e65fb639c50440b46f421b9520ea9c574`; ZIP digest `a436ec262c87fde240c4065f650d47f80c861b75d37a146840af895e52c93efc` |
| Follow-up Persistence `43223035880` / `131199161718` | same | SUCCESS | File-backed persistence; actual Alarm Overlay Snooze, first connection close, second connection reopen, reload, Complete and notification cancellation |
| Build `43223035750` | same | PENDING | No jobs allocated at last poll |
| Device Smoke `43223035920` | same | QUEUED | Seven scenario jobs not yet executed |

D01-D05 are not blanket-PASS. Snapshot evidence contributes to D02/D03 and selected D01/D04 observations, but does not prove complete schema objects, Backup/Restore or forced interruption/recovery. Historical run results on `b78488c...` remain historical.


## COMMAND 07-A.2.28.2 — new candidate and expanded acceptance coverage (2026-11-12)

**Current product candidate:** `551ecdc0542bb00f72c21167b4c721094b3a3cba`.

| Run | SHA | Status | Scope |
|---|---|---|---|
| Build `43224398615` | `551ecdc...` | PENDING | No jobs allocated at last poll |
| SQLite Snapshot `43224398076` | same | QUEUED | Expanded full schema catalog, all FK definitions, A-D comparison and five reopen cycles |
| Follow-up Persistence `43224398303` | same | QUEUED | File-backed persistence and Alarm Overlay close/reopen |
| Device Smoke `43224398160` | same | QUEUED | Scenario preparation not yet executed |

New code/test commits after the `a6d2d58...` exact-head successes:
- `45c39211...`: complete SQLite schema catalog and FK definition capture in Snapshot A-D.
- `7d3466f8...`: file-based backup JSON restored into a different file-backed SQLite database, followed by a second close/reopen and relation/Reminder verification.
- `551ecdc0...`: deliberate malformed source failure followed by source repair and safe retry of schema installation.

The successful Snapshot `43223035907` and Follow-up `43223035880` are tied to `a6d2d58...` only. They cannot validate `551ecdc...`. New tests are not accepted until their exact-head runs complete.


## COMMAND 07-A.2.28.3 — current candidate PDF/font gates (2026-11-12)

**Candidate SHA:** `75737f4fb95b4357e8b6e0511ee2443c6aa5aff4`.

| Run | SHA | Status | Scope |
|---|---|---|---|
| Build `43224808961` | candidate | PENDING | No jobs allocated |
| SQLite Snapshot `43224809374` | candidate | QUEUED | Full schema catalog, FK definitions and five reopen cycles |
| Follow-up Persistence `43224808860` | candidate | QUEUED | File-backed Alarm Overlay persistence |
| Device Smoke `43224808776` | candidate | QUEUED | Seven-scenario preparation not started |
| Draft Review APK `43224808804` | candidate | SKIPPED | No Artifact |

Added but not yet executed: Persian PDF sample with embedded-font/ToUnicode checks and Poppler render; APK audit that verifies all five Git blob IDs against upstream commit `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7` and logs SHA-256/size; expanded D01 schema catalog; D04 separate-file Backup/Restore; D05 failed-migration repair and retry. These are pending implementation checks, not PASS evidence.

## COMMAND 07-A.2.28.3 — PDF audit root-cause and exact-head continuation (2026-11-12)

Current product branch candidate at documentation checkpoint: `9a07f4680c49bc8c4246e2bf30b2cd4eaddd2e4e`.

### PDF evidence from prior candidate `75737f4...`
- PDF sample was generated successfully by the PDF typography test; size 18,334 bytes.
- `pdffonts` reported `Vazirmatn-Bold` and `Vazirmatn-Regular`, both embedded (`emb=yes`) with Unicode mapping (`uni=yes`).
- The actual PDF was downloaded from the run artifact, extracted with Poppler, and rendered to PNG. Manual visual inspection showed connected Persian glyphs, readable RTL layout, half-space text, Persian digits, mixed Persian/English, and Regular/Bold content.
- PDF file SHA-256: `9cd1f26a4e565be2b8e1e29b67aedaaa0266e73c5ec7a3fb439b4a817d3147cb`.
- Artifact ZIP SHA-256: `bd3fdcbe83b0ffdf2ffad819b05bec8d7769c01ea2000c6b76bfe178f0c2c7e3`; artifact ID `13949126911`; Run `43224808961`.

### Harness defects found and corrected
The visual job failed after the PDF generation test itself passed. Root cause 1: the `pdffonts` awk audit used incorrect whitespace-token field positions for `emb` and `uni`. Corrected in commit `97effacf705ae10e43760eec4e50d0905def11fa` (`$5` = emb, `$7` = uni).
Manual Poppler extraction then confirmed mixed-direction text is emitted in visual order inside the RTL paragraph; the English date appears as `12-11-2026`, and the company label as `Example Ltd`. The extraction assertions were aligned with that observed output in commit `9a07f4680c49bc8c4246e2bf30b2cd4eaddd2e4e`. No product assertions were removed.

The visual PASS from the previous candidate is not transferable. The complete PDF audit must pass again on `9a07f468...` or the later exact candidate, including embedded font check, text extraction, PNG rendering and preserved artifact.

### Latest relevant candidate commits
- `75737f4...`: build workflow added upstream Vazirmatn Git blob provenance, per-file SHA-256 reporting, OFL license check, APK asset path audit, and legacy runtime-reference guard.
- `97effacf...`: corrected PDF font audit column parsing.
- `9a07f468...`: aligned mixed RTL text extraction checks with observed Poppler output.

Do not report PDF or APK acceptance on the current candidate until the exact-head Build workflow completes successfully and all three APK jobs plus font packaging audits produce verifiable artifacts.

### PDF extraction normalization follow-up — 2026-11-12

Manual extraction of the actual PDF from Run `43224808961` showed Poppler returns shaped Arabic glyphs in presentation-form code points, while the rendered PNG is visually connected and legible. Raw extraction is retained. Commit `ee200b573ef70df8101c77de2a68241192898244` now creates a second NFKC-normalized extraction artifact before semantic assertions, preserving both raw and normalized evidence. This is a harness normalization step; it does not change the PDF renderer or its font binaries. Re-run the complete PDF workflow on the current exact product SHA before claiming PDF acceptance.

### Vazirmatn upstream binary provenance — independently cross-checked

Upstream repository `rastikerdar/vazirmatn`, exact source commit `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7` (2023-05-01), was checked through its Git tree. The five upstream TTF blob object IDs exactly match the expected blob IDs now enforced by the APK audit:
- Light — `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42` (122,920 bytes)
- Regular — `64e4a8189557a17b63fd7a77794207483e592972` (122,752 bytes)
- Medium — `1e08dd54d90a4879451ef0f80fe0d8068fb7462f` (122,656 bytes)
- SemiBold — `6b3842aca6055c8258404b1758133b81c961a13f` (122,920 bytes)
- Bold — `efa9b095da01d299310bdcae293e24e657fe6da9` (123,036 bytes)

This establishes exact upstream Git-object identity for the five files. Per-file SHA-256 output and APK inclusion still require successful exact-head build jobs; the upstream Git blob SHA-1 values are not presented as SHA-256.

### Typography single-source refinement — current product candidate `3768b4e39f1235bd993337da8009349d632aa05d`

A duplicate Vazirmatn family literal existed in the canonical theme token and font option registry alongside `AppFonts`. Commit `3768b4e39f1235bd993337da8009349d632aa05d` now makes `lib/theme/app_fonts.dart` the single code-level family source; `ArvinTheme.fontFamily` and the user font registry alias `AppFonts.vazirmatnFamily`. The theme token test and build-time font audit now assert this relationship. This is a behavior-preserving refactor; exact-head Analyze, Typography tests and build audit remain required.

### Light/dark typography weight correction and Android preference reload coverage

Current product candidate: `63c67ea3a6788c8c33a7234c8c291c9607f1d299`.

Source inspection found the previous root ThemeData mapping did not match the approved weight contract (body text was 500/600, titleMedium/titleSmall 700, and labelLarge 700). Commit `63c67ea3a6788c8c33a7234c8c291c9607f1d299` aligns both light and dark themes:
- body/minor/calendar text: 400;
- card/task title styles: 600;
- page title: 700;
- labels/controls: 500.

The Android Reminder + Persian Typography smoke now exercises the actual Android SharedPreferences plugin: it saves System Default, recreates the app root and verifies both theme families are not forced; then saves Vazirmatn, recreates the root again, verifies both themes use Vazirmatn and checks the inherited overlay typography. This is app-root reinitialization on Android; a separate OS-level force-stop/process-kill persistence test remains NOT VERIFIED.

Exact-head Analyze, regression, typography and Device Smoke results remain pending until their jobs complete on `63c67ea...`.

### APK font audit strengthened — exact candidate `0aa1645999e38e32506bf3d3c15f900865428f90`

The APK packaging audit now extracts each of the five font entries directly from the built APK using `unzip -p`, computes SHA-256 over the embedded bytes, and compares that digest with the source font's SHA-256. A missing asset or content mismatch fails the job. This is stricter than archive-path presence alone. Debug, Staging and Release must each pass this check on the same final acceptance SHA; results are pending.

## Exact-head SQLite Snapshot result — COMMAND 07-A.2.28

**Tested product SHA:** `0aa1645999e38e32506bf3d3c15f900865428f90`  
**Snapshot workflow:** `43232240309` — SUCCESS  
**Job:** SQLite A-D snapshots (five real reopen cycles) — SUCCESS  
**Artifact ID:** `13950118322`  
**Artifact:** `arvin-command-07-a2-20-sqlite-snapshots-0aa1645999e38e32506bf3d3c15f900865428f90`  
**Artifact ZIP SHA-256:** `0452e415dfe87b7a2b0ac797440fc5bdfd5f9998e91be44d8bd0214f0fb8d071`

The downloaded JSON artifact was independently parsed:
- A/B/C/D snapshots all contain one Task, two Reminder rows, two Follow-up records, three Follow-up-Person links and three Person records.
- Five file-backed close/reopen cycles completed.
- All four snapshots have an empty `foreign_key_check`; foreign-key enforcement reports enabled.
- The three retired Task columns are absent.
- 50 sqlite_master objects were captured: 28 indexes and zero triggers.
- Declared Foreign Key definitions were captured for 14 tables.
- Snapshot comparison reports A/B/C/D consistency for data, full schema catalog and FK definitions.

This is a **PASS for the Snapshot A-D diagnostic only** on SHA `0aa164...`. It is not full D01 acceptance (fresh schema and all supported historical upgrades still require complete suite evidence), and it does not establish D02-D05 by itself.

At the same candidate's last poll:
- Follow-up File Persistence Run `43232240334`: IN_PROGRESS; repository persistence test executing, Alarm Overlay close/reopen step pending.
- Device Smoke Run `43232240252`: QUEUED.
- Build/Regression Run `43232240534`: PENDING; no jobs allocated yet.
No result transfers to a later product SHA.

### Governance verification — COMMAND 07-A.2.28

Live repository Ruleset `main-protection` (ID `20952260`) remains ACTIVE on `refs/heads/main`, but its pull-request rule currently has `required_approving_review_count=0` and `require_code_owner_review=false`; bypass actors are empty. Deletion and non-fast-forward protections are enabled. No repository security setting was changed.

The docs PR #3388 CODEOWNERS file was expanded to cover the canonical typography contract, Vazirmatn assets, pubspec registration, both theme directories, PDF renderer, app root, Settings, Alarm Overlay, build workflow, typography/PDF tests and Android typography smoke. It is still an unmerged PR; the current main branch does not yet contain this CODEOWNERS file. Therefore effective CODEOWNER enforcement is **NOT VERIFIED / NOT ACTIVE**. Enabling required approval and CODEOWNER review remains a separate product-owner-controlled repository settings action.

## COMMAND 07-A.2.30 — raw evidence index (2026-11-12)

### Product candidate and PR graph

- [Execution PR #3384](https://github.com/mobinpda-lab/Arvin-clean/pull/3384): current head `492a5c433ee215d0188a6075b159d4d72329d35e`; base branch `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`; OPEN / DRAFT / UNMERGED.
- [Documentation PR #3388](https://github.com/mobinpda-lab/Arvin-clean/pull/3388): base `main` at `45e4202b03a434459e4c021a04efa7e8396359db`; OPEN / DRAFT / UNMERGED.
- Main HEAD observed: `45e4202b03a434459e4c021a04efa7e8396359db`. Compare main → PR #3384 base: 2,200 commits ahead, 0 behind. Compare PR #3384 base → previous candidate `46f7b28...`: 108 commits ahead, 0 behind.
- [Timeline remediation commit `492a5c4`](https://github.com/mobinpda-lab/Arvin-clean/commit/492a5c433ee215d0188a6075b159d4d72329d35e): avoids rendering a Reminder note when it duplicates the Reminder heading.

### Current candidate `492a5c4...` — completed evidence

- [SQLite Snapshot run 43247842246](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43247842246): SUCCESS; job `131285215042`; artifact ID `13958416974`; ZIP digest `sha256:0e57caf9e4357d8d4d43e82ad0f60377f69d3ebd4c7cbaefb89b6818fa93565b`.
- Downloaded SQLite JSON artifact SHA-256: `445a3b733834ef118a0d7ae79e91b7b5f867538aa6e77910ea3a3752e47c7721`. Contents: source SHA `492a5c4...`; five file-backed reopen cycles; 22 tables; 28 indexes; zero triggers; FK enabled; empty `foreign_key_check`; A/B/C/D data/schema/FK definitions identical.
- [Follow-up File Persistence run 43247842181](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43247842181): SUCCESS; job `131285224802`; no artifact published.
- [Build run 43247842294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43247842294): PENDING at last poll; no jobs allocated.
- [Device Smoke run 43247842521](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43247842521): QUEUED; preparation job `131285216498` queued; no device scenario result.

### Previous candidate `46f7b28...` — historical, not transferable

- [Build run 43238200093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43238200093): Analyze and Visual PASS; Debug and Release APK jobs PASS; Staging job was IN_PROGRESS at last poll; Regression shards 0/1/2/4 had 43 failure records (11/2/21/9); shards 3 and 5 were cancelled after PR synchronization and are not PASS.
- [Device Smoke run 43238200496](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43238200496): preparation job remained QUEUED.
- [Follow-up File Persistence run 43238200586](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43238200586): SUCCESS.
- [SQLite Snapshot run 43238200490](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43238200490): SUCCESS; artifact ID `13952699032`; ZIP SHA-256 `bdb0d42bcb7473bd91501a0a4e3c261d2c9001f95122b8db47356cc364089d5a`; JSON SHA-256 `fe64bc1b9a8275ab018ac3683e29d8b3d0462dc48f6eaec38572c05bfe465e2c`.
- Debug APK artifact ID `13953344600`; APK SHA-256 `41924a4be7470bb425d19baa76bb6781f9b3dbebbd9e31bc3716073adeacb16a`; ZIP SHA-256 `c3844157fdc84e3c731bec9881f4a5ce3b8c63455962dcde5d07955145b16bd8`.
- Release APK artifact ID `13956310335`; APK SHA-256 `eb3b681fa1e7030eeb6a09ef74c1aacb7527f1170cdafa76f1d94e289a2d16c3`; ZIP SHA-256 `f68610edd91855f4bf80577c5c9710c248fc3395f681417f47198541ffa5c8df`.
- PDF artifact ID `13953438208`; PDF SHA-256 `0b276df9ed223a31033ace1fed04daadb3bd21a962a476b69c6a4bca8bf4dccb`; ZIP SHA-256 `05ade08cf47cd3ff2866406c685e56b3398c9a8240ad8fcfc3be5ba9e9d32b86`. The PDF and rendered PNG were downloaded and independently inspected; Poppler confirmed embedded Vazirmatn Regular/Bold with Unicode maps.

### Typography source and corrected SHA-256

- Upstream source commit: `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7` in `rastikerdar/vazirmatn`; SIL OFL 1.1.
- Correct SHA-256 values for Light/Regular/Medium/SemiBold/Bold: `9ab4f094b861b7d4e318f01953b9771ddeb189d7c79bbb3989d5a95a4b07ff60`, `b69fd4c680b8f3f225feabcc655a2c585d97627b8f5f5c0f9985e894069f3a56`, `b986623e4ddef10755e04be39f8ea7bcb1dc08bfe8dd0aa6af395736f256ad4a`, `3f239d8364c14ee32c46b6839fa197c28958358b82a9673d2c6acc8506d78bc5`, `f635fdbea28f265de395ba83b4b1570dcf2f58d13c65469e61903b1c2d2ae723`.
- Exact-head Debug/Release build logs confirmed each embedded font SHA-256 equals its source file SHA-256 and the legacy-font purge passed. Staging remains unverified.

### Acceptance status

- D01: snapshot diagnostic PASS only; full historical migration acceptance NOT COMPLETE.
- D02: NOT ACCEPTED (four-state Missing/NULL/FALSE/TRUE contract still requires independent exact-head closure).
- D03: NOT ACCEPTED (full Follow-up metadata/unknown-field close-reopen parity not proven).
- D04: NOT ACCEPTED (complete file-backed Backup/Restore/reopen parity not proven).
- D05: NOT ACCEPTED (interrupted migration, rollback and recovery/non-destruction not proven).
- Seven Device Smoke scenarios: NOT VERIFIED.
- System Default after OS-level Force Stop: NOT VERIFIED.
- Merge / Release / Deployment: NOT AUTHORIZED.

### Staging artifact completion correction — previous candidate `46f7b28...`

- [Build run 43238200093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43238200093) Staging job `131251173638` subsequently completed SUCCESS (the earlier QUEUED/IN_PROGRESS note was an interim poll).
- Staging APK artifact ID `13957987267`; artifact ZIP SHA-256 `d380b5f028799fa3f3c7fafd5e80c79d56b1c1a151036ea8073c6e7ee35258f8`; extracted APK SHA-256 `b61bc476b29c5a862c007c493729f9b7d74f394a995fb8edd09981b27869b875`; APK size 80,373,632 bytes.
- All five embedded Vazirmatn hashes in Staging match source SHA-256 values in the typography contract. Font provenance, APK content, legacy purge, SIL OFL 1.1 and five-weight packaging gates reported PASS. This does not transfer to `492a5c4...`.

### Staging signature and publishability evidence

- Verification artifact ID `13957842406`; artifact ZIP SHA-256 `4cf84b5be1bc0846bc51a9cd67de5c709fbb4e428d24870a647dbab95cfb1c3c`.
- `manifest-audit.txt` and `release-manifest.json` bind the Staging APK to source SHA `46f7b28...`; APK SHA-256 `b61bc476b29c5a862c007c493729f9b7d74f394a995fb8edd09981b27869b875`; `android_debuggable=false`; `publishable=false`; signing key class `EPHEMERAL_TEST_ONLY_NOT_PRODUCTION`.
- Raw `apksigner-verify.log` confirms V2 and V3 signatures verified, V1 false, one RSA-2048 signer, certificate SHA-256 `cb57c0c635c87eec37d87e3bf23e0e8ae465b353c84e5ad0467984a8706f9cae`.
- The manifest field `signer_certificate_sha256` remains `NOT_AVAILABLE` despite the certificate digest in the raw log; keep this as an evidence-parser gap, not a signing failure.

### Release APK signing audit boundary

- Release artifact `13956310335` contains `app-release.apk` with SHA-256 `eb3b681fa1e7030eeb6a09ef74c1aacb7527f1170cdafa76f1d94e289a2d16c3`.
- Binary inspection of the APK ZIP central-directory boundary found no `APK Sig Block 42`; this Release APK is unsigned. It is a build/font-packaging artifact only, not installable as a signed update and not publishable.
- `android/app/build.gradle.kts` only sets the `production` signing config when all protected production inputs are present. No production signing proof is available for this workflow. Do not infer production signing from the successful Release build job.

### Original 22 Regression inventory — exact source

- [Build run 43232240534](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43232240534), checkout SHA `0aa1645999e38e32506bf3d3c15f900865428f90`, shard job `131238073327` contains the 22 failure records referenced by the earlier report. The complete 22-row disposition table is in `docs/ARVIN_PROJECT_STATE.md` under “Original 22 Regression failures — exact historical inventory”.
- Do not conflate this historical 22-record Shard 2 inventory with the later 43 failure records across four completed shards on `46f7b28...` or the 21 failure records in Shard 2 on current candidate `492a5c4...`.