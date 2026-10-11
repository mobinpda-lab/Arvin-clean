# Arvin Decision Log

## 2026-10-11 — Restore rollback must include taxonomy catalogs
- Finding: both Home restore and BackupPage merged Category/Tag catalogs after Task/Project/Calendar/settings writes, but rollback omitted catalog cleanup. A failure injected after catalog merge could leave incoming catalog entries behind after other stores were rolled back.
- Decision: snapshot pre-restore Category/Tag catalogs and, on rollback, remove only incoming catalog entries that were absent from the snapshot. Restore the previous Tasks before deleting newly introduced tags so old Task-tag relations remain authoritative.
- Implementation checkpoint: [commit 05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354).
- Added failure injection after the catalog stage in Home and BackupPage orchestration tests. Exact-head CI is pending; do not mark validated until results complete.
- PR record: https://github.com/mobinpda-lab/Arvin-clean/pull/2585#issuecomment-6106998968

## 2026-10-11 — Dependency order
- Prove restore transaction/failure behavior first; physical-device/file-provider round-trip second; Calendar event identity/no-duplicate acceptance third.
- Parallel work: Issue #2580 may proceed as read-only audit and documentation-only fixes that do not change restore semantics.
- Evidence: https://github.com/mobinpda-lab/Arvin-clean/pull/2585#issuecomment-6106883617

## Canonical taxonomy
- Product/domain concepts are Project, Category and Tag.
- Persian UI term for Category is «دسته». Group is not a fourth domain entity; display-only grouping and generic technical group terms are distinct.
- Do not infer a database Category-to-Project foreign key from semantic wording alone.
- Reference: https://github.com/mobinpda-lab/Arvin-clean/issues/2582 and https://github.com/mobinpda-lab/Arvin-clean/issues/2580

## Data and architecture guards
- Fix existing paths; do not add a parallel store, backup format, restore engine, taxonomy, or Task system.
- Preserve Task identity, Project membership, Category/Tag catalogs and assignments, settings, repeat/occurrence history, and Calendar-link metadata.
- Missing/null legacy Project fields preserve local Projects; an explicit empty list means restore an empty Project catalog.
- Never claim a gate is done without evidence. CI/emulator success is necessary but not physical-device acceptance.

