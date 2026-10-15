## 2026-10-14 — CI recovery learning

- A queued workflow is not a pass. Evidence must name the exact commit SHA and reach a terminal result.
- Workflow dispatch should carry an explicit target SHA, and every build lane should assert the checkout equals that SHA. The run name should expose the requested target for audit.
- When a branch moves between PR discovery and dispatch, the dispatcher must not mistake a run on the new branch head for a build of the earlier requested commit, or vice versa.
- Historical success must not mask a newer failure for the same SHA; use the latest exact-head result and avoid rapid retry loops.
- Zero runs for an exact SHA proves absence of returned run evidence, not the reason for absence. Investigate event history, workflow state, permissions and policy before declaring a root cause.
- The recovery dispatcher does not replace normal CI, product acceptance, physical-device validation or release gates.

---

# Arvin Project Knowledge

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean

## Authoritative continuation rule
Always re-fetch current main, PR heads/bases, issues, source files and exact-head workflow results before acting. A chat summary is only a pointer; GitHub is authoritative. Do not infer current CI state from a previous commit.

## Product and architecture invariants
- Task is the canonical actionable entity and source of truth.
- Quick Add and Full Task Form create/edit the same Task.
- Canonical taxonomy concepts are Project, Category and Tag. Category and Group are one concept; technical name `Category`, Persian UI term «دسته». No independent Group entity/store.
- Checklist and repeat belong to Task. Repeating does not create duplicate root Tasks; past execution/history remains immutable.
- Calendar is a projection of Task, not an owner. Create one external event and then update by stable Task/external event identity; never deduplicate by title/date.
- Home, Reports, Calendar, widgets and backup/restore must not become independent sources of truth.
- Fix existing paths; avoid parallel storage, backup formats, repositories or engines.
- Before migration or data-risk changes, require backup, rollback strategy and restore evidence.

## Backup/restore knowledge from live code review
- Canonical Category and Tag catalogs are independent of whether any Task currently uses them; backups must preserve unassigned values.
- Restore spans Task, Project, Calendar-link, settings and taxonomy stores. A failure can leave partial state unless rollback covers each mutated store.
- Commit [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354) adds Category/Tag snapshots and rollback cleanup for newly imported catalog entries in both Home and BackupPage, plus failure-injection test seams.
- Exact-head Build and Android smoke were not complete at last check. This is an implementation checkpoint, not a validated fix yet.
- Old backup compatibility must be preserved; missing/null optional data must not be confused with an explicitly empty collection.

## Taxonomy and relationship caution
- Current decision is in [ADR-2026-10-10-PCTADP](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), Issue #2582.
- Do not assume the conceptual Project → Category → Task drawing proves a database foreign key from Category to Project. Verify the actual model/schema.
- Issue #2580 remains open until the full cross-surface conformance audit is evidenced.

## User experience memory
- User reported missing «ثبت در تقویم گوشی» and «ویرایش» actions in Arvin's Calendar task view on 2026-10-09. Treat as an open user-reported regression until inspected and validated; do not silently mark fixed.
- Reports should be product-centered and plain Persian, distinguish verified facts from pending/unproven work, and include GitHub Read/Write status for each autonomous run.

## Release quality
Green CI and emulator tests are necessary but insufficient. Release evidence must include physical device/file-provider backup/restore, Calendar no-duplicate identity, and Golden Flow acceptance, plus user/install docs and known issues.

## Repeat Tracking Level — verified product knowledge (2026-10-11)
- All commitment use cases remain canonical Tasks. Loan/debt/payment/habit/contract/customer-follow-up must not become separate product subsystems.
- The existing repeat model already has `RecurrenceTrackingLevel.normal` and `.tracking`, persisted inside `Task.recurrence`; missing values from legacy JSON fall back to `normal`.
- The existing Task JSON already carries repeat occurrence history and per-occurrence checklist state. The recurrence repository/page also already contain some progress/history behavior. Start by completing existing paths, not by creating another engine/store/model.
- Follow-up and Repeat Tracking are different concepts. A Task's follow-up boolean/history must not substitute for the repeat rule's tracking level.
- Requested user language is «نوع پیگیری»، «عادی»، «مهم و قابل پیگیری». Keep developer terms out of normal UI. Advanced tracking details should appear progressively only when requested.
- Current audit targets: primary Task Create/Edit integration, restrained Home cue, Report Center level filter and defensible metrics. No code-level implementation or end-to-end acceptance was performed during the first-pass audit.
- Data invariant: past occurrence/history/checklist state stays unchanged when tracking level or future repeat settings change; backups must remain backward-compatible.

