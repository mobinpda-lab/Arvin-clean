## AUTHORITATIVE UPDATE — 2026-10-14 — Exact-head CI false-positive

- **Problem:** The recovery dispatcher could treat a normal PR-triggered Build as exact-head evidence when run metadata named the PR head, even though the Build checkout uses the synthetic merge SHA for `pull_request`.
- **Classification:** CI orchestration / evidence identity.
- **Root cause:** Metadata SHA was treated as checkout proof; those are not equivalent for normal pull-request runs.
- **Fix:** PR #2699 commit `af3e3724ae08a956bb91fcbd82174ec23a2d2066` only accepts matching `workflow_dispatch` runs as exact-head evidence. Those Build jobs pin and assert the requested `target_sha`.
- **Status:** FIX IMPLEMENTED; exact-head CI and end-to-end dispatcher validation pending. No release/merge claim until the final SHA passes required checks and the dispatcher is exercised.
- **Remaining distinction:** This fixes the false-positive in recovery logic. It does not by itself prove why some earlier PR heads had no workflow runs, nor replace product acceptance or physical-device validation.

---

## 2026-10-14 — Missing exact-head Build evidence

- **Problem:** PR #2695 exact heads `6d01c603...` and `0432e3a...` returned no Actions runs; older failed/successful runs are not valid evidence for those heads.
- **Classification:** Infrastructure / CI orchestration (root cause unconfirmed).
- **Impact:** Cannot promote the Person integration; stacked branch and product acceptance remain blocked.
- **Mitigation:** PR #2699 adds a scheduled/manual recovery dispatcher and SHA-pinned Build dispatch.
- **Root cause:** Unknown. Do not infer token suppression or a permission fault without event-level evidence.
- **Validation required:** Exact-head Build and Device Smoke on final PR #2699 head; after merge, run the dispatcher against a controlled missing-evidence PR and confirm requested SHA = checked-out SHA = accepted run SHA, with terminal checks.
- **Status:** OPEN / UNDER VALIDATION. Release remains NO-GO.

---

# LIVE PROBLEM UPDATE — 2026-10-14 — Person integration CI failures

- **Problem:** Person-linked Follow-up integration head `07c7f9005b7331f07468e20d13b3939c990bd9fd` failed all six test shards; Analyze and Debug/Release APK succeeded.
- **Confirmed failure clusters:** ordinary Follow-up editor and Task Detail widget tests timed out in `pumpAndSettle` while the editor always displayed a Person-directory loading animation; waiting-response service/list fixtures used result-only legacy aliases instead of structured `waitingForResponse + personIds`; report filter tests attempted to tap lazy controls before those controls were built; report waiting logic did not require Person IDs.
- **Changes committed on PR #2695 branch, not yet validated:** `e57df8e`, `0432e3a`, `d2de8f2`, `c169b1c`, `dc5a9a5`, `a612dde`.
- **Status:** OPEN / VALIDATION BLOCKED. No exact-head workflow run was returned for `0432e3a7874ce5bc0f798345e232a480dc3d65b3`. Do not call the repairs successful until tests and build run on that exact SHA.
- **Safety rule:** keep tests; do not restore result-only legacy values as the active waiting-state source; do not merge the non-mergeable draft. Preserve the canonical Task store and backup/restore path.
- **Next:** trigger or obtain exact-head Build + all six Device Smoke lanes, review remaining failures, then reconcile against current parent PR #2666 head `ad762774009e5b5c7ee341146a8160c52e2b9bb2` and rerun on the final head.

---

## LIVE PROBLEM REGISTER OVERRIDE — 2026-10-12 (verified)

This section is the current release-risk summary. Older SHA and workflow-status statements below are historical unless revalidated against GitHub.

