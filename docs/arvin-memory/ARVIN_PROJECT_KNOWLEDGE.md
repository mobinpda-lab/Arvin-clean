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

## 2026-10-15 — Authoritative reminder migration rule
- Owner selected Option B. This supersedes older statements that legacy Task.reminderDate must never be automatically migrated.
- Candidate migration occurs at canonical Task JSON decode and uses stable ID legacy-task-reminder, isLegacyTaskReminder metadata, and legacyTaskReminderMigrationVersion.
- Preserve the legacy timestamp; midnight is not evidence of all-day intent. The migrated reminder keeps Calendar identity task-reminder:<taskId> and the existing scheduler key; the old field remains for compatibility but is not emitted/scheduled a second time after migration.
- The owner reports that the current app DB is empty. Do not assume all backups, test fixtures or other installations are empty.
- SQL, backup/restore, rollback/retry, Calendar no-duplicate, exact-head CI and physical-device acceptance remain required.



## 2026-10-19 — Wave 4.11 Reminder persistence notes

- FollowUps are embedded in the canonical Task model and also projected into the existing SQL `follow_ups` / `follow_up_people` relations by TaskStore. TaskReminder instances are serialized in the Task JSON envelope (`legacy_payload_json`); the current schema version is 6.
- A linked Follow-up reminder is mirrored into the existing TaskReminder collection using `followUpId`, with a stable ID `follow-up-reminder:<followUpId>`. On edits the repository updates the linked record rather than adding another one; clearing the reminder time removes only the explicitly linked record.
- The FollowUp reminder delivery projection remains the delivery identity source for linked reminders. Generic TaskReminder delivery skips linked mirrors to avoid double scheduling/delivery. This is an integration strategy, not yet validated by runtime tests.
- The reminder field in the form is labelled `یادآور پیگیری بعدی`. `nextFollowUp` remains a distinct scheduling concept and must not create a reminder by itself.
- Wave 4.11 test additions and repository changes must be validated on the final exact PR head. Build run 39232215264 failed on older SHA `91d5412dad2f80aeffc464434f693583f4180be2` because new tests were outside `main()`; commit `44019c81b8ad394b7c4ce4496347004a79a519ad` corrected their scope, but no passing run has yet been established.
- Do not infer a database migration is required solely because `followUpId` was added: the JSON envelope persists the full TaskReminder payload. Still require a real persistence reload and Backup/Restore regression test before marking the relationship verified.



## 2026-10-19 — Follow-up Reminder identity and Calendar de-duplication

- Repository add/update reconciles a single TaskReminder per explicit followUpId; repeated add with the same Follow-up ID updates the existing Follow-up rather than appending another record.
- Clearing FollowUp.reminderDate removes only the linked TaskReminder; the Follow-up's next action, result, Person IDs, waiting state and history remain canonical data.
- Calendar projection must not emit both the Follow-up reminder and its TaskReminder mirror. Keep the existing followup:<taskId>:<followUpId> Calendar ID and skip linked mirrors in the generic TaskReminder projection.
- A Backup/Restore integration regression now covers Task/Follow-up/Reminder IDs, date/title, Person association, Waiting for Response and unrelated reminders. Run it on the final PR head before claiming durability.
- Build/Device Smoke run 39233581512 / 39233581540 on head 12ef171beef4533d12efe08f3bdacca5e2e03f36 was cancelled after later implementation commits; the next terminal evidence must match the final head.



## Wave 4.12 live state — 2026-10-19

- Current observed main SHA: d9fb7a247037762216662a20fb32028ecc8a0f6b.
- PR #2833 head at the start of this checkpoint: d06062fb19c3f3ad54051f3a682f69be4146dd91. Build Run 39234124721 was fully green (9/9); artifact metadata for both APKs names that exact SHA.
- Device Smoke Run 39234124429 was still running at last poll; never infer completion from partial lane success.
- A green Release APK build is not official release acceptance: android/app/build.gradle.kts uses debug signing on main. Do not publish that APK as a production release.
- Exact-SHA acceptance requires the verification step to execute, not be SKIPPED. Calendar Provider acceptance requires a writable provider and explicit CREATE/NO-OP/UPDATE/DELETE evidence.
- Canonical release status and requirement matrix files have now been created on the existing PR branch because both were absent from main and the working branch. Their commits changed the candidate SHA, requiring new CI evidence.


