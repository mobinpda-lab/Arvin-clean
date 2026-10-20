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



## ARVIN WAVE 5.10 — partial implementation record (2026-10-20)

Status: **IN PROGRESS — RELEASE: NO-GO**. This entry records code changes without claiming validation that has not run.

- Live PR identified by repository search: #2833, Draft, branch `fix/follow-up-record-authority-20261019`; repository is `mobinpda-lab/Arvin-clean`. Repository metadata reports push permission, but this connector exposes no direct workflow-dispatch operation and no local Flutter/Android execution environment was used.
- New code commit: `7c4b2c5b0d64aa0a9852f650e1ddb24cd6712361` adds an occurrence-specific Checklist editor to `lib/task_recurrence_page.dart`, using existing `TaskRecurrenceRepository.checklistForOccurrence` and `setChecklistForOccurrence` against canonical TaskStore.
- Follow-up correction: `776e672ff93ed1825c1f621a121aafb5f8afb13d` corrects the checklist marker parsing expression.
- UI test commit: `80154c45b8be73739acc8d172bb3b38899fb3884` adds a widget test for per-occurrence checklist isolation and persistence; `708fa0840a11e5f71cc751414d8166cc612a8100` adjusts the test to reselect the occurrence after remount.
- Latest source/test commits have **not** been validated by `flutter analyze`, Flutter tests, CI, Android process restart, or Android Backup/Restore. Do not infer PASS from commits existing.
- The existing generic detail callback `_checklistChangedFromDetail` in `lib/main.dart` still writes `target.checklist`; the new per-occurrence editor is available in the Repeat editor. Full replacement of the generic detail callback with an occurrence-aware detail flow remains open.
- Seven-occurrence A/B/C → A/B/D acceptance, preservation of past snapshots and lifecycle history, no-duplicate repeat, timezone/invalid-key migration, real Android restart, Backup/Restore, Exact-SHA, official signing, Calendar Provider, Notification cold-start, PDF and Golden Flow remain **NOT PROVEN / NOT RUN**.
- External pattern check: Joplin Repeating To-Dos plugin provides a separate recurrence configuration and scheduling model, but the originally referenced BeatLink repository is archived; no code was copied. The currently listed Joplin plugin page documents its recurrence UI and next-date scheduling. TimeJot Help explicitly distinguishes device backup from recommended daily export/import, including attachment caveats; TimeJot changelog mentions timezone-related fixes. These are design references only, not Arvin test evidence.
- References: https://joplinapp.org/plugins/plugin/com.github.TheScriptingGuy.joplin-plugin-repeating-todos/ ; https://github.com/BeatLink/Joplin-Repeating-Todos-Plugin ; https://timejot.app/help/ ; https://timejot.app/changelog/ .
- Run evidence previously inspected: Build run `39416899830` had Analyze, test shards 0–5, Debug APK and Release test APK jobs successful, but each `Verify exact requested revision` step was skipped. Device Smoke run `39416899883` had cancelled Task Lifecycle and Checklist Evolution lanes and was not a full pass. This evidence is historical and does not validate the new commits.
- Release decision remains **BLOCKED — RELEASE: NO-GO**. No merge, tag, or release was performed.
