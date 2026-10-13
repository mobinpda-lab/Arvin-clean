## 2026-10-13 — Follow-up flag is compatibility-only

- **Problem:** creating or completing a FollowUp still toggled `Task.followUpEnabled`, retaining the removed flag concept in active write paths.
- **Decision:** new FollowUp writes and editor saves must not derive or toggle `followUpEnabled`. Existing stored values remain readable/preserved during compatibility migration.
- **Reason:** every Task is inherently eligible for follow-up; FollowUp records represent actual follow-up history.
- **Impact:** TaskStore, FollowUpRepository and Task Editor were updated. Focused regression tests were added; exact-head validation is pending.
- **Status:** implemented in source, validation pending.

---

## 2026-10-13 — Owner decision: configurable all-day reminder notification time

- **Problem:** 09:00 is the preferred default, not a hard-coded time that every user must accept.
- **Decision:** all-day/date-only Task reminders notify at **09:00 local time by default**; users may change the time in Settings. Timed Task reminders and FollowUp reminders retain their own times.
- **Persistence/runtime:** reuse `AppSettingsService` and SharedPreferences; persist the selected minute-of-day, include it in portable settings backup/restore, default missing legacy values to 540 minutes, and apply the preference in alarm planning and background delivery. Changing the preference requests rescheduling.
- **Architecture:** no parallel settings store, reminder store, scheduler or notification model. Calendar entries remain all-day/date-only.
- **Validation finding:** exact-head CI found `taskReminderId` uninitialized in two `FollowUpReminderCandidate` constructors; fixed by initializing it to null for legacy/default constructors in commit `a8263d5119c16c69db7fd282d53820504650b57e`.
- **Status:** policy and implementation path are recorded; new exact-head CI is required. No release claim until validation passes.

---

## 2026-10-13 — Owner decision: all-day reminder time is configurable

- **Product decision:** all-day/date-only Task reminder notifications default to **09:00 local time**, but the user can change the time in Settings under «یادآورها و اعلان‌ها».
- **Persistence:** store the chosen minute-of-day through the existing `AppSettingsService` / SharedPreferences foundation. Legacy installs and backups missing this key use 09:00. Portable backup/restore carries the preference and validates it as a local time from 00:00 through 23:59.
- **Runtime contract:** both alarm planning and background delivery must load and apply the saved preference. Changing it must reschedule the existing alarm. Calendar projection remains all-day; timed reminders and FollowUp reminders remain unchanged.
- **Architecture:** no second settings store, reminder store, scheduler, or notification model.
- **Validation status:** implementation and tests added on the safe integration branch; exact-head CI and Android runtime acceptance are pending. Do not merge/release until validated.

---

## 2026-10-13 — Owner decision: all-day reminder notification time APPROVED

- **Initial owner decision (amended 2026-10-13):** 09:00 local time is the default for date-only/all-day Task reminders; users can change it in Settings.
- **Scope:** this selects notification delivery time only; Calendar representation remains all-day/date-only. Timed reminders keep their selected time.
- **Status:** product-policy ambiguity is resolved. This does not imply CI, Calendar Provider Acceptance, device smoke, physical-device validation, backup/restore, or release gates have passed.
- **Next:** re-query PR #2666's live head after this memory write and verify required validation on that exact SHA. Keep PR Draft and release NO-GO until gates pass.

---

## 2026-10-13 — TaskReminder projection, sync, and delivery integration

- **Decision:** New Task reminders use `task-reminder-item:<taskId>:<reminderId>` for external identity. The migrated legacy item keeps `task-reminder:<taskId>`; after migration the legacy field is not projected separately. Inbound edit/delete resolves the exact item by stable identity and does not rename/delete the Task or neighboring reminders.
- **Decision:** Notification delivery keys are independent per reminder. The migrated legacy item retains the previous `task:<taskId>@<timestamp>` delivery identity; new items use their own stable identity. Date-only reminders remain all-day in Calendar and use a separate notification-time helper.
- **Persistence fix:** Task JSON always serializes `taskReminders`, `nextReminderSequence`, and `legacyReminderMigrationCompleted`; `TaskStore._canonicalEnvelope` treats them as known canonical keys. This prevents a previously persisted collection from being reintroduced when the current collection is empty.
- **Impact:** Updated projection, outbound/inbound Calendar reconciliation, alarm planning, delivery projection/state, Task Editor and TaskEditApplyService; added tests for same-time distinct reminders, stable IDs, inbound edit/delete isolation, SQL/backup round-trip and deletion tombstone.
- **Owner decision resolved (2026-10-13):** 09:00 local time is the default for all-day/date-only reminder notifications, and users can change it in Settings. Timed reminders retain their selected time.
- **Status:** Draft PR #2666 only. Exact-head Build/Calendar acceptance remain unverified; Device Smoke is skipped. Do not merge/release.

---
## 2026-10-13 — Safe integration slice: canonical TaskReminder and migration marker

- **Problem:** canonical Task supported only singular `reminderDate`; the approved multiple-reminder design requires a stable-ID collection and idempotent representation of the legacy Task reminder.
- **Decision:** add `TaskReminder` with `id/taskId/title/date/status/createdAt/updatedAt/isAllDay/sequence`; decode the legacy Task reminder into deterministic ID `legacy-task-reminder:<taskId>`; retain the legacy timestamp and persist `legacyReminderMigrationCompleted` as a tombstone so removal is not silently recreated on later decode.
- **Reason:** preserve old-reader/rollback compatibility while making the canonical Task JSON representation idempotent.
- **Impact:** model/JSON slice only plus focused regression tests; no separate store or schema migration.
- **Status:** committed on safe integration PR #2666; exact-head Build is pending at the time of the code checkpoint. Calendar projection suppression/identity reconciliation and persistence/restore tests remain open; do not merge or release yet.

---
## 2026-10-13 — Approved reminder migration contract takes precedence

- **Problem:** the implementation design in PR #2655 and `ARVIN_MULTIPLE_REMINDERS_DESIGN.md` retains legacy `Task.reminderDate` without migrating it, while the approved architecture decision requires a deterministic, idempotent migration into exactly one TaskReminder.
- **Decision:** the owner-approved architecture decision is authoritative. Reconcile the lower-level design and implementation to migrate legacy Task reminders without dropping the legacy value before durable validation and without emitting both legacy and new Calendar/notification identities.
- **Reason:** avoid design drift, missed reminders and duplicate Calendar events while keeping Task as the canonical source of truth.
- **Impact:** PR #2655 must not be merged as-is. Implement migration and regression tests on a fresh branch from current main; retain independent `nextFollowUp` and per-FollowUp `reminderDate` semantics.
- **Current owner-data context:** owner reports the current database is empty; this is not evidence that old backups, fixtures or legacy payloads do not exist.
- **Status:** decision recorded; code reconciliation and validation pending.

---
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


## 2026-10-12 — Owner decision: Calendar reminder vs. in-app follow-up (binding product rule)
- **Decision:** Follow-up (nextFollowUp) and reminder (reminderDate) are two independent concepts and must never be merged, inferred from one another, copied, or cleared as a side effect of editing or displaying either.
- **Phone calendar rule:** Only an explicitly configured reminder (reminderDate) may be projected to the phone calendar, clearly titled «یادآوری». A follow-up date/time alone must never create a phone-calendar reminder or OS notification.
- **Arvin Home rule:** Follow-up date/time (nextFollowUp) is shown as «پیگیری» in Arvin's Home / next-action presentation. It is not titled «یادآوری» and does not itself trigger a phone notification.
- **Independent edits:** Changing follow-up must not change reminder; changing reminder must not change follow-up. Clearing either field must not clear the other.
- **Calendar identity:** When a reminder is edited, update its existing linked event using canonical Task identity and the stored external event identity; do not create duplicates. Imported calendar events must not echo back as newly created reminders.
- **Examples:** Task «خرید فرش اتاق»: follow-up = 15 Mehr at 17:00 → shown in Arvin Home as «پیگیری»; reminder = 15 Mehr at 09:00 → phone calendar entry titled «یادآوری». Either can exist without the other.
- **Acceptance tests required:** follow-up-only creates no phone-calendar reminder/OS notification; reminder-only appears as «یادآوری» in phone calendar; both can coexist with different dates/times; editing/clearing either leaves the other unchanged through UI, JSON, SQL persistence and backup/restore; editing a linked reminder updates the same external event without duplicates; imported events do not loop back.
- **Status:** Owner-approved product rule. Documentation decision is being recorded; implementation and exact-head/device acceptance are not implied by this decision and remain subject to evidence.


## 2026-10-12 — Owner clarification: one-time initial reminder from Next Follow-up
- **Supersedes the conflicting sentence above** that says a follow-up date/time alone must never create a reminder. The two concepts remain independent after initialization, but the owner has specified a one-time creation bridge.
- **Concepts must remain distinct:** (1) follow-up-enabled Task, (2) a recorded Follow-up/action, (3) Next Follow-up (`nextFollowUp`), (4) reminder (`reminderDate`), and (5) the date/time belonging to a recorded Follow-up. The recorded Follow-up date/time is not the Next Follow-up date/time.
- **Initial state:** Next Follow-up is empty until the user explicitly activates/sets it with the “Next Follow-up” action.
- **One-time bridge:** when Next Follow-up is set for the first time, create an initial reminder at the same date/time. If Next Follow-up is date-only, the initial reminder is an all-day reminder.
- **After initialization, independence is binding:** changing Next Follow-up must not move or rewrite the reminder; deleting Next Follow-up must not delete the reminder; deleting/editing the reminder must not change Next Follow-up. A Task may have a reminder without any Next Follow-up. Users can independently create, edit and delete each concept; each may be date-and-time or date-only where applicable.
- **Presentation/projection:** Next Follow-up is shown in Arvin as «پیگیری بعدی»/next action. The reminder is shown/projected as «یادآوری» and uses the existing calendar-link identity for in-place updates; do not create duplicates or imported-event echo loops.
- **Example:** «خرید فرش اتاق»: first setting Next Follow-up to 15 Mehr, 17:00 creates an initial reminder at 15 Mehr, 17:00. If Next Follow-up later changes to 20 Mehr, 10:00, the reminder remains at 15 Mehr, 17:00. Deleting Next Follow-up leaves that reminder intact.
- **Still needs owner clarification:** if a reminder already exists when Next Follow-up is first activated, should the existing reminder be preserved, or should no additional reminder be created? Do not overwrite or duplicate an existing reminder until this edge case is decided.
- **Acceptance tests required:** initial date+time creates matching reminder once; date-only creates all-day reminder; later date/time edits do not update reminder; deleting Next Follow-up leaves reminder; reminder-only Task works; editing/deleting reminder leaves Next Follow-up intact; recorded Follow-up date/time remains separate; all behavior survives UI, JSON, SQL persistence and backup/restore; calendar edits update the same linked event with no duplicates/echo loops.
- **Status:** owner product clarification recorded; implementation/code audit, tests, exact-head CI and physical-device acceptance remain unverified. This decision does not authorize claiming the feature complete.


## 2026-10-13 — Follow-up/reminder compatibility audit

- **Problem:** the UI contract requires date-only Next Follow-up to create an all-day initial reminder, but FollowUp model stores only nullable DateTime fields and the Calendar projection does not mark FollowUp reminders all-day.
- **Decision:** preserve independent `nextFollowUp` and `reminderDate`; do not infer all-day from midnight and do not auto-overwrite/duplicate a pre-existing reminder. The exact behavior when a reminder already exists at first activation remains pending explicit owner decision.
- **Reason:** midnight can represent a real timed reminder; legacy JSON/backup values do not preserve intent separately. A dedicated all-day marker (separately for Next Follow-up and Reminder) is the candidate for forward data, subject to compatibility design and owner approval before implementation.
- **Impact:** model/editor/projection and canonical Task JSON/SQL-envelope/backup-restore regression tests are required. Platform Calendar bridge already accepts all-day state; the gap is in source semantics and projection.
- **Status:** audit recorded; implementation blocked on the two product/data decisions; release NO-GO.


## 2026-10-13 — Owner clarification: reminder is independent; creation is opt-in
- Reminder is independent of previous/next follow-up and of the recorded Follow-up history. Setting Next Follow-up does not itself create a reminder; create one only if the user explicitly wants/chooses it.
- When the user chooses to create a reminder for Next Follow-up, prefill reminder title from the follow-up-enabled Task title and date/time from Next Follow-up. User may independently edit reminder title/date/time afterward.
- User-requested additional reminders are allowed. Never silently overwrite an existing reminder or create duplicates. Later changes/deletion of Next Follow-up must not mutate reminders; reminder edit/delete must not mutate Next Follow-up.
- Date-only/all-day intent is independent for Next Follow-up and reminder; midnight is not a safe inference for legacy values.
- Implementation and regression validation remain outstanding; this is a product-contract clarification, not proof of shipped behavior.


## 2026-10-13 — Owner decision: multiple follow-ups and reminders per Task
- One Task can contain multiple recorded Follow-up history entries and multiple independent reminders.
- Each reminder must have its own editable title and schedule and must be independently editable/deletable without mutating other reminders or Follow-up history. Each Follow-up history entry remains distinct.
- Next Follow-up is the next-action value, separate from recorded Follow-up history and reminders. Reminder creation is opt-in; when explicitly requested for Next Follow-up, Task title and Next Follow-up date/time are only initial values.
- Implementation, storage/backup round-trip and Calendar identity/no-duplicate validation remain required; this records product intent, not shipped behavior.


## 2026-10-13 — Proposed canonical model for multiple independent Task reminders (NOT APPROVED)
- Problem: the canonical Task has one nullable `reminderDate`; each FollowUp has one nullable `reminderDate`. This does not represent an arbitrary collection of Task-level reminders independent of FollowUp history.
- Proposal for review only: embed a `TaskReminder` collection in canonical Task JSON, each with stable immutable ID, editable title, schedule and explicit date-only/all-day metadata. Reuse existing notification and Calendar engines; no parallel reminder store.
- Compatibility gate: preserve legacy singular fields deliberately; specify decode/edit/export/restore behavior and duplicate prevention before code changes. Keep `nextFollowUp` separate; only seed a reminder on explicit user opt-in. Never infer all-day from midnight.
- Status: **PROPOSED / OWNER-ARCHITECTURE APPROVAL REQUIRED / NO CODE CHANGE**. See Issue #2654 and PR #2652.

## 2026-10-13 — Owner-approved multiple Task reminders and safe migration
- **Problem:** one Task-level `reminderDate` cannot represent multiple independent reminders; naive integration risks legacy-data loss and duplicate Calendar events.
- **Decision:** owner approved the multiple-reminder product model and requested safe migration. Each Task may contain multiple stable-ID TaskReminders with independent title/schedule/status and created/updated metadata. Keep `nextFollowUp`, Task reminders, and per-FollowUp `reminderDate` separate.
- **Migration contract:** migrate legacy Task `reminderDate` to exactly one reminder using deterministic identity and idempotent retry; preserve old data until durable validation; never infer all-day from midnight; preserve Calendar identity so legacy/new projections do not duplicate events.
- **Architecture:** canonical Task JSON/SQL and existing Calendar/notification/backup systems remain the source of truth. No parallel store/scheduler. Internal Follow-up Action projection remains display-only and excluded from outbound sync and reminder notifications.
- **Status:** OWNER DECISION APPROVED; implementation, tests, physical-device validation and release approval remain outstanding. Supersedes earlier entries that described architecture approval as pending. See `ARVIN_MULTIPLE_REMINDER_ARCHITECTURE_DECISION.md`, Issue #2654 and PR #2655.