- **Current main checkpoint:** `a4dae51e93d9b3dcbc55ded366280e59183f16bc`. Build [38202955720](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955720) passed Analyze, all six test shards, Debug APK and Release APK; Device Smoke [38202955719](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955719) passed all six emulator lanes.
- **P0 / Physical-device acceptance:** Calendar same-event update/no-duplicate behavior; real Android file-provider Backup/Restore and restored Calendar-link integrity; installed-app golden flow; Persian RTL/compact-screen visual acceptance remain unverified. Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN and release NO-GO.
- **P0 / Calendar installed-app mismatch:** [Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) remains open. Current main contains visible action wiring, recurrence projection, and launcher-level tests for edit/register actions and the seven-occurrence boundary; this does not establish that the owner's previously installed APK contained those changes.
- **P1 / Cleanup:** [PR #2619](https://github.com/mobinpda-lab/Arvin-clean/pull/2619) remains open/unmerged at head `387694b5d5b29ca5fb72fedead56ed91368ca460`. Exact-head Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) completed successfully: Analyze, all six test shards, Debug APK and Release APK PASS. Exact-head Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) completed successfully: all six Android Emulator lanes PASS. Automated validation is complete for this head; path-by-path deletion/content migration review remains before merge. Emulator success does not establish physical-device acceptance.
- **P1 / Consolidated status report:** [PR #2620](https://github.com/mobinpda-lab/Arvin-clean/pull/2620) is ready for review, unmerged; exact-head Build [38211356787](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38211356787) passed. Device Smoke was skipped for documentation-only changes.
- **P1 / Integrated UI lane:** reconcile #2591, #2595, #2602 and #2607 into one tested integration head. #2595 and #2602 lack exact-head Build evidence in the latest query; #2607 reports merge conflicts. Preserve root `Task.description`; no root `Task.note`, schema or migration change.
- **Next action:** finish exact-head Build and all six Device Smoke lanes for #2619; refresh live checkpoint and evidence map; then obtain exact-head CI for #2602 and reconcile overlapping UI PRs without weakening tests. No installation is requested yet; ask the owner only when one integrated candidate passes available automated gates.

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


## 2026-10-13 — Follow-up / Reminder open compatibility issues

- **P1 — Missing first-set bridge:** selecting Next Follow-up currently saves the field but does not create the one-time initial reminder required by the product contract. Add tests for first-set and subsequent edit/delete independence after owner decision.
- **P1 — All-day semantics absent:** FollowUp has no explicit all-day marker and calendar projection omits `isAllDay`; midnight inference is unsafe. Define a backward-compatible representation for both independently date-only fields and test JSON, SQL envelope and backup/restore.
- **P1 — Editor incompleteness:** Next Follow-up inherits the history timestamp's time and has no clear-next action in inspected code; implement only after all-day representation is agreed.
- **BLOCKED — Existing reminder at first activation:** product owner must choose whether to preserve it, ask, or take another explicit action. Never overwrite or create a duplicate by assumption.
- No product code changed in the 2026-10-13 audit. Release remains NO-GO.


## P1 — User-controlled Follow-up reminder creation and independent editing (owner clarification 2026-10-13)
- **Contract:** setting Next Follow-up does not automatically create a reminder. Create a reminder for it only if the user explicitly wants/chooses it; prefill the Task title and Next Follow-up date/time, then allow independent editing. Reminder can exist without Next Follow-up. Additional reminders are permitted when explicitly requested.
- **Data safety:** no silent overwrite or duplicate creation; Next Follow-up changes/deletion must not mutate reminders, and reminder edits/deletion must not mutate Next Follow-up. Each independently supports date-only/all-day or date/time.
- **Current evidence boundary:** source audit found missing initial creation bridge and explicit Follow-up all-day metadata; no implementation or Flutter validation is claimed here.
- **Next action:** implement against canonical Task/FollowUp storage and stable Calendar event identity; add tests for title/date/time prefill when user opts in, multiple reminder creation, independent edit/delete, collision/no-duplicate safety, date-only projection, JSON/SQL/backup-restore and calendar same-event update. Release remains NO-GO pending full gates.


## P1 — Multiple Follow-up entries and independent reminders per Task (owner decision 2026-10-13)
- **Contract:** one Task may have multiple recorded Follow-up entries and multiple independent reminders. There is no one-per-Task limit.
- **Risk to verify:** editor or model may overwrite a prior entry, collapse reminders into one date field, or reuse Calendar identity. Preserve distinct entries and stable reminder/event identities.
- **Next action:** audit existing FollowUp collection/model and reminder representation; implement through canonical Task storage; test create/edit/delete of one among several, ordering/history preservation, JSON/SQL/backup-restore round-trip, Calendar event updates/no duplicates, and independent Next Follow-up/reminder behavior. Release remains NO-GO until gates pass.


## LIVE FINDING — 2026-10-13 — Multiple independent Task reminders
- **Open / architecture-data gate:** canonical `Task` currently has one `reminderDate`; `FollowUp` has one `reminderDate` per follow-up record. Multiple independent Task-level reminders not attached to FollowUp records are not represented.
- **Impact:** the requested product behavior cannot be claimed implemented; adding a list without compatibility, backup/restore and stable Calendar identity tests risks lost/duplicated reminders.
- **Proposed direction only:** embedded stable-ID reminder collection on canonical Task, with explicit all-day metadata; reuse existing persistence, backup/restore, notification and Calendar projection foundations.
- **Blocked until:** owner/architecture approval of legacy singular-field compatibility and date-only semantics. Do not infer date-only from midnight or auto-convert `nextFollowUp`. Tracker: Issue #2654; PR #2652.

## 2026-10-14 — Recovery dispatcher workflow-ref mismatch

- **Problem:** Dispatching to a target PR branch can run an older workflow definition without `target_sha` support; run metadata `head_sha` may identify the workflow ref rather than the checked-out target. A shared concurrency key can cancel simultaneous recovery builds.
- **Root cause:** The dispatch ref, workflow definition version, requested target SHA, run metadata SHA, and actual checkout SHA were treated as if they necessarily matched.
- **Impact:** Recovery could fail to start a verifiable exact-target Build or incorrectly classify a run; multiple targets could cancel one another.
- **Solution:** Run the workflow from the default branch, pass and assert the explicit target SHA in every quality/APK job, match runs by target-SHA run name, and isolate concurrency per target.
- **Status:** Fix committed to PR #2699; exact-head CI pending and operational acceptance remains open until controlled dispatch evidence exists.


## 2026-10-14 — Person directory delete-title test failure: current status

- **Original failure:** Build [38573235905](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38573235905) on older SHA `a162941fdf824463162ac6198a30b4373bfb751a` failed one widget test because the title assertion matched both the AlertDialog title and confirmation button.
- **Correction status:** current PR #2695 head `93202e9e24e33bff31daaf933b2c4fb1417dfb46` scopes the title finder to the AlertDialog; exact-head Build [38579471120](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38579471120) passes all six test shards.
- **Safety:** PR #2715 was closed without merge after its base produced an unexpectedly broad/diverged diff. Do not cherry-pick it.
- **Remaining status:** this specific test issue is resolved on the current Person PR head; physical-device and integrated product acceptance remain open. Release remains NO-GO.


## 2026-10-15 — Legacy Task reminder migration decision resolved; validation open
- **Problem:** prior records conflicted on migration of Task.reminderDate into TaskReminder.
- **Owner decision:** Option B, recorded at Issue #2654 comment 6178475884.
- **Candidate mitigation:** Task JSON decode creates one stable legacy TaskReminder with a persisted marker; Calendar and scheduler projections retain old identity; editor and inbound Calendar paths preserve independent reminder behavior.
- **Remaining risk:** no terminal exact-head CI result yet. SQL persistence, real backup/restore, rollback/retry, Calendar no-duplicate and physical-device acceptance remain unproven.
- **Status:** Candidate implementation; validation blocked/pending. Release NO-GO.



## 2026-10-19 — Wave 4.11 Follow-up Reminder contract status

| Problem / requirement | Evidence / current status | Classification | Next action |
|---|---|---|---|
| `TaskReminder.followUpId` was only a model/JSON field | Repository now mirrors FollowUp reminder create/edit/clear to canonical `Task.taskReminders` through `FollowUpRepository`; commits `2989741558cdc834787f38751469e91788cf42e7`, `b4b14a2497c460b2bd8da1711b7a8663cb1c42d6`. | IMPLEMENTED_NOT_VERIFIED | Run focused repository/model tests and confirm persistence after TaskStore reload on latest SHA. |
| Follow-up reminder mirror could be delivered twice through both TaskReminder and FollowUp projections | Generic TaskReminder planner/projection now skips linked mirrors, retaining the established FollowUp delivery identity; commits `e83229579d36108786f11393ca622de85c13b693`, `f6d34abe1b435530e72cc3ef0c8e90746dda4e90`, `dba7a12b55edb1ffc7981f5526a8c7c4330640c6`. | IMPLEMENTED_NOT_VERIFIED | Add/run tests proving create/no-op/update/clear notification behavior and calendar identity. |
| Initial Wave 4.10 tests were syntactically out of scope | Build run [39232215264](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39232215264) shows Analyze failure at lines 197 and 214; commit `44019c81b8ad394b7c4ce4496347004a79a519ad` moves them into `main()`. | IMPLEMENTED_NOT_VERIFIED | Obtain a fresh terminal CI result for current PR head; do not treat historical artifacts as gate closure. |
| SQLite and Backup/Restore relationship durability is not yet proven | Existing TaskStore envelope persists TaskReminder JSON; no new schema migration was added; repository tests added but not run. | IN_PROGRESS | Execute SQL reload + Backup/Restore relationship cycle; add migration only if evidence shows envelope persistence insufficient. |
| Release signing / exact SHA / real Calendar Provider gates | Prior canonical memory and current Gradle file show release signing configured with debug signing; real Provider acceptance and exact-head validation still lack current evidence. | BLOCKED | Continue independent PRs #2824, #2827 and #2831 with exact-SHA evidence. |



## 2026-10-19 — Wave 4.11 follow-up lifecycle delta

| Requirement / risk | Latest change | Status | Next action |
|---|---|---|---|
| Duplicate FollowUp writes for the same ID | Repository add now updates the matching Follow-up in place; tests added. | IMPLEMENTED_NOT_VERIFIED | Run repository tests on final head and confirm SQL relation row count stays one. |
| Linked TaskReminder appears twice in Calendar projection | Generic TaskReminder projection skips linked mirrors; stable Follow-up Calendar ID retained; regression test added. | IMPLEMENTED_NOT_VERIFIED | Run Calendar projection tests and real Provider acceptance on writable provider. |
| Backup/Restore could lose Follow-up reminder relation | Added canonical backup + TaskStore reload integration test. | IMPLEMENTED_NOT_VERIFIED | Run the test and inspect restored IDs/associations; do not infer from test presence. |
| Latest-head Build/Smoke evidence invalidated by subsequent changes | Runs on 12ef171beef4533d12efe08f3bdacca5e2e03f36 were cancelled when the branch advanced. | IN_PROGRESS | Wait for terminal Build and Device Smoke results on the final head. |
| Calendar Provider acceptance environment has no writable calendar | Run [39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224) explicitly reports LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR. | BLOCKED | Provision/authorize a writable provider environment; retain the failure until Create/No-op/Update/Delete are actually accepted. |



## Wave 4.12 live blocker checkpoint — 2026-10-19

| Risk / gate | Evidence | Status | Next action |
|---|---|---|---|
| Device Smoke final lanes | Run 39234124429; People and Backup/Restore IN_PROGRESS, Calendar QUEUED at last poll | IN_PROGRESS | Poll to terminal; don't report 7/7 before completion. |
| Exact-SHA checkout assertion | PR #2827 Run 39211789444, Verify exact requested revision SKIPPED | BLOCKED | Authorized target_sha dispatch and inspect checkout/log/artifact evidence. |
| Official Release signing | main android/app/build.gradle.kts sets release signingConfig to debug | BLOCKED | Owner supplies approved keystore/secret setup and independently approved certificate fingerprint; run apksigner and SHA-256. |
| Calendar Provider acceptance | PR #2831 Run 39211706224 failed: no writable provider | BLOCKED | Use authorized writable provider environment for CREATE/NO-OP/UPDATE/DELETE. |
| Canonical release docs absent | 404 for both files on main and Wave 4.11 branch | RESOLVED AS DOCUMENTATION SETUP | Created canonical files in existing PR branch; new head needs fresh CI. |
| Wave 4.11 candidate verification | Build 39234124721 green on d06062fb19c3f3ad54051f3a682f69be4146dd91; Device Smoke not terminal at last poll | IN_PROGRESS | Recheck terminal results and rerun evidence on post-doc head. |


## Wave 4.13 blocker register — 2026-10-19

| Blocker | Evidence | Status | Next action |
|---|---|---|---|
| Current-head Device Smoke | [39235854812](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854812): only Home and Quick Capture terminal SUCCESS at latest poll; SQL Persistence and SQL Migration in progress; People, Backup/Restore and Calendar queued | IN_PROGRESS | Poll to terminal, then refresh after docs head changes. |
| Exact-SHA checkout | [39235854952](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854952) exact-revision step SKIPPED; direct workflow_dispatch not exposed | BLOCKED | Authorized target SHA dispatch; inspect checkout assertion and artifact metadata. |
| Writable Calendar Provider | [39203189292](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203189292), artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) proves Provider package exists but no writable row. Three seeding/control-flow attempts recorded in #2831. | BLOCKED | Authorized alternate writable-provider environment; execute identity-based CREATE → NO-OP → UPDATE → DELETE. |
| Official signing | main Gradle Release variant uses Debug signing; Release APK hash is known but not signer-verified; approved key/fingerprint unavailable through connected tools | BLOCKED | Authorized keystore/secret setup + independently approved fingerprint; run `apksigner verify --verbose --print-certs` and compare. |
| Follow-up Reminder lifecycle | Repository/model/editor and regression tests exist; current PR-triggered Build tests passed, but exact checkout and complete Device Smoke are not proven | IMPLEMENTED_NOT_VERIFIED | Verify all lifecycle, notification, calendar-link and backup tests on final candidate SHA. |
| PDF/font and remaining product UX | No new final-candidate visual/PDF evidence produced in this wave | IMPLEMENTED_NOT_VERIFIED / BLOCKED where external assets or device proof required | Audit license, RTL/embedding/line-wrap and compare actual generated PDF preview; continue other lanes independently. |

Release remains NO-GO.


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


## WAVE 4.16 — 2026-10-19

- **Follow-up Reminder test gap:** Existing projection coverage exercised some title fallback behavior, but repository-level persistence coverage did not isolate title-only edits with stable reminder identity/time and repeated update idempotency. Regression tests were added in PR #2833 commit `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`. Status: IMPLEMENTED_NOT_VERIFIED pending terminal CI.
- **Device Smoke cancellation:** Run [39240952294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952294) is CANCELLED; Calendar lane was cancelled after six successful lanes. It is not a 7/7 pass.
- **Writable Calendar Provider unavailable:** Run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) fails the real-provider acceptance with `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`. API 35 stock emulator has CalendarProvider2 but no writable calendar row. Diagnostic artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078) was uploaded successfully. Status: `BLOCKED_NO_WRITABLE_CALENDAR_PROVIDER`; next authorized alternative is a CI emulator image/configuration or isolated provider environment with a real writable calendar and explicit credentials/configuration, none currently exposed by this interface.
- **Exact-SHA execution:** workflow supports target_sha and assertion, but connected integration has no workflow_dispatch action. Authorized dispatch is required.
- **Official signing:** main still uses Debug signing for Release; approved key/fingerprint are unavailable.


