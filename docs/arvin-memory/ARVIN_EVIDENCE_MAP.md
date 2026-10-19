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



## 2026-10-19 — Wave 4.11 Follow-up Reminder evidence

| Feature / Gate | SHA / Run | Result | Evidence / limitation |
|---|---|---|---|
| PR #2833 baseline Build | `91d5412dad2f80aeffc464434f693583f4180be2`; [Run 39232215264](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39232215264) | **FAILURE** | Analyze reports syntax/scope errors in `test/follow_up_reminder_model_test.dart` at lines 197 and 214; test-3 and test-4 also fail. |
| APK jobs on baseline | Same Run 39232215264 | Debug and Release APK jobs SUCCESS | Artifacts exist: [Debug APK artifact](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178256927), [Release APK artifact](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178341746). These are not release-approved; Release signing is still configured to use the debug signing config. |
| Test scope correction | `44019c81b8ad394b7c4ce4496347004a79a519ad` | IMPLEMENTED_NOT_VERIFIED | Two new tests moved inside `main()`; no subsequent run was returned at time of this update. |
| Follow-up-to-TaskReminder reconciliation | `2989741558cdc834787f38751469e91788cf42e7` | IMPLEMENTED_NOT_VERIFIED | Repository mirrors date/title to linked TaskReminder, preserves linked ID on edits, and removes only linked reminder when cleared. Persistence is in canonical Task JSON envelope; no new SQL migration. |
| Duplicate notification guard | `e83229579d36108786f11393ca622de85c13b693`, `f6d34abe1b435530e72cc3ef0c8e90746dda4e90`, `dba7a12b55edb1ffc7981f5526a8c7c4330640c6` | IMPLEMENTED_NOT_VERIFIED | Linked TaskReminder mirror is skipped by generic TaskReminder delivery projection so the established Follow-up delivery key remains authoritative. |
| Repository lifecycle regression tests | `b4b14a2497c460b2bd8da1711b7a8663cb1c42d6` | IMPLEMENTED_NOT_VERIFIED | Tests cover stable ID across edit, scoped clear, preserving unrelated reminders/Person/waiting/result, and `nextFollowUp` alone. Tests have not been run. |
| Latest UI label | `9dc9d9f3b9156ab1095b722ca7dbc89bdaf7eeee` | IMPLEMENTED_NOT_VERIFIED | UI label changed to `یادآور پیگیری بعدی`; not yet validated by widget test on this SHA. |

**Evidence rule:** no result above establishes a passing gate on the latest PR head. Device Smoke, Backup/Restore integration, writable Calendar Provider acceptance, exact-SHA verification and official signing remain unproven.



## 2026-10-19 — Follow-up Reminder idempotency, Calendar de-duplication, Backup/Restore test

| Feature / Gate | Commit | Result | Evidence / limitation |
|---|---|---|---|
| Idempotent FollowUp create by stable ID | 937361328d56bae7b1831e8366f570658826cb15 | IMPLEMENTED_NOT_VERIFIED | Repository add replaces the existing Follow-up when the same ID is resubmitted; test added in c24e7b4dfe81313b4c45a95960cc47e3e5458755. |
| Calendar projection duplicate prevention | a26189099c60985f88ea2500b55ae17c89af8ee3 | IMPLEMENTED_NOT_VERIFIED | Calendar projection skips TaskReminder entries linked by Follow-up ID; regression test commit 1d820bf3e6f6eb4d5889a2bc4c2835c6e09d5f42 expects exactly one existing followup:<taskId>:<followUpId> event. |
| SQL + canonical Backup/Restore relationship test | 2253ef62f404ef064b4bf85d40a16cbf880ed554 | IMPLEMENTED_NOT_VERIFIED | New integration test round-trips Task, Follow-up, linked Reminder ID/date/title, Person association, Waiting for Response and unrelated Reminder through TaskStore and the existing canonical backup document. |
| Latest complete Build / Device Smoke | Final PR #2833 head after these changes | PENDING | Older head 12ef171beef4533d12efe08f3bdacca5e2e03f36 had Analyze SUCCESS, but its Build and Device Smoke runs were cancelled by subsequent branch updates. Do not count them as full passes. |

No new SQL schema migration was introduced; the current TaskStore JSON envelope is the persistence path for TaskReminder metadata. Actual migration and Backup/Restore behavior remain pending until the tests run on the final head.



## Wave 4.12 live evidence checkpoint — 2026-10-19

| Gate | SHA / Run | Result | Evidence |
|---|---|---|---|
| Build + Analyze + all test shards | PR #2833 head d06062fb19c3f3ad54051f3a682f69be4146dd91; [39234124721](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124721) | SUCCESS, 9/9 jobs | Analyze, six test shards, Debug APK, Release APK. Artifacts IDs 12178910414 and 12177339192 explicitly reference this SHA. |
| Device Smoke | [39234124429](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124429) | IN PROGRESS at last poll | Home, Quick Capture, SQL Persistence, SQL Migration SUCCESS; People/Backup-Restore IN_PROGRESS; Calendar QUEUED. |
| Exact SHA | PR #2827 [39211789444](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211789444) | BLOCKED | Verify exact requested revision was SKIPPED on Device Smoke lanes. |
| Release certificate | PR #2824 head ccc9f9b122420ef999828088f70a7aa950c5b979 | BLOCKED | android/app/build.gradle.kts still configures release with debug signing; no authorized fingerprint verified. |
| Real Calendar Provider | PR #2831 [39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224) | FAILURE / BLOCKED | No writable Calendar Provider in the stock emulator. |
| Canonical release/matrix docs | Commits e2989ffa6b585368bfc4effaf4647ec53a792c46 / 0525f14a93f8d548e6b84cb70daa5d7e1177e6ed | Created | Both were absent on main and Wave 4.11 branch at inspection; now added to the existing PR branch. Their new head requires fresh CI. |

Do not transfer green CI results from d06062fb19c3f3ad54051f3a682f69be4146dd91 to the later documentation commits.


## Wave 4.13 evidence addendum — 2026-10-19

| Evidence | Result | Scope / limitation |
|---|---|---|
| Build [39235854952](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854952) | SUCCESS, 9/9 jobs | PR event; exact requested revision step SKIPPED. Do not treat as exact-head proof. |
| Debug artifact [12178863114](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178863114) | Available; APK SHA-256 `c44abc1cd8c67b4737d8f01a95d28c15f67cc49bcbb3222eda28e256da58f0f0` | Extracted and hashed in this session; not release-signing evidence. |
| Release artifact [12179281920](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179281920) | Available; APK SHA-256 `6c6e38199c9d29ae26a4ff33e45082882ff05d0ee0bd8d276889148e78f2fabd` | Extracted and hashed in this session; `apksigner` unavailable locally and Gradle release config uses Debug signing. |
| Device Smoke [39235854812](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854812) | Home + Quick Capture SUCCESS; SQL Persistence + SQL Migration IN_PROGRESS; People + Backup/Restore + Calendar QUEUED | Incomplete; no 7/7 claim. |
| Provider diagnostic artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) | Provider package present; no writable calendar row | Limitation evidence only, not CREATE → NO-OP → UPDATE → DELETE PASS. |
| Exact-SHA | SKIPPED on Build run | Authorized `workflow_dispatch(target_sha)` still unavailable. |

When the docs-only head changes, old run evidence stays attached to the prior candidate and must not be transferred to the new SHA.


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


## WAVE 4.16 — EVIDENCE UPDATE — 2026-10-19

