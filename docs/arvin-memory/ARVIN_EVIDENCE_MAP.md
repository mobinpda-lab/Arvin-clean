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


## LIVE EXECUTION WAVE 1 — 2026-10-19 — Fresh baseline and P0 evidence recovery

**Governance:** RELEASE: NO-GO. This entry records observed evidence and limitations only. No merge, tag, or release action was performed.

### Baseline and recent main history

- Main SHA observed: `d9fb7a247037762216662a20fb32028ecc8a0f6b`.
- Latest five commits observed through GitHub commit search:
  - [`d9fb7a2`](https://github.com/mobinpda-lab/Arvin-clean/commit/d9fb7a247037762216662a20fb32028ecc8a0f6b) — recurring-task triple-window projection.
  - [`2999e40`](https://github.com/mobinpda-lab/Arvin-clean/commit/2999e40562834fa6b034fe1cefe0688ede21a076) — calendar registration icon.
  - [`6c3e79b`](https://github.com/mobinpda-lab/Arvin-clean/commit/6c3e79bb3540adf13799034406b3d274c35a4f9e) — Calendar/Home projection polish.
  - [`5bc882b`](https://github.com/mobinpda-lab/Arvin-clean/commit/5bc882bea115d09ec4b77d2f790ee7b0b4352bf9) — Person/waiting-response Report Center filters.
  - [`445d075`](https://github.com/mobinpda-lab/Arvin-clean/commit/445d0754b465cbd6c507ce28ca17a150881b9b37) — Home reminder deduplication test.
- Local working tree: NOT INSPECTABLE in this GitHub-only execution environment.

### Current PR topology observed

| PR | Head SHA | Base / base SHA | Live state | Integration note |
|---|---|---|---|---|
| [#2817](https://github.com/mobinpda-lab/Arvin-clean/pull/2817) | `77a6a1bec2d6d5e99d4eef0a737abc4d24130469` | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | OPEN, DRAFT, mergeable=true | Release hardening parent; telemetry acceptance remains a release concern. |
| [#2821](https://github.com/mobinpda-lab/Arvin-clean/pull/2821) | `e80be91f4f461d0387d3b5b9349c217715bdba2e` | `hardening/v5.09-release-approval-and-telemetry` / `77a6a1bec2d6d5e99d4eef0a737abc4d24130469` | OPEN, DRAFT, mergeable=true | Stacked on #2817; do not integrate directly to main without dependency reconciliation. |
| [#2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824) | `5c76d3f1f00804f15668c6d80c65c02e9abe05b9` | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | OPEN, DRAFT, mergeable=true | Signature workflow exists only on branch; not on default branch. |
| [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666) | `b75e2427f5e06c49553f064f26376a9e70fcbd7c` | `main` / `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d` | OPEN, non-mergeable | Base is behind current main; broad 277-commit / 90-file integration branch. |
| [#2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681) | `4c2795e92d70cee208f38a150a28b1f63f31c7f2` | #2666 branch / `c9d244d7ec45d18e5a8c89159a2eeac1c68ae9e1` | OPEN, non-mergeable | Stacked child; base does not equal current #2666 head. |
| [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695) | `44810fcf5bb96db8c028a1574889e3f2d45af75f` | #2666 branch / `ad762774009e5b5c7ee341146a8160c52e2b9bb2` | OPEN, DRAFT, metadata mergeable=true | Stale parent base; must be reconciled even though metadata currently says mergeable. |
| [#2790](https://github.com/mobinpda-lab/Arvin-clean/pull/2790) | `6ff42e4b48bdfd7410d621a4b9407324ce9980c3` | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | OPEN, DRAFT | Test-only full backup/restore integrity; base is stale. |
| [#2791](https://github.com/mobinpda-lab/Arvin-clean/pull/2791) | `ae3a4b7a6dfec72b7b5d271a9a544f33256df341` | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | OPEN, DRAFT | PDF-only Vazirmatn font embedding proposal; exact-head PDF test/build evidence pending. |
| [#2796](https://github.com/mobinpda-lab/Arvin-clean/pull/2796) | `12d5322619ce6c21d03b418595cfdedd92db2861` | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | OPEN, DRAFT | Follow-up UI/model compatibility work; base stale. UI font proposal must be reconciled with current canonical typography contract. |
| [#2798](https://github.com/mobinpda-lab/Arvin-clean/pull/2798) | `95d2f70f263d5d75ac0cbd7ef3efeb93f40e3c09` | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | OPEN, DRAFT | Compatibility spike only; do not merge. |
| [#2755](https://github.com/mobinpda-lab/Arvin-clean/pull/2755) | `6aca28916068a6a21fe0a1a85e1e510bb743a60d` | `main` / `e04467a38b92121cfb3b635f39c4c5e8fd0569ba` | OPEN, DRAFT, non-mergeable | Overlaps with report-filter work already visible on main. |
| [#2745](https://github.com/mobinpda-lab/Arvin-clean/pull/2745) | `01a905ed6543bdd6f73cd0e4044b65fc6cf0bc29` | `main` / `d2267190ee83b7e462483f5d114395626c55e150` | OPEN, DRAFT | Person directory branch; base stale and some foundation already exists on main. |
| [#2679](https://github.com/mobinpda-lab/Arvin-clean/pull/2679) | `349350cb74c423816685a25c36f5cd782b13aac4` | `main` / `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d` | OPEN, DRAFT, non-mergeable | Waiting-response navigation; exact-head validation absent in PR notes. |
| [#2762](https://github.com/mobinpda-lab/Arvin-clean/pull/2762) | `777e4d573f3901d1b94b1b0d9289608993270384` | `main` / `e04467a38b92121cfb3b635f39c4c5e8fd0569ba` | OPEN, DRAFT, non-mergeable | Overlapping form/calendar/report changes; stale base. |

### Existing canonical implementation found on current main

- `lib/models/task.dart` already contains `TaskReminder`, structured FollowUp waiting state and Person IDs.
- `lib/services/person_follow_up_report_projection.dart` already contains the shared Person/Follow-up report projection, referenced by `lib/report_center_page.dart`.
- `lib/backup_manager.dart` and existing BackupPage are the canonical backup foundation; extend rather than create another engine.
- `lib/services/task_report_pdf_renderer.dart` is the existing PDF renderer. Current UI canonical documents state VazirHarf v34.003 is the only default Persian UI font and prohibit Vazirmatn as the canonical UI font. Keep the PDF-only font proposal separate from UI typography decisions.
- Issues [#2682](https://github.com/mobinpda-lab/Arvin-clean/issues/2682) and [#2683](https://github.com/mobinpda-lab/Arvin-clean/issues/2683) currently report CLOSED in live issue metadata; their closure is not substitute for exact-head and end-to-end evidence.

### P0 — Calendar Provider Acceptance

- Workflow file exists on default branch: [calendar-provider-acceptance.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/calendar-provider-acceptance.yml); it declares `workflow_dispatch`.
- The available GitHub connector exposes GET/read and selected rerun operations, but no workflow-dispatch/create-run action. Attempt to query full workflow run history through the generic GET connector was rejected as an unsupported URL (`HTTP 400: GitHub Fetch URL is not an allowed public GitHub repository or search endpoint`). The commit-run wrapper only returns pull-request-triggered runs and cannot establish exhaustive dispatch history.
- `CALENDAR_DISPATCH_CAPABILITY: UNAVAILABLE` in this connection; no new dispatch is claimed.
- No qualifying Calendar Provider Acceptance run or its three official files was retrieved in this wave.
- `result.txt`: NOT RECEIVED.
- `test-output.txt`: NOT RECEIVED.
- `environment.txt`: NOT RECEIVED.
- Gate: BLOCKED until successful run SHA equals the intended candidate SHA and all three files prove `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`.

### P0 — Build / Device Smoke

- Build [Run 39148486792](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486792): completed/success; run metadata head SHA is `e80be91f4f461d0387d3b5b9349c217715bdba2e`. All 9 jobs returned success: Analyze, six test shards, Debug APK and Release APK.
- Device Smoke [Run 39148486773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486773): completed/success; run metadata head SHA is the same candidate. All seven lanes returned success: People, Backup/Restore, Calendar, SQL persistence, Home, Quick Capture, SQL migration.
- Important qualification: both runs were triggered by `pull_request`; the Build's “Verify exact requested revision” step was skipped in all jobs. Device Smoke artifact names include synthetic merge SHA `76189b7a0b2b873b7f7d1477dc2cc4233edf30a4`. Therefore these are successful PR/synthetic-merge runs, **not proven exact-head checkout validation** under the project's exact-head policy.
- Artifact listing for Build Run 39148486792:
  - Release APK artifact [12144700746](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144700746), `arvin-release-apk`, not expired, expires 2027-01-16; originating run head SHA matches the candidate.
  - Debug APK artifact [12144461948](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144461948), `arvin-debug-apk`, not expired, expires 2027-01-16.
- Device Smoke artifacts visible from the first-page listing include Calendar [12144936225](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144936225), People [12144961248](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144961248), Home [12144282705](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144282705), Quick Capture [12144178175](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144178175), and Persian time picker [12144486950](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144461948). Several screenshot steps were skipped by lane design; no claim is made that three required screenshots were all inspected.

### P0 — APK checksum / signature

- Source artifact `arvin-release-apk` / artifact ID `12144700746` was downloaded from Build Run `39148486792`; ZIP contained `app-release.apk`.
- Actual APK SHA-256 computed in this execution environment: `ceb696e84819549be5ccfd534bb773f842961800bd0436bc371b2a1c42242896`, matching the expected hash encoded in PR #2824's workflow.
- Local Android SDK / `apksigner` is unavailable in this environment (`ANDROID_HOME` unset; no executable `apksigner` found). The hash match proves byte identity only; it does not prove signature validity or certificate identity.
- [PR #2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824) keeps `.github/workflows/verify-apk-signature.yml` only on its unmerged branch; fetching that path from `main` returned 404. It is not yet a normally dispatchable default-branch workflow.
- Prior failed runs: [39153178383](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153178383) failed at “Setup Android SDK”; [39153221573](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153221573) failed at “Install Android Build Tools 34.0.0”. [Device Smoke 39153251028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153251028) failed on the signature branch's Calendar lane. Signature gate remains BLOCKED.

### P1 — Independent work status

- Backup/Restore: canonical implementation exists on main; PR #2790 adds a valuable full clear-and-restore integrity test, but it is Draft and has no accepted exact-head evidence in this wave. Status: NOT VERIFIED.
- PDF font: PR #2791 proposes embedding Vazirmatn UI-FD only in the official PDF renderer; exact-head targeted PDF tests/build and rendered-artifact inspection were not retrieved. Status: NOT VERIFIED.
- Follow-up UI: PR #2796 removes the Quick Capture switch and preserves the legacy JSON field, but exact-head tests are pending and its UI-font proposal conflicts with the current canonical UI font lock if it changes the default font. Status: NOT VERIFIED.
- Multiple reminders and Person/reporting: foundational code and projection are already present on main, while broad stacked branches are stale or non-mergeable. Do not merge or port duplicate models. Reconcile each narrow diff against current main and current canonical tests.

### Actions actually performed in this wave

1. Read the live repository metadata, latest five commits, required governance documents and live metadata for all requested PRs.
2. Inspected Build and Device Smoke job/step summaries and first-page artifact inventories.
3. Retrieved the Calendar Provider Acceptance workflow from default branch and verified its `workflow_dispatch` declaration.
4. Retrieved PR #2824's workflow patch and confirmed the signature workflow is branch-only.
5. Downloaded the original Release APK artifact and independently computed its SHA-256. It matches the expected value; cryptographic signature verification was not performed.
6. No repository code was changed, no workflow was dispatched, no PR was merged, no tag was created and no Release was created or published.

### Next executable action

Use an authorized GitHub Actions dispatch-capable executor (or authenticated REST `POST /repos/mobinpda-lab/Arvin-clean/actions/workflows/calendar-provider-acceptance.yml/dispatches`) against `fix/v5.19-calendar-smoke-overflow-navigation`, then verify exact run SHA and download all three evidence files. Separately make the signature-audit workflow available on default branch only through a reviewed, authorized change, then execute it against source Run `39148486792` and expected SHA above. Do not bypass release governance.

**Release decision: NO-GO.**


### Failure-log detail recovered after initial checkpoint — 2026-10-19

- Signature audit Run [39153178383](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153178383), job [117750860500](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153178383): Android SDK setup emitted `Warning: Failed to find package 'tools'`; `sdkmanager` exited 1.
- Signature audit Run [39153221573](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153221573), job [117750993883](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153221573): `yes: standard output: Broken pipe`; shell exited 1 before artifact checksum/signature verification.
- Signature-branch Device Smoke Run [39153251028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153251028), Calendar job [117751102395](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153251028): test `Android calendar card tap, long press, SQLite completion and Persian time picker` failed at `integration_test/calendar_card_interaction_test.dart:66`; expected key `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up`, found zero widgets. This is failure evidence for SHA `5c76d3f1f00804f15668c6d80c65c02e9abe05b9`, not the Calendar candidate SHA `e80be91f4f461d0387d3b5b9349c217715bdba2e`.
- The corrected Persian time-picker artifact ID from Device Smoke Run `39148486773` is `12144486950`; the Debug APK artifact from Build Run `39148486792` is separately `12144461948`.


---

## 2026-10-19 — ARVIN Wave 2 live evidence and blocker classification

Baseline recheck: `main` remains `d9fb7a247037762216662a20fb32028ecc8a0f6b` ([commit](https://github.com/mobinpda-lab/Arvin-clean/commit/d9fb7a247037762216662a20fb32028ecc8a0f6b)). The working tree is not available through the connected tools. No merge, tag, or release was performed.

| Gate | Status | Verified evidence | Remaining limitation |
|---|---|---|---|
| Calendar Provider Acceptance for PR #2821 head `e80be91f4f461d0387d3b5b9349c217715bdba2e` | BLOCKED | Main workflow [calendar-provider-acceptance.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/calendar-provider-acceptance.yml) has `workflow_dispatch`; existing [Device Smoke run 39148486773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486773) is a PR-triggered run, not accepted provider evidence | No Calendar Provider Acceptance run or three evidence files were returned for the candidate SHA. Connected GitHub actions expose no workflow-dispatch operation. The existing PR #2821 targets the hardening branch, not main, so its ordinary PR event does not match the provider workflow's `pull_request.branches: [main]` filter. |
| APK checksum | PASS (artifact integrity only) | [Signature audit run 39200518146](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200518146), workflow commit `c832480b0655f13a749ecf845b067276e54cf204`, downloaded APK from [Build run 39148486792](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486792), artifact [12144700746](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144700746). Expected and actual APK SHA-256 both equal `ceb696e84819549be5ccfd534bb773f842961800bd0436bc371b2a1c42242896`. | APK SHA proves bytes match the expected artifact, not release-signing identity. |
| APK cryptographic signature | PASS (signature validity only) | Run 39200518146: `apksigner verify --verbose --print-certs` exited successfully; APK Signature Scheme v2 = true; one signer. | Signer certificate DN is `C=US, O=Android, CN=Android Debug`; certificate SHA-256 is `b6f35a1f55f5e2d0c3bc25ab0df5b4c7853eabada3e1ab43e7af1284069a5f16`. This is not evidence of an approved release certificate. |
| Release signer identity | FAIL | Same audit run and certificate output above. | Build artifact named `app-release.apk` is signed with Android Debug certificate. Obtain/rebuild with the approved release signing identity and re-run checksum + apksigner; do not accept debug signing as release proof. |
| Signature workflow infrastructure | PARTIALLY RESOLVED; latest SHA NOT VERIFIED | PR [#2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824). The earlier failures were: [run 39153178383](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153178383), obsolete `tools` package request; [run 39153221573](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39153221573), `yes: standard output: Broken pipe`. Workflow setup was updated to install current `platform-tools` and `build-tools;34.0.0`, suppress expected `yes` SIGPIPE output and preserve sdkmanager failure status. | Successful audit run 39200518146 checked workflow SHA `c832480b0655f13a749ecf845b067276e54cf204`; current PR head is `4c8f7bf29382d05a2ed1b1fe8fa36c5c7fc43219`. Do not imply the later workflow commit was separately executed. |
| Build exact SHA | NOT VERIFIED for target `e80be91f4f461d0387d3b5b9349c217715bdba2e` | [build.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/build.yml) already supports `workflow_dispatch.inputs.target_sha`, checks out the supplied SHA and asserts `git rev-parse HEAD`. Prior [Build run 39148486792](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486792) passed its build/test jobs, but the exact-target verification step was skipped for the PR event. | Direct workflow dispatch is not exposed by the connected GitHub action interface. Prior PR run/artifact names refer to synthetic merge SHA `76189b7a0b2b873b7f7d1477dc2cc4233edf30a4`, not independent exact-head checkout proof. |
| Device Smoke exact SHA | NOT VERIFIED for target `e80be91f4f461d0387d3b5b9349c217715bdba2e` | Prior [Device Smoke run 39148486773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486773) completed 7/7 lanes on its PR merge checkout. | Main `device-smoke.yml` had no target-SHA input or exact-checkout assertion. Draft [PR #2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827), head `6603dd84c5d4036fc52957c1fab6f9831d42ad05`, adds exact-SHA dispatch/check-out support. No exact-SHA dispatch has been run. |
| Backup/Restore full-cycle test | NOT VERIFIED on exact head; partial PR CI evidence | [PR #2790](https://github.com/mobinpda-lab/Arvin-clean/pull/2790), head `6ff42e4b48bdfd7410d621a4b9407324ce9980c3`. [Build run 39060931997](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39060931997) passed Analyze, all six test shards, Debug and Release APK jobs; the exact-revision step was skipped because this was a PR event. Device Smoke [run 39060932020](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39060932020) passed Backup/Restore, People, Home, Quick Capture, SQL Persistence and SQL Migration. | Overall Device Smoke failed Calendar lane at `integration_test/calendar_card_interaction_test.dart:105`: expected key `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up`, found zero widgets. Root cause remains Unknown (test assertion vs product behavior). PR #2790 base is stale (`824ca8f...`) relative to current main. No physical file-provider/rollback test evidence. |
| PDF font | NOT VERIFIED for production rendering; PR CI partial PASS | [PR #2791](https://github.com/mobinpda-lab/Arvin-clean/pull/2791), head `ae3a4b7a6dfec72b7b5d271a9a544f33256df341`; [Build run 39067627239](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39067627239) passed Analyze, all six test shards and Debug/Release APK jobs; [Device Smoke run 39067627152](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39067627152) passed all seven emulator lanes. Release APK artifact [12114221385](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12114221385); screenshot artifacts are linked from the Device Smoke run. | Runs were PR-triggered and exact-revision step was skipped. No produced/inspected official PDF artifact or visual proof for RTL shaping, Persian digits, line wrapping, tables and embedded Regular/Medium/SemiBold/Bold variants. PR bundles Regular and Bold only. Source/license are declared as Vazirmatn v33.003 + SIL OFL. |
| Follow-up / Reminder / Person / Report | NOT VERIFIED as an integrated exact-head gate | Current main includes report-filter fix commit `5bc882bea115d09ec4b77d2f790ee7b0b4352bf9`. Open branches [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666), [#2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681), [#2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695), [#2679](https://github.com/mobinpda-lab/Arvin-clean/pull/2679), [#2755](https://github.com/mobinpda-lab/Arvin-clean/pull/2755) and [#2762](https://github.com/mobinpda-lab/Arvin-clean/pull/2762) have overlapping/stale bases; #2666, #2681, #2679, #2755 and #2762 report non-mergeable states. | No blind merges. Need targeted current-head tests for independent Reminder deletion, Person association, waiting-response report projection, legacy JSON and migrations. |
| UI font contract | REVIEW REQUIRED before PR #2796 merge | [PR #2796](https://github.com/mobinpda-lab/Arvin-clean/pull/2796), head `12d5322619ce6c21d03b418595cfdedd92db2861`, removes the legacy Follow-up switch and retains JSON compatibility, but also registers Vazirmatn as a selectable UI font. | Keep PDF font work isolated from UI typography. The canonical UI default remains VazirHarf; explicitly review the additional UI font option independently rather than treating PDF acceptance as approval for UI font changes. |

### New safe code/workflow change
- Updated the APK signature audit workflow on PR #2824. Latest branch commit: `4c8f7bf29382d05a2ed1b1fe8fa36c5c7fc43219`. The actual successful audit was on the prior workflow commit `c832480b0655f13a749ecf845b067276e54cf204`; the cryptographic result and Android Debug signer finding are recorded above.
- Opened Draft [PR #2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827) to add exact-SHA dispatch and checkout verification to Device Smoke. It is based on current main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b` and remains unmerged/unvalidated for dispatch.

**Release decision: NO-GO.** No Calendar Provider Acceptance PASS, no exact-target Build/Device Smoke evidence for `e80be91...`, and the inspected APK has an Android Debug certificate. No merge, tag or release occurred.


## 2026-10-19 — Wave 2 addendum: Follow-up authority/data preservation and queued workflow fixes

- **Confirmed mainline behavior defect:** on main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`, `followUpEnabled` still influences Home/list scopes, report `hasFollowUp`, Task Detail status/badge/action, and the swipe-conversion guard. `TaskStore.convertToFollowUp` only set that boolean and created no FollowUp record. These are behavioral consumers, not merely serialization compatibility.
- **Confirmed metadata-loss defect:** `FollowUpRepository.setCompleted` reconstructed a FollowUp but omitted `title`, `waitingForResponse`, and `personIds`. Completing a record could therefore drop Person associations and waiting-state metadata.
- **Narrow repair PR:** [#2828](https://github.com/mobinpda-lab/Arvin-clean/pull/2828), latest head `98fa7a7dc4c493dc7e67336b5a639b072fd67b0f`. It makes FollowUp records/legacy date authoritative, creates a real record on conversion when only the old flag exists, mirrors record existence into the legacy serialization flag, and preserves completion metadata. Tests cover Home/list/report filters, Task Detail, conversion/idempotence, serialization compatibility and completion preservation. Build [run 39201513099](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201513099) and Device Smoke [run 39201513050](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201513050) are QUEUED at latest poll; no PASS claim. This is an isolated slice, not a merge of broad/non-mergeable PR #2666.
- **Device Smoke exact-target support:** [PR #2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827), latest head `a4c4f0fc05c83e9a1bb92534335d3745de9d1c8b`. Initial Build [run 39200699495](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200699495) failed because the workflow contract test expected the old artifact-name expression. Build [run 39201358367](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201358367) then failed Analyze because the new assertion interpolated literal `$actual`; the test was corrected to use a raw string. New-head Build [run 39201576910](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201576910) is PENDING and Device Smoke [run 39201576924](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201576924) QUEUED. Exact-target dispatch itself remains NOT RUN.
- **Backup/Restore test evidence refined:** [Build run 39060931997](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39060931997), PR #2790 head `6ff42e4b48bdfd7410d621a4b9407324ce9980c3`, has a passing test-shard output for `canonical_backup_manager_test.dart: full export clear database import cycle preserves Task, reminders, follow-up history and person IDs`. The Build exact-revision step was skipped for the PR event, so this is merge-checkout evidence, not exact-head proof. Device Smoke [run 39060932020](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39060932020) passed the Backup/Restore lane but failed Calendar at [job log](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39060932020); failure detail is the missing follow-up card key recorded above.
- **PDF evidence at Wave2 poll (superseded by Wave3 below):** [Build run 39067627239](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39067627239), PR #2791 head `ae3a4b7a6dfec72b7b5d271a9a544f33256df341`, passed font-embedding and local-asset tests, but no PDF artifact was yet uploaded. Wave3 subsequently produced and visually inspected artifacts [12164826241](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164826241) and [12164731659](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164731659); see the Wave3 PDF section below.
- **Signature guard at Wave2 poll:** [run 39200526227](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200526227) verified workflow SHA `4c8f7bf29382d05a2ed1b1fe8fa36c5c7fc43219` but found Android Debug signer. The newer fail-closed workflow commit `ccc9f9b122420ef999828088f70a7aa950c5b979` adds debug-cert rejection and requires `ARVIN_RELEASE_CERT_SHA256`; no signature-audit run for that newest workflow head was available. Build [39200813493](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200813493) succeeded on the PR checkout with exact-revision check skipped; Device Smoke [39200813437](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200813437) was still queued at that poll.
- **Calendar Provider Acceptance at Wave2 poll (superseded by Wave3 below):** no candidate-SHA run or result files were available then. Wave3 now has a real Provider run on PR #2831 head that emitted `RESULT=LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`; candidate `e80be91f...` remains untested because direct dispatch is unavailable. See Wave3 Provider evidence below.

**Wave2 snapshot (superseded by the Wave3 live evidence below):** APK byte checksum PASS; APK cryptographic signature PASS; release signer identity FAIL; Calendar Provider Acceptance BLOCKED; exact-target Build/Device Smoke NOT VERIFIED; Backup/Restore PASS only on older PR checkout; PDF visual artifact not yet available; Follow-up fix CI PENDING. `RELEASE: NO-GO`.


## 2026-10-19 — Wave 3 live evidence addendum

### Baseline and candidate
- Live `main` remains `d9fb7a247037762216662a20fb32028ecc8a0f6b`; no direct-main writes.
- Release candidate `e80be91f4f461d0387d3b5b9349c217715bdba2e` is still the head of Draft PR [#2821](https://github.com/mobinpda-lab/Arvin-clean/pull/2821), stacked on Draft [#2817](https://github.com/mobinpda-lab/Arvin-clean/pull/2817) (base head `77a6a1bec2d6d5e99d4eef0a737abc4d24130469)). It remains a candidate, not an accepted release SHA.
- Direct workflow dispatch and the repository Actions variable endpoint are not exposed by the connected GitHub interface; attempts to inspect the variable endpoint were rejected with HTTP 400. Do not infer that `ARVIN_RELEASE_CERT_SHA256` exists or has an approved value.

### P0 — Follow-up / Person data integrity
- [PR #2828](https://github.com/mobinpda-lab/Arvin-clean/pull/2828), current head `50f1d26a8e4102f078e2f184771f98d521152dc4`, addresses the old-flag behavior and a newly confirmed SQL migration defect.
- Build [run 39201513099](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201513099) failed on test shard 4 because the completion round-trip returned null for Follow-up title. Root cause: `SqlTaskMigrationWriter` omitted title, `waiting_for_response`, and `follow_up_people` rows; `TaskStore` then reconstructed FollowUps from those incomplete SQL rows.
- The current branch fixes the writer and adds an idempotent one-time backfill from the retained Task envelope for title, true waiting state, and missing Person links. Regression tests cover both new-import persistence and backfill. Latest Build [39203068667](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203068667) completed SUCCESS on head `50f1d26a8e4102f078e2f184771f98d521152dc4`: Analyze, six test shards, Debug APK and Release APK all passed, including migration/backfill regression tests. Device Smoke [39203068653](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203068653) completed SUCCESS with all seven lanes (Home, Backup/Restore, Quick Capture, Calendar, SQL persistence, People, SQL migration). These PR-triggered runs still skip the exact-target assertion and do not prove candidate `e80be91f...`.

### P0 — Build / Device Smoke exact SHA
- [PR #2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827), head `a4c4f0fc05c83e9a1bb92534335d3745de9d1c8b`, adds `target_sha` support, explicit checkout and fail-closed SHA assertion.
- Build [run 39201576910](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201576910) completed SUCCESS with Analyze, six test shards, Debug APK and Release APK all successful on the PR run. The exact-target assertion was SKIPPED because this was a pull-request event.
- Build [run 39201576910](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201576910) completed SUCCESS and produced [Release APK artifact 12164156756](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164156756) and [Debug APK artifact 12163794225](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12163794225).
- Device Smoke [run 39201576924](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39201576924) completed SUCCESS on PR head `a4c4f0fc05c83e9a1bb92534335d3745de9d1c8b` with all seven lanes successful. Its artifacts include [Calendar lane 12164816854](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164816854), [People lane 12163659164](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12163659164), [Home lane 12163689415](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12163689415), [Quick Capture lane 12163878541](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12163878541), and [Persian Time Picker 12164042873](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164042873). The Device Smoke artifact names use synthetic merge SHA `944701c8820132bae120a8a4da69880453099029`; exact-target assertion was SKIPPED. No dispatch against candidate `e80be91f...` has occurred.

### P0 — Calendar Provider
- [PR #2831](https://github.com/mobinpda-lab/Arvin-clean/pull/2831), head `78781ce52339e10b978dd4ee57a4ce3d6e9a07aa`, adds exact-SHA checkout/assertion to the Provider workflow and an explicit no-op duplicate-event assertion.
- Provider run [39203189292](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203189292) completed SUCCESS as a workflow on exact head `78781ce52339e10b978dd4ee57a4ce3d6e9a07aa`, but its actual result is `RESULT=LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`, not PASS. Artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) contains all three files. `environment.txt` confirms `HEAD_SHA=78781ce...`, API 35, and Calendar Provider discovery; `test-output.txt` shows the test intentionally emitted the limitation after finding no writable calendar.
- Seed attempt [run 39204160911](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39204160911), head `569c2dec41682ff81cb9afafed62bdb99f5fa7d6`, completed with the limitation result; logs show `adb shell content insert` printed usage because the binding separators were malformed, so no successful seed was established.
- [Run 39204991082](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39204991082), head `a2f706b47d638fb63d15b946326fba4156e70611`, failed before seed/test because POSIX `sh` rejected `set -o pipefail`.
- Current run [39205227469](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39205227469), head `196eff68ce2c2db09eb37cad86b69435428d285c`, emitted the same Provider limitation, then failed because the emulator runner split the multiline script into separate shell invocations; the final `if` had no matching `fi`, so no evidence artifact was published.
- Three independent seed/script corrections did not establish a writable calendar. Per the Wave3 stop rule, no further edits to this seed path are made in this wave. Provider remains BLOCKED; candidate `e80be91f...` is still untested.
- Acceptance still requires `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE` in `result.txt`, with matching `test-output.txt` and `environment.txt`. A stock-emulator limitation is not PASS.

### P0 — APK signature
- [PR #2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824), current workflow head `ccc9f9b122420ef999828088f70a7aa950c5b979`, now fails closed for Android Debug signing and requires `ARVIN_RELEASE_CERT_SHA256`. The mainline `android/app/build.gradle.kts` explicitly sets Release signing to `signingConfigs.getByName("debug")` (lines 34–37); the official release keystore is not wired into the current Gradle configuration.
- Build [39200813493](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200813493) and Device Smoke [39200813437](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200813437) completed SUCCESS, but these are general PR CI, not a signature-gate run on the latest workflow head.
- The source APK artifact [12144700746](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12144700746) from [Build 39148486792](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39148486792) was re-downloaded and independently hashed in this wave: `ceb696e84819549be5ccfd534bb773f842961800bd0436bc371b2a1c42242896`, matching expected.
- Signature audit [39200526227](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39200526227) verified APK cryptography but found signer `C=US, O=Android, CN=Android Debug`, certificate SHA-256 `b6f35a1f55f5e2d0c3bc25ab0df5b4c7853eabada3e1ab43e7af1284069a5f16`. Release signer identity remains FAIL; no approved fingerprint has been verified.

### P1 — PDF font and actual rendering
- Uploaded ZIP was opened and verified as Vazirmatn v33.003; `OFL.txt` states SIL Open Font License 1.1. The PDF PR [#2791](https://github.com/mobinpda-lab/Arvin-clean/pull/2791) now bundles the exact upstream UI-FD Regular, Medium, SemiBold and Bold TTF blobs, loads all four in the report renderer, and documents source/version/license in `assets/fonts/vazirmatn/README.md`.
- A real PDF artifact was produced by the production renderer: [artifact 12164826241](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164826241) from older head `03b105b26f502b257ac28e796a875e1ea711b3e4`, and richer artifact [12164731659](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164731659) from Build [39203354122](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203354122), PR head `9cf025b5a9678373d6b5a89a8a043ba49bf53243`. Latest Build completed SUCCESS: Analyze, all six test shards, Debug APK, Release APK, and PDF-preview job all passed.
- Local inspection of the richer artifact: one A4 page; `pdffonts` confirmed embedded `Vazirmatn-UI-FD-Regular`, `Medium`, `SemiBold`, and `Bold`; raster preview showed connected Persian glyphs, RTL layout, Persian digits, date/time, tags, checklist, reminder, Follow-up metadata and long-text wrapping without obvious clipping. The renderer does not use a table layout, so table rendering is not applicable to this report format. Comparing against an app Preview screenshot remains NOT VERIFIED because no UI preview screenshot artifact was available. Device Smoke [39203354193](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203354193) completed SUCCESS with all seven lanes. Exact-target assertion was skipped on the PR event.
- [PR #2796](https://github.com/mobinpda-lab/Arvin-clean/pull/2796), current head `a85bd3ec13e09802ee35b382f4ab9d42b4c11a4d`, exposes only locally supported choices (Vazirmatn, System, VazirHarf), maps legacy unsupported IDs safely to VazirHarf, and registers Regular/Medium/SemiBold/Bold weights from the ZIP's v33.003 standard TTF files. Git blob SHAs for all four weights match the ZIP; OFL 1.1 is present. The default remains VazirHarf. Build [39203982600](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203982600) completed SUCCESS (Analyze, all six shards, Debug/Release APK); Device Smoke [39203982579](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203982579) is IN PROGRESS with five lanes passed and People/Calendar still running.

### P1 — Backup/Restore
- [PR #2790](https://github.com/mobinpda-lab/Arvin-clean/pull/2790), latest head `6ca1cff18f6631352995241b783b7b3bfcec55d5`, extends the full-cycle test to assert checklist and external Calendar-link metadata in addition to multiple reminders, Follow-up history/next action and Person IDs. Build [39204622671](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39204622671) completed SUCCESS: Analyze, six shards, Debug/Release APK and expanded full-cycle test passed. Device Smoke [39204622845](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39204622845) remains QUEUED. Exact-target proof is still pending; no destructive test was run against real user data.

**Wave 3 gate status at this poll:** Follow-up/Person migration fix CI IN PROGRESS; Calendar Provider on candidate `e80be91f...` BLOCKED (dispatch unavailable); candidate exact-SHA Build/Device Smoke NOT VERIFIED; APK checksum and cryptographic signature PASS but Release signer identity FAIL; PDF four-weight embedding and basic visual render PASS on earlier PR head, richer wrapping fixture NOT RUN to completion; Backup/Restore PASS only on older PR checkout; UI font PR remains separate. `RELEASE: NO-GO`.


## Wave 3 PR dependency / SHA baseline (live check 2026-10-19)

| PR | State | Base ref / SHA | Head SHA | Dependency / caution |
|---|---|---|---|---|
| [#2817](https://github.com/mobinpda-lab/Arvin-clean/pull/2817) | OPEN / DRAFT | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | `77a6a1bec2d6d5e99d4eef0a737abc4d24130469` | Parent hardening gate; not merged |
| [#2821](https://github.com/mobinpda-lab/Arvin-clean/pull/2821) | OPEN / DRAFT | `hardening/v5.09-release-approval-and-telemetry` / `77a6a1bec2d6d5e99d4eef0a737abc4d24130469` | `e80be91f4f461d0387d3b5b9349c217715bdba2e` | Stacked on #2817; current release candidate, exact-head gates not yet proven |
| [#2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824) | OPEN / DRAFT | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | `ccc9f9b122420ef999828088f70a7aa950c5b979` | Signature workflow; release identity still FAIL |
| [#2826](https://github.com/mobinpda-lab/Arvin-clean/pull/2826) | OPEN / DRAFT | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | `fa693f1adacf306c5698a675d59832132f0e0f93` | Documentation-only evidence updates |
| [#2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827) | OPEN / DRAFT | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | `a4c4f0fc05c83e9a1bb92534335d3745de9d1c8b` | Exact-SHA Device Smoke workflow support; dispatch itself not run |
| [#2828](https://github.com/mobinpda-lab/Arvin-clean/pull/2828) | OPEN / DRAFT | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | `50f1d26a8e4102f078e2f184771f98d521152dc4` | Follow-up / SQL migration integrity fix; Build + Device Smoke pass on PR checkout |
| [#2790](https://github.com/mobinpda-lab/Arvin-clean/pull/2790) | OPEN / DRAFT | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | `6ca1cff18f6631352995241b783b7b3bfcec55d5` | Base snapshot is older than current main; reconcile before merge |
| [#2791](https://github.com/mobinpda-lab/Arvin-clean/pull/2791) | OPEN / DRAFT | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | `9cf025b5a9678373d6b5a89a8a043ba49bf53243` | PDF font + artifact; base snapshot older than current main |
| [#2796](https://github.com/mobinpda-lab/Arvin-clean/pull/2796) | OPEN / DRAFT | `main` / `824ca8f17c92e76b3887001891d7d5b6f17974a6` | `a85bd3ec13e09802ee35b382f4ab9d42b4c11a4d` | UI font picker; base snapshot older than current main |
| [#2831](https://github.com/mobinpda-lab/Arvin-clean/pull/2831) | OPEN / DRAFT | `main` / `d9fb7a247037762216662a20fb32028ecc8a0f6b` | `196eff68ce2c2db09eb37cad86b69435428d285c` | Provider exact-head workflow/test; latest run in progress |

**Base warning:** PRs #2790, #2791 and #2796 still report base snapshot `824ca8f17c92e76b3887001891d7d5b6f17974a6`, older than current `main` `d9fb7a247037762216662a20fb32028ecc8a0f6b`. Their successful CI is useful PR-checkout evidence, but it must not be treated as proof of integration against current main until the branches are reconciled. No base changes, merges or force pushes were performed.
