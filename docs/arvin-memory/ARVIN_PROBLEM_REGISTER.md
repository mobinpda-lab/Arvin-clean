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