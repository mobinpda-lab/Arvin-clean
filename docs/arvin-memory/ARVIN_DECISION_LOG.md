## 2026-10-14 — Exact-head CI evidence must prove checkout

- **Problem:** A normal `pull_request` run may report the PR head in metadata while checking out GitHub's synthetic merge ref. Using metadata alone can incorrectly suppress exact-head recovery.
- **Decision:** Only accept a recovery `workflow_dispatch` run as exact-head evidence when its run head SHA and declared target SHA both match the current PR head; the Build's quality and APK jobs must assert the actual checked-out SHA.
- **Reason:** Run metadata, requested target and actual checkout are distinct evidence. All must align before declaring exact-head validation.
- **Impact:** A green merge-ref run or historical run cannot mask missing validation of the exact PR head.
- **Status:** Implemented in PR #2699 commit `af3e3724ae08a956bb91fcbd82174ec23a2d2066`; final-head CI and operational dispatcher acceptance pending.

---

## 2026-10-14 — Exact-head CI recovery dispatcher

- **Problem:** Some current PR heads have no visible Arvin Build run/checks, so older green runs cannot validate current changes.
- **Decision:** Add a scheduled/manual recovery dispatcher as a backstop, with explicit `target_sha` input, pinned checkout, run-name evidence and a checkout assertion in all Build lanes. The dispatcher must exclude forks, never merge/release, avoid duplicate active runs, rate-limit recent failures, and require the latest exact-head result.
- **Reason:** A branch ref can move between discovery and dispatch. Branch-only dispatch is insufficient evidence that the intended SHA was tested.
- **Impact:** Makes recovery possible without depending solely on the ordinary PR event, while preserving the product release gates.
- **Status:** Implemented in PR #2699 but **not yet validated**. Missing CI on PR #2695 remains unexplained; this is mitigation, not proven root-cause closure.

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

## 2026-10-14 — Run recovery from the default workflow definition

- **Problem:** A recovery dispatch sent to a PR branch may use a stale `build.yml` without the `target_sha` input or checkout assertion. A dispatch sent to the default branch has `run.head_sha` for the workflow ref, not the target code SHA; treating those as identical is incorrect. Shared concurrency can also cancel separate recovery runs.
- **Decision:** Dispatch `build.yml` on the repository default branch, pass the target commit as `target_sha`, pin checkout to that SHA, and assert `git rev-parse HEAD == target_sha` in every quality/APK lane. Identify a target run by its explicit target-SHA run name and successful asserted jobs; do not infer target identity from workflow-run `head_sha`. Use per-target concurrency.
- **Reason:** The workflow definition/input schema must be dependable, and metadata SHA is not the same as the checked-out source SHA.
- **Impact:** More reliable exact-head evidence and no cancellation between different targets.
- **Status:** Implemented in PR #2699; exact-head CI and post-merge operational acceptance pending.


## 2026-10-15 — SUPERSEDING OWNER DECISION: legacy Task reminder migration (Option B)
- **Problem:** Previous notes left the migration rule unresolved and conflicted between preserving the singular legacy field and migrating into the canonical collection.
- **Decision:** Owner explicitly selected Option B: deterministic one-time, idempotent migration of non-null Task.reminderDate into canonical TaskReminder.
- **Owner data context:** The current app database is reported empty and Arvin has not yet been populated with real user data. This does not prove all backups, fixtures or other installations are empty.
- **Safeguards:** stable ID legacy-task-reminder; persisted migration version; preserve date/time; do not infer all-day from midnight; preserve Calendar identity task-reminder:<taskId> and scheduler key; preserve existing independent reminders; test JSON, SQL, backup/restore, rollback and no-duplicate behavior.
- **Status:** Candidate implementation is on this PR branch. Exact-head CI and complete acceptance remain pending. Release NO-GO.
- **Evidence:** https://github.com/mobinpda-lab/Arvin-clean/issues/2654#issuecomment-6178475884


## 2026-10-15 — Decision record: PR #2725 validated

Both required exact-head gates for `ba2306cfc66ad982f8e8ab73b838a4a8d6ed6b55` are terminal `success`: Build `38752957837` and Device Smoke `38752957813` (all six lanes). Proceed with the authorized squash merge of PR #2725 only while its head remains unchanged. After confirmed merge, create `feat/person-reports-followup-issue-2683` from fresh `main` and begin Issue #2683. Do not conflate CI success with physical-device release acceptance.



## 2026-10-19 — Wave 4.11 Follow-up Reminder persistence contract

- **Decision:** Keep the existing `FollowUp.reminderDate` as the Follow-up edit contract while mirroring a timed Follow-up into the existing `Task.taskReminders` collection with stable `followUpId`. Do not create a second reminder model, table, or scheduler.
- **Stable identity:** New linked reminders use `follow-up-reminder:<followUpId>`; edits preserve the existing linked reminder ID and update its title/time. Clearing the Follow-up reminder time removes only reminders explicitly linked by `followUpId`.
- **Title policy:** Use the Follow-up title; if blank, use `پیگیری — <Task title>`; if both are blank, use `پیگیری`. Follow-up result text is not used as title.
- **Notification compatibility:** Generic TaskReminder scheduling skips linked mirrors; existing Follow-up projection remains the delivery path so the established Follow-up delivery identity is retained and duplicate notifications are avoided by design.
- **Persistence/migration:** TaskStore's canonical Task JSON envelope already persists TaskReminder objects, and the existing SQL schema is version 6. No new schema migration was introduced. This is not yet proof of end-to-end SQLite reload or Backup/Restore correctness.
- **Evidence:** implementation commits `2989741558cdc834787f38751469e91788cf42e7`, `e83229579d36108786f11393ca622de85c13b693`, `f6d34abe1b435530e72cc3ef0c8e90746dda4e90`, `dba7a12b55edb1ffc7981f5526a8c7c4330640c6`; regression tests commit `b4b14a2497c460b2bd8da1711b7a8663cb1c42d6`. All are **IMPLEMENTED_NOT_VERIFIED** until focused and CI tests pass.
- **Release decision:** retain `BLOCKED — RELEASE: NO-GO`.



## 2026-10-19 — Idempotent writes and Calendar projection identity

- Decision: Repeated FollowUp saves with the same stable Follow-up ID are reconciled in place, not appended. This prevents duplicate history rows and makes reminder reconciliation idempotent.
- Decision: Keep the established Calendar ID followup:<taskId>:<followUpId> for linked Follow-up reminders. The persisted TaskReminder is a mirror for independent durable identity, while Calendar projection skips the mirror to prevent duplicate events and preserve existing external links.
- Verification status: implementation commits 937361328d56bae7b1831e8366f570658826cb15 and a26189099c60985f88ea2500b55ae17c89af8ee3; tests c24e7b4dfe81313b4c45a95960cc47e3e5458755 and 1d820bf3e6f6eb4d5889a2bc4c2835c6e09d5f42. All remain IMPLEMENTED_NOT_VERIFIED until current-head CI passes.
- Backup/Restore: Added a SQL + canonical backup round-trip test in commit 2253ef62f404ef064b4bf85d40a16cbf880ed554. This is not evidence of success until executed.
- Open contract: Notification rescheduling is wired through the existing coordinator, but full outbound Calendar Provider create/no-op/update/delete acceptance remains blocked; do not infer it from projection unit tests.



## 2026-10-19 — Wave 4.12 release evidence and canonical docs

- Decision: Keep PR #2833 OPEN/DRAFT; no merge/tag/release until every required gate passes on one fixed SHA.
- Verified evidence: Build Run 39234124721 succeeded 9/9 on head d06062fb19c3f3ad54051f3a682f69be4146dd91. The debug and release build artifacts list that exact source SHA. This does not validate official release signing.
- Non-terminal evidence: Device Smoke Run 39234124429 had People and Backup/Restore IN_PROGRESS and Calendar QUEUED at last poll; do not count as 7/7.
- Exact-SHA remains blocked because Run 39211789444 skips Verify exact requested revision. Official signing remains blocked because release Gradle uses debug signing and no approved fingerprint is available. Calendar Provider acceptance remains blocked by Run 39211706224 (no writable provider).
- Canonical files ARVIN_GO_RELEASE_FINAL_STATUS.md and ARVIN_REQUIREMENT_TRACEABILITY_MATRIX.md were missing on main and Wave 4.11 branch, so created them on the existing PR branch (commits e2989ffa6b585368bfc4effaf4647ec53a792c46 and 0525f14a93f8d548e6b84cb70daa5d7e1177e6ed). No parallel numbered docs created.
- Because documentation commits advance the branch, CI evidence must be checked again on the resulting head.


## Wave 4.13 decisions — 2026-10-19

1. **Preserve evidence boundaries.** Build [39235854952](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854952) is 9/9 SUCCESS for a PR-triggered integration run, but its exact-revision assertion is SKIPPED. Record build success, not exact-head acceptance.
2. **Calendar Provider diagnosis is environmental at the current evidence level.** Artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) proves the Calendar Provider package exists on API 35, while no writable calendar row is discoverable. Do not classify this as an Arvin product-code defect and do not call it accepted.
3. **Stop speculative provider seeding after the documented three failed attempts.** The connected tools expose no alternate authorized writable-provider environment or direct workflow dispatch. Keep the Provider gate BLOCKED until such an environment exists.
4. **Signing stays fail-closed.** Release artifact SHA-256 `6c6e38199c9d29ae26a4ff33e45082882ff05d0ee0bd8d276889148e78f2fabd` is recorded only for file identity. Since Gradle release signing is Debug and no approved key/fingerprint is available, it is not an official release candidate.
5. **Any documentation commit creates a new candidate SHA.** Rerun the required gates on that resulting head; do not transfer prior results. No merge/tag/release.


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


## 2026-10-19 — Wave 4.16 Follow-up Reminder regression coverage

- Existing Follow-up repository/projection architecture remains authoritative; no parallel Reminder store, scheduler, or Calendar sync engine was introduced.
- Added repository-level tests for both blank-title fallback cases and title-only edit identity/time stability with repeated update idempotency in PR #2833, commit `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`.
- Validation state at this checkpoint: Build run [39243365218](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365218) was IN_PROGRESS; Device Smoke [39243365263](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365263) was queued/starting. Do not claim tests passed before terminal results.
- Calendar Provider is an environment blocker, not product PASS: [Run 39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) reports no writable calendar on the stock API 35 emulator and publishes diagnostics. Preserve CREATE → NO-OP → UPDATE → DELETE criteria.
- Exact-SHA requires authorized workflow_dispatch with checked-out HEAD assertion; PR-triggered runs with skipped assertions are insufficient.
- Official Release signing requires owner-authorized credentials and independent certificate fingerprint approval. Release remains NO-GO.


## Wave 4.17 decision update — 2026-10-19

- Continue on existing PR #2833 and its current branch; do not create a duplicate PR or merge.
- A real lifecycle defect was found: due notification calculation did not exclude completed FollowUps even though the alarm planner and future projection do. Implemented the smallest safe fix and regression test in commit `9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b`; wait for current-head CI before considering it verified.
- Do not infer final Build/Device Smoke from prior SHA. Runs `39243593152` and `39243593281` target `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7` and were nonterminal at last inspection.
- Calendar Provider acceptance, authorized exact-SHA dispatch, and official Release signing remain independent mandatory blockers.
- Decision unchanged: **BLOCKED — RELEASE: NO-GO**.


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


## Wave 4.18 — Calendar Provider UPDATE correction (2026-10-19)

Decision: preserve the existing Android Calendar Provider boundary and fix the item-URI update rather than adding another provider/scheduler. The previous acceptance run [39245131251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251) failed during UPDATE because the native update supplied a selection alongside an event item URI. Commit [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f) now queries and validates the exact event's calendar ownership before updating that event URI without an extra selection. This is IMPLEMENTED_NOT_VERIFIED pending fresh CI and real CREATE → NO-OP → UPDATE → DELETE acceptance. No merge, tag or release; NO-GO remains.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

Decision: Provider lifecycle is PASS only for the single writable-calendar path on the tested merge candidate. Do not promote release because 7/7 Device Smoke, Exact-SHA and official signing are not established.