## Wave 4.17 problem update — 2026-10-19

- **Defect fixed, pending CI:** `FollowUpReminderDeliveryService.due` could include a completed FollowUp if its reminder timestamp was due/past. Added a completed-state guard and a regression test in commit `9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b`. Do not mark resolved/verified until the actual post-fix test run passes.
- **CI evidence lag:** Build and Device Smoke runs `39243593152` and `39243593281` target the previous SHA `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7`; their last observed states were nonterminal. They do not validate the post-fix commit.
- **Calendar Provider:** writable provider limitation remains open; previous failed run `39241395995` and unexpired artifact `12182310078` refer to SHA `094c43f1f92de263d26950915b13df7380e69244`.
- **Exact SHA:** authorized `workflow_dispatch` capability unavailable through current integration. Do not treat PR-triggered jobs as satisfying dispatch-only assertion.
- **Signing:** main Release config still uses debug signing; approved release key and independent fingerprint remain an owner dependency.
- Release remains **BLOCKED — RELEASE: NO-GO**.


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


## Wave 4.18 — Calendar Provider UPDATE failure (2026-10-19)

- Problem: Provider acceptance run [39245131251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251) failed in `SystemCalendarBridge.updateProviderEvent` → `CalendarProviderSyncExecutor.execute` → integration acceptance.
- Root cause: native ContentResolver update used an event item URI and an additional `CALENDAR_ID = ?` selection, which the Calendar Provider rejects for item-URI update.
- Fix: commit [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f) queries the exact URI, checks event and calendar identity, and then updates that URI with no selection.
- Status: FIX IMPLEMENTED; validation pending. Provider gate remains BLOCKED until the actual CREATE → NO-OP → UPDATE → DELETE test passes on the qualified revision.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