## 2026-10-11 — Repeat Tracking Level Architecture (RTLC)
- Problem: basic Repeat is sufficient for routines, while important recurring commitments need stronger status/history/progress and reporting; separate systems would duplicate Task behavior and storage.
- Decision: add/use `NORMAL` and `TRACKING` as behavior/UX/report levels of existing Repeat. User-facing Persian selector: «نوع پیگیری» → «عادی» (default) / «مهم و قابل پیگیری».
- Architecture: keep `Task → Repeat Definition → Occurrence projection → Execution State → History`; no Loan/Debt/Habit/Payment/Contract/Customer Follow-up entity, parallel store/database/repository/engine, or copied Task per repeat.
- Protected invariants: existing Task identity/model, repeat engine, storage and backup compatibility; past history immutable; future schedule/settings adjustable; occurrence checklist state independent.
- Existing-code audit: `RecurrenceTrackingLevel` already exists in `lib/models/recurrence.dart`, is serialized in `RecurrenceRule`, and defaults to normal when older JSON omits it. `Task` already serializes `occurrenceHistory` and `checklistOccurrences`. Improve existing paths; do not duplicate them.
- Compatibility guard: Repeat tracking level is not the same as Follow-up. Do not conflate `recurrence.trackingLevel` with `followUpEnabled`.
- Remaining product integration/validation: Create/Edit Task after Repeat, Task Detail, light Home cue, Report Center filter/metrics, immutable history/checklist behavior, backup/restore round-trip, exact-head tests/build, screenshots and physical-device acceptance.
- Decision record: [Issue #2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605); related repeat lifecycle [#2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254), Task editor [#2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593).
- Status: ACCEPTED product direction; implementation IN PROGRESS; not release-approved.


## 2026-10-11 — Gate root Task.note split pending owner decision
- **Problem:** PR #2595 adds a new root `Task.note` field and changes Task JSON, TaskStore known keys and backup/restore expectations. Current main Task has `description` but no root `note`; Notebook and FollowUp note semantics already exist.
- **Decision:** Do not merge or propagate the new root field until the product owner explicitly approves the distinction between Task Description and Task Note and its legacy-data/backup mapping. This is a safety hold, not rejection of the form UX.
- **Reason:** The Command v8 does not authorize this root data-contract change, and silent semantic splitting could mis-handle existing content.
- **Impact:** #2595 and overlapping #2602 remain Draft; compare and consolidate the Task Editor/time-picker path without introducing an unapproved schema change. Keep tests intact.
- **Status:** BLOCKED pending owner decision. GitHub review records: [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110326453), [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6110326886).


## 2026-10-11 — Owner decision: retain Description only
- **Decision:** The owner selected Option 1. The canonical root Task model retains the existing `description` field only; do not add a separate root `Task.note` field.
- **Implications:** Remove/revert the unapproved root `Task.note` addition from the Task Editor implementation lane. Do not introduce a new root-note storage key, serialization contract, migration, or backup/restore field. Preserve existing scoped note concepts where they already belong (for example Notebook and FollowUp); this decision does not remove those features.
- **Validation:** Verify legacy Task JSON remains readable, TaskStore known-key handling is correct, and existing backup/restore behavior and tests remain intact. Do not weaken tests. Keep overlapping PRs Draft until the canonical patch and exact-head checks are reconciled.
- **Source of truth:** Owner decision in conversation on 2026-10-11; communicate to PR #2595 and #2602 and revalidate live GitHub state.

## OWNER DECISION — 2026-10-11 (supersedes earlier decision gate)
- Owner selected Option 1: keep the existing root `Task.description` as the only root Task text field; do not add a root `Task.note`.
- This resolves the prior owner-decision gate. Scoped `FollowUp.note` and Notebook note/checklist concepts remain unchanged; this decision does not authorize deleting or migrating those scoped fields.
- Required implementation on the canonical Task-form lane: remove only the newly introduced root `Task.note` from the Task model, JSON serialization/deserialization, TaskStore known-key handling, editor UI/state, and backup/restore test changes. Preserve legacy payload safety and existing Description values; add/retain regression tests proving legacy JSON and backup/restore round-trip still work without a second root field.
- PR #2595 must remain Draft until this correction and exact-head Analyze, all test shards, Debug/Release APK and relevant device smoke are verified. PR #2602 must not reintroduce the root field and its previously failing test shards must be fixed at root cause; never weaken assertions.
- Current execution result: decision resolved and documented; implementation patch not yet applied or validated in this step. No merge, main write, APK build, or release occurred.

## 2026-10-11 — Calendar sync field scope and Done/Archive boundary
- **Decision:** Only Task title, date, time, description, recurrence details and reminder sync with the phone calendar.
- **Non-trigger:** marking a Task Done or moving it to Archive alone must not trigger calendar synchronization.
- **Reason/impact:** keep phone calendar as a projection of the canonical Task, avoid unrelated event updates and duplicates, and preserve stable Task↔external-event identity.
- **Acceptance:** update the same linked event for eligible field edits; no title/date matching; automated regression plus provider/device acceptance.
- **Record:** [#2248 comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2248#issuecomment-6111402411).
- **Status:** owner contract recorded; implementation and device acceptance not yet proven.

## 2026-10-11 — Reports icon placement, not a new Report Center
- **Decision:** reuse the existing Reports icon and existing Report Center; place the icon in the bottom navigation row.
- **Forbidden:** creating a second reports page, renderer, projection, store or engine.
- **Status:** owner clarification recorded at [#2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385#issuecomment-6111105369); code/visual acceptance pending.

## 2026-10-11 — Notebook toolbar and interactive checklist defect
- **Problem:** numbered/tick/checklist labels clip in RTL; checklist shows literal `[ ]` and tapping does not toggle.
- **Decision:** repair the existing Notebook UI and canonical checklist path; preserve Task.checklist/Notebook storage and persistence. Do not add a parallel checklist representation.
- **Acceptance:** labels visible at supported phone widths; real compact checkbox toggles and persists after save/reopen; tests plus installed Android validation.
- **Records:** [#850](https://github.com/mobinpda-lab/Arvin-clean/issues/850#issuecomment-6111078741), [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111079224).
- **Status:** defect registered; not yet fixed or accepted.

## 2026-10-11 — Pastel visual language expansion
- **Decision:** extend the existing Home/Calendar pastel language across existing Arvin surfaces, especially Notebook, Report Center, Next Action, forms and settings.
- **Implementation boundary:** use the existing semantic `ArvinColors`, shared light/dark ThemeData card/input styling and current widgets. Do not add another design system, store, screen, entity or projection.
- **Status semantics:** completed=soft green, overdue=soft red, follow-up=soft amber, planned=soft blue; Notebook notes use soft lavender and checklists soft green.
- **Protected:** Task remains source of truth; preserve RTL/VazirHarf, existing Report Center and Notebook repository, recurrence/tracking/calendar behavior and backup/restore.
- **Evidence:** [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607); acceptance ledger [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111556987).
- **Status:** implementation staged on a draft PR; exact-head CI/device validation pending. Notebook inline checklist `[ ]` non-toggle issue remains a separate functional defect.