| Requirement / gate | Source SHA / run | Result | Evidence and limitation |
|---|---|---|---|
| Follow-up title fallback + stable identity/time regression tests | PR #2833 code commit `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`; Build [39243365218](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365218) | IN_PROGRESS at last poll | Repository-level tests added; do not mark PASS until all required Build jobs terminate successfully. |
| Device Smoke for previous code head | Run [39240952294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952294), source metadata SHA `273944bb6504c7d51fa4b5f8b869a5519591f682` | CANCELLED | Six lanes succeeded; Calendar lane cancelled. Not full acceptance. |
| Build for previous code head | Run [39240952251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952251), source metadata SHA `273944bb6504c7d51fa4b5f8b869a5519591f682` | SUCCESS, 9/9 jobs; Exact-SHA assertion skipped | Debug Artifact [12181028571](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12181028571), digest `sha256:017b04a392cfbb3fe73cdeb53067b5053b557999b89e088ec2ac3574c9cd17cc`; Release Artifact [12180934054](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12180934054), digest `sha256:def49ff62e32839a2ab8c836b100841e5d9ee7f86e54dae28c99792a8b3639a9`. Artifact ZIP digests only. |
| Real Calendar Provider | Run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995), PR #2831 SHA `094c43f1f92de263d26950915b13df7380e69244` | FAILURE / BLOCKED | Exact-target assertion succeeded for that SHA; acceptance reports no writable calendar on stock API 35 emulator. Diagnostic Artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078) successfully uploaded. |
| Official Release signing | main `android/app/build.gradle.kts` | BLOCKED | Release uses Debug signing; authorized key and approved fingerprint unavailable. |


## Wave 4.17 evidence delta — 2026-10-19

| Evidence | SHA / Run | Result | Qualification |
|---|---|---|---|
| Completed-FollowUp notification guard + regression test | Commit [9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b](https://github.com/mobinpda-lab/Arvin-clean/commit/9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b) | Implemented; validation pending | Delivery loop now excludes completed FollowUps. CI on prior SHA is not evidence for this fix. |
| Build before fix | [39243593152](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593152), SHA `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7` | Nonterminal at last inspection | Analyze and test shards 1–5 passed; test-0 and APK builds in progress. Not a full pass. |
| Device Smoke before fix | [39243593281](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593281), SHA `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7` | Nonterminal | Home and Quick Capture in progress; five lanes queued. |
| Calendar Provider diagnostics | [Run 39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995), SHA `094c43f1f92de263d26950915b13df7380e69244` | FAILURE | [Artifact 12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078) remains unexpired; real writable provider acceptance not established. |
| Official Release signer | `main:android/app/build.gradle.kts` | BLOCKED | Release signing config still points to debug; no approved key/fingerprint. |


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


## Wave 4.18 evidence map — 2026-10-19

- Historical Build [39245131077](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131077): SUCCESS, 9/9 jobs; test shards 0–5, Analyze, Debug APK and Release APK passed. Exact-target assertion skipped. APK ZIP artifacts: Debug ID 12183247865, digest `sha256:c112b7084a2f51d507ef34bce273b0fe62ba4839242cfe38089766524621f9fa`; Release ID 12182474529, digest `sha256:75b666184ba608c894a8204561bf0978ac6c485da4eb4cd8825e8067ac2464d4`.
- Historical Device Smoke [39245131071](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131071): all seven lanes SUCCESS. Artifact naming records integration SHA `fd90b02a8a438ae6387ebebbd13c64d7f4b38c04`; do not transfer to the later source fix.
- Calendar Provider [39245131251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251): FAILURE at UPDATE. Diagnostic artifact ID 12183547745, digest `sha256:7e78ac4527d476c06b90e336fd1b8c0df62914be780570d0a9b28902290f6391`.
- Source fix [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f): exact event/calendar ownership checked before item-URI update. Fresh run/artifact evidence for this SHA was not returned; validation remains pending.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

Evidence binding rule: Build and Provider results are tied to merge SHA `bf4f1a94f515c213f0630b6c642451d73ab17a4c`; artifact names mentioning PR head do not override `environment.txt` and checkout logs. Do not reuse prior PASS claims for the new HEAD created by this test-coverage update.


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