Open blockers: (1) Exact-SHA dispatch needs authorized Actions write/dispatch access; (2) official release key and independently approved SHA-256 certificate fingerprint are unavailable; (3) current Device Smoke is incomplete; (4) two-writable-calendar migration was not exercised because API 35 exposed one writable calendar. The new acceptance assertions await fresh CI.


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

## Wave 4.42 — Secure Release signing work item

- **Problem:** the prior Release variant selected the Debug signing certificate, so a successful Flutter/Gradle Release build was not proof of production signing.
- **Repair written:** fail-closed production signing in `android/app/build.gradle.kts` (commit `2ab94473ae61b6d1d99565e889116e55d101acb1`); official signing, v2/v3, independent fingerprint and APK SHA checks integrated into existing `.github/workflows/release-closure.yml` (commit `347be0f79890acb92e601f7ed6d6bad2eea6756f`); Build workflow remains exact-SHA/non-official CI (commit `e106bacfb88953230e59a912a7183a16aa0281c0`); legacy ungated release shortcut disabled (commit `556f9912840ec588e509ea1809d4da30677d5896`); ignore rules in `.gitignore` (commit `015edef211ff9a0c45050359ce6e9ff6d5fca15a`).
- **Existing signing decision inspected:** open Draft PR #2824 adds a separate historical-artifact audit; do not rely on its hard-coded historical APK checksum for the current candidate. The current release-closure path verifies the APK built by that same job before artifact upload and product gates.
- **Evidence already checked:** recursive Git tree scan at parent head `443ccc914ae66e22bba4cffa3293d90bc49ad1a9` found no tracked `.jks`, `.keystore`, `key.properties`, or release-signing-properties paths. Root and Android ignore rules cover those classes.
- **Remaining technical validation:** inspect the complete diff; obtain terminal results for Build run [39324997907](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39324997907) (workflow YAML lint and Gradle fail-closed check); execute the official path only from trusted `main` with exact target SHA; inspect logs for `EXACT_TARGET_SHA`, `apksigner` v2/v3 PASS, expected certificate match, APK-file SHA-256, numeric run/job and artifact ID; verify cleanup and that secret-bearing files are absent from artifacts.
- **Owner dependency:** repository Actions Secrets cannot be inspected through the connected tools. The owner must set the five required secrets through GitHub repository settings and supply an independently trusted expected certificate fingerprint. The owner must perform the authorized `workflow_dispatch`; this session has no workflow-dispatch operation.
- **Status:** IMPLEMENTATION WRITTEN / VALIDATION PENDING / OWNER ACTION REQUIRED. Do not claim official signing is operational. Release stays `BLOCKED — RELEASE: NO-GO`.


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

