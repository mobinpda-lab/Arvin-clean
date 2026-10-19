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