## Report Center filter contract — 2026-10-11
- Report is a read-only consumer of canonical data, not an owner of data.
- Use the existing Persian/Jalali picker for date ranges; internal DateTime values remain Gregorian only as the storage/runtime representation.
- Filter panel is an expandable bottom-sheet accordion. Time is initially open; other sections are compact/collapsed and show selected counts.
- Project, Category, Tag, status and Tracking are multi-select. OR within each group, AND across groups.
- Notebook records remain canonical Task objects with NotebookItemKind. Reports can filter by note/checklist kind, title/description, created/updated dates, and shared Category/Tag/Project dimensions.
- Existing Task follow-up state and RecurrenceRule.trackingLevel remain the sources for Follow-up and Tracking filters.
- No second Task/Note store, report engine, or parallel relation is permitted.
- Explicit limitation: current model has no separate Note-to-another-Task link; do not fake a linked-task filter. Phone-calendar-only external events are not proven Report Center inputs.
- Implementation/evidence pointer: PR #2607, branch feat/calendar-pastel-compact-cards-20261011. Exact-head Analyze/tests/build/device validation and owner acceptance remain pending.


## Repository-wide audit facts — 2026-10-11
- Main snapshot: a6ced27660d34cd87dd8915aff68d3a7555fd57a; 740 paths; 21 workflows; 249 test/integration-test files; 190 docs.
- GitHub scale: 1,248 branches, 19 open PRs and 1,096 open Issues. Search found 876 open AUTO-FIX records; this queue volume needs classification, not bulk closure.
- Main report filter still uses Gregorian showDatePicker/showTimePicker. The Jalali/shared-time implementation is in unmerged #2607/#2591.
- Release automation fan-out is real: 1,535 workflow runs are associated with the current main SHA, dominated by repeated release-closure/final-validation workflow_run events. #2531 is the existing isolation lane.
- TaskStore on main is SQL/Drift-backed with a one-time legacy SharedPreferences migration. #1324 remains open but its latest evidence is old and must be refreshed before closing.
- Open issue #866 tracks unsafe premature Recovery Wave closure; preserve fail-closed acceptance semantics.
- Current product acceptance ledger #1139 has unchecked installed-device requirements. Older #358 physical-device deferral text is stale relative to the newer ledger.


## Live checkpoint 2026-10-12
Current main is `cea76673d871ce52b84dacf69f355c4282802baa`. Documentation cleanup PR #2613 is merged. Exact-main Build #38178428086 and Device Smoke #38178428043 have stale/incomplete status and are not accepted as passing. Release remains blocked by physical-device Calendar, Backup/Restore, golden-flow and owner-approval gates. Read the live `ARVIN_EXECUTION_STATE.md` before acting; historical SHA/run notes above are not current truth.


## Binding UX rule — Follow-up vs. reminder (2026-10-12)
- «پیگیری» is an in-app next action/review time. Show it on Arvin Home / next-action surfaces; do not project it to the phone calendar or generate an OS notification solely because it exists.
- «یادآوری» is an explicitly configured notification time. Only this field may create/update a phone-calendar entry, titled «یادآوری».
- These fields are independent in storage, UI, editing, projections and backup/restore. Either may exist without the other; never auto-copy, infer, clear or synchronize their values.
- Example: «خرید فرش اتاق» with follow-up 15 Mehr 17:00 appears in Arvin as «پیگیری»; reminder 15 Mehr 09:00 appears in the phone calendar as «یادآوری».
- Any change must preserve Task as the sole source of truth and use the existing external-event link to update the same calendar event. No duplicate events or imported-event echo loops.
- See the binding decision in ARVIN_DECISION_LOG.md (2026-10-12). This is a product contract, not evidence that all implementation/device acceptance tests already pass.


## Owner clarification — Next Follow-up and reminder lifecycle (2026-10-12)
- Keep five concepts separate: follow-up-enabled Task, recorded Follow-up/action, Next Follow-up (`nextFollowUp`), reminder (`reminderDate`), and the date/time associated with a recorded Follow-up.
- Next Follow-up starts empty and is activated explicitly by the user. On its first setting only, create an initial reminder at the same date/time; if the chosen Next Follow-up is date-only, make that initial reminder all-day.
- Thereafter these are independent: editing or deleting Next Follow-up never edits/deletes the reminder; editing/deleting the reminder never edits/deletes Next Follow-up. A reminder can exist without Next Follow-up. Each is independently manageable and may be date+time or date-only.
- Next Follow-up is an Arvin next-action cue («پیگیری بعدی»); reminder is the calendar/notification concept («یادآوری»). Preserve Task as the canonical source and stable Task/external-event identity for updates; no duplicate events or imported-event echo loops.
- Example: initial Next Follow-up = 15 Mehr 17:00 creates reminder = 15 Mehr 17:00. Later Next Follow-up = 20 Mehr 10:00 leaves reminder at 15 Mehr 17:00; deleting Next Follow-up also leaves the reminder.
- **Open edge case:** when a reminder already exists at the moment Next Follow-up is first set, owner decision is still needed on whether to preserve it and skip creation or another explicit behavior. Do not overwrite or duplicate the existing reminder by assumption.
- This is an owner-approved product contract, not proof of code/test/device completion. Audit the existing implementation and tests before any code change; preserve JSON/SQL/backup compatibility and add regression coverage for all lifecycle rules.

## Follow-up / Reminder all-day compatibility — 2026-10-13

- `FollowUp.dateTime` is the recorded history timestamp; `nextFollowUp` is the next-action date/time; `reminderDate` is an independent reminder date/time. Do not conflate them.
- Current FollowUp JSON has no all-day metadata. Task-level `allDay` only describes Task dueDate and must not be reused as a FollowUp flag.
- Task SQL storage persists a canonical JSON envelope; canonical backup serializes `Task.toJson()` and restore uses `Task.fromJson()`. Any new FollowUp all-day marker must round-trip through both paths.
- CalendarReminder and provider sync already support `isAllDay/allDay`; FollowUp Calendar projection currently leaves the flag at its false default.
- Never use hour==0 as proof of all-day for FollowUp reminders. New explicit metadata is required to distinguish intentional midnight from date-only intent; old ambiguous values should remain unchanged unless a separately approved migration rule exists.
- Existing editor does not create an initial reminder when Next Follow-up is first set, does not offer date-only selection for Next Follow-up, and does not expose clear-next in the inspected UI. Existing reminder edit/clear is already tested as independent behavior.


## Owner-confirmed Follow-up / Reminder lifecycle (2026-10-13)
- The reminder is a separate user-editable object/value, independent of previous and next follow-up records.
- Setting Next Follow-up does not automatically create a reminder. Create one only when the user explicitly wants/chooses it; then prefill Task title and Next Follow-up date/time as initial values. This is not a live binding.
- The user may ask for additional reminders and can independently edit reminder title/date/time. Never silently overwrite or duplicate an existing reminder.
- Changes/deletion to Next Follow-up never move/delete reminders. Reminder edits/deletion never change Next Follow-up. Reminder may remain without Next Follow-up.
- Both Next Follow-up and reminder independently support date-only/all-day or date/time; preserve legacy midnight values without guessing.
- Code implementation and exact-head tests/build/calendar/persistence/backup validation are not established by this decision record.


## Owner-confirmed cardinality — Follow-up and Reminder (2026-10-13)
- A single canonical Task may have multiple recorded Follow-up entries and multiple independent reminders; there is no one-per-Task restriction.
- Recorded Follow-up entries are history records. Next Follow-up is the distinct next-action value. Reminders are independently editable/schedulable entries.
- Editing or deleting one reminder must not affect other reminders or Follow-up values/history. Editing/deleting a Follow-up record must not affect reminders. Reminder creation remains user-controlled, not automatic.
- All entries must persist through the canonical Task model, SQL JSON envelope and backup/restore, and retain stable identities for Calendar projection/sync. Do not add a parallel store.


## 2026-10-13 — Reminder cardinality and compatibility gate
- Live model audit: `Task.reminderDate` is singular; each `FollowUp` also has singular `reminderDate`. A Task can have multiple FollowUp records, but the model lacks a collection of Task-level reminders independent of FollowUps.
- Existing `test/follow_up_reminder_model_test.dart` covers one FollowUp reminder JSON round-trip, legacy JSON without reminderDate, and persistence inside Task JSON; it does not prove multiple Task reminders or all-day semantics.
- Proposal only: a stable-ID `TaskReminder` collection embedded in canonical Task, with editable title/schedule and explicit date-only/all-day metadata, projected through existing Calendar/notification engines. No parallel store.
- Preserve old fields and define a deliberate compatibility path before implementation. `nextFollowUp` remains distinct and reminder creation is opt-in. No code/schema change until the architecture gate is approved.

## 2026-10-14 — Consolidated owner contract for Follow-up and Reminder
- A Task inherently supports zero, one or multiple Follow-up records; a Task-level flag is not the source of truth.
- Full Task Form: remove "کار پیگیری‌دار"; use "پیگیری‌ها" + "+ افزودن پیگیری". Quick Entry: remove "دارای پیگیری"; retain Checklist option.
- Keep Follow-up occurrence/history, `nextFollowUp` (planned next action), Task-level Reminder collection and Follow-up-specific `reminderDate` separate. No implicit reminder/notification/external sync from `nextFollowUp`.
- Multiple Task-level reminders need stable identity and independent edit/delete behavior. Waiting Response supports multiple Person references; Person management is a simple Settings directory, not CRM.
- Task is canonical. Calendar and Reports are projections. Calendar tap opens Task; long press offers management. Backup/Restore integrity includes Tasks, Checklist, Repeat, Tracking, Follow-ups, Reminders, People, History and Calendar links.
- **Data safety stop:** historical records conflict on legacy `Task.reminderDate` migration. Do not auto-convert, clear, overwrite or duplicate until the canonical migration rule and existing Calendar identity mapping are explicitly reconciled.
- Durable issue records: #2654 comment 6176411140 and #1901 comment 6176412001. Documentation alone is not implementation evidence.
