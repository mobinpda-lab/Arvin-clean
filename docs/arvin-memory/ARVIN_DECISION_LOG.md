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