## Wave 4.13 verified operational facts — 2026-10-19

- PR #2833 candidate source head at this checkpoint: `4567397be8374c82993271a12f552219a3727be1`; docs update will advance it.
- Follow-up reminder work reuses canonical Task/FollowUp and embedded TaskReminder structures; repository code reconciles the Follow-up-linked reminder by stable `followUpId`, preserves reminder identity on edit, and removes only the reminder linked to the Follow-up when its reminder time is cleared. This is implementation evidence, not full lifecycle acceptance.
- Build run [39235854952](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854952) passed Analyze, all six test shards, Debug and Release APK jobs. The exact-target assertion was skipped on the PR event, so checkout identity is not proven.
- Release artifact [12179281920](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179281920) contains APK SHA-256 `6c6e38199c9d29ae26a4ff33e45082882ff05d0ee0bd8d276889148e78f2fabd`; this is not signer verification.
- Provider acceptance artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) establishes API 35 and installed CalendarProvider2, but no writable calendar row. Never interpret the test harness's normal return on this branch as PASS.
- Connected GitHub actions do not expose workflow dispatch or repository secret/variable inspection. Treat those as access limitations, not evidence that credentials do not exist.


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


## Wave 4.16 live-state note — 2026-10-19

Follow-up Reminder implementation remains on PR #2833 and reuses the existing Task/Follow-up/TaskReminder structures. New regression tests were added for reminder title fallback and title-only edits preserving stable Reminder ID and schedule. Commit: `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`; Build/Device Smoke validation was pending at the checkpoint and must be read from terminal runs before assigning a verified status.

Calendar Provider CI uses an Android API 35 stock/default emulator. The provider component is present but no writable calendar row is discoverable; run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) failed acceptance and published diagnostics [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078). No real-provider acceptance is established.


## Wave 4.17 project knowledge update — 2026-10-19

- Reminder identity/reconciliation remains canonical in `FollowUpRepository` and the Task/FollowUp persistence contract. Notification due calculation is a separate runtime layer; all relevant lifecycle states must be filtered there too.
- Found and fixed a state-filter mismatch: `FollowUpReminderProjection.pending` and `FollowUpReminderAlarmPlanner.nextAlarmAt` already skip completed FollowUps, but `FollowUpReminderDeliveryService.due` did not. The due-delivery guard and regression test are in commit `9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b`; pending actual CI validation.
- Existing repository tests use `FollowUpRepository` and `TaskStore().load()` to inspect persisted Task/FollowUp/TaskReminder state, including stable ID/time, Person IDs, repeated saves and scoped clearing. These are test assertions, not proof of the complete notification/Calendar/backup golden flow.
- The Calendar Provider test explicitly reports the stock-emulator no-writable-calendar limitation rather than fabricating success; current diagnostic evidence remains the failed older run 39241395995 and artifact 12182310078.


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


## Wave 4.18 — Calendar Provider item URI update rule (2026-10-19)

On Android Calendar Provider, when updating a specific event through an item URI formed with `ContentUris.withAppendedId(Events.CONTENT_URI, eventId)`, do not pass an additional selection to the update call. Validate the event ID and calendar ID by querying that exact URI first, then update only that URI. This rule was applied in commit [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f); new-head tests and full Provider acceptance are still pending. Historical Device Smoke is not proof of Provider lifecycle acceptance.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

Implementation note: event UPDATE/DELETE verify event ID and calendar ownership through the item URI, then mutate that exact URI without an extra selection. Acceptance assertions are being strengthened to check real-provider uniqueness after NO-OP and deletion visibility in the migration path.


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
