## LIVE PROBLEM REGISTER OVERRIDE — 2026-10-12

This section is the current release-risk summary. Older SHA and workflow-status statements below are historical unless revalidated against live GitHub.

- **P0 / Automated baseline:** main Build [38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086) passed on exact main SHA `cea76673d871ce52b84dacf69f355c4282802baa`; main Device Smoke [38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043) passed all six emulator scenarios. This closes automated evidence only for that SHA.
- **P0 / Memory PR exact-head validation:** PR #2614 remains OPEN/DRAFT at last check. Always retrieve its current head and required Build jobs before readiness or merge; stale-head results are not valid evidence.
- **P0 / Physical-device acceptance:** Calendar same-event update/no-duplicate behavior; real Android system-file-provider Backup/Restore, rollback and restored Calendar-link integrity remain NOT VERIFIED.
- **P0 / Product handover:** installed-device golden flow, Persian RTL/compact-screen visual acceptance and explicit owner release approval remain outstanding. Keep release gate [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN; no release authorized.
- **P1 / Integration:** reconcile overlapping implementation PRs #2591, #2595, #2602 and #2607 into a single tested integration head. Preserve canonical root `Task.description`; do not introduce `Task.note` or alter schema/migration/backup semantics without an explicit owner decision.

---

# Arvin Problem Register

Updated: 2026-10-11 from live GitHub review.
Repository: https://github.com/mobinpda-lab/Arvin-clean
Rule: a problem is not marked resolved solely because a PR exists or an APK builds. Closure requires current code/test evidence and, where relevant, owner/device acceptance.

## P0 — Release, data safety and installed-device acceptance

| Problem | Evidence / owner record | Status | Next action |
|---|---|---|---|
| Exact-current-main Build and Android Device Smoke evidence not established by the current lookup | [main `a6ced276`](https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a), [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) | BLOCKED / EVIDENCE MISSING | Trigger or recover the existing validation workflow on exact current main SHA; inspect all jobs/artifacts. Empty status lookup is not a pass. |
| Physical-device backup/restore round-trip, Android file-picker/provider behavior and failed-restore integrity | [merged #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585), [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) | AUTOMATED IMPLEMENTATION MERGED; DEVICE ACCEPTANCE NOT VERIFIED | Test actual device, record OS/device/build, export and restore artifact, before/after canonical data counts/IDs and rollback behavior. |
| Calendar actions/recurrence and stable external-event behavior on installed APK | [merged #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587), [#2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535), [#2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) | MERGED CODE; PHYSICAL-DEVICE ACCEPTANCE NOT VERIFIED | Verify Edit and phone-calendar actions remain visible; verify planned recurrence days and same-event update/no duplicates. |
| Golden User Flow and final owner acceptance | [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139) | OPEN | Execute create → date/time → taxonomy → checklist/repeat/follow-up → calendar → edit same Task/event → complete → backup/restore → integrity check on the candidate APK. |

## P1 — Core workflow and architecture

| Problem | Evidence / owner record | Status | Next action |
|---|---|---|---|
| Task editor regression/acceptance: repeat/reminder reachability, date/time behavior, RTL taxonomy row | [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602), [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595), [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591) | BLOCKED; #2602 recorded test-shard failures and Device Smoke skipped | Fix root causes without weakening behavior tests; reconcile stacked/overlapping changes; run full Build and Device Smoke on the final combined head. |
| Repeat occurrence lifecycle, independent checklist execution state and immutable history | [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | OPEN / ACCEPTANCE REQUIRED | Verify occurrence state isolation, history immutability and future-only repeat edits. |
| Repository-wide Project / Category / Tag ontology conformance | [#2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580), [PCTADP ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md) | OPEN | Complete code/UI/persistence/test/docs inventory. Category = Group synonym; no fourth Group entity. |

## P2 — Product completeness and governance

| Problem | Evidence / owner record | Status | Next action |
|---|---|---|---|
| Report Center advanced combined filters, preview, copy/share/print/PDF | [#2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385) | OPEN / UX COMPLETENESS NOT ACCEPTED | Audit existing paths and extend them; no parallel report/filter/export engines. |
| One coherent protocol, audit, state and memory hierarchy | [#2598](https://github.com/mobinpda-lab/Arvin-clean/pull/2598), [#2599](https://github.com/mobinpda-lab/Arvin-clean/pull/2599), [#2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) | BLOCKED ON RECONCILIATION | Rebase against current main; choose one authority, one execution standard, one status/roadmap source, one decision history and the existing owner acceptance ledger #1139. |
| Release handover package | AMPOP v5 / autonomous command v8 | PENDING | Prepare release notes, installation guide, user guide, known issues, architecture summary and evidence report only after acceptance evidence exists. |

## Closed / merged items — do not reopen without new evidence
- Backup catalog preservation and rollback protection: PR #2585 merged as commit `a6ced276...`; physical-device acceptance remains separate and open.
- Calendar collapsed-card primary actions and recurrence navigation/count behavior: PR #2587 merged as commit `c57606c...`; physical-device acceptance remains separate and open.
- Calendar edit updates the linked external event by identity: PR #2570 merged as commit `34a6cee...`; physical-device no-duplicate proof remains separate and open.

## Risk controls
- Task is the canonical source of truth. No parallel task/storage/restore engine.
- Never match Task/Project/Calendar records by title or date when stable IDs are available.
- Do not weaken product guarantees to make tests green.
- Do not merge or release based on stale-head CI, emulator-only evidence or documentation claims.
- Do not claim a physical-device result unless the actual device result is recorded.

## P1 — Repeat Tracking Level integration (RTLC)

| Problem | Evidence / owner record | Status | Next action |
|---|---|---|---|
| Tracking level exists in repeat model/serialization but end-user integration is not yet evidenced across Task Create/Edit, Home and Report Center | [Decision #2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), [repeat lifecycle #2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | IN PROGRESS / ACCEPTANCE OPEN | Integrate existing `recurrence.trackingLevel` into the main Task form after Repeat; default «عادی»; add focused selection/round-trip tests. Then audit Home and Report Center. |
| Requested missed/upcoming/progress metrics may not all be derivable from currently verified canonical history semantics | [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605) | NOT VERIFIED | Define metric semantics from existing recurrence projection/history; test every displayed count against canonical records before showing it. If model/engine change is truly needed, document and request architecture review first. |
| Risk of conflating Follow-up with Repeat Tracking or creating parallel domain/storage systems | [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), [Task editor #2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593) | GUARDRAIL | Keep `followUpEnabled` distinct from `recurrence.trackingLevel`; no new entity/store/database/engine or copied Task per occurrence. |
| RTLC backup/restore, immutable-history and occurrence-checklist independence are not end-to-end validated | [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) | NOT VERIFIED | Add tests for existing-field round-trip and past-state immutability; validate backup→restore on exact candidate head and actual device before acceptance. |

### Fresh evidence — PR #2602 task-form regression
- Exact head: `15c40a81ec7e45fe690de40ebbd9cf005e57af80`.
- [Build #38139809938](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809938): Debug/Release APK jobs passed; overall quality failed on three test shards.
- [Device Smoke #38139809930](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809930): skipped.
- Failures include missing Repeat/Recurrence controls, reminder/date-time behavior, date-only All-Day persistence, Clock Dial behavior and taxonomy row width (99.33 px versus >270 px expectation).
- Status remains BLOCKED. Fix root causes, preserve behavior assertions, rerun exact-head CI and Device Smoke. Do not merge #2602.



## Deep conversation audit addendum — 2026-10-11

| Problem / requirement | Evidence | Status | Next action |
|---|---|---|---|
| Universal time selection/display is not yet proven unified across all product surfaces | [Accepted standard #2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589), [docs PR #2590](https://github.com/mobinpda-lab/Arvin-clean/pull/2590), [implementation PR #2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591) | OPEN / ROLLOUT NOT ACCEPTED | Audit direct/custom pickers and display formatters across Home filters, Backup Schedule, Follow-up, Reports, Task Editor and Quick Capture. Resolve overlap with #2595 and #2602; validate Persian digits, RTL, exact-minute entry, Cancel safety and real-device behavior. |
| High-priority checklist requested under the full/edit Task form is not evidenced as delivered | Owner requirement indexed in [conversation decision history](ARVIN_CONVERSATION_DECISION_HISTORY.md); repeat/checklist lifecycle [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | NOT VERIFIED | Implement/reuse checklist within canonical Task form; support a general checklist for any Task (example daily school checklist at 06:00 with کیف/خوراکی/لباس). Preserve independent per-occurrence state for Repeat; add persistence and edit/reopen tests. |
| Conversation-level requirements are not all represented in the prior memory index | New [conversation decision history](ARVIN_CONVERSATION_DECISION_HISTORY.md) on memory branch | DOCUMENTATION ADDED ON OPEN PR; NOT ON MAIN | Read back and verify; reconcile docs PRs #2598/#2599/#2600 and rebase before merge. |
| Task form/time-picker implementation is fragmented across overlapping PRs | [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591), [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595), [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602) | BLOCKED ON CANONICAL-LANE DECISION/RECONCILIATION | Compare exact live heads/diffs, choose one lane, fix #2602 root causes without weakening tests, then integrate RTLC once. No parallel edits to the same Task Editor. |


## 2026-10-11 — New root Task.note field is an unapproved data-contract gate

- **Finding:** Fresh patch comparison of #2595 shows a new root `Task.note` property, Task JSON serialization/deserialization changes, TaskStore known-key changes, and backup/restore contract test changes. Current main `lib/models/task.dart` at main SHA `a6ced27660d34cd87dd8915aff68d3a7555fd57a` has root `description` and Notebook item kinds but no root `Task.note`; scoped `FollowUp.note` and Notebook concepts already exist.
- **Risk:** Existing user data may have used `description` as the main long-form content. Splitting description and note without an owner-approved mapping can alter edit/export/import/restore semantics or silently migrate data incorrectly.
- **Contract check:** Command v8 lists Task fields including Description but does not explicitly authorize adding a second root note field. This is not approved as a mere UI-only change.
- **Status:** BLOCKED pending explicit owner decision on whether Task needs both a short Description and a separate Note, plus legacy JSON/backup mapping. Do not merge #2595 or carry this field into another branch until decided. Keep #2595/#2602 Draft; reconcile their overlapping Task Editor/time-picker changes into one lane.
- **GitHub record:** [#2595 review comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110326453), [#2602 review comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6110326886).
- **Safe continuation:** Continue read-only comparison and tests/CI evidence work that does not mutate the Task data contract; do not modify app code for this split before owner decision.


## 2026-10-11 — Resolved: Task root Description/Note data-contract gate
- **Owner decision:** Option 1 selected — keep the existing root `Task.description`; do not add root `Task.note`.
- **Required action:** PR #2595 must remove its added root `Task.note` property and associated JSON/TaskStore/backup contract changes. PR #2602 must not inherit or reintroduce that field. Existing Notebook/FollowUp note concepts remain unchanged.
- **Validation gate:** Confirm no root `Task.note` references remain in the proposed canonical Task implementation, legacy JSON and backup/restore tests pass, and no tests are weakened. This resolves the product decision only; it does not mean the PRs, CI, build, device checks, or release are complete.

## OWNER DECISION — 2026-10-11 (supersedes earlier decision gate)
- Owner selected Option 1: keep the existing root `Task.description` as the only root Task text field; do not add a root `Task.note`.
- This resolves the prior owner-decision gate. Scoped `FollowUp.note` and Notebook note/checklist concepts remain unchanged; this decision does not authorize deleting or migrating those scoped fields.
- Required implementation on the canonical Task-form lane: remove only the newly introduced root `Task.note` from the Task model, JSON serialization/deserialization, TaskStore known-key handling, editor UI/state, and backup/restore test changes. Preserve legacy payload safety and existing Description values; add/retain regression tests proving legacy JSON and backup/restore round-trip still work without a second root field.
- PR #2595 must remain Draft until this correction and exact-head Analyze, all test shards, Debug/Release APK and relevant device smoke are verified. PR #2602 must not reintroduce the root field and its previously failing test shards must be fixed at root cause; never weaken assertions.
- Current execution result: decision resolved and documented; implementation patch not yet applied or validated in this step. No merge, main write, APK build, or release occurred.



## 2026-10-11 — Repeat count/date defaults and Calendar edit sync
- P0/P1 owner-reported product defects: repeat does not produce expected 7 occurrences; enabling repeat should prefill today's local date/current time and keep both editable; editing a Task does not reliably update its linked phone-calendar event.
- Existing tracker #2535 covers 7-occurrence calendar projection. Existing architecture gate #2254 governs count/start/end/immutable history. Existing #2248 governs stable Task↔Event identity and destination changes.
- Observed code defect: no-range outbound projection omits future recurrence occurrences; timestamp-based recurrence reminder IDs change when scheduled date/time changes, but edit-only sync matches links by reminder ID. This risks missing old event update and/or duplicates.
- Safe editor fix is in Draft PR #2606. Calendar identity/projection fix remains BLOCKED on independent architecture review; do not modify storage/model/event identity before the contract is approved.


## Report Center filter interaction — 2026-10-11

| Problem | Evidence | Status | Next action |
|---|---|---|---|
| Report filter test interaction lost the Apply control after selecting time/category | [Failed exact-head run #38161588760](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38161588760); shard 2 stack at `test/report_center_page_test.dart:111` | Test-only correction committed; VALIDATION PENDING | Check exact-head run [#38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144); inspect fresh logs if it still fails. |
| Category accordion test tapped outside the modal sheet hit-test area | [Failed exact-head run #38161588760](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38161588760); shard 4 hit-test warning at line 173 and `Bad state: No element` at line 180 | Test-only correction committed; VALIDATION PENDING | Verify `scrollUntilVisible` correction on exact head; do not suppress hit-test warnings or weaken assertions. |
| Report Center time picker implementation status was described inaccurately in an earlier comment | Current PR head `5278c5a...` imports `universal_arvin_time_picker.dart` and `_pickTime` calls `showUniversalArvinTimePicker` | CORRECTED | Keep time-picker migration as implemented in this PR; separate remaining Persian-digit/RTL/device validation from source-code integration. |

Test-only correction commit: [9ae99714](https://github.com/mobinpda-lab/Arvin-clean/commit/9ae99714e3cc36fe73814b1c0af0c3611adff2d4). Current validation run: [38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144), queued at checkpoint; no result yet. PR #2607 stays Draft.


## Report Center filter test helper follow-up — 2026-10-11

| Problem | Evidence | Status | Next action |
|---|---|---|---|
| Prior test correction passed `ListView` where Flutter `scrollUntilVisible` requires a `Scrollable` finder | [Run #38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144), shard 2 and 4 logs: `type 'ListView' is not a subtype of type 'Scrollable'` at test lines 104 and 178 | Corrected in commit [45caa5a3](https://github.com/mobinpda-lab/Arvin-clean/commit/45caa5a3d7c7b3b29264f0197d6affd2b1798df5); VALIDATION PENDING | Verify fresh exact-head run #38163195995 and Device Smoke #38163195983. |


## 2026-10-11 — Report filter and release blockers

- Open: PR #2607 report-filter regression test can fail when the test scrolls to a selected category chip then taps the section header outside the modal bottom-sheet viewport. Test-only fix committed as `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439`; awaiting exact-head CI.
- Open: Device Smoke is skipped for Draft PR #2607 by the workflow's explicit Draft gate. This is missing validation evidence, not a successful smoke test.
- Release blocker: Release Closure run #38163384915 reports issue #2102 must be closed only after exact-main CI, device evidence and product acceptance, and PR #1901 (P0/P1 real-device regression lane) must also be closed before publication. Neither was closed automatically. Preserve these gates.


## Repository-wide audit additions — 2026-10-11

### P0 — Release orchestration storm
- Evidence: current main SHA has 1,535 Actions runs; recent history contains repeated Release Closure failures/cancellations and Final Head Release Validation skips. Current runs #38164393875 (failure) and #38164416537 (skipped).
- Root cause: release-closure.yml listens to every completed Production Orchestrator run, which itself wakes from Build/Device Smoke/Parallel Wave and a five-minute schedule.
- Existing solution lane: PR #2531; currently stale/behind main and must be reconciled and validated. Do not create duplicate workflow fixes.

### P0 — Release gate and bypass risk
- Issue #2102 and PR #1901 remain open; owner ledger #1139 has unchecked installed-device acceptance.
- Manual release.yml has a direct workflow_dispatch release-creation path separate from the gated release-closure path. Review/guard it before release use.
- pubspec is 1.0.1+2, but existing Draft tags use v0.1.0-arvin-<sha>; release-closure expects a version/build/main-SHA tag. Issue #2135 is stale and open.

### P1 — Report date/time still Gregorian on main
- Main lib/report_center_page.dart uses showDatePicker/showTimePicker. PR #2607 exact-head Build passed but Device Smoke was skipped because it remains Draft; #2591/#2607 share files and need sequencing.
- Do not call the report-filter request done until Persian/Jalali date, Persian-digit time, RTL layout and user acceptance are verified.

### P1 — Governance/memory drift
- ARVIN_STATUS and ARVIN_PROJECT_STATE retain PR #135/v49.0-era state while the operating package is v49.1.
- Package v49.1 references AMPOP v5, which is only on unmerged #2598. Owner command v8 is now recorded in the memory branch, not main.
- #2598/#2599/#2600/#2601 have old merge base 72a2f4cc...; #2598/#2599 overlap docs/ARVIN_STATUS.md. #2600 contained 11 memory files before the audit; the current branch has 13 after adding the exact owner Command v8 and repository-wide audit. Consolidate canonical vs historical memory documents before merge.
- Official scorecards use August baseline dates and old main SHAs.

### P1 — Task Note contract not reflected by current PR source
- Issue #2593/PR #2594 accepts optional Task Note distinct from Description. Current PR #2595 source has no root Task.note or editor Note input, while its PR body claims otherwise and cites an old head. Reconcile source, tests, persistence and description before merge.

### P1 — Queue noise and unsafe recovery close
- 876 open AUTO-FIX search results; classify by exact failing SHA/root cause and supersession evidence, not mass-close.
- Issue #866 remains open for premature Recovery Wave auto-close; add/verify parent-wave acceptance regression before considering it fixed.
- Issue #1324 remains open despite SQL/Drift TaskStore on main; refresh current-main migration/round-trip evidence before closure.
- Issues #2248 (calendar target identity), #2254/#2605 (repeat cycle/history), #2580 (taxonomy conformance) remain important product/architecture acceptance lanes.

### P2 — branch/history scale
- 1,248 branches were enumerated across 13 pages. Inventory active PR branches, historical branches and orphan candidates; do not bulk-delete without dependency checks.
- 1,096 open Issues were not individually read in this pass; 19 open PRs and targeted P0/P1 issues were inspected. Continue bounded, evidence-led history passes.


### Additional P0/P1 product acceptance records — 2026-10-11
- #1608 P0 Release-Ready evidence board remains open.
- #1602 P0 parallel product closure for Keyboard/Back, Swipe, Notebook and Calendar remains open.
- #830 P0/P1 release execution board remains open and should be reconciled with current gate #2102 and acceptance ledger #1139.
- #2535 P0 installed-APK acceptance remains open: Calendar actions and all scheduled repeat days need validation on the installed product.
- #1843 Home visual/clipping/phone-calendar action, #1860 typography scaling, #1851 Quick Capture Persian date/time, #1852 taxonomy refresh, #1068 final QA checklist and #1067 Calendar/Jalali acceptance remain open. They overlap newer PRs/issues but are not closed by PR existence alone.


### 2026-10-11 — workflow churn and release gate refresh
- **P0 — repeated release/orchestrator activity:** live exact-main runs around 18:38–18:42 UTC show repeated Production Orchestrator / Production Loop / Promotion Bridge runs, with Release Closure failures/cancellations and Final Head Release Validation skips. This is not release evidence.
- Main release closure still cancels in-progress executions and accepts any successful Production Orchestrator completion. Existing PR #2531 proposes trigger isolation and non-cancelling concurrency; validate its exact-head checks and review before integration.
- **Release remains blocked:** #2102 OPEN, #1901 OPEN, #1139 OPEN; owner-installed-device acceptance incomplete; two Draft prereleases explicitly unapproved.
- **P1 — recovery auto-close:** #866 remains open; prior issue evidence shows Recovery Wave #847 closed after a partial child PR, then required manual reopening. Worker/parent closure must be acceptance-complete and evidence-based.
- **P1 — provider pressure:** #866 comments include repeated HTTP 429 cooldown/retry events. Do not classify provider rate limiting as an Arvin product defect or bypass the cooldown.
- **P1 — migration proof:** #1324 remains open for SQL/Drift lossless migration boundary and round-trip acceptance; current main architecture presence alone does not satisfy issue acceptance.


## Live checkpoint 2026-10-12
- **P0:** Current-main Build #38178428086 and Device Smoke #38178428043 have stale/incomplete states; recover existing evidence, do not infer pass/fail from missing logs.
- **P0:** Installed-device Calendar same-event update/no-duplicate behavior remains unproven.
- **P0:** Real Android system-provider Backup/Restore, rollback and Calendar-link integrity remain unproven.
- **P1:** Restore canonical memory package to main; drafts #2600/#2608 are stale/overlapping.
- **P1:** Reconcile #2591/#2595/#2602/#2607 shared Task Editor, Quick Capture, Report Center and time-picker paths before integration.
- **P1:** Preserve the root Task.description decision; do not add Task.note or alter migration/backup semantics without owner approval.