## ARVIN WAVE 5.11 — open problem register (2026-10-20)
1. **P0 — Checklist UI/Storage integration: IN PROGRESS / NOT PROVEN.** Shared component is present in Task Details and Repeat and uses existing TaskRecurrenceRepository/TaskStore. Repeating Task template mutation from the legacy detail callback is guarded. Current-head tests have not run.
2. **P0 — Seven occurrence template migration: NOT RUN.** Need four past snapshots exactly preserved and three current/future snapshots rebuilt from A/B/D with all options unchecked; retain Task ID, occurrence keys, history, completed/cancelled lifecycle and record counts; rerun must be idempotent.
3. **P0 — Current-head CI: BLOCKED / NOT RETURNED.** PR #2833 head `08f610f5442aa9c822e0645458d0ef438f7321ef` has no Actions run/status returned through the current connector. Direct workflow_dispatch is unavailable here. Prior run `39422835185` failed compiling test source on another SHA and has SKIPPED exact-revision verification.
4. **P0 — Android restart and Backup/Restore: NOT RUN.** Need real process PID change, launcher restart, actual app backup and supported restore of the same accepted Task, followed by TaskStore comparison.
5. **P1 — timezone/day-boundary and invalid occurrence keys: NOT PROVEN.** Test local calendar day at midnight and timezone offsets; retain malformed/ambiguous legacy keys pending a documented migration decision.
6. **P1 — Release controls: BLOCKED.** PR #2817, Issue #2102 and PR #1901 remain open until freshly audited; Exact-SHA, official certificate/fingerprint, apksigner verification, extracted APK SHA-256 and artifact/revision binding are not proven. Calendar Provider, notification cold-start, Persian PDF, Golden Flow and P0/P1 regression closure are also open.
7. **P1 — external design references only.** Joplin's scheduling/reset behavior and TimeJot's export/restore approach inform design, not acceptance evidence. No third-party code was copied.
No item above is closed by commits alone. **BLOCKED — RELEASE: NO-GO**.


