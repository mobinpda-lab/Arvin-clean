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
