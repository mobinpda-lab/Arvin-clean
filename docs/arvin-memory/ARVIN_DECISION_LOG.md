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

## 2026-10-11 — Persian-first multi-filter Report Center
- Decision: report date selection uses Arvin's existing Jalali date picker; Gregorian calendar UI is not acceptable for the Persian RTL product.
- Decision: Report Center filters use compact expandable roll boxes with visible selected counts and retained selections while collapsed.
- Decision: Project, Category, Tag, status, and Tracking filters support multi-select. Choices within one group are OR'ed; active groups combine with AND.
- Decision: Note filters consume canonical Task records marked as Notebook items and support title/description search, note/checklist kind, created/updated date range, plus the existing Category/Tag/Project filters. No parallel Note or Report store is allowed.
- Boundary: a separate Note-to-another-Task relation does not currently exist in the canonical model; do not invent it. External phone-calendar-only events are not confirmed as Report Center inputs.
- Status: implementation branch feat/calendar-pastel-compact-cards-20261011; exact-head CI, device visual acceptance, and owner approval pending.


## Owner command authority — 2026-10-11
- The owner supplied ARVIN AUTONOMOUS DELIVERY & EVOLUTION COMMAND v8.0 and explicitly declared it to replace all prior execution commands.
- Preserve the exact command in ARVIN_AUTONOMOUS_DELIVERY_EVOLUTION_COMMAND_V8.md on this branch. It must be reconciled into the canonical main documentation hierarchy; do not treat AMPOP v5 or older v49-era continuation commands as silently replacing owner v8.
- Execution policy remains evidence-led: no merge/release or architecture/data change without the appropriate gate; audit the current repository before each change.
- Audit reconciliation: Issue #2593/PR #2594 explicitly accepts an optional Task Note distinct from Description. Current PR #2595 source does not yet expose the root Task Note despite stale PR-body claims. This is an implementation/description mismatch, not proof of an unapproved product direction.


## 2026-10-12 — Documentation authority and release checkpoint
- **Problem:** The required memory files and v8 command are not present on current `main`; the existing drafts #2600/#2608 are stale and overlap.
- **Decision:** Consolidate the memory package on a branch created from exact current main SHA `cea76673d871ce52b84dacf69f355c4282802baa`; do not write directly to main or merge stale branches blindly.
- **Reason:** Keep GitHub as project brain while preserving an auditable review path.
- **Impact:** No application code, schema, migration, backup format or release artifact changed.
- **Status:** In progress; PR and exact-head validation still required.


## 2026-10-12 — Owner decision: preserve independent nextFollowUp and reminderDate
- **Problem:** Follow-up scheduling and system notification time were being collapsed by a proposed editor compatibility mapping.
- **Decision:** `nextFollowUp` is the next planned action/review time; `reminderDate` is the system notification time. They are independent. Never copy one into the other as a fallback, clear either to simplify UI, or treat one as proof the other exists.
- **Calendar:** project a FollowUp reminder only when explicit `reminderDate` exists; display policy must not mutate the canonical fields. Keep next-follow-up scheduling independently available.
- **Reports:** future follow-ups and reminders must be filterable independently.
- **Status:** ACCEPTED. Implementation correction staged in PR #2636; exact-head validation pending.
- **References:** [PR #2642](https://github.com/mobinpda-lab/Arvin-clean/pull/2642), [PR #2636](https://github.com/mobinpda-lab/Arvin-clean/pull/2636), [PR #2631](https://github.com/mobinpda-lab/Arvin-clean/pull/2631).



## AUTHORITATIVE LIVE CHECKPOINT — 2026-10-12 — PR #2647 merged; exact-head Build + Device Smoke green

This entry supersedes older status wording where it conflicts. Older entries remain historical audit records.

- **Implementation merged:** PR [#2647](https://github.com/mobinpda-lab/Arvin-clean/pull/2647) merged by squash at commit [18117aea2fa07b5a9a02e6021f41ff4faae120cc](https://github.com/mobinpda-lab/Arvin-clean/commit/18117aea2fa07b5a9a02e6021f41ff4faae120cc). Tested PR head: 7f44964b4ce6eab005d756a564dc912e40c70bb3.
- **Build evidence:** [Run 38291907900](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38291907900) completed SUCCESS on the exact PR head: Analyze, Android V2 audit, test shards 0–5, Debug APK, Release APK and APK verification passed.
- **Device Smoke evidence:** [Run 38292607493](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38292607493) completed SUCCESS on the same exact PR head. All six lanes passed: Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore. These are Android emulator/CI results, not physical-device acceptance.
- **Implemented:** Full Task Form no longer invents a follow-up timestamp when enabling the follow-up flag and preserves an existing legacy Task.followUpDate; Quick Entry now has compact «دارای پیگیری» and «دارای چک‌لیست» controls with Task-owned Roll Boxes. nextFollowUp and reminderDate remain independent per merged owner decision [PR #2643](https://github.com/mobinpda-lab/Arvin-clean/pull/2643).
- **Exact evidence boundary:** the green runs validate the PR head, not the resulting merge commit. The latest workflow lookup did not yet return post-merge Build/Device Smoke runs for merge commit 18117aea2fa07b5a9a02e6021f41ff4faae120cc; do not describe post-merge mainline CI as green until that exact commit is checked.
- **Remaining blockers:** PR [#2636](https://github.com/mobinpda-lab/Arvin-clean/pull/2636) remains OPEN and reports mergeable=false; do not merge it until nextFollowUp/reminderDate normalization and clearing paths are reconciled to the owner contract and legacy/JSON/persistence/backup round-trip tests are added. Physical Android device Calendar CREATE-then-UPDATE/no-duplicate proof, real file-provider Backup/Restore with Calendar-link integrity, installed-app golden flow, Persian RTL/compact-screen visual acceptance, and explicit owner release approval remain unverified.
- **Release: NO-GO.** Passing emulator CI and merging PR #2647 do not constitute final release approval.
- **Next action:** verify post-merge CI for commit 18117aea2fa07b5a9a02e6021f41ff4faae120cc; continue safe compatibility work without merging #2636; preserve issue #2102 as the release gate until all outstanding evidence is collected.


### Decision implementation status
- **Problem:** Follow-up activation could invent a timestamp; Quick Entry lacked compact Task-owned follow-up/checklist controls.
- **Decision:** Enabling the flag alone does not generate a time; preserve an existing legacy Task.followUpDate; keep nextFollowUp (next planned action/review) and reminderDate (notification time) independent; checklist and follow-ups remain attached to the canonical Task.
- **Reason:** Avoid confusing a next action with a notification and prevent timestamp fabrication or parallel storage.
- **Impact:** Task Editor and Quick Entry behavior updated with regression tests.
- **Status:** IMPLEMENTATION MERGED in PR #2647 at 18117aea2fa07b5a9a02e6021f41ff4faae120cc; exact PR-head Build and six emulator smoke lanes passed. Post-merge exact-SHA CI and physical-device acceptance remain pending.