## Wave 5.14 open problem register — 2026-10-20
| ID | Problem / gate | Status | Evidence / next action |
|---|---|---|---|
| W514-P1 | Exact Build on current source HEAD `b15b0c0...` | BLOCKED / QUEUED | Rerun of existing recovery dispatcher is queued; confirm it dispatches `build.yml` with `target_sha` equal to the live PR head and verify checkout in every required Job. |
| W514-P2 | Analyze on earlier exact SHA `c16d234...` | FAIL (resolved in newer source) | Run 39431510949 found three analyzer infos; fixes are in `c7a60da...`. Run 39431989516 reports Analyze PASS. Confirm on the current head. |
| W514-P3 | Release APK job on `c7a60da...` | FAIL — environment/toolchain | Run 39431989516 failed downloading NDK with `Error on ZipFile unknown archive`. Retry the current-head Release job once; do not alter pinned toolchain absent repeatable evidence. |
| W514-P4 | Seven-occurrence UI acceptance | NOT RUN | Dispatch Arvin Device Smoke on `wave-4-10/follow-up-reminder-contract`; inspect artifact/logs for the seven real keys, before/after snapshots, tick preservation, no duplicates, Task ID and history. |
| W514-P5 | Real Android process restart of the same Task | BLOCKED | Existing script uses force-stop, PID absence, Launcher Activity, new PID and a separate verifier. Run it on current HEAD; compare saved full store snapshot and Task ID. |
| W514-P6 | Official Backup/Restore of the same accepted Task | NOT VERIFIED | Current test injects a file-backed fake service. Use the official in-app export/restore path and a real SAF/provider file; compare full canonical store snapshot and record counts. |
| W514-P7 | Calendar Provider current-head acceptance | NOT VERIFIED | Prior CREATE/NO-OP/UPDATE/DELETE/destination migration pass is from stale PR head commit `6d78b1...`. Run Calendar Provider Acceptance on current branch SHA. |
| W514-P8 | SQL Persistence and Migration current-head acceptance | NOT VERIFIED | Existing smoke jobs passed only on stale checkout; rerun current-head Device Smoke. |
| W514-P9 | Official signing / fingerprint / APK verification | BLOCKED | No official signing env was used. APK `12268044570` SHA-256 is `c7d58816a6b822080e11c4e846c2d60ac2eae81c52573d839769fab128a623b1` but it is Debug-key signed. Verify official APK with `apksigner verify --verbose --print-certs` and trusted fingerprint only after authorized signing. |
| W514-P10 | Notification tap/cold-start, Persian multi-page PDF, Golden Flow, P0/P1 regression suite | NOT VERIFIED | No current-head artifacts. PR #1901 remains OPEN; collect exact-SHA logs and device evidence. |
| W514-P11 | Security/Release closure | BLOCKED | PR #2817 OPEN/DRAFT, Issue #2102 OPEN, PR #1901 OPEN. No merge/tag/release until every required gate passes and owner approval is recorded. |

### Current execution constraint
GitHub read and push were verified. The repository API reports read/push/admin permission; an actual push succeeded. The connector does not expose a direct manual workflow-dispatch operation for Device Smoke or Calendar Provider. The existing PR CI Recovery Dispatcher can dispatch exact-SHA Build only; manual owner action is required to run the other two workflows on the current branch.


### W514-P12 — Current docs HEAD exact Build
The prior source HEAD `b15b0c0...` has Run `39432745217` in QUEUED state. The live PR HEAD then moved to docs-only commit `49f69caf...`; no exact-SHA terminal Build result for that HEAD was confirmed. Recovery Dispatcher job `118663216037` was QUEUED. Do not report either queued run as PASS.


