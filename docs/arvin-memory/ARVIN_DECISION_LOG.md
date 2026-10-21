
## 2026-10-21 — Wave 5.48 Exact-SHA recovery and product preservation

- **Decision:** continue PR #2868 as the CI recovery path while it remains OPEN and mergeable; do not merge it in this wave. CI fix commit: `52781290a159f1836ebe23d719a8856408c3e52f`; product/docs are separate.
- **Exact-SHA contract:** validate the full 40-hex target before checkout in Preflight, verify the preflight checkout, then compare each real Build/Device runner's `git rev-parse HEAD` with its expected SHA immediately after checkout. Non-Dispatch events log `NOT_APPLICABLE_NON_DISPATCH`, never a Dispatch PASS.
- **Concurrency:** retain literal `cancel-in-progress: true`. Dispatch groups include `github.run_id`, separating independent manual runs; this does not guarantee every pending workflow survives GitHub queue replacement semantics.
- **Product preservation:** restore all nine real smoke scenarios and [the existing Restart/PID script](https://github.com/mobinpda-lab/Arvin-clean/blob/4214101dd9a93542783fb97eb0d4a5cb34643950/scripts/ci/run-device-smoke.sh). Do not weaken or remove `test/ci_concurrency_contract_test.dart` assertions.
- **Parser dependency:** contract-test lanes explicitly set up Ruby 3.3 through `ruby/setup-ruby@v1`; the Dart contract checks the version and parses workflows using Psych. Parser and tests remain unverified until the new run is terminal.
- **Execution boundary:** exact-SHA Dispatch was not sent because the connected tool surface lacks a dispatch action. Keep that gate BLOCKED.
- **Release:** `BLOCKED — RELEASE: NO-GO`.


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

## Wave 4.42 — Decision: isolate production Android signing (2026-10-20)

- **Decision:** keep ordinary PR/push CI usable without production secrets, but make the official path explicit and fail-closed. The normal Release-variant CI APK is development-only and is named `arvin-release-dev-debug-signed-apk`; it must not be promoted as official.
- **Security boundary:** the existing `Arvin Release Closure` is the sole production signing/publication path. It only runs from trusted `main` (automatic successful main Device Smoke, or manual dispatch from main with exact `target_sha` matching the current main tip); it verifies the checked-out SHA before exposing secrets. The normal Build workflow has no production secrets and remains the exact-SHA CI path. Open Draft PR #2824 was inspected; its separate historical-artifact audit is not a replacement for verifying the APK inside the live release build.
- **Signing contract:** Gradle reads credentials only from job environment variables; the release-closure job decodes the keystore to runner temp with restrictive permissions; no keystore/password/private key is committed or uploaded. Official APK acceptance requires successful `apksigner verify --verbose --print-certs`, explicit v2/v3 true evidence, and equality between the extracted certificate SHA-256 and independently authorized `ARVIN_RELEASE_CERT_SHA256`. The unsafe tag-only `release.yml` shortcut was disabled so it cannot bypass the canonical release gate.
- **Owner action:** configure repository Actions Secrets `ARVIN_RELEASE_KEYSTORE_BASE64`, `ARVIN_RELEASE_STORE_PASSWORD`, `ARVIN_RELEASE_KEY_ALIAS`, `ARVIN_RELEASE_KEY_PASSWORD`, and `ARVIN_RELEASE_CERT_SHA256` through GitHub settings. Do not paste secrets into chat, PRs, issues, or commits. Confirm the fingerprint from an independently trusted owner-controlled source.
- **Validation is pending:** a tracked-path scan at parent head `443ccc914ae66e22bba4cffa3293d90bc49ad1a9` found no keystore/key-properties paths. Build run [39324997907](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39324997907) is still PENDING on parent head `e9ee7370e11c3e41f2696a0a2a4146cbb7455fcd`; its YAML lint and fail-closed Gradle check have no terminal results yet. No workflow dispatch, official APK, certificate fingerprint, v2/v3 verification output, APK checksum, or artifact ID has been produced. Do not state that signing is configured or operational until a trusted run proves it.
- **Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.


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

## ARVIN WAVE 5.11 — architecture decision (2026-10-20)
Decision: recurring Task checklist state must be accessed through the existing `TaskRecurrenceRepository` and canonical `TaskStore`; do not add a parallel repository/storage or let the Task Details page write the recurring Task's generic `checklist` template.
- Introduced `lib/widgets/occurrence_checklist_editor.dart` as one shared UI component for both Repeat and Task Details. It requires an explicit selected occurrence key before reading/toggling/saving; no occurrence date is inferred from an unrelated due date.
- Task Details now renders the shared occurrence editor for repeating Tasks. Repeat uses the same component. `_checklistChangedFromDetail` now returns without changing `target.checklist` when the Task has recurrence. The generic template remains editable through the normal task-edit flow, whose recurrence-template policy belongs to `TaskEditApplyService.apply`.
- Code commits: `8f1efd1de21c0954fa14bd66ce5a487814dec891`, `2780e8902a4fddf444c2135f537b821e32d3e73a`, `7eb93299cb425597aab1ebb227e898c32793b327`, `ba206df93f57846179291be81efbffdc0f6b0023`, `202639c132a50ea3b0025b82b68562e395c55f61`; test commits `f8fabc8aba08aa54ce146851e17853326880c794`, `08f610f5442aa9c822e0645458d0ef438f7321ef`.
- Status: architecture is implemented in source but NOT PROVEN until current-head Flutter tests and device checks run. The shared editor's available-occurrence list and invalid/legacy-key boundaries still need dedicated tests.
- Joplin reference decision: retain the conceptual separation between recurrence configuration and occurrence scheduling only. Do not adopt Joplin's completion behavior that reopens a Task and resets subtasks; it conflicts with Arvin's requirement that each occurrence's checklist and lifecycle state remain independent. No third-party code copied.
- TimeJot reference decision: distinguish Android device backup from an app-supported export that can be explicitly imported and verified. Neither reference substitutes for Arvin's own same-task Backup/Restore acceptance.
- Release remains **BLOCKED — RELEASE: NO-GO** pending empirical evidence.

### Branch ancestry reconciliation — 2026-10-20
The live PR #2833 head and the listed Wave 5.10 commits are on divergent histories; do not treat Wave 5.10 code commits as part of the PR branch merely because their SHAs exist. Compare evidence: base `7c4b2c5b0d64aa0a9852f650e1ddb24cd6712361` versus head `9adbb87b59fedfa0013ee9082c33f69f08c124c7` = `diverged`, ahead 176 / behind 1; base `708fa0840a11e5f71cc751414d8166cc612a8100` versus that head = `diverged`, ahead 176 / behind 4. Decision: integrate the required behavior in the current PR branch, not by assuming the other branch's commits are inherited. The Wave 5.11 shared editor is the current branch implementation; the code/test candidate before final documentation-only commits was `08f610f5442aa9c822e0645458d0ef438f7321ef`. Read live PR metadata again before dispatching; it remains unvalidated until Actions and device evidence run on the final head.


## Wave 5.14 decisions — 2026-10-20
### D-W514-01 — Occurrence Checklist state is canonical data
Occurrence checklist writes must return the updated canonical Task to the mounted Detail page and Home state. A later generic Task edit must not serialize an older in-memory Task over the occurrence snapshots. The selected occurrence must reload after Task replacement so the visible checklist matches the canonical store. This is a focused change to the existing TaskStore / TaskRecurrenceRepository path; no parallel repository or storage engine was added.

### D-W514-02 — Acceptance must use the real occurrence UI
The Android scenario now chooses a reminder date four local calendar days in the past, creates the daily Task through the UI, selects all seven generated occurrence keys, saves different checklist ticks through the occurrence editor, then changes the shared template through the UI. The four past snapshots are expected to retain their exact ticks; today and future are expected to contain A/B/D unchecked. Lifecycle history is preserved and checked independently. This scenario remains NOT RUN until Device Smoke executes on the current HEAD.

### D-W514-03 — Restart proof compares identity and complete store snapshot
The existing device-smoke script already force-stops the Android package, checks that the prior PID disappears, relaunches the actual Launcher Activity, and runs a separate restart-verifier integration test. Wave 5.14 now persists the accepted Task ID and complete canonical-store JSON snapshot outside TaskStore, then compares it after restart. The verifier fixture prefix was corrected to match the creator. This is still NOT VERIFIED until the workflow runs on the current HEAD.

### D-W514-04 — Backup/Restore remains a separate gate
The Checklist Evolution integration test uses an injected file-backed backup service and temporary file. That proves a test harness path only; it does not prove official SAF/provider Backup/Restore of the same accepted Task. Do not promote this result to PASS. Keep release blocked until the supported in-app backup file is produced, restored through the real provider path, and compared against the same canonical Task snapshot.

### D-W514-05 — External recurrence/backup patterns are references, not code to copy
- Joplin Repeating Todos plugin: https://joplinapp.org/plugins/plugin/com.github.TheScriptingGuy.joplin-plugin-repeating-todos/
- Plugin source and license: https://github.com/TheScriptingGuy/Joplin-Repeating-Todos-Plugin
- TimeJot help: https://timejot.app/help/
- TimeJot changelog: https://timejot.app/changelog/
No external code was copied. Joplin's recurrence/subtask completion behavior is not imported wholesale because Arvin must preserve independent occurrence checklist snapshots and lifecycle history. TimeJot's distinction between device-level backup and user-driven export/import is used only as a design reminder; Arvin's own supported backup format and restore path remain authoritative.

### D-W514-06 — Release remains NO-GO
No Merge, Tag, official APK publication, or security-PR promotion. The Release APK artifact from Run 39431510949 is Debug-key signed, and no trusted official fingerprint or apksigner evidence exists. NDK archive failure in Run 39431989516 is treated as environment/toolchain evidence, not a reason to change the pinned NDK without further reproduction.


### D-W514-07 — Do not conflate queued and completed Build evidence
Build Run `39432745217` targets `b15b0c0...` and was QUEUED. The subsequent docs-only commit moved PR HEAD to `49f69caf...`; no result for that new HEAD was confirmed at this checkpoint. The recovery dispatcher must select the live PR HEAD and its Build must pass the exact-checkout gate before the current revision can be marked validated.


## Wave 5.14 final documentation checkpoint — 2026-10-20 13:47 UTC
Immediately before this documentation-only append, live PR HEAD was `7828b825d8e9fb50b0fe0b41a239c140454b3dd0`; base SHA remained `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Build Run `39432745217` for prior source SHA `b15b0c0...` was QUEUED, and Run `39432344723` for `0b42e588...` was IN PROGRESS. Recovery Dispatcher job `118663216037` was QUEUED; no exact-SHA result for the live HEAD was confirmed. Treat these as separate revisions and do not convert any queued/in-progress run into PASS. The resulting documentation-only HEAD also requires its own exact-SHA Build if exact revision closure is claimed.


### D-W514-08 — Preserve accurate workflow revision identity
The old Device Smoke / Build run used PR source commit `6d78b1cba4d0ec829fe26325c9233cd30100d766` on the PR branch. GitHub API metadata shows a single parent, so do not label it a synthetic merge commit. It was 23 commits behind source HEAD `266b2a58...` at this correction checkpoint. The acceptance limitation is unchanged: the run does not validate current source HEAD.


## Post-run evidence update — 2026-10-20 13:55 UTC
- Build Run [39432745217](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217) completed SUCCESS on exact source target `b15b0c09ec718459b3702e63b2c38701f0291293`. Every Job's `Verify exact requested revision` step passed. Analyze, Test shards 0–5, Debug APK, and Release-variant APK all passed.
- Job IDs: Analyze `118661728356`; Test-0 `118661728445`; Test-1 `118661728687`; Test-2 `118661728428`; Test-3 `118661728375`; Test-4 `118661728381`; Test-5 `118661728619`; APK Debug `118661728193`; APK Release-variant `118661728559`.
- Release-variant artifact: [Run 39432745217 / artifact 12269333049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217/artifacts/12269333049). Downloaded APK SHA-256: `0e13c02e50d1f6871758fe47d82cf4921da15b87b9aabbb6d77970c280b032a2`; uploaded artifact ZIP SHA-256 from the Job log: `c26189789f50da7cec6bd8b086d726ce369b54013f3e260554edf235f29761e6`. This is a non-official Release-variant artifact using Debug signing because `ARVIN_OFFICIAL_RELEASE` was not enabled; do not publish it.
- Important workflow provenance: this Run was dispatched by the default-branch recovery dispatcher, so its workflow definition came from main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`, while its source checkout was exact target `b15b0c0...`. The PR branch's `.github/workflows/build.yml` contains an additional fail-closed signing test and non-official artifact naming not present in the main workflow version. Therefore the branch's own workflow definition still needs a manual branch-selected Build dispatch with `target_sha` equal to the live PR HEAD.
- At this update, Run [39433741028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39433741028) for previous docs HEAD `266b2a58...` was still QUEUED. The Recovery Dispatcher job `118667403566` was QUEUED to scan live PR heads. No terminal Build result for the then-live docs HEAD `bfc499fc...` was confirmed.
- The code/source validation at `b15b0c0...` is PASS; current-head Device Smoke, Calendar Provider, official SAF Backup/Restore, official signing/fingerprint/apksigner, and release approval remain open.


## Wave 5.17 — decision log (2026-10-20)

1. **No release promotion:** PR #2833 remains draft/unmerged; PR #2817 remains draft/unmerged; PR #1901 remains open/unmerged; Issue #2102 remains open. Decision: BLOCKED — RELEASE: NO-GO.
2. **Do not claim exact-head CI from stale runs:** the most recent PR branch Build/Device Smoke evidence found by branch query is on 6d78b1cba4d0ec829fe26325c9233cd30100d766, not current HEAD 036dc407d54aea5fd7f7ed1fa54adf924651647f.
3. **Workflow route:** normal PR synchronize triggers Build and Device Smoke; both use cancel-in-progress. Branch-filtered queued/in-progress checks were empty immediately before this single docs commit, so one atomic documentation update was safer than five sequential commits. The Build exact-SHA assertion is skipped for normal pull_request runs; exact target dispatch remains required for the Exact-SHA gate.
4. **No speculative product code changes:** no reproducible failing test or local Flutter/ADB execution environment was available. A code patch without a reproduced defect would be guesswork and could jeopardize occurrence identity/history.
5. **External references are design-only:** Joplin's reset-on-completion model differs from Arvin's per-occurrence state contract; TimeJot illustrates the distinction between device backup and export/import; Persian Calendar is GPL-3.0 and no source code was copied.
6. **Wave 5.11 history:** 938bb05cf7e6337ad244a3cca16e482a242aea22 is verified as an ancestor of current HEAD by compare metadata, but the full seven-commit chain was not independently enumerated. Do not mark the seven-commit requirement PASS.
7. **No merge, tag or release.** Required next evidence is exact-SHA Build with all Analyze/test shards/APK jobs, full Device Smoke, seven-occurrence storage comparison, same-task Restart and Backup/Restore, writable Calendar Provider lifecycle, official signing verification, and final canonical-document re-read.


## Wave 5.21 — decision log (2026-10-20)

1. Re-read live PR #2833 before editing: HEAD `3ce1d46b80d4842890b6759583dbf685deaeafde`, base SHA `49910e585ee73afcf56a7f8d927b9c69e763c5c5`, parent `036dc407d54aea5fd7f7ed1fa54adf924651647f`; PR remains OPEN/DRAFT/UNMERGED.
2. Reuse exact-source Build Run [39445690981](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39445690981); do not repeat Build on the same SHA. All 9 jobs verified exact target and succeeded.
3. Do not attribute Device Smoke Run #39416899883 to current HEAD; it was cancelled and used older SHA `6d78b1cba4d0ec829fe26325c9233cd30100d766`. No current-head Device Smoke run was found, and no direct dispatch operation is exposed by the connected GitHub tool surface.
4. No Wave 5.20 run/issue/commit record was found; status is “no execution record found”, not a claim that no human action occurred elsewhere.
5. No code patch was made because there is no reproducible current-head Device Smoke failure log. Do not weaken tests or guess at a root cause.
6. Do not claim seven-occurrence UI acceptance, same-task Restart, real Backup/Restore, writable Calendar Provider lifecycle, official signing, or release readiness without empirical evidence.
7. No merge, tag, or release. **BLOCKED — RELEASE: NO-GO.**


## Wave 5.21 — Calendar Provider evidence refinement (2026-10-20)

- The previously green Calendar Provider run #39416899861 was not accepted blindly: artifact #12262580173 was downloaded and inspected. Its result file says `PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; logs record NO-OP preserving event ID 3, UPDATE preserving event ID 3, migration from calendar 1 to 2, DELETE removing the target, and unrelated sentinel rows retained.
- Artifact provenance is checkout SHA `2494062c1a1219276a3d97c799d1996990506716`, PR head `6d78b1cba4d0ec829fe26325c9233cd30100d766`. This is valid historical integration evidence, not proof for the current Wave 5.21 head.
- Current-head Device Smoke, Checklist seven-occurrence UI, Restart, real Backup/Restore and official signing remain open. No merge, tag or release.


## Wave 5.22 — Canonical product-concept governance decision (2026-10-20)

- **Decision:** establish `docs/product/ARVIN_PRODUCT_CONCEPTS.md` as the canonical vocabulary and behavioral reference for Arvin, linked here: [ARVIN_PRODUCT_CONCEPTS.md](../product/ARVIN_PRODUCT_CONCEPTS.md).
- **Scope:** documentation and product governance only. No runtime behavior, schema, recurrence/checklist logic, notification scheduling, calendar behavior, backup/restore implementation, or signing configuration was changed.
- **Required governance:** future product PRs and code reviews must consult the concept reference; a proposal that changes behavior must record rationale, affected data, compatibility/migration/rollback, decision owner, and acceptance criteria. Historical decisions remain intact.
- **Open decisions intentionally not guessed:** stable checklist item IDs and edit semantics; occurrence-key timezone canonicalization; missed-occurrence policy; follow-up date precedence; notification standalone/Snooze/tap lifecycle; restore replace/merge and ID conflict policy; reopen transitions; calendar partial-failure policy; and whether independent subtasks/multi-step tasks are needed.
- **Status distinction:** document establishment is not implementation acceptance and does not satisfy release gates. Final commit/read-back status must be taken from the final GitHub state.
- Release remains **BLOCKED — RELEASE: NO-GO**. No merge, tag or release.

## Wave 5.35 — Live evidence checkpoint (2026-10-20)

- Live PR #2833: head `16c567290ec8fd41c56c323613a41fbc92c39d5f`, base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`; OPEN / DRAFT / UNMERGED.
- Exact-target run query returned zero runs. The available GitHub tool surface has no workflow-dispatch action; no new Build or Device Smoke dispatch was executed. Missing execution must not be called PASS.
- Build [39416899830](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899830) passed 9/9 jobs against synthetic merge checkout `2494062c1a1219276a3d97c799d1996990506716`; exact-revision step skipped. This is not exact-head evidence for `16c567290ec8fd41c56c323613a41fbc92c39d5f`.
- Device Smoke [39416899883](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899883) had seven successful scenarios and two cancelled scenarios. Logs prove cancellation at the smoke step but not its initiator; cause remains NOT VERIFIED.
- Decision: keep release gate closed. Real Task Checklist evolution, restart PID proof, same-Task backup/restore, extracted APK hash and trusted signing fingerprint remain BLOCKED/NOT VERIFIED. No merge, tag, or release.


## Wave 5.36 — Decision log (2026-10-20)

- **Decision:** repair both CI entry points before retrying exact-SHA acceptance. Build now requires the target SHA on manual dispatch and verifies actual checkout in both job families; Device Smoke now accepts the same required input and checks out/verifies it in every scenario.
- **Evidence:** [Build workflow commit](https://github.com/mobinpda-lab/Arvin-clean/commit/4b0f91620e0d865ea7e3cb029dc5ca57ac41b950); [Device Smoke workflow commit](https://github.com/mobinpda-lab/Arvin-clean/commit/d4c90a461c6b876f246f62d33817d93cebfdbe17). Both files were read back from GitHub.
- **Execution boundary:** no dispatch was performed because the available connected GitHub tool surface has no workflow-dispatch action. The exact-target run query returned zero. Therefore no claim is made that the modified workflows have executed or passed.
- **Release gate:** keep PR #2833 OPEN / DRAFT / UNMERGED; no merge, official tag, or release. Same-Task Checklist, restart, backup/restore, official certificate fingerprint, PDF, notifications and P0/P1 acceptance remain open until direct evidence is attached to a fixed SHA.


## WAVE 5.53 — evidence update (2026-10-21)

- Live default branch `main`: `d9fb7a247037762216662a20fb32028ecc8a0f6b`. CI PR #2868 remains OPEN / DRAFT / UNMERGED; head branch `fix/exact-sha-dispatch-contract-20261021`, head SHA `315923c1cbf6bfb8f661949a4fca18e304ae51ea`, base `main` at `d9fb7a247037762216662a20fb32028ecc8a0f6b`. Product PR #2833 remains OPEN / DRAFT / UNMERGED; head branch `wave-4-10/follow-up-reminder-contract`, head SHA last reported by PR metadata `992699f87715db3642dfbc56ab3def32800e5104`. No PR was merged.
- Historical Build [39543365234](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39543365234), Job [119035976068](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39543365234/job/119035976068), failed in `test/device_smoke_workflow_contract_test.dart`: test `Build and Device Smoke enforce exact-SHA controls per runner job`, assertion at line 263 expected `officialReleaseRequested` in `android/app/build.gradle.kts`; 196 tests passed and 1 failed. The command was `flutter test --total-shards 6 --shard-index 4`. This is a missing-security-control assertion in the checked-out run revision, not a reason to weaken the test.
- The current CI PR head's `android/app/build.gradle.kts` contains an explicit `ARVIN_OFFICIAL_RELEASE=true` gate, nonblank validation for store file/password/key alias/key password, a dedicated `arvinProduction` signing config for explicit official builds, and a Debug signing path for non-production builds. This code-level inspection is not independent proof that any APK is officially signed; no approved certificate fingerprint has been verified.
- Current Build run [39547647963](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39547647963), associated with CI PR head `315923c1cbf6bfb8f661949a4fca18e304ae51ea`, finished successfully: Analyze, `test-0` through `test-5`, Debug Build and Release Build all passed. This was a pull_request event, not an Exact-SHA Dispatch.
- Current Device Smoke run [39547648453](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39547648453) had successful main emulator steps for `home`, `quick-capture`, `sql-persistence`, `sql-migration`, `backup-restore`, `people`, and `calendar`. The main steps for `task-lifecycle` and `checklist-evolution` were `SKIPPED`; their acceptance remains BLOCKED. Calendar smoke does not prove independent Calendar Provider lifecycle acceptance.
- Exact-SHA Dispatch remains `BLOCKED — DISPATCH UNAVAILABLE`: the connected GitHub tools expose no workflow_dispatch action. PR CI must not be represented as exact-SHA dispatch evidence. APK signature verification and independent certificate fingerprint matching remain `NOT VERIFIED`. Release remains `BLOCKED — RELEASE: NO-GO`.
- Product capability rule: code existence and successful unit/device smoke are distinct from acceptance. Preserve Task/Repeat/Occurrence, Checklist history, SQL persistence/migration, Restart, Backup/Restore, notifications, Calendar Provider, Persian PDF/RTL, Golden Flow and P0/P1 regressions; do not infer removal from missing evidence. Unknown acceptance and product trade-offs remain **نیازمند تصمیم مبین**.