## Wave 5.14 final documentation checkpoint — 2026-10-20 13:47 UTC
Immediately before this documentation-only append, live PR HEAD was `7828b825d8e9fb50b0fe0b41a239c140454b3dd0`; base SHA remained `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Build Run `39432745217` for prior source SHA `b15b0c0...` was QUEUED, and Run `39432344723` for `0b42e588...` was IN PROGRESS. Recovery Dispatcher job `118663216037` was QUEUED; no exact-SHA result for the live HEAD was confirmed. Treat these as separate revisions and do not convert any queued/in-progress run into PASS. The resulting documentation-only HEAD also requires its own exact-SHA Build if exact revision closure is claimed.


### W514-P13 — Stale workflow evidence is an old PR head, not a merge SHA
Run 39416899830 and Run 39416899883 used source commit `6d78b1cba4d0ec829fe26325c9233cd30100d766`, parent `2219b92...`; the Actions API reports `event=pull_request` and `head_branch=wave-4-10/follow-up-reminder-contract`. It was 23 commits behind `266b2a58...` at this correction checkpoint. Continue to classify it as stale evidence, without calling it a synthetic merge candidate.


## Post-run evidence update — 2026-10-20 13:55 UTC
- Build Run [39432745217](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217) completed SUCCESS on exact source target `b15b0c09ec718459b3702e63b2c38701f0291293`. Every Job's `Verify exact requested revision` step passed. Analyze, Test shards 0–5, Debug APK, and Release-variant APK all passed.
- Job IDs: Analyze `118661728356`; Test-0 `118661728445`; Test-1 `118661728687`; Test-2 `118661728428`; Test-3 `118661728375`; Test-4 `118661728381`; Test-5 `118661728619`; APK Debug `118661728193`; APK Release-variant `118661728559`.
- Release-variant artifact: [Run 39432745217 / artifact 12269333049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217/artifacts/12269333049). Downloaded APK SHA-256: `0e13c02e50d1f6871758fe47d82cf4921da15b87b9aabbb6d77970c280b032a2`; uploaded artifact ZIP SHA-256 from the Job log: `c26189789f50da7cec6bd8b086d726ce369b54013f3e260554edf235f29761e6`. This is a non-official Release-variant artifact using Debug signing because `ARVIN_OFFICIAL_RELEASE` was not enabled; do not publish it.
- Important workflow provenance: this Run was dispatched by the default-branch recovery dispatcher, so its workflow definition came from main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`, while its source checkout was exact target `b15b0c0...`. The PR branch's `.github/workflows/build.yml` contains an additional fail-closed signing test and non-official artifact naming not present in the main workflow version. Therefore the branch's own workflow definition still needs a manual branch-selected Build dispatch with `target_sha` equal to the live PR HEAD.
- At this update, Run [39433741028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39433741028) for previous docs HEAD `266b2a58...` was still QUEUED. The Recovery Dispatcher job `118667403566` was QUEUED to scan live PR heads. No terminal Build result for the then-live docs HEAD `bfc499fc...` was confirmed.
- The code/source validation at `b15b0c0...` is PASS; current-head Device Smoke, Calendar Provider, official SAF Backup/Restore, official signing/fingerprint/apksigner, and release approval remain open.


## Wave 5.17 — active problem register refresh (2026-10-20)

| Problem / gate | Status | Required next action |
|---|---|---|
| Exact-SHA Build for PR #2833 HEAD | BLOCKED | Run the existing pr-ci-recovery-dispatcher.yml from authorized default-branch Actions context; require target_sha=036dc407d54aea5fd7f7ed1fa54adf924651647f (or the new HEAD after this docs commit), and verify checkout assertions in all jobs. |
| Device Smoke on current head | BLOCKED | Complete all lanes on one stable SHA; review artifacts and prevent another synchronize event from cancelling the useful run. |
| Seven-Occurrence Checklist/Repeat acceptance | NOT RUN | Create the A/B/C baseline, capture canonical storage, change template to A/B/D, then compare four past vs current/future occurrences and verify no duplicates. |
| Task recurrence/editor/store regression tests | NOT RUN | Run existing focused tests and all six shards; inspect failing logs before changing assertions or behavior. |
| Restart same task | BLOCKED — DEVICE EXECUTION REQUIRED | Use real Android package/launcher activity; record old/new PID and compare all seven occurrence keys and checkmarks. |
| Backup/Restore same task | BLOCKED — DEVICE EXECUTION REQUIRED | Use official app backup/export and supported restore; compare identity mapping, occurrence state, history, links and record counts. |
| Calendar Provider CREATE/NO-OP/UPDATE/transfer/DELETE | BLOCKED | Run on writable provider; record event/calendar IDs, query results and unrelated sentinel preservation. |
| Persian calendar boundary/time-zone tests | NOT RUN | Test both-direction conversions, leap year, Esfand 29/30, month boundaries, local-day transitions, digit/month formatting and recurrence integration. |
| Official signing and APK identity | NOT VERIFIED | Obtain approved release certificate/fingerprint; verify apksigner --verbose --print-certs, APK SHA-256, run/job/artifact provenance, and temporary keystore cleanup. |
| PR #2817 security closure | OPEN / DRAFT | Validate required authorization and telemetry independently; no secret exposure and no release side effects. |
| PR #1901 P0/P1 regressions | OPEN | Reconcile product regressions against current base; real-device screenshots and owner acceptance remain required. |
| Issue #2102 | OPEN | Keep release gate open until P0/P1 evidence and product-owner acceptance are complete. |
| Wave 5.11 seven-commit ancestry | NOT VERIFIED | Enumerate all seven expected SHAs and verify each is in current HEAD ancestry, not merely present in search results. |

No problem in this table is closed by static code inspection or workflow-file presence alone.


## Wave 5.21 — problem register refresh (2026-10-20)

| Problem | Status | Next required evidence |
|---|---|---|
| Current-head Device Smoke | BLOCKED | Owner checks auth and active runs, dispatches `device-smoke.yml` only if safe, waits for all 9 lanes, reads artifacts and proves checkout SHA from logs. |
| Checklist seven-occurrence acceptance | BLOCKED — DEVICE EXECUTION REQUIRED | Real UI creation/edit; capture Task ID, seven actual occurrence keys, A/B/C→A/B/D, four past checklists/ticks, current/future unchecked items, history and record counts. |
| Restart same Task | BLOCKED — DEVICE EXECUTION REQUIRED | Capture Activity/PID, force-stop, confirm process exit, relaunch, capture new PID and compare full canonical snapshot. |
| Backup/Restore same Task | BLOCKED — DEVICE EXECUTION REQUIRED | Use official supported in-app backup/restore; compare identity mapping, occurrences, checklist state, history, links and duplicate counts. |
| Calendar Provider | NOT VERIFIED | Writable provider evidence for CREATE → NO-OP → UPDATE → move target calendar → DELETE; verify Event/Calendar IDs and unrelated sentinel retention. |
| Jalali/local-day/timezone | NOT RUN | Validate both-direction conversion, leap year, month edges, local midnight/timezone changes and occurrence key alignment. |
| Notification tap/cold-start | NOT RUN | Demonstrate correct Task/event opens from cold process and no stale/wrong target. |
| PDF Persian multi-page / Golden Flow / P0-P1 | NOT VERIFIED | Current-head integration artifacts, screenshots/logs and product-owner review. |
| Official APK signature and provenance | NOT VERIFIED | Approved certificate fingerprint, `apksigner verify --verbose --print-certs`, SHA-256 of extracted APK (not ZIP), artifact/run/job linkage, temporary keystore cleanup. |
| Security PR #2817 | OPEN/DRAFT | Complete security and telemetry gates with owner-approved signing policy. |
| Release Issue #2102 | OPEN | Preserve NO-GO until all product and security gates pass. |
| Regression PR #1901 | OPEN / not mergeable | Reconcile P0/P1 and collect current-device evidence. |
| Wave 5.20 | NOT VERIFIED | No issue or commit execution record found in the queried GitHub surfaces. |

Do not mark any row PASS based solely on static inspection or generic CI success.


## Wave 5.21 — Calendar Provider problem status refinement (2026-10-20)

| Problem | Status | Next required evidence |
|---|---|---|
| Calendar Provider lifecycle on historical integration revision | PASS — artifact inspected | Keep historical provenance bound to checkout SHA `2494062c1a1219276a3d97c799d1996990506716` / PR head `6d78b1cba4d0ec829fe26325c9233cd30100d766`; do not transfer this PASS to current HEAD. |
| Calendar Provider lifecycle on final Wave 5.21 HEAD | NOT VERIFIED | Rerun current-head workflow, inspect artifact, prove CREATE → NO-OP → UPDATE → calendar transfer → DELETE and unrelated sentinel retention. |


## Wave 5.22 — Product contract gaps and canonical reference (2026-10-20)

Canonical reference: [ARVIN_PRODUCT_CONCEPTS.md](../product/ARVIN_PRODUCT_CONCEPTS.md). The reference formalizes definitions, invariants and acceptance scenarios; it does not close implementation problems.

| Gap / decision | Status | Required next evidence or decision |
|---|---|---|
| Stable checklist item identity across rename/delete/reorder | NOT VERIFIED / open decision | Decide migration-compatible identity model; tests proving no checked-state transfer |
| Occurrence key and timezone/day-boundary contract | NOT VERIFIED | Canonicalize only after explicit decision; local-midnight, timezone-change and DST tests |
| Missed occurrence behavior | Open product decision | Product-owner approval plus tests for missed/skipped/completed separation |
| Follow-up date precedence and lifecycle | NOT VERIFIED / open decision | Define precedence for Task.followUpDate and FollowUp.nextFollowUp; test multiple actions and history |
| Notification delivery, Snooze and tap/cold-start routing | NOT VERIFIED | Real-device permission, scheduling, delivery, tap destination, restart and deleted-target evidence |
| Full backup/restore of SQL data, occurrence history and relationships | NOT VERIFIED | Restore same task and compare IDs, snapshots, taxonomy and linked data in target environment |
| Calendar Provider on current candidate SHA | NOT VERIFIED | Current-SHA artifact showing CREATE/NO-OP/UPDATE/migration/DELETE and unrelated-event preservation |
| Search/filters/widgets/attachments/accessibility full coverage | NOT VERIFIED | Feature-by-feature source audit and acceptance evidence; do not infer presence from README or model fields |

Do not mark any row PASS because the concept is documented or a model class exists. Release remains **BLOCKED — RELEASE: NO-GO**.