# AUTHORITATIVE CONTINUATION — 2026-10-13 (branch synchronization gate)

- **Parent PR #2666:** latest observed head `d16e52050567a6631a21b563d336a0bba1c3c32b`; open and unmerged. Build is pending, Calendar Provider Acceptance is in progress, Device Smoke is queued.
- **Child PR #2681:** Draft and unmerged; last observed code/documentation head before this state refresh was `20706e956906933d1a7194251df717e2edd88ad7`. GitHub reports it not mergeable against its stacked base. Do not merge, force-push, or overwrite the latest parent branch. First reconcile the branch with the latest parent safely.
- **Related PR #2679:** older waiting-list implementation has conflicting latest-only/result-text semantics. Its Build test shard failed one waiting-list test after 232 tests passed on its own merge head. This is not validation for #2681. Reconcile shared semantics before merging either.
- **Architecture decisions are documented:** Follow-up & Waiting Response decision v2.0 and current implementation/cleanup status are in `ARVIN_FOLLOW_UP_PERSON_MODEL_DECISION.md`; the repository audit is in `ARVIN_REPOSITORY_CLEANUP_AUDIT_2026-10-13.md`.
- **Cleanup changes on child branch:** remove additional legacy flag writes; preserve Follow-up waiting/Person fields during Calendar inbound edits; use canonical records for Report's Follow-up filter; support multiple structured waiting Follow-ups; add focused regression tests.
- **Open P1s:** [#2682 Person directory backup/restore](https://github.com/mobinpda-lab/Arvin-clean/issues/2682) and [#2683 Person-based reports](https://github.com/mobinpda-lab/Arvin-clean/issues/2683).
- **Validation:** no workflow runs returned for the child PR head; tests are not confirmed passing. Parent CI is not complete. No physical-device evidence.
- **Next action:** synchronize branch, then run focused tests/analyzer, full exact-head CI, migration/backup-restore rollback tests, Calendar acceptance, and device smoke. Keep release **NO-GO**.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (latest repository/CI poll)

- **Working branch / PR:** `integration/follow-up-person-model-20261013` / [PR #2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681), current recorded head before this checkpoint `d87f5a3e3de72e8227b4dd6dd954149757c79774`. PR remains Draft and unmerged. Its base is the integration branch, and GitHub reports it **not mergeable**; base synchronization/conflict resolution is still required.
- **Parent PR #2666:** current head observed `d70827e1db927dcac2afc7367ca0d2e759359d8e`, open/unmerged. Build and Device Smoke are queued; Calendar Provider Acceptance is in progress. These are not pass results.
- **Related PR #2679:** remains Draft and has an older conflicting assumption that waiting state is driven by result text/latest Follow-up. Its Build run [38417142693](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38417142693) failed in test shard 2: 232 tests passed and one waiting-list test failed. This evidence belongs to #2679's merge head, not PR #2681. Reconcile semantics before either PR is merged independently.
- **New P1 tracking issues:** [#2682 Person directory backup/restore](https://github.com/mobinpda-lab/Arvin-clean/issues/2682); [#2683 Person-based reporting](https://github.com/mobinpda-lab/Arvin-clean/issues/2683).
- **Cleanup tests:** added/updated on the child branch, including waiting-list semantics, Calendar preservation, Person deletion, Report filtering, and legacy-flag independence. They remain **unverified** because no PR-associated CI runs were returned for the child head.
- **Next action:** synchronize the child with the latest parent integration branch without overwriting either branch's changes; then run focused tests/analyzer and full exact-head CI. Close #2682 and #2683 only with evidence. Release remains **NO-GO**.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (repository cleanup audit)

- **Repository:** `mobinpda-lab/Arvin-clean`.
- **Working branch:** `integration/follow-up-person-model-20261013`.
- **Draft PR:** [#2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681), stacked on parent [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666). Both remain unmerged; child PR remains Draft.
- **Owner decisions verified in GitHub:** `ARVIN_FOLLOW_UP_PERSON_MODEL_DECISION.md` records the accepted Follow-up, waiting-response, Person directory, independent Reminder/next-action, Quick Add and Full Form decisions.
- **Implemented source slice:** FollowUp model JSON and SQL fields include structured `waitingForResponse` and `personIds`; Settings has a reusable Person directory; Follow-up entry validates Person selection when waiting; Quick Add and Task Editor no longer expose the old flag control.
- **Cleanup this pass:** removed additional active writes to legacy `followUpEnabled`; changed Report filter to use canonical Follow-up records; fixed Calendar inbound edits to preserve waiting status/Person IDs; made waiting detection and the waiting list operate on each structured Follow-up record; added focused regression tests.
- **Audit report:** `docs/arvin-memory/ARVIN_REPOSITORY_CLEANUP_AUDIT_2026-10-13.md`.
- **P1 blocker:** portable backup/restore does not yet include standalone `people_directory` records. Fixing this touches restore/rollback and must be implemented with round-trip/failure-rollback tests; do not mark Person directory delivery complete until this is closed.
- **P1 blocker:** Person-based reporting is not complete. Current report fix only removes dependence on the legacy flag; it does not yet provide full Person filtering/results.
- **Validation:** tests were authored/updated but not executed or confirmed passing on the child head. Parent PR #2666 exact-head workflows were queued/pending when last checked; child PR #2681 had no PR-associated runs because it targets the integration branch. No physical-device evidence.
- **Release:** **NO-GO**. Continue from this checkpoint; do not restart the architecture analysis. Next: close the backup/restore Person directory gap with transactional rollback coverage, complete Person reporting, audit remaining legacy flag consumers and all Follow-up reconstruction sites, then run exact-head CI and device acceptance.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (follow-up architecture implementation slice)

- **Working branch:** `integration/follow-up-person-model-20261013`, created from PR #2666 head `68724d6191590b81b2d611f59b7944a7fcbb06e0` to isolate architecture work from concurrent updates on the reminder integration branch.
- **Parent integration PR:** #2666 remains open/unmerged. This branch is stacked on that integration branch and must not be merged to `main` ahead of its parent.
- **Completed code slice:** `WaitingForResponseService.markWaiting` now preserves the existing FollowUp reminder date, next action time, and completion state instead of silently dropping them. `TaskStore.addFollowUp`, FollowUp completion updates, and Task Editor saves no longer turn on or derive the legacy `followUpEnabled` flag; existing legacy values remain preserved for compatibility.
- **Regression tests added:** verify marking a FollowUp as waiting preserves reminder/completion fields; verify creating a FollowUp for a Task without legacy follow-up data does not turn on `followUpEnabled`.
- **Not yet validated:** Flutter tests/analyzer/build have not been run in this environment; create/review a draft PR and inspect exact-head CI before treating this slice as complete.
- **Architecture remains incomplete:** FollowUp still lacks first-class `waitingForResponse` and Person IDs; current waiting state is encoded in `result`; SQL `follow_ups` has no columns for those fields; Settings has no reusable Person directory. Next implement canonical Person directory + FollowUp association with idempotent SQL migration and backup/restore coverage, then editor UI and Person-based reporting.
- **Preserve invariants:** `nextFollowUp` and `reminderDate` remain independent; no reminder/calendar event may be created from `nextFollowUp`; never delete Task/FollowUp when a Person association is removed.
- **Release:** NO-GO. No physical-device, backup/restore, or exact-head CI acceptance is established.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (Follow-up & Waiting Response Person architecture decision)

- Owner supplied and accepted the Follow-up & Waiting Response Architecture Command v2.0. No clarification is needed to begin implementation planning.
- Created `docs/arvin-memory/ARVIN_FOLLOW_UP_PERSON_MODEL_DECISION.md` in commit `12faf7b6df5f1076de2dcd9c5e85128426ef148b`.
- Inspected current branch model and persistence: `Task` already has `followUps`, legacy `followUpEnabled`/`followUpDate`, `PersonReference`, and multiple Task Reminders. `FollowUp` currently lacks waiting-response status and Person IDs; `TaskStore.addFollowUp` still sets `followUpEnabled = true`; the full editor still renders `کار پیگیری‌دار` and auto-populated follow-up time.
- Required product invariants: all Tasks are eligible for follow-up; zero-to-many Follow-up records; `nextFollowUp` is next action time only; Reminder stays independent and may be zero-to-many; waiting response requires Person association; Person directory is lightweight, not CRM; Person-filtered reports; detaching Person or deleting Reminder cannot delete Task/Follow-up.
- No model/UI/schema/migration code changed for this architecture yet. This is intentional until the Person canonical identity, persistence schema and legacy migration behavior are traced end-to-end; migration/data-loss risk requires careful implementation and explicit evidence.
- Next action: inventory Task/Follow-up serialization, SQL/Drift schema, TaskStore mutations, backup/restore, Quick Entry, full editor, Settings taxonomy, report filtering, Calendar and tests; then implement model/persistence migration first, tests second, UI/report integration third.
- Preserve existing reminder branch work and the prior accepted rule that `nextFollowUp` and `reminderDate` are independent. Do not create reminders, notifications or external Calendar events from `nextFollowUp`.
- Current validation for this new architecture: not run. Existing branch PR #2666 remains unmerged; release remains NO-GO pending exact-head CI, migration/backup-restore/Calendar validation and physical-device evidence.

---
# AUTHORITATIVE CONTINUATION — 2026-10-13 (exact-head reminder sync failures triage)

- Re-read this checkpoint and queried live PR #2666. It is open, ready for review, mergeable, and unmerged on `integration/task-multiple-reminders-safe-20261013`; release remains NO-GO.
- Exact head at the start of triage: `e55a9feedf464ad553adb4dd76a948f9a9ed6b6e`.
- Exact-head CI: Analyze passed; Debug and Release APK builds passed; Calendar Provider Acceptance passed; all six Device Smoke lanes passed. Build quality failed because five test shards failed. Do not infer product acceptance from the passing orchestration workflows.
- Failure evidence from run 38415626957:
  - Calendar inbound sync rejects `task-reminder-item:<taskId>:<reminderId>` as ineligible in `SystemCalendarBridge.isEligible`.
  - Calendar task-ID parser treats the `task-reminder-item:` prefix as `task-reminder:`, yielding the wrong Task ID.
  - Other failures remain in inbound Calendar update/delete and alarm rescheduling tests, the Task Editor checklist toggle expectation, settings widget visibility, and portable settings backup contract.
- Safe code fixes committed on this branch:
  - `a5f82209748ca6781873af0c73abf71352a239f7`: allow new independent Task reminder IDs through Calendar sync eligibility.
  - `1bbdbe06260a6cf8dfaa7ea3034604d02ce0dfd8`: parse Task ID from `task-reminder-item:` before broader legacy prefixes.
  - `66300d53e209db9e649c6d97bdb42bc35a74cec3`: align portable backup contract test with the owner-approved configurable 09:00 all-day reminder preference.
- These are source/test changes, not yet validated. Re-query PR #2666's current head and exact-head Actions after this state update; review new test failures before any further changes.
- Remaining work: inspect and fix real Calendar inbound/outbound and notification reschedule failures; resolve the checklist test by comparing intended UX to implementation; determine why the settings test does not find a key that exists in source; run all test shards and required build/provider/device gates on the final SHA; collect physical-device and real backup/restore + Calendar-link integrity evidence.
- Do not merge PR #2666 until exact-head gates pass. Physical-device acceptance remains unverified; release NO-GO.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (projection compile and analyzer lint repairs)

- **Product decision:** all-day/date-only Task reminders default to 09:00 local time; user can change the time in Settings. Timed reminders and FollowUp reminders are unchanged.
- **Existing implementation confirmed:** settings model/UI, SharedPreferences persistence, portable backup/restore, planner/background delivery injection and reschedule call already exist. Avoid duplicate implementation.
- **Repair 1:** initialized `FollowUpReminderCandidate.taskReminderId` to null in default and `.task` constructors; commit `a8263d5119c16c69db7fd282d53820504650b57e`.
- **Repair 2:** exact-head Analyze then failed on two info-level lints because CI treats analyzer findings as failure: prefer initializing formal for `Task.nextReminderSequence`, and braces around the return in `_sameTaskReminders`. Fixed in commits `9d91bb309c3f7df86b70e4a25ca29d4e1a0082ad` and `159f9c3bcb2d74ad06e8e7681251d5d49cab57e`.
- **Next:** re-query live PR head after this memory write and inspect all Build, Calendar Provider Acceptance and six Device Smoke lanes for that exact final SHA. Prior runs against earlier heads do not validate these fixes.
- **Release:** NO-GO until Analyze, all test shards, Debug/Release APK, Calendar Provider Acceptance, all six smoke lanes, backup/restore/link integrity and physical-device acceptance are evidenced.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (configurable all-day reminder policy + compile repair)

- **Owner decision:** all-day/date-only Task reminders default to **09:00 local time** and users can change this in Settings. Timed Task reminders and FollowUp reminders are unaffected.
- **Implementation audit:** existing code already includes `AppSettings.allDayReminderNotificationMinutes`, the Settings time picker, AppSettingsService/SharedPreferences persistence, portable backup/restore compatibility, runtime injection into alarm planning and background delivery, and rescheduling after changes. Do not create duplicate settings infrastructure.
- **Root cause found from exact-head CI:** `FollowUpReminderCandidate` declared nullable final field `taskReminderId` but the default and `.task` constructors did not initialize it. Analyze and Android builds failed at `lib/services/follow_up_reminder_projection.dart:7,15`; Calendar Provider Acceptance and several device smoke lanes consequently failed to compile.
- **Repair committed:** initialized `taskReminderId = null` in the default and `.task` constructors. Fix commit: `a8263d5119c16c69db7fd282d53820504650b57e`.
- **Validation:** the failing run was against PR head `7ee42dbdf899226dfa27a2ee13cb4be6871715a4` / synthetic merge `a8e59ae43a8c66f437e9e8a89ee6385c4f5428f7`; those results do not validate the fix. Re-query current PR head and Actions after memory updates, then inspect the new exact-head results.
- **Current gates:** Build Analyze/test shards/Debug+Release APK, Calendar Provider Acceptance and all six Device Smoke lanes must pass on the final head. Physical-device validation, backup/restore and Calendar-link integrity evidence remain required.
- **Release:** NO-GO. PR #2666 is ready for review, open and unmerged; do not merge until every required gate is evidenced.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (full validation gate)

- **Reminder policy:** all-day/date-only Task reminder notifications default to 09:00 local time and are user-configurable in Settings. The preference persists through the existing AppSettingsService and is applied by alarm planning/background delivery.
- **CI contract:** Draft PRs intentionally use the Fast Lane and skip heavy Build/Device validation. The attempted workflow change to run Device Smoke on Draft violated `tool/validate_fast_lane.py` and was reverted. Do not alter this contract as a workaround.
- **Next action:** mark PR #2666 ready for review (not merged) so the established Build + all six Device Smoke lanes run. Keep release NO-GO until exact-head Analyze, test shards, Debug/Release APK, Calendar Provider Acceptance, all six Device Smoke lanes, backup/restore/link integrity, and physical-device acceptance are evidenced.
- **Branch/PR:** `integration/task-multiple-reminders-safe-20261013`, PR #2666. Re-query the head after the workflow correction and after marking ready; only exact-head results count.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (draft-safe Device Smoke validation)

- **Reminder policy:** all-day/date-only Task reminders default to 09:00 local time, and users can change this in Settings. The preference persists through the existing AppSettingsService and is applied by alarm planning and background delivery.
- **Validation automation correction:** `.github/workflows/device-smoke.yml` previously skipped all six Android smoke lanes while a PR was Draft. The draft-only skip is intentional under the Fast Lane contract; full Device Smoke runs when the PR is ready for review.
- **Branch/PR:** `integration/task-multiple-reminders-safe-20261013`, PR #2666. This CI correction creates a new head; only runs for the resulting exact SHA count as validation.
- **Current required evidence:** Build Analyze + test shards 0–5, Debug/Release APK, Calendar Provider Acceptance, all six Device Smoke lanes, physical-device behavior, backup/restore and Calendar-link integrity.
- **Release:** NO-GO. PR remains Draft/unmerged until required gates pass.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (all-day reminder time configurable)

- **Owner decision:** all-day/date-only Task reminder notifications default to **09:00 local time**, and the user can change the time in Settings. It is not hard-coded as an unchangeable hour.
- **Implementation added:** canonical `AppSettingsService` preference in minutes after local midnight, Settings time picker, portable backup/restore field with backward-compatible 09:00 fallback, configurable notification projection/delivery/alarm planner, background runner setting load, and reschedule after settings changes.
- **Branch/PR:** `integration/task-multiple-reminders-safe-20261013`, PR #2666. This update is committed as one Git commit; query the live head and Actions after the ref update.
- **Validation:** tests have been added/updated but have not yet been run to a terminal green result. Build, Calendar Provider Acceptance, Device Smoke, physical-device acceptance, backup/restore and Calendar-link integrity must be checked on the exact resulting SHA.
- **PR status:** marked ready for review solely to trigger the established full validation path; still unmerged. This status is not merge approval.
- **Release:** NO-GO until all required gates pass on the final exact head.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner decision recorded)

- **Owner decision:** 09:00 in the user's local time zone is approved for all-day/date-only Task reminder notifications. Timed reminders retain their selected time. This resolves the product-policy ambiguity, not validation gates.
- **PR #2666:** Draft/open/unmerged on `integration/task-multiple-reminders-safe-20261013`. Re-query the live head after this memory commit because this write advances the branch.
- **Last validation observed before owner decision:** Build run 38397084236 and Calendar Provider Acceptance run 38397084168 were in progress; Device Smoke run 38397084187 was skipped. Re-poll exact-head Actions and inspect logs/artifacts. Green orchestration runs are not product validation.
- **Still required:** all test/analyzer shards, Debug and Release APK, Calendar Provider Acceptance, all six Device Smoke lanes, physical-device validation, backup/restore and Calendar-link integrity. Resolve failures on the current head and rerun after final changes.
- **Release:** NO-GO until required gates are evidenced. Do not merge just because the owner decision is resolved.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (latest exact-head poll)

Use this checkpoint instead of earlier state summaries; re-query the live PR head after this memory write because the write itself advances the branch.

- **PR #2666:** Draft, open, mergeable, unmerged. Branch `integration/task-multiple-reminders-safe-20261013`, base main `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`.
- **Latest code/test checkpoint before this state write:** `13456ed6b4f83ab7216975bf233e673cee2c3bae`. The last change corrected the model test to expect an explicitly serialized empty TaskReminder list.
- **Implemented:** TaskReminder model and deterministic legacy decode; migration tombstone; sequence persistence; TaskStore canonical-envelope keys; full editor CRUD and edit-apply; Calendar projection with stable identity; inbound/outbound Calendar sync; notification projection/delivery/alarm planner/state; model/editor/Calendar/SQL/backup tests.
- **Persistence safety:** always serialize `taskReminders` (including empty), `nextReminderSequence`, and `legacyReminderMigrationCompleted`. TaskStore treats them as canonical fields so stale legacy JSON cannot restore a deleted reminder. A SQL save/reload regression test was added.
- **CI on code checkpoint `13456ed...`:** Build [38396952083](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38396952083) is pending with no jobs reported yet; Calendar Provider Acceptance [38396952020](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38396952020) is in progress; Device Smoke [38396952092](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38396952092) is skipped. Orchestrator/Production Loop/Parallel Wave successes are not product validation.
- **Owner decision:** 09:00 local time is the default for all-day notifications, and users can change it in Settings. Validate the configurable preference and runtime rescheduling on the exact head before merge.
- **Next:** query the new live PR head after this doc write; trigger/recheck exact-head Build and Calendar Provider Acceptance, inspect test/analyzer output, and do not claim acceptance until terminal results and artifacts are reviewed. Then require all test shards, Debug/Release APK, all six Device Smoke lanes, physical-device validation, backup/restore and Calendar-link integrity.
- **Release:** NO-GO. No PR merge.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (TaskReminder full vertical slice, pending validation)

This is the newest checkpoint. Re-read the live PR head and Actions before relying on any status below; earlier checkpoints are historical.

- **Repository/main base:** `mobinpda-lab/Arvin-clean`, base SHA `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`.
- **Integration branch/PR:** `integration/task-multiple-reminders-safe-20261013`, [PR #2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666), Draft and unmerged. It is a safe integration branch; do not merge PR #2655 blindly.
- **Implemented source areas:** `lib/models/task.dart` (TaskReminder metadata, deterministic legacy decode, sequence and migration tombstone); `lib/services/task_store.dart` (canonical envelope recognizes reminder fields, empty collection/tombstone always serialize); `lib/task_editor_dialog.dart` (independent reminder add/edit/delete); `lib/services/task_edit_apply_service.dart`; Calendar projection, outbound and inbound sync; notification projection, delivery, alarm planner and delivery state.
- **Compatibility behavior:** the legacy Task reminder maps to deterministic ID `legacy-task-reminder:<taskId>` and retains the external Calendar identity `task-reminder:<taskId>`; new reminders use `task-reminder-item:<taskId>:<reminderId>`. The migration marker suppresses legacy duplicate projection and acts as a deletion tombstone. `FollowUp.reminderDate` and `nextFollowUp` remain independent. Internal Follow-up Action projections remain display-only.
- **Important persistence fix:** `TaskStore._canonicalEnvelope` used to preserve old fields it did not recognize. Conditional omission of an empty reminder collection could therefore restore deleted reminders from prior JSON. Task JSON now always writes the collection, next sequence and migration marker, and TaskStore recognizes them as canonical keys. A SQL save/reload regression test covers this case.
- **Tests added/ported:** model migration/idempotence/tombstone; Calendar stable ID and same-time distinct reminders; inbound provider edit/delete isolation for new and migrated reminders; outbound eligibility; notification identity, all-day scheduling and alarm planning; Task Editor CRUD/migration deletion; TaskEditApplyService; SQL persistence and backup/restore round-trip. These are code-level additions, not yet confirmed passing.
- **Code checkpoint before memory updates:** `f143a5886c907483d4101e4c8510b41907dc2d77` included editor-apply tests; later SQL-envelope, persistence, backup tests and guard fixes followed. Four memory docs were updated immediately before this state file. This state-file write itself advances the branch head, so re-query the live PR for the actual final SHA.
- **Validation status at latest pre-doc checkpoint:** Build pending; Calendar Provider Acceptance queued/in progress; Device Smoke skipped. No green exact-final-head validation, no physical-device result, and no release acceptance is established.
- **Owner decision resolved (amended 2026-10-13):** 09:00 local time is the default for all-day reminders, and users can override it in Settings. Validation of persistence, runtime delivery and rescheduling remains required before merge.
- **Next action:** update PR description and trigger/check Actions on the resulting exact head; inspect all Build/analyzer/test failures; finish SQL/backup and UI review; obtain the all-day notification-time decision; then run the required exact-head Analyze, test shards 0–5, Debug/Release APK, Calendar Provider Acceptance, six Device Smoke lanes and physical-device acceptance.
- **Release:** NO-GO until the exact-head quality gates and owner decision are satisfied.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (TaskReminder model + legacy decoder slice)

This is the newest checkpoint. Re-read live PR metadata and exact-head CI before continuing; older checkpoints below are historical where they conflict.

- **Repository/main:** `mobinpda-lab/Arvin-clean`; main checkpoint `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`.
- **Safe integration PR:** [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666), branch `integration/task-multiple-reminders-safe-20261013`, base main. It was a docs-only integration plan; this run began porting the approved feature in small slices. Keep Draft and unmerged.
- **Completed code slice:** `lib/models/task.dart` now contains `TaskReminder` fields `id/taskId/title/date/status/createdAt/updatedAt/isAllDay/sequence`, canonical Task JSON serialization, sequence persistence, deterministic legacy reminder ID `legacy-task-reminder:<taskId>`, and a persisted `legacyReminderMigrationCompleted` tombstone. The legacy `Task.reminderDate` remains present for rollback/old-reader compatibility. Midnight is not inferred as all-day; `nextFollowUp` does not create a reminder.
- **Tombstone rationale:** if a migrated item is later removed, the marker prevents subsequent `Task.fromJson` from silently recreating it. Calendar projection must also respect the marker; until that slice lands, duplicate external projection is an open blocker.
- **Regression tests added:** `test/follow_up_reminder_model_test.dart` now covers deterministic migration, repeated JSON round-trip, sequence allocation above existing reminders, deletion tombstone, and `nextFollowUp` independence.
- **Code checkpoint SHA:** `cc1d668b814f96f6c4b1f34f3cebce85ff484714` (model + focused tests). The exact-head Build was pending and Device Smoke was skipped at that poll. Four subsequent documentation commits updated Decision Log, Project Knowledge, Problem Register and Evidence Map; therefore CI for the code checkpoint is not proof for the current branch head.
- **Memory:** those four documents were updated on this branch. This execution-state update itself creates another commit; query PR #2666's resulting head and exact-head runs after the write.
- **Still open:** Calendar projection must emit migrated legacy reminders under the existing identity `task-reminder:<taskId>` exactly once, suppress separate legacy projection when the marker is set, and honor deletion tombstones. Then port independent new-reminder projection, notifications, editor CRUD, backup/restore and SQL round-trip; reconcile main's display-only Follow-up Action projection and never send it to outbound sync/scheduler.
- **Next action:** finish the legacy/new reminder Calendar projection identity slice and focused tests on this safe integration branch; poll the newest exact-head Build/Calendar Provider/Device Smoke. Do not merge until all required CI, provider, backup/restore and physical-device gates pass.
- **Release:** NO-GO. No claim of passing tests/build/device acceptance is made here.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (approved migration contract reconciliation)

This entry is the newest operational checkpoint. Older entries are historical and must not override these live findings.

- **Owner data state:** owner reports no information has been entered; current database is raw/empty. Do not describe owner-entered records as currently at risk. Do not assume all old backups/fixtures/installed copies are empty.
- **Main:** `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`.
- **Safe integration branch:** `integration/task-multiple-reminders-safe-20261013`, 11 commits ahead of main, 0 behind at the latest compare. Latest known head before this checkpoint: `4e83cdc9133a94a37cc1aa40eb28e7b887505754`; this update creates a new head, so its own CI must be rechecked.
- **Owner decision:** `docs/arvin-memory/ARVIN_MULTIPLE_REMINDER_ARCHITECTURE_DECISION.md` says OWNER DECISION APPROVED. The approved contract requires migration of legacy `Task.reminderDate` into exactly one stable-ID TaskReminder, idempotent retry, preserving the legacy value until the new record is durably written/validated, and no duplicate Calendar projection.
- **Critical contradiction found:** `docs/arvin-memory/ARVIN_MULTIPLE_REMINDERS_DESIGN.md` and PR #2655 currently say not to auto-migrate the legacy Task reminder. This conflicts with the approved architecture decision. The architecture decision is authoritative; reconcile the design and code before integration. Do not merge PR #2655 as-is.
- **Current source audit:** main Task model has singular `Task.reminderDate`; no Task-level reminder collection. PR #2655 adds a collection and editor/notification/calendar changes, but its current model lacks required `taskId`, `status`, `createdAt`, `updatedAt` metadata and leaves the legacy reminder outside the collection.
- **CI checkpoint for docs-only branch head `4e83cdc...`:** Analyze succeeded; six test shards and Debug/Release APK jobs were still in progress at the last poll. Device Smoke was skipped for this docs-only branch. These results are not evidence for feature code or physical-device acceptance.
- **Completed this run:** re-read execution state, owner decision, Issues #2654/#2635, PRs #2655/#2666, Task model and reminder projection. No app code, database, backup, or owner data was changed in this checkpoint.
- **Next action:** on a fresh code branch from current main, port the feature in slices and reconcile the migration contract first. Add required reminder metadata, deterministic legacy identity, idempotent migration and tests; then ensure the legacy and migrated record project to exactly one Calendar event/notification. Follow with editor CRUD, backup/restore, notifications, and provider tests. Keep PR #2666 Draft and PR #2655 unmerged until exact-head checks pass.
- **Release:** NO-GO. Physical-device Calendar, real-file Backup/Restore and Persian RTL/compact-screen acceptance are still separate mandatory gates.

---
# AUTHORITATIVE CONTINUATION — 2026-10-13 (reminder-model gate and CI poll)

This checkpoint supersedes live-status statements below where conflicting; preserve older entries as history.

- **Repo:** `mobinpda-lab/Arvin-clean`; current observed main/base checkpoint for PR #2652: `8136c929237c321f2e879a80f067970c31cb0100`.
- **PR #2652:** open, unmerged; title “docs(arvin): clarify multiple follow-ups and independent reminders”; branch `docs/owner-clarification-reminder-seed-20261013`; latest pre-this-state-update head `ca0b80a6c4275d44054c4ad9eb2b72d5f9832392`. Updating this state file creates a newer head; query that exact SHA's CI before treating it as validated.
- **Completed:** re-polled Build run [38317606450](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38317606450): Analyze, test shards 0–5, Debug APK and Release APK all SUCCESS. Device Smoke run [38317606458](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38317606458): Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore all SUCCESS. These are evidence for pre-update head `00ae93b2dba36093c4074624fe951efec51e2ab4`, not for later documentation commits or the unimplemented feature.
- **Persistent gap:** Issue [#2654](https://github.com/mobinpda-lab/Arvin-clean/issues/2654) tracks multiple independent Task-level reminders. Source `lib/models/task.dart` has a singular Task reminder and singular FollowUp reminder field per FollowUp. Existing test `test/follow_up_reminder_model_test.dart` proves only one FollowUp reminder JSON round-trip and legacy missing-field handling.
- **Decision gate:** an architecture proposal was added to PR #2652: candidate is a stable-ID `TaskReminder` collection embedded in canonical Task, with editable title/schedule and explicit date-only/all-day metadata, using existing Calendar/notification engines. **PROPOSAL ONLY, NOT APPROVED.** Legacy `Task.reminderDate` and `FollowUp.reminderDate` compatibility, old backup decoding, duplicate prevention, and all-day-vs-midnight semantics must be decided before implementation. No application code or schema migration changed.
- **Memory updated in this branch:** Decision Log, Project Knowledge, Problem Register, Evidence Map; source evidence and limitations recorded. Issue #2635 contains the owner's opt-in reminder contract.
- **Release:** NO-GO. Emulator smoke is not physical-device acceptance. No feature code was changed or validated in this continuation.
- **Next action:** obtain owner/architecture approval for the proposed compatibility semantics, then implement the model on a dedicated branch with legacy JSON, SQL, backup/restore, independent edit/delete, notification and stable Calendar identity tests. Keep PR #2652 unmerged until its latest exact-head checks finish.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner reminder cardinality audit)

This entry supersedes stale live-status wording below where it conflicts; historical entries remain for audit.

- **Repository/main:** `mobinpda-lab/Arvin-clean`; observed current main checkpoint `8136c929237c321f2e879a80f067970c31cb0100`.
- **Docs PR:** [#2652](https://github.com/mobinpda-lab/Arvin-clean/pull/2652), branch `docs/owner-clarification-reminder-seed-20261013`, pre-update head `2b1f89e51aa7f42bca10d92352e49d6c73c7fd83`, base `8136c929237c321f2e879a80f067970c31cb0100`. PR title corrected to “docs(arvin): clarify multiple follow-ups and independent reminders”; it remains open/unmerged. This state update creates a new head; re-check all exact-head runs.
- **Current pre-update CI:** Build run [38316746472](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38316746472): Analyze, six test shards, and Debug APK SUCCESS; Release APK still IN_PROGRESS. Device Smoke [38316746569](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38316746569): Home SUCCESS; Quick Capture and SQL Persistence IN_PROGRESS; People, SQL Migration and Backup/Restore QUEUED. These results apply only to the pre-update SHA; not release evidence.
- **Source audit:** main `lib/models/task.dart` currently supports one `Task.reminderDate` and one optional `FollowUp.reminderDate` per FollowUp record. Multiple FollowUp records can each carry a reminder, but there is no collection for multiple Task-level reminders that exist independently of FollowUp records. `nextFollowUp` and `reminderDate` remain separate nullable fields. The editor’s `_pickNext()` derives hour/minute from the recorded FollowUp timestamp; there is no date-only marker for either FollowUp field, and the Calendar projection does not pass FollowUp all-day state.
- **Recorded owner contract:** [Issue #2635](https://github.com/mobinpda-lab/Arvin-clean/issues/2635) now has a 2026-10-13 clarification: setting `nextFollowUp` does not create a reminder; reminder creation is opt-in; seeded Task title/date-time are independently editable; no normalization, overwrite, or duplicate creation.
- **New explicit model gap:** [Issue #2654](https://github.com/mobinpda-lab/Arvin-clean/issues/2654) records the requirement for multiple independent Task-level reminders, current cardinality limits, compatibility requirements, and acceptance tests. This is an architecture/persistence/backup/Calendar identity gate. **Do not implement a schema migration until the canonical representation and legacy-field compatibility are documented.**
- **No application code changed in this continuation.** No Flutter analyze/test/build/device run was executed by the assistant; GitHub Actions status above is separate CI evidence. Release remains **NO-GO**.
- **Next action:** complete the canonical model/compatibility design for #2654, including explicit all-day metadata and treatment of legacy singular fields; then implement on a dedicated branch with JSON, SQL persistence, backup/restore, independent edit/delete, Calendar identity and exact-head CI/device-smoke tests. Keep PR #2652 unmerged until its new exact-head checks finish.

---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (post-audit live state)

This entry supersedes older live-status wording below. Historical checkpoints remain for audit.

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; observed main SHA `18117aea2fa07b5a9a02e6021f41ff4faae120cc`.
- PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) remains OPEN and unmerged; base SHA matches the observed main checkpoint; branch `docs/decision-follow-up-vs-reminder-20261012`; latest pre-checkpoint head `bd1e73e94395f9ed4fee6ea20b96b4fca2291a0e`. Branch compare: 13 commits ahead, 0 behind; GitHub reports mergeable=true. This is documentation-only and must not be merged without exact-head validation.
- **Exact-head CI evidence for pre-checkpoint SHA `bd1e73e...`:** Build [38305322486](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322486) PENDING; Device Smoke [38305322504](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322504) PENDING; G1 lock sync [38305322539](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322539) IN PROGRESS; PR Wakeup [38305322472](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322472) IN PROGRESS; Production Loop [38305322668](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322668) SUCCESS; Orchestrator [38305322659](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305322659) SUCCESS; Parallel Wave [38305323414](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305323414) SKIPPED. These statuses apply only to `bd1e73e...`. This execution-state update creates a newer commit; re-check the resulting exact SHA and do not reuse these results as its validation.
- **Completed this run — read-only source compatibility audit and memory recording:** confirmed that FollowUp has separate nullable `nextFollowUp` and `reminderDate` values but no explicit all-day metadata; the editor does not create the initial reminder when Next Follow-up is first set, inherits the history time, and lacks a clear-next action in the inspected path; FollowUp Calendar projection omits `isAllDay`. SQL storage uses the canonical Task JSON envelope; backup uses `Task.toJson()` and restore uses `Task.fromJson()`. Findings were recorded across execution state, decision log, project knowledge, problem register, evidence map, and the follow-up/reminder addendum on this branch.
- **Owner/data gates remain:** (1) define what happens when a reminder already exists at first activation of Next Follow-up; (2) approve a backward-compatible all-day representation that distinguishes date-only from intentional midnight for both independently editable fields. Do not overwrite/duplicate existing reminders, infer all-day from midnight, or silently normalize legacy fields.
- **No application code changed.** No Flutter analyze/test/build/device validation was run in this source-audit step. Release remains **NO-GO**.
- **Next action:** poll exact-head Build and all six Device Smoke lanes for the resulting latest commit; continue safe compatibility analysis. Implementation remains blocked on the two owner/data decisions above.

---



# AUTHORITATIVE CONTINUATION — 2026-10-13 (follow-up/reminder compatibility audit)

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; live main SHA observed: `18117aea2fa07b5a9a02e6021f41ff4faae120cc`. PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) is OPEN, unmerged, base SHA matches this main checkpoint, head `aa3dabf145b7ee7c8042978e58901de769da6634`; exact-head Build was IN_PROGRESS and Device Smoke QUEUED at this poll. A documentation update creates a new head, so check runs again on the resulting exact SHA.
- **Completed read-only compatibility audit:** `FollowUp` stores nullable `reminderDate` and `nextFollowUp` separately, but has no explicit all-day metadata for either. `Task.allDay` applies to Task due-date only. `FollowUp.toJson/fromJson` serializes these fields as ISO strings and does not encode date-only intent separately.
- **Canonical persistence and backup path:** the SQL Task store writes the full canonical Task envelope as JSON; canonical backup serializes via `Task.toJson()`, and restore reconstructs through `Task.fromJson()`. The existing `FollowUp` fields therefore travel through the canonical Task payload, but a new all-day flag must be represented in the model/JSON and covered by SQL envelope + backup/restore round-trip tests. Existing date-only values already serialized at midnight cannot be reliably distinguished from intentional midnight times retroactively.
- **Calendar path:** `FollowUpCalendarProjection` currently omits `isAllDay` for FollowUp reminder projections (default false). The date-only heuristic is applied to Task due dates only. `CalendarReminder`, sync revision and `SystemCalendarBridge` already carry all-day state; the missing semantics originate earlier in the FollowUp model/editor/projection.
- **Editor path:** `FollowUpEntryPage._pickNext()` inherits hour/minute from the recorded Follow-up `dateTime`; it does not offer a date-only choice or clear-next action in the inspected code. Saving `nextFollowUp` currently does not create an initial `reminderDate`. Existing tests cover JSON round-trip, independent reminder edit/clear, and date-only Task due dates, but no verified regression coverage for first-set creation, clear-next independence, or date-only FollowUp reminder projection.
- **Data safety:** do not infer all-day from midnight, overwrite a pre-existing reminder, or silently normalize legacy `nextFollowUp` into `reminderDate`. The existing-reminder first-activation behavior is still an owner decision. A separate persisted all-day marker for Next Follow-up and Reminder is the safer candidate because each can independently be date-only or timed, but this is a model/backup compatibility change and must be specified before implementation.
- **This run:** source/docs audit only; no app code changed and no Flutter analyze/test/build/device validation was executed. Release remains **NO-GO**.
- **Next action:** owner decision on first activation when a reminder already exists; then agree on backward-compatible all-day representation. Safe work may continue after recording these gates; do not merge this PR without exact-head validation.
# AUTHORITATIVE CONTINUATION — 2026-10-12 (Device Smoke completion and source-level compatibility audit)

This newest entry supersedes conflicting earlier live-status statements below. Historical checkpoints remain for audit. Verified through GitHub at the time of this update.

- **Latest observed main commit:** `326afaa276b04650a86a811b18560eb4e20ed5cd`. Older checkpoint references to `ddcf96955f3a62081d7ab24f922d8031c44e6202` are historical branch-base information, not the latest main SHA.
- **PR #2639 pre-memory-update CI evidence:** Build [38255658613](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38255658613) passed Analyze, all six test shards, Debug APK and Release APK on SHA `104111cb79e1669a529d4c9daf53536796683c68`.
- **PR #2639 Device Smoke completed:** [run 38255658812](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38255658812) is now terminal SUCCESS on that same SHA. All six lanes passed: Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore. Artifacts verified at final poll include Home, Quick Capture and People. This is automated Android-emulator evidence only, not physical-device acceptance.
- **Content-level compatibility findings are recorded and verified** in [Issue #2102 comment 6125444112](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6125444112): PR #2636 normalizes legacy `nextFollowUp` into `reminderDate` and clears the old field on save; its tests demonstrate the new normalization but do not prove all downstream/backup compatibility or owner approval. PR #2595 removes Quick Add description/category/tag entry from the compact interface and no longer assigns those values when constructing its draft; the reviewed tests do not establish compatibility/preservation of data entered through the previous Quick Add UI.
- **Integration remains blocked on product/data gates:** do not merge #2636 until explicit owner decision and compatibility coverage for legacy reads/writes, downstream consumers and backup/restore. Do not integrate #2595 until the intended Quick Add field contract and preservation regression tests are settled. The overlapping #2591/#2595/#2602/#2607 UI/time-picker work must not be independently merged.
- **Release remains NO-GO:** physical-device Calendar same-event update/no-duplicate evidence, real-device Backup/Restore and Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen visual acceptance and explicit owner approval are still required.
- **Next actions:** because this memory-only update changes the PR #2639 head, re-check the resulting exact-head Build and Device Smoke; do not reuse the prior SHA's green status as evidence for the new commit. Continue from the existing compatibility gates without duplicating already completed audits or starting unnecessary duplicate runs.

---

# AUTHORITATIVE CONTINUATION — 2026-10-12 (live re-poll after compact UI CI)

This section supersedes any older status statement below where it conflicts. Historical material is preserved for audit. Last verified against GitHub Actions and PR metadata during this continuation.

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; last verified main checkpoint remains `ddcf96955f3a62081d7ab24f922d8031c44e6202` for the compact UI branch's base. Do not assume a newer main SHA without refreshing it.
- **PR #2627 — compact task density:** OPEN, non-draft, mergeable, head `91b949f2417d3ca5aa5a7868ef7d7a2434858d67`, base `ddcf96955f3a62081d7ab24f922d8031c44e6202`. Exact-head Build [38227563489](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563489) passed Analyze, test shards 0–5, Debug APK and Release APK.
- **PR #2627 Device Smoke** [38227563488](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563488) remains IN PROGRESS at the latest poll. Home, Quick Capture, SQL Persistence and SQL Migration are SUCCESS; Backup/Restore and People are IN PROGRESS. The currently listed artifacts are Home and Quick Capture only. Do not treat the run as complete until all six lanes finish; inspect final artifacts and results.
- **Documentation PR #2626:** OPEN, mergeable, head `3c5a26a2481305c5b8a542f3c5b977e1fcbfd6b0`, base `ddcf96955f3a62081d7ab24f922d8031c44e6202`. Its Build [38228374059](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38228374059) currently has Analyze and all six test shards passing; Debug/Release APK jobs are still IN PROGRESS. Device Smoke [38228373999](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38228373999) is not complete: Home and Quick Capture are IN PROGRESS; People, SQL Persistence, SQL Migration and Backup/Restore are QUEUED. This checkpoint update will cause another CI cycle on the documentation branch; verify the resulting exact-head runs before considering merge.
- **PR #2619 cleanup:** OPEN and currently reports `mergeable=false`, head last recorded as `387694b5d5b29ca5fb72fedead56ed91368ca460`. Do not merge blindly. Continue path-by-path review and reconcile the branch against current main, then require exact-head Build and all six Device Smoke lanes.
- **Actions recorded during this continuation:** posted fresh status comments to PR #2627 and Issue #2102; comments record the incomplete Device Smoke state and preserve the no-premature-merge/release gate.
- **UX requirement:** compact task cards/rows should apply consistently beyond Home/Calendar to Reports, Next Action, Notebook, search/results and other lists where appropriate. Current PR #2627 specifically implements Home card progressive disclosure and compact Calendar reminder rows; it does not yet prove coverage across every listed surface. Treat broad compact-density coverage and Persian RTL/compact-screen screenshot review as open acceptance items.
- **Decision:** keep PR #2627 unmerged until six smoke lanes complete and visual acceptance is recorded. Do not infer physical-device acceptance from emulator results. Release remains **NO-GO** until physical-device Calendar same-event update/no-duplicate behavior, real Android file-provider Backup/Restore with Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen visual acceptance, and explicit product-owner approval are evidenced.
- **Next actions:** (1) poll exact-head #2627 Device Smoke and review all six lanes/artifacts; (2) poll exact-head #2626 Build and Device Smoke after this documentation update; (3) do compact RTL visual acceptance; (4) reconcile #2619 against main without losing canonical backup/data semantics; (5) continue dependency-aware integration of overlapping UI PRs #2591/#2595/#2602/#2607. Do not add meaningless commits to manufacture CI and do not merge overlapping drafts independently.

---

# AUTHORITATIVE LIVE CONTINUATION — 2026-10-12 (verified after PR #2625 merge)

This is the first section to read on every continuation. Historical notes below are retained for audit and are superseded wherever they conflict with this checkpoint. Recheck live GitHub before every write or readiness decision.

- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Current main checkpoint: `ddcf96955f3a62081d7ab24f922d8031c44e6202` (PR #2625 merged).
- **Completed — execution-memory refresh:** PR [#2625](https://github.com/mobinpda-lab/Arvin-clean/pull/2625) merged at `ddcf96955f3a62081d7ab24f922d8031c44e6202`. Exact-head Build [38224390186](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38224390186) passed Analyze, test shards 0–5, Debug APK and Release APK. Exact-head emulator Device Smoke [38224390103](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38224390103) passed all six lanes: Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore. This is emulator evidence, not physical-device acceptance.
- **Owner UX direction — compact task density (2026-10-12):** reduce task card/row vertical height wherever practical, especially Home and Calendar, and consistently in Reports, Next Action, Notebook, search/results and all task lists. Prefer compact rows; keep title and essential status/date visible; hide/collapse descriptions, checklist previews, tags and secondary metadata by default, reveal full information on tap/expand/detail. Preserve data, touch target usability, legibility, accessibility, Persian RTL and compact-screen responsiveness. Add regression tests for collapsed defaults and full-content expansion, then perform screenshot/physical-device visual review. This is presentation-only; do not change Task persistence, recurrence, Calendar identity/sync or backup semantics. Requirement recorded on [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607) and [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102).
- **PR #2627 — compact task density implementation:** OPEN, non-draft, current head `91b949f2417d3ca5aa5a7868ef7d7a2434858d67` (base `ddcf96955f3a62081d7ab24f922d8031c44e6202`). Home task titles are single-line/ellipsized; Task description, follow-up preview, checklist progress, taxonomy and priority detail are hidden by default and available via per-task disclosure; due date remains visible. Calendar reminder rows use dense layout and one-line clamped date/time summaries. Initial exact-head Build [38226230568](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38226230568) failed one regression test because expanded cards did not render `Task.description` (176 passed, 1 failed); Analyze, Debug/Release APK and the other five test shards passed. The defect was fixed in commit `91b949f2417d3ca5aa5a7868ef7d7a2434858d67` by rendering non-empty Task description only while expanded. Corrected exact-head Build [38227563489](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563489) now PASSES Analyze, all six test shards, Debug APK and Release APK. Device Smoke [38227563488](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38227563488) remains in progress: Home and Quick Capture passed; SQL Persistence and SQL Migration were running; People and Backup/Restore were queued at last poll. Keep unmerged until all six emulator lanes pass and Persian RTL/compact-screen visual review is recorded.
- **PR #2607 — broad pastel/compact UI:** OPEN/DRAFT, head `8d3d60a1b321fa4ceb9f5da779a144d3705b9103`, merge conflicts reported. Build [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) passed on that head; Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) was skipped because the PR is Draft. Do not merge independently. Reconcile with #2591/#2595/#2602 into one integration head; include the compact-density requirement and test collapsed/expanded content.
- **PR #2602 — Task Editor taxonomy/progressive disclosure:** OPEN/DRAFT at `1ddea0c9e6481dbf944f70f4faceb91499908c80`; no exact-head workflow run/status was returned in the latest checks. BLOCKED pending an authorized workflow trigger and verified exact-head results. Do not manufacture CI evidence with a meaningless commit or weakened tests.
- **PR #2619 — cleanup:** OPEN, unmerged; head `387694b5d5b29ca5fb72fedead56ed91368ca460`; latest metadata reports `mergeable=false`. Its Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) and six-lane emulator Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) passed on that head. Reconcile with current main, review every deletion/migration and rerun exact-head validation before merge.
- **Architecture invariants:** Task remains the sole source of truth; Quick Add and Full Form edit the same Task identity; Category = Group; Checklist and Repeat belong to Task; Repeat creates no copied root Tasks and past history remains immutable; Calendar is a projection and updates the same external event by stable Task/event identity; Home and Reports do not own parallel storage. Keep root `Task.description` as the sole root Task text field; do not add root `Task.note` or alter schema/migration/backup without explicit approval.
- **Integration rule:** do not merge overlapping #2591, #2595, #2602 and #2607 independently. Reconcile to one canonical integration branch, then require exact-head Analyze, all six test shards, Debug/Release APK, relevant emulator smoke and review.
- **Release status: NO-GO.** Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN until physical-device evidence covers Calendar same-event update/no duplicates, Android file-provider Backup/Restore and restored Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen acceptance, and explicit owner approval.
- **Next action:** reconcile overlapping UI work into one tested integration head that implements compact task density; separately reconcile and review #2619; resolve #2602's missing exact-head CI through an authorized trigger. Do not claim physical-device acceptance based on emulator tests.

## Execution status

- **Completed:** #2625 exact-head Build and all six emulator smoke lanes; merged.
- **In progress:** UI integration, compact card/row density and progressive disclosure; PR #2627 exact-head revalidation after the description-display fix.
- **Blocked:** #2602 exact-head CI evidence; #2619 base/conflict reconciliation and path review; physical-device acceptance and Persian RTL/compact-screen visual review.
- **Current bottleneck:** overlapping UI PRs, #2627 revalidation still running, and unresolved #2602 CI evidence.
- **Next checkpoint:** confirm #2627 Build and all six emulator smoke lanes on the corrected exact head, then reconcile overlapping UI PRs into one integration head.

---

# LIVE RECHECK ADDENDUM — 2026-10-12 (latest GitHub verification)

This addendum supersedes earlier workflow-status wording below where it conflicts. It is on the proposed documentation branch only until PR #2621 is reviewed and merged.

- Current `main` observed SHA: `a4dae51e93d9b3dcbc55ded366280e59183f16bc`. Exact-main Build [38202955720](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955720) passed Analyze, test shards 0–5, Debug APK and Release APK; exact-main emulator Device Smoke [38202955719](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955719) passed all six lanes (Home, Quick Capture, People, SQL Persistence, SQL Migration, Backup/Restore).
- PR #2619 cleanup exact head `387694b5d5b29ca5fb72fedead56ed91368ca460`: Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) and all six emulator lanes in Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) passed. Maintainer path-by-path review and physical-device acceptance remain outstanding; do not merge solely on CI.
- PR #2621 live-state documentation head before this addendum: `62d16314809b70914d21efaffccca436c969258d`. Build [38218042934](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38218042934) passed Analyze, test shards 0–5, Debug APK and Release APK. Device Smoke [38218042946](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38218042946) passed all six emulator lanes. This evidence validates that prior PR head only; revalidate the new head after this addendum.
- PR #2602 remains OPEN/DRAFT at head `1ddea0c9e6481dbf944f70f4faceb91499908c80`; live queries returned no exact-head workflow runs or commit statuses. The latest three test-harness corrections therefore remain unvalidated. Do not merge.
- PR #2591 has a prior exact-head Build pass but no verified physical-device acceptance; #2595 lacks current exact-head validation; #2607 remains overlapping and reports merge conflicts. Do not merge #2591/#2595/#2602/#2607 independently. Next code action is a dependency-aware, single integration head followed by exact-head Build + all six emulator lanes.
- Owner-provided visual references remain tracked in [#2623](https://github.com/mobinpda-lab/Arvin-clean/issues/2623) and [#2624](https://github.com/mobinpda-lab/Arvin-clean/issues/2624). Their visual contracts and the pastel visual decision are documented, but the issue bodies still do not prove that the original image binaries are committed to GitHub or that runtime UI has passed screenshot comparison.
- Release remains **NO-GO** until real-phone evidence covers Calendar same-event update/no duplicates, Android file-provider Backup/Restore and restored Calendar-link integrity, installed-app golden flow, Persian RTL/compact-screen acceptance, and explicit product-owner approval. Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) open.

# LIVE CONTINUATION OVERRIDE — 2026-10-12 (verified)

This is the latest continuation checkpoint in this proposed change. It becomes authoritative on `main` only after review and merge. Refresh GitHub before every write or readiness decision.

- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`; last observed main SHA: `a4dae51e93d9b3dcbc55ded366280e59183f16bc`.
- **Current main validation:** Build [38202955720](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955720) passed Analyze, test shards 0–5, Debug APK and Release APK; Device Smoke [38202955719](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38202955719) passed Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore emulator lanes on that main checkpoint.
- **PR #2619 — cleanup:** open, unmerged, mergeable; current head `387694b5d5b29ca5fb72fedead56ed91368ca460`. Exact-head Build [38213691941](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691941) completed successfully: Analyze, test shards 0–5, Debug APK and Release APK all PASS. Exact-head Device Smoke [38213691798](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38213691798) completed successfully: Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore all PASS on Android Emulator. This closes automated validation for the current cleanup head only; path-by-path deletion/content-migration review and physical-device acceptance remain separate gates. Do not merge until maintainer review is complete.
- **PR #2620 — consolidated project report:** open, ready for review, unmerged. Exact-head Build [38211356787](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38211356787) passed Analyze, all six test shards, Debug APK and Release APK. Device Smoke [38211356834](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38211356834) was skipped for this documentation-only change, as expected.
- **PR #2618 — prior state refresh:** its branch conflicts with current main and must not be merged as-is. This PR is a clean replacement based on current main; after merge, read the file back at the merge SHA to confirm the live checkpoint persisted.
- **Overlapping product changes:** #2591 Universal Time Picker has Build success on exact head `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 Task Form does not have exact-head Build evidence in the latest query; #2602 exact head `1ddea0c9e6481dbf944f70f4faceb91499908c80` has no workflow runs returned; #2607 Build succeeded on exact head `8d3d60a1b321fa4ceb9f5da779a144d3705b9103` but PR metadata reports merge conflicts. Do not merge these overlapping branches independently. Reconcile them into one integration head and validate that exact SHA.
- Keep [Issue #2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) OPEN and Release **NO-GO** until real-phone evidence covers Calendar update-same-event/no duplicates, Android file-provider Backup/Restore and restored Calendar-link integrity, installed-app golden flow, Persian RTL/compact-screen acceptance, and explicit owner approval.
- No installation or manual testing is requested from the owner yet. Continue repository inspection, code/test integration, automated validation and documentation first. Ask for phone installation only after one integrated candidate has passed available automated gates; then provide the exact APK, install steps and short acceptance checklist.
- **Next action:** complete path-by-path review of #2619 deletions and migrated canonical content; recheck whether any stale references remain. In parallel, continue reconciling #2591/#2595/#2602/#2607 into one integration head without adding root `Task.note`. The #2621 memory-refresh branch had Build PASS on pre-refresh head `ab8a10fd6be03a991ab1710ef6ad3cd6b69cc1a8` (run [38214238032](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38214238032)); its Device Smoke [38214238051](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38214238051) was still in progress at last poll (Home, Quick Capture and SQL Persistence passed; SQL Migration and Backup/Restore running; People queued). This memory update creates a new head, so recheck exact-head CI before treating the refreshed memory branch as validated.

---

# ARVIN EXECUTION STATE — LIVE CHECKPOINT
**Checkpoint:** 2026-10-12 (UTC)
**Repository:** `mobinpda-lab/Arvin-clean`
**Branch:** `main`
**Last observed main SHA:** `a4dae51e93d9b3dcbc55ded366280e59183f16bc`
**Overall state:** IN PROGRESS — RELEASE BLOCKED

> This checkpoint supersedes older live-status and CI claims below. The changes in this PR are proposed until reviewed and merged.

## Last completed step
1. Read the v8 execution command and reviewed the existing memory drafts in PRs #2600 and #2608.
2. Rechecked current `main`, release-gate Issue #2102, open PRs and exact-main workflow runs.
3. Confirmed all required `docs/arvin-memory/ARVIN_*.md` memory files are **absent from current main**. They exist only in open documentation branches/PRs; therefore the v8 “read execution state first” path is currently not available on main.
4. Confirmed cleanup PR #2613 is merged; current main is `cea76673d871ce52b84dacf69f355c4282802baa`.
5. Started a documentation-only consolidation branch from this exact main commit to restore the canonical memory package without direct writes to main.

## Current exact-main validation
- Build: [run 38178428086](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428086), exact SHA `cea76673d871ce52b84dacf69f355c4282802baa`. Fresh API query confirms overall conclusion `success`; Analyze, all six test shards, Debug APK and Release APK jobs are completed successfully. Non-expired artifacts: Debug APK 11717311531 (92,487,308 bytes), Release APK 11716328109 (32,681,865 bytes). This is exact-main CI evidence, not physical-device acceptance or release approval.
- Device Smoke: [run 38178428043](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38178428043), exact SHA `cea76673d871ce52b84dacf69f355c4282802baa`. Latest live job query confirms all six scenarios completed successfully: Home, Quick Capture, People, SQL Persistence, SQL Migration and Backup/Restore. This is automated Android-emulator evidence only; it does not prove physical-device acceptance. Earlier `BlobNotFound` log retrieval is superseded by the completed job conclusions and must not be reported as a current test failure.
- Recover/inspect the existing runs and artifacts before triggering duplicate workflows. If recovery is impossible, document the failure and start one controlled fresh validation batch only after checking workflow state.

## Completed
- PR #2613 merged at `cea76673d871ce52b84dacf69f355c4282802baa`: documentation cleanup only; no product code/schema/migration changed.
- PR-head CI and emulator smoke passed for #2613 head `55c3f829d7e443a6a4ae91de5e4b433965357400`; this is not physical-device acceptance.
- Live checkpoints recorded on Issue #2102 in comments [6114272356](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6114272356) and [6114324441](https://github.com/mobinpda-lab/Arvin-clean/issues/2102#issuecomment-6114324441); the latter captures the partial APK/screenshot artifact evidence.

## In progress
- Restore the required project-memory package to main through a reviewed documentation-only PR. The required files currently live in overlapping draft PRs #2600 and #2608; do not merge either stale branch blindly.
- Exact-main Build and all six Device Smoke emulator scenarios are confirmed successful. Physical-device acceptance remains outstanding; do not equate emulator CI with installed-device evidence.
- Reconcile shared implementation files in #2591, #2595, #2602 and #2607 before integration. Their diffs overlap in Task Editor, Quick Capture, main routing, Report Center and Universal Arvin Time Picker.
- Preserve the report-filter owner requirements and Persian/Jalali time controls; implementation/combined-head acceptance is still open.

## Blocked / release gates
- Physical-device Calendar same-event update/no-duplicate proof.
- Real Android system file-provider Backup/Restore, rollback and restored Calendar-link integrity.
- Golden-flow installed-device acceptance: Task create/edit, Date/Time, Checklist, Repeat/Occurrence, permissions, keyboard/scroll/error states.
- Persian RTL, typography and compact-screen visual acceptance.
- Explicit owner approval after reviewing evidence.
- The `Task.note` vs `Task.description` data-contract issue remains owner-decision sensitive; do not add a root `Task.note`, alter schema, migration or backup semantics without an explicit decision. Existing recorded direction says root `Task.description` remains canonical.

## Next action
Finish the documentation consolidation PR only after its exact-head Build completes successfully and its checkpoint remains coherent. The exact-main Device Smoke run is complete with all six emulator scenarios passing; next, preserve this updated evidence, then continue reconciling overlapping code PRs into a single tested integration sequence. Do not publish an APK as a release or claim Release Ready.

## Current bottleneck
Project memory is not present on main and PR #2614 exact-head Build is still running. Exact-main Build and all six emulator smoke scenarios pass, while release acceptance still lacks physical-device proof and explicit owner approval.

## Product invariants
- Task is the sole source of truth; Quick Add and Full Form must preserve the same Task ID.
- Category and Group are synonyms; do not create a separate Group entity/store.
- Checklist belongs to Task; Repeat is a Task capability and must not create copied Task records.
- Repeat chain: Task → Repeat Definition → Occurrence → Execution State → History; past immutable, future adjustable.
- Calendar is a projection; update by Task ID / External Event ID, never by title/date matching.
- Tracking does not replace CRM; Home has no independent storage; Report is a read-only consumer.
- Preserve user data, stable IDs, Persian RTL and VazirHarf v34.003.
- Mark work complete only with relevant code, tests, build, validation and evidence.

---

## Historical checkpoints (not current status)
The material below is retained to preserve earlier audit findings and evidence links. Its dates, branch heads, run statuses and next-action statements are historical; the live checkpoint above always wins.

# LIVE CONTINUATION CHECKPOINT — 2026-10-11 18:27 Iran time

This checkpoint supersedes older PR-head snapshots and "Next action" entries below. Refresh all live GitHub state before future operations.

## Latest completed step
- Re-read this execution state first, then refreshed live PR #2591/#2595/#2600/#2601/#2602 and accepted RTLC issue #2605.
- Compared patches for #2591, #2595 and #2602 to identify shared files and data-contract risk. All three are still OPEN; #2591 and #2595/#2602 are Draft, #2595 is stacked on #2591. PR #2600 remains OPEN/DRAFT. Current reported heads: #2591 `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 `0786a2e067594d92b35c6a3028c633e8abc9bb3d`; #2600 `0413c5a7b862d4e0718f67a2587ec8dc36b04429`; #2601 `b832aeb6e0f55c78db0b1814adc0d5bd63447c23`; #2602 `15c40a81ec7e45fe690de40ebbd9cf005e57af80`. Refresh before relying on them.
- Verified current main `a6ced27660d34cd87dd8915aff68d3a7555fd57a` and read `lib/models/task.dart`: canonical root Task has `description`, but no root `note`; it already has Notebook item-kind and scoped note concepts.
- Found a new unapproved data-contract change in #2595: adds root `Task.note`, modifies Task serialization/deserialization and TaskStore known keys, and changes backup/restore test expectations. Command v8 lists Task Description but does not authorize a second root field. This is a data/architecture gate, so do not silently approve it or propagate it.
- Posted review comments on #2595 and #2602 to keep both Draft and reconcile the overlapping form lane; comments: https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110326453 and https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6110326886.
- Recorded the finding in `ARVIN_PROBLEM_REGISTER.md` (commit `4fa06f3f2feb3e368ef55116320e76ad235ee216`) and `ARVIN_DECISION_LOG.md` (commit `53a35664b40b1ab64ba9a8642663013056953fe3`) on the existing documentation branch. GitHub Read/Write access was used; no app code, main, APK, merge, or release was changed.

## Current status
- **Completed:** Cross-PR overlap/data-contract audit; comments posted; data-risk gate recorded in memory.
- **In Progress:** Universal time picker rollout and Task form reconciliation; RTLC integration remains accepted direction but not implemented/accepted; product and release evidence.
- **Blocked:** Approval of root `Task.note` vs existing `description` semantics and legacy data/backup mapping requires explicit product-owner decision. This is the stop condition defined by Command v8 (data risk/architecture change).
- **Current bottleneck:** Several Task Editor PRs overlap and #2595 introduces an unapproved Task data-contract change; #2602 previously failed three test shards and Device Smoke was skipped.
- **Next action:** Ask owner whether a separate root Task Note is intended in addition to Description. Until decided, continue only safe read-only patch/CI evidence work and documentation reconciliation; do not merge #2595/#2602 or propagate `Task.note`. After decision, consolidate to one canonical form/time-picker branch, fix test root causes without weakening tests, then integrate RTLC once and run exact-head CI + Device Smoke + physical-device acceptance.

---

## Documentation audit writeback — 2026-10-11

- Conversation-decision history was added at `docs/arvin-memory/ARVIN_CONVERSATION_DECISION_HISTORY.md`, commit `cef2a03e7d4f0dd73cbefad796e0393c8723267d`; read-back verified time-picker and checklist requirements are present.
- `ARVIN_PROBLEM_REGISTER.md` addendum committed at `abfe3d719eed8ec134c26fd82ba8d432bd83e315`; `ARVIN_EVIDENCE_MAP.md` addendum committed at `7933bf44f36fdfed1da9b4e918acd0218a28bbb6`.
- PR #2600 audit comment posted: https://github.com/mobinpda-lab/Arvin-clean/pull/2600#issuecomment-6109981897.
- Current memory branch has been updated but is still not main; re-fetch current head before any later write. No application code, APK, merge or release change was made.

# DEEP CONVERSATION AUDIT CHECKPOINT — 2026-10-11 (supersedes stale next-action notes below)

## Owner request
The owner explicitly asked for a meticulous review of this conversation so no requirement, prior finding, or dependency is missed. This checkpoint records that audit and corrects earlier stale notes below; use live GitHub before every subsequent action.

## GitHub Read/Write and live repository reality
- Read/Write access verified in this run. All writes are limited to the existing documentation branch `docs/arvin-autonomous-memory-20261011`; no write to `main`, no app code edit, no APK build, and no release/merge performed.
- Latest main commit confirmed by commit search: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. `main` does not yet contain this `docs/arvin-memory/` checkpoint.
- PR #2600 is OPEN/DRAFT, branch `docs/arvin-autonomous-memory-20261011`, head `40963f0fe54ba8d34375c1c6c7fc62c01f27b627`, base SHA `72a2f4cc24df7a38eff9856ce403461615db5280` (stale versus main). Do not merge until rebase/reconciliation and validation.
- Documentation PRs #2598 (`32860ad0a07778d210ba1dac4caf2dc68effccc5`), #2599 (`bd03c61749f4cf093f25251330a54ca773f48c7f`) and #2600 overlap and are all based on old main `72a2f4c...`. Reconcile into one consistent authority hierarchy; do not create competing status/roadmap/memory sources.
- #2590 is OPEN (not merged), head `1810e454a20e29eec837be9ac446e222795d79f8`; #2591 is OPEN/DRAFT, head `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 is OPEN/DRAFT, head `0786a2e067594d92b35c6a3028c633e8abc9bb3d`, stacked on #2591; #2602 is OPEN/DRAFT, head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`; #2601 is OPEN, head `b832aeb6e0f55c78db0b1814adc0d5bd63447c23`. Each still has stale base `72a2f4c...` except #2595's base is the earlier #2591 head `0c43dfbe3c0f7188cea6e03614300be81271e158`.
- Latest recorded #2602 CI: Build #38139809938 passed Analyze and Debug/Release APK jobs but failed three test shards; Device Smoke #38139809930 was skipped. Failures include missing repeat control keys, automatic/manual reminder behavior, date-only All-Day persistence, custom Clock Dial test, and taxonomy row width 99.33px vs >270px expectation. Do not merge or weaken tests.
- RTLC decision #2605 is OPEN and explicitly accepted as product direction, not implemented/accepted. Existing `RecurrenceTrackingLevel` JSON field and history/checklist foundations must be reused; keep `followUpEnabled` distinct.
- Release gate #2102 and owner acceptance ledger #1139 remain open. Main-head workflow/status lookup previously returned no PR-associated runs/statuses; that is missing evidence, not a pass. Physical-device acceptance and owner release approval remain unverified.

## Audit findings: important items that must not be lost
1. **Universal time picker (P0 product consistency):** #2589 is accepted UX direction, implementation PR #2591 and docs PR #2590 remain open. Audit all direct/custom time pickers and passive time formatting, including Home filters, Backup Schedule, Follow-up, Reports, Task Editor and Quick Capture. Preserve canonical Task times, reminder/follow-up/repeat/calendar/backup behavior; Persian digits, RTL, 24-hour dial, exact-minute entry, contextual title, cancel/save safety, and real-device proof are required. Existing audit says six direct `showTimePicker` call sites remained on main; recheck current source before action.
2. **Task form overlap and acceptance:** #2595 and #2602 touch the same form; #2595 depends on #2591. Choose one canonical branch only after comparing live diffs/heads. Keep quick entry minimal and Full Form editing the same Task; do not duplicate Tasks. Progressive disclosure must not hide or break date/time, All-Day, reminder, repeat, priority or checklist.
3. **Repeat Tracking Level (RTLC):** after Repeat, selector «نوع پیگیری» → «عادی» default / «مهم و قابل پیگیری»; use existing `recurrence.trackingLevel`. Then separately audit Home's restrained cue and Report Center filters/metrics. Preserve Task ID, occurrence history immutability, per-occurrence checklist isolation, and backup compatibility. Do not conflate with Follow-up.
4. **Calendar installed-app regression:** owner reported missing «ویرایش» and «ثبت در تقویم گوشی», and recurrence showing only current day rather than planned days (up to seven). #2587 and #2570 are merged in current mainline, but this is code status only; #2535 and #1139 remain acceptance gates. Test action visibility, all scheduled dates, stable linked-event update/no duplicates on physical device.
5. **Backup/restore P0:** #2585 is merged at current main SHA, and #2587 is merged at `c57606c...`. Still unverified: physical Android system file-picker/provider, export/restore round-trip, late-stage rollback, preservation of IDs/relations/settings/notebook checklists/catalogs/calendar links, and before/after integrity.
6. **Reports:** #2385 remains open. Extend existing canonical report/filter/print/share/PDF paths; do not create a second report model/engine. RTLC report filtering/metrics are an additional acceptance gate.
7. **Taxonomy:** Project, Category, Tag are canonical; Category = Group synonym, no fourth Group entity/store. Verify actual schema; do not infer a Project foreign key. RTL selector order and width must be genuinely usable at target phone viewport.
8. **Visual/product contract:** preserve Persian RTL and VazirHarf v34.003 (do not replace with Vazirmatn), approved palette (#4A4CAB, #E9EAFF, #F8F8FB, #FDFDFE, #232433, #80829C), Home's four axes Time/Project/Category/Tag, no obsolete stats cards/title/dropdown, clock + calendar icons side-by-side in every create/edit form, and approved reminder widget/lock-screen actions. Color-only changes do not satisfy redesign acceptance.
9. **Checklist requirement:** checklist remains part of Task. The owner requested a high-priority checklist directly under the full/edit Task form, generic for all Tasks (example: daily school checklist active at 06:00 with کیف/خوراکی/لباس). Recurrence occurrence state must remain independent; do not create a separate checklist subsystem.
10. **Release handover:** before final handover, require release notes, installation guide, user guide, known issues, architecture summary and evidence report, tied to an exact candidate artifact and explicit owner acceptance.

## Completed audit step
Compared the current Command v8 against the existing memory documents, decision records, live issues and overlapping PR state. Found that earlier snapshots contain contradictory/stale claims and that the conversation decision-history file is not present on this memory branch. The new decision-history document is being added on this existing branch to close that memory gap; it is an index of decisions, not implementation evidence.

## Next action
1. Read back the new conversation decision-history file and this updated state from this exact branch.
2. Comment on #2600 with the audited gaps and stale-base/documentation hierarchy.
3. Select one canonical task-form implementation lane after diff/test comparison; repair #2602 root causes without weakening tests, then integrate RTLC once.
4. Recover/run exact-current-main Build + Device Smoke evidence; continue physical-device and owner acceptance gates.
5. Reconcile/rebase docs PRs before any merge. Do not claim final/release-ready until product evidence and owner acceptance exist.

---

# LIVE CONTINUATION CHECKPOINT — 2026-10-11

This section supersedes conflicting older snapshots below. The detailed earlier notes are historical context and must not be treated as current status without rechecking.

## Startup result
- Repository: `mobinpda-lab/Arvin-clean`; branch checked: `main`.
- Current main SHA: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` — https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a
- GitHub access: Read/Write verified; this checkpoint update is being committed only to the existing documentation branch for PR #2600, not directly to main.
- PR #2585 backup/restore safety is MERGED at `a6ced276...`.
- PR #2587 Calendar collapsed-card actions/recurrence is MERGED at `c57606c223a1d6141bd3d11e1a75cc5cda428470`.
- The main-head Actions wrapper returned no PR-associated workflow runs and combined status returned no statuses for `a6ced276...`; this is **no current-head CI evidence from those lookups**, not proof that no workflow exists or ever ran.
- PR #2600 (this memory branch) remains OPEN/DRAFT and is based on old main `72a2f4cc...`; it must be rebased/reconciled against current main before merge.
- PR #2598 (AMPOP/governance), #2599 (repository audit), and #2600 (memory) are three overlapping OPEN/DRAFT documentation PRs based on the old main. Keep them unmerged until they form one consistent hierarchy and avoid competing status/roadmap/memory copies.
- PR #2601 integrated APK candidate remains OPEN and is based on old main; it is not a release artifact accepted for delivery.
- PR #2602 task-editor changes remain OPEN/DRAFT. The latest recorded Build passed Analyze and APK builds but failed three test shards; Device Smoke was skipped. Do not merge. Fix repeat/reminder reachability, date/time behavior and RTL taxonomy layout; reconcile overlap with PR #2595.
- PR #2595 overlaps task form changes and is stacked on PR #2591 shared time picker. Keep one canonical implementation and validate the final combined head. PR #2591 still lacks verified physical-device acceptance.
- Owner acceptance/release blockers remain in #1139 and #2102; Calendar installed-device recurrence/actions in #2535; advanced Report Center in #2385; taxonomy conformance audit in #2580; repeat/checklist lifecycle acceptance in #2254.
- Physical Android-device acceptance, exact-current-main Build/Device Smoke evidence, complete Golden Flow, full restore round-trip/rollback proof, and final owner acceptance remain NOT VERIFIED.

## Last completed step
Re-read the requested Autonomous Delivery & Evolution Command against live GitHub, read the memory state/evidence map on the existing PR #2600 branch, checked the main commit history, and refreshed PR/issue state. Confirmed that the six-file memory set is incomplete on this branch: `ARVIN_PROBLEM_REGISTER.md` is missing.

## Next action
1. Complete the existing memory branch with a problem register and this live checkpoint.
2. Read back both changes and verify exact commit/file paths.
3. Comment on PR #2600 with the stale-base and documentation-hierarchy blockers.
4. Continue with the highest-priority product gate: recover exact-current-main CI/Device Smoke evidence and reconcile the task-editor PR overlap; do not claim release readiness.

## Current bottleneck
Release evidence and owner acceptance, not lack of another architecture or another workflow. Do not create a new factory or parallel implementation.



Updated: 2026-10-11 (live GitHub recheck; exact-head Build passed, Device Smoke partially complete)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified by live operations.
Authority: live GitHub refs, source, tests and workflow evidence.

## Live recheck — 2026-10-11 13:40 Iran time

- Re-read this state and evidence map on the existing memory branch; confirmed PR #2600 is the intended documentation-only continuation path. The file is not yet on `main`.
- Main remains `72a2f4cc24df7a38eff9856ce403461615db5280`.
- PR #2585 exact head checked: `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Build run [38130522723](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522723) is complete and successful: Analyze, all six test shards, Debug APK and Release APK.
- Device Smoke run [38130522703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522703) is still in progress. Home, Quick Capture and SQL Persistence passed; SQL Migration and Backup/Restore are in progress; People is queued. Do not call the full smoke suite passed.
- No physical-device or actual Android system file-picker/provider acceptance was found. Release remains blocked; PR #2585 and #2587 remain unmerged.
- The live Build/Smoke runs above supersede the older pending status recorded below where they conflict.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.** No physical-device acceptance has been provided.

## Last completed step
- Read this state and `ARVIN_EVIDENCE_MAP.md` first, then rechecked PR #2585, Issue #2580, the relevant backup/settings/task/notebook sources, and current-head Actions.
- Owner approval for standalone Category/Tag portability was already recorded in PR #2585 and Issue #2580. The later owner-approved expansion requires notes/notebook checklists and portable app settings, stable-ID reconciliation, preservation of local-only records, omitted-key safety for legacy settings, and rollback across stores.
- Implemented in the existing branch `fix-backup-taxonomy-catalogs-20261010`, without a parallel restore engine:
  - `ArvinBackupManager.reconcileTasksById`: matching Task IDs update, backup-only Tasks add, local-only Tasks remain.
  - Project reconciliation uses stable Project IDs and preserves memberships for local-only Tasks.
  - Settings merge only applies supplied keys, including nested Calendar, backup schedule and Daily Content preferences. Explicit nullable defaults are serialized; older backups that omit a key do not reset it.
  - Daily Content preferences are included in foreground and scheduled backup payloads and validated before restore writes.
  - Scheduled backups now include Calendar-link metadata and canonical Category/Tag catalogs in addition to Tasks, Projects and portable settings.
  - Added tests for Task/Project reconciliation, local-only Notebook/checklist retention, partial legacy settings, explicit nullable settings and scheduled-backup payload contents.
- Current code PR #2585 head: `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Exact-head Analyze and all six test shards are SUCCESS; Debug APK is SUCCESS; Release APK is still IN_PROGRESS. Device Smoke: Home and Quick Capture are SUCCESS; SQL Migration and SQL Persistence are IN_PROGRESS; Backup/Restore and People are QUEUED. These are emulator/CI results, not physical-device acceptance. Previous exact heads exposed stale settings/replace-only test expectations; these were updated to the approved ID-reconciliation contract before the current head.
- PR #2585 remains OPEN / NOT MERGED. CI and emulator results do not prove real Android system file-picker/provider acceptance.
- Main base observed for PR #2585: `72a2f4cc24df7a38eff9856ce403461615db5280` (documentation-only PCTADP decision registration).
- Calendar linked-event edit [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) is merged at [`34a6cee`](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128); physical-device proof remains absent.
- Calendar action visibility/recurrence [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587) remains OPEN / NOT MERGED at `4442ce450e4295e500a9db6d5dc5b4d9657b3770`; historical exact-head Build #38089112669 and Device Smoke #38089112675 succeeded across emulator lanes. Physical-device acceptance remains absent.
- Memory documentation [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) remains OPEN / DRAFT; this state refresh is on its existing documentation branch.

## Current GitHub reality
- [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) remains open for the repository-wide Project/Category/Tag ontology audit. Owner approval for unused Category/Tag portability is recorded.
- [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) is the sole implementation path for backup/restore changes. Current head `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`; exact-head Analyze and all six test shards succeeded, Debug APK succeeded, Release APK and four Device Smoke lanes remain pending/in progress at the latest live check.
- Existing canonical storage remains authoritative: Tasks/Notebook items use TaskStore; Projects use ProjectStore; Category/Tag catalogs use TaskStore; Calendar-link identity uses ExternalCalendarLinkStore. No duplicate storage or restore engine was added.
- Notes and Notebook checklists are canonical Task records; backup paths load the full TaskStore rather than a filtered Home projection.
- Portable settings currently include AppSettingsService values, backup schedule and Daily Content preferences. Device-bound folder/provider URIs, secrets and transient encryption passphrases are not portable settings.
- Catalog merge remains additive and backward-compatible; formatVersion remains 1 and older backups may omit optional catalog/settings fields.

## Taxonomy audit findings (partial)
- `lib/models/task.dart`: `Task.category` and `Task.tags` are separate.
- `lib/models/goal_project.dart`: Project membership stores canonical Task IDs in `itemIds`; this model does not declare a Category relation.
- `lib/home/grouping/home_grouping_service.dart`: `HomeGroup<Task>` is a presentation grouping abstraction, not proof of a fourth domain entity.
- `lib/services/task_store.dart`: canonical Category catalog uses SQL `taxonomy_categories`; canonical Tag catalog uses SQL `tags`.
- `lib/services/tag_store.dart` defines legacy SharedPreferences key `arvin.tags`, but current search found no caller; migration derives SQL Tag rows from `Task.tags`, not `arvin.tags`. Keep this as a low-confidence legacy candidate and do not delete/migrate it without evidence it was populated by a shipped path.
- Source review confirmed the original backup gap for unused standalone Category/Tag catalog entries. The existing PR now serializes these catalog values and merges them additively with regression coverage. Exact-head tests are still pending.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy. Do not mass-replace “group”; classify domain, user-facing, presentation, generic technical and historical uses first.

## In progress
1. Complete exact-head Build for PR #2585: Analyze, all six test shards, Debug APK and Release APK.
2. Complete exact-head Android Device Smoke; inspect any failing shard/job and repair safely before claiming success.
3. Verify backup/restore round-trip with legacy v1 backups, unused + assigned catalogs, settings, notes/checklists, stable-ID reconciliation and late-stage rollback.
4. Complete physical Android system file-picker/provider and before/after data-integrity acceptance; emulator smoke is not a substitute.
5. Continue the repository-wide Project/Category/Tag audit and keep PR #2585 and #2587 open until physical acceptance is evidenced.

## Blocked / unproven
- Exact-head Release APK and Device Smoke for `5f59d7c7edb12217a2aa3f7a139a042676dc0e76` are still running/queued at the latest live check.
- Physical Android file-picker/provider backup and restore, failed-restore recovery and real data-integrity acceptance.
- Physical-device Calendar same-ID edit/no-duplicate behavior, action visibility, recurrence/checklist acceptance.
- Full Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- Full taxonomy conformance inventory and final release handover/owner acceptance.

## Next actions
- Poll exact-head Actions for `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`; use only evidence attached to that exact head. If Release APK and Device Smoke settle, refresh this checkpoint and the evidence map.
- If any job fails, inspect its log, fix the root cause in the same PR, and rerun validation on the new head.
- Update the evidence map after Build/Smoke settles, then continue physical-device acceptance and remaining taxonomy audit.
- Keep PRs open/unmerged; never claim release readiness from CI alone.

## Risk rules
Task remains the source of truth for Tasks and Notebook items; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Never claim user/device acceptance without direct evidence.

## LIVE CONTINUATION CHECKPOINT — 2026-10-11 (Command v8 + RTLC)

This section supersedes earlier next-action text where it conflicts. Do not restart analysis; continue from this checkpoint after a live recheck.

### Latest verified repository state
- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Latest main commit returned by GitHub commit search: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` (`fix(backup): preserve portable user data with safe restore`). The preceding mainline commit found was `c57606c223a1d6141bd3d11e1a75cc5cda428470` for Calendar collapsed-card actions/recurrence.
- GitHub Read/Write access is active. This update is restricted to the existing documentation branch for PR #2600; no direct main write is intended.
- Memory files are not present at the corresponding paths on main yet; the current memory branch is `docs/arvin-autonomous-memory-20261011`, PR #2600 OPEN/DRAFT, head `b285719410d380aa1f5d0df7c625493c243a3b12`, base SHA `72a2f4cc24df7a38eff9856ce403461615db5280`. This stale base must be reconciled before merge.
- Overlapping documentation PRs #2598/#2599/#2600 must be consolidated/reconciled before merge; do not merge stale documentation blindly.

### Latest completed step
- Read the owner-provided Autonomous Delivery & Evolution Command v8.
- Located the existing persistent-memory branch/PR rather than creating a parallel memory system.
- Registered the accepted Repeat Tracking Level Contract as [Decision Issue #2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), and recorded the decision against existing repeat work #2254 and Task editor work #2593.
- Read-only source audit confirmed that `RecurrenceTrackingLevel { normal, tracking }` already exists in `lib/models/recurrence.dart`, persists within the existing `Task.recurrence` JSON, and defaults to normal for older JSON. `Task` already carries `occurrenceHistory` and `checklistOccurrences`; recurrence repository/page and tests cover some tracking/progress behavior. Do not rebuild these.
- Source search did not find direct tracking-level integration in `lib/task_editor_dialog.dart`, `lib/report_center_page.dart` or Home. This is an integration audit target, not proof that no indirect path exists.
- Explicitly preserve the distinction between Follow-up and Repeat tracking: `followUpEnabled` must not be used as a substitute for `recurrence.trackingLevel`.
- Audit comments were recorded on #2605 and #2254. No application code, schema, database, engine or APK changed in this step; no tests/build/device validation were run for RTLC.

### Current completed / in progress / blocked
- COMPLETED: RTLC product decision registration; first-pass source audit; existing model and persistence support identified.
- IN PROGRESS: update this memory PR with the latest continuation checkpoint and RTLC decision/knowledge/problem/evidence records.
- BLOCKED / NOT VERIFIED: tracking-level integration in full Task Create/Edit, Home cue, Report Center filter and validated missed/remaining/upcoming metrics; full occurrence-history/checklist immutability tests; RTLC backup/restore round-trip; screenshots and physical-device acceptance.
- RELEASE BLOCKED: exact-current-main CI/device evidence and physical-device/owner acceptance remain required. Main-head status lookup is not sufficient to claim a pass.

### Next action — ordered
1. Read back and verify the memory-branch documentation commits and comment on PR #2600 about stale base/documentation hierarchy.
2. Inspect current PR #2591/#2595/#2602 heads and overlap; do not launch conflicting edits or merge failing/stale branches.
3. Continue RTLC with focused integration of the existing `recurrence.trackingLevel` into Task Create/Edit after Repeat, defaulting to «عادی». Keep Follow-up separate. Add/adjust tests for selection and JSON round-trip before widening to Home and Report Center.
4. Derive missed/remaining/upcoming metrics from canonical repeat/history projections; if definitions or model semantics are insufficient, document the exact gap before any protected model/engine/storage change.
5. Validate exact-head tests/build, backup/restore compatibility, screenshots and device behavior. Do not claim done until evidence and owner acceptance exist.

### Current bottleneck
Product acceptance and proof on the current exact head—not another parallel architecture or factory. Keep Task as source of truth, Repeat as Task behavior, occurrence checklist state independent, past history immutable and future settings adjustable.

## Fresh CI checkpoint — PR #2602 exact head (2026-10-11)
- Checked workflow run [#38139809938](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809938) for PR #2602 head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`: Debug and Release APK jobs passed, but overall Build failed because three quality test shards failed. Device Smoke [#38139809930](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809930) was skipped.
- Confirmed failures: repeat lifecycle control key missing; recurrence RollBox key missing; automatic/manual reminder tests failed; date-only All-Day persistence failed; custom due-time Clock Dial test failed; RTL taxonomy row width expected >270 px but actual 99.33 px.
- Recorded exact evidence in PR #2602 comment [#6109904220](https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6109904220). Do not merge or weaken tests; fix reachability/date-time/layout root causes and rerun all shards + Device Smoke.



## OWNER DECISION UPDATE — 2026-10-11

### Completed: Task Description vs Note decision
- Owner selected **Option 1**: retain only the existing root Task `description`; do not add a separate root `Task.note`.
- This supersedes the earlier “Blocked: ask owner” next-action text in historical checkpoints. The product decision is resolved; implementation cleanup and validation remain outstanding.
- Required follow-through: comment on #2595 and #2602; remove/revert root `Task.note` plus serialization/TaskStore/backup changes that exist only to support it; preserve existing Notebook/FollowUp note behavior; run exact-head tests/build and inspect backup/restore compatibility. Do not weaken tests or merge/release without evidence.
- GitHub Read/Write access used for recording this decision. App code has not yet been changed by this decision-recording step.

## OWNER DECISION — 2026-10-11 (supersedes earlier decision gate)
- Owner selected Option 1: keep the existing root `Task.description` as the only root Task text field; do not add a root `Task.note`.
- This resolves the prior owner-decision gate. Scoped `FollowUp.note` and Notebook note/checklist concepts remain unchanged; this decision does not authorize deleting or migrating those scoped fields.
- Required implementation on the canonical Task-form lane: remove only the newly introduced root `Task.note` from the Task model, JSON serialization/deserialization, TaskStore known-key handling, editor UI/state, and backup/restore test changes. Preserve legacy payload safety and existing Description values; add/retain regression tests proving legacy JSON and backup/restore round-trip still work without a second root field.
- PR #2595 must remain Draft until this correction and exact-head Analyze, all test shards, Debug/Release APK and relevant device smoke are verified. PR #2602 must not reintroduce the root field and its previously failing test shards must be fixed at root cause; never weaken assertions.
- Current execution result: decision resolved and documented; implementation patch not yet applied or validated in this step. No merge, main write, APK build, or release occurred.


## LIVE CONTINUATION — 2026-10-11, root Task text field correction
- Owner decision: root `Task.description` only; no root `Task.note`. This supersedes the earlier decision gate.
- Applied a focused correction to the existing PR #2595 branch `feat/task-form-simple-first-20261011`: removed the root field from `Task` construction/model JSON, removed Task Editor's duplicate note controller/input, removed the TaskStore root known-key addition, updated backup/restore and TaskStore contract tests, and added a regression test that a legacy root `note` key is ignored while `description` is preserved. FollowUp.note and nested FollowUp persistence were retained.
- Latest branch head observed: `cc8180575bb50087283c43a444d54af05de9bc81`. GitHub workflow runs associated with this exact head were queued at last check (ARVIN Orchestrator PR Wakeup, ARVIN Production Loop, ARVIN Orchestrator). Therefore code is changed, but Analyze/tests/build/device validation are **PENDING**, not passed.
- Read-back checks: Task class has no root note field; Task Editor has no note controller or root note input; Task contract regression test is present; TaskStore known Task keys no longer add root note. No merge, main write, APK build, or release occurred.
- Next action: inspect workflow/job status for exact head `cc8180575bb50087283c43a444d54af05de9bc81`; fix any real failures without weakening assertions. Recheck PR #2602 for the same forbidden root field and resolve its previously failing shards separately. Keep #2595/#2602 Draft until evidence passes.


## Validation read-back correction — 2026-10-11
- Exact latest code head remains `cc8180575bb50087283c43a444d54af05de9bc81` for the Task Description-only correction.
- Associated runs `38150519178` (PR Wakeup), `38150519183` (Production Loop), and `38150519223` (Orchestrator) completed successfully, but they are orchestration jobs only. Combined commit status returned no statuses. This is **not** Analyze/test/build evidence; product validation remains pending.
- Read-only inspection of current `main/lib/notebook_page.dart` confirms Notebook notes are handled through the Notebook repository/editor and `description`; that code was not changed. `FollowUp.note` remains in its own nested model and storage.
- PR #2595 progress comment posted: https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110488803.



## OWNER FIELD REPORT — 2026-10-11: recurrence and calendar edit sync
- Owner reported: repeating Tasks are not generating the expected 7 occurrences; when recurrence is enabled, today's local date and current local time must be filled automatically but remain editable; automatic Calendar sync still fails after Task edits.
- Reused existing contracts/issues #2535 (P0 recurrence/calendar acceptance), #2254 (recurrence lifecycle/count architecture), and #2248 (Task↔Event identity/auto-sync architecture gate). No parallel Task, occurrence store, or Calendar engine is authorized.
- Safe editor implementation started in Draft PR #2606, branch `fix/repeat-seven-default-date-time-20261011`: selecting a repeat frequency fills current local date/time when missing, leaves the date/time form controls editable, keeps automatic reminder aligned, defaults occurrence count to 7, and allows count edits. Added widget regression coverage. Latest commit after assertion correction: `323b5a6afddd7977450ead87467e5d9dac206b04`.
- Validation status: CI for an earlier head was still running when checked; that evidence does not validate latest head. Need exact-head analyze/test shards/Debug+Release APK. Device Smoke was skipped on earlier run. No merge or main write.
- Calendar root cause evidence from current main: recurrence projection only enumerates occurrences when both `visibleFrom` and `visibleTo` are provided, but normal outbound sync calls `calendarProjection.project(snapshot)` without a range. Additionally recurrence event IDs include the scheduled timestamp; after date/time edit the ID changes, while the edit-only path uses `linkedOnly: true`, so it can fail to match the prior external link. These are recorded against #2248; identity changes are blocked pending the independent architecture review. Do not claim Calendar sync fixed.
- Next: validate PR #2606 exact head; then resolve #2248 identity contract safely (stable per-occurrence identity, past occurrence immutability, target calendar move/no duplicate, and failure diagnostics) before code changes.

## LIVE CONTINUATION CHECKPOINT — 2026-10-11 (Command v8 execution)

### Latest completed step
- Re-read this state file from the existing memory branch before acting. The file is not yet on main; PR #2600 remains the delivery path for memory docs and must be reconciled with overlapping docs PRs before merge.
- Refreshed PR #2606 exact-head CI for `323b5a6afddd7977450ead87467e5d9dac206b04`: Build run [38151948139](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38151948139) passed Analyze, all six test shards, Debug APK and Release APK. Device Smoke [38151948178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38151948178) was skipped. This is automated validation for repeat-editor defaults, not device/calendar-provider acceptance; PR #2606 stays Draft.
- Owner decision confirmed: root Task has `description` only; no root `Task.note`. Scoped FollowUp/Notebook note semantics remain unchanged. Refresh actual PR heads before relying on prior snapshots.
- Recorded latest owner contracts in existing owners: Calendar sync field scope and Done/Archive boundary [#2248](https://github.com/mobinpda-lab/Arvin-clean/pull/2248#issuecomment-6111402411); existing Reports icon only needs bottom-nav placement [#2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385#issuecomment-6111105369); Notebook toolbar/checklist defects [#850](https://github.com/mobinpda-lab/Arvin-clean/issues/850#issuecomment-6111078741) and [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111079224).
- Calendar sync scope: title, date, time, description, recurrence details and reminder only. Marking Done or moving to Archive alone must not trigger calendar sync. Preserve Task↔external event identity; never match by title/date or create duplicates.
- Report Center correction: move/reuse the existing Reports icon in bottom navigation and route to the existing Report Center; no new icon/engine/page.
- Notebook defect remains pending: RTL toolbar labels must be fully visible; checklist must be a real compact interactive checkbox, not literal `[ ]`; tapping toggles and state persists via canonical Task.checklist/Notebook storage.
- No main-branch write, merge, APK handover, physical-device validation or release occurred in this continuation step.

### Current status / next action
- **Completed:** GitHub Read/Write used; exact-head #2606 automated CI checked; latest owner contracts recorded on existing GitHub owners.
- **In Progress:** #2606 awaits Android/provider regression; Task form PRs #2591/#2595/#2602 overlap and require live head/diff reconciliation; Notebook fix and bottom-nav Reports placement require code changes and evidence.
- **Blocked:** Physical-device acceptance, full Calendar provider/two-way/no-duplicate acceptance, restore/file-provider round-trip, Golden Flow and explicit release-owner approval remain unproven.
- **Next action:** Refresh live heads/statuses. Continue canonical branches; prioritize data/calendar correctness and exact-head evidence, fix Notebook rendering/toggle in its existing path, and move the existing Report Center entry to bottom navigation without a second report path. Keep CI evidence distinct from device/owner acceptance.

## 2026-10-11 — Pastel visual language expansion

- Owner requested extending the Home/Calendar pastel look across all Arvin sections, explicitly including Notebook and Reports.
- Extended existing PR [#2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607) instead of creating a parallel branch/system. New title: `feat(ui): extend pastel visual language across Arvin`.
- Current PR head at checkpoint: `f526389e2058263af308f714bce49d7c4033000f`.
- Changes on the PR branch: shared light/dark CardTheme with rounded borders/subtle shadows/compact vertical spacing; rounded filled light/dark form fields; Notebook note cards lavender and checklist cards soft green; Report Center cards green when complete, red when overdue, amber for follow-up and blue for planned; Next Action cards red/blue/amber by reason. Calendar/Home visual refinements remain in the same PR.
- Regression coverage added for report status colors, Notebook note/checklist colors and Next Action status colors. Existing Task/Notebook storage paths are retained.
- GitHub Read/Write used. PR metadata updated; owner scope/guardrails added to the existing acceptance ledger [#1139 comment](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111556987).
- Exact-head CI for `f526389e2058263af308f714bce49d7c4033000f`: Build run [38158589426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589426) was pending/queued at last check; Device Smoke [38158589424](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589424) was skipped. Orchestrator success is not code/test/build proof.
- PR #2607 remains Draft and unmerged. No physical-device screenshot/visual acceptance is available. The separate Notebook inline checklist `[ ]` toggle bug is NOT fixed by this visual pass and remains open.

### Next action
- Refresh exact-head CI. Fix any Analyze/test/build failures without weakening tests. Review all affected screens at narrow phone widths and RTL, then request owner/device acceptance. Keep the PR Draft until evidence and owner acceptance are complete.

## 2026-10-11 — Pastel UI validation follow-up
- First exact-head Analyze on `f526389e2058263af308f714bce49d7c4033000f` failed because the new Notebook pastel-card test was placed before local helpers `repositoryAt` and `pumpNotebook` (Analyze run [38158589426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158589426), job 114526628385).
- Corrected the test placement in commit `571e5ed7c6751bcf56ba042a02ed6081e7023b0f` so helper declarations precede the test. This is a test-order fix, not a weakening of assertions.
- Latest PR head refreshed via GitHub: `571e5ed7c6751bcf56ba042a02ed6081e7023b0f`. New Build run [38158724999](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158724999) is running; exact-head Analyze/tests/APK results are not yet final. Device Smoke [38158725094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38158725094) skipped.
- Keep PR #2607 Draft. Next: inspect the new Analyze/test/build conclusions, repair root causes if needed, and only then arrange installed Android visual review.

## Report filter extension — 2026-10-11
- Owner reported the Report Center date filter still showed the Gregorian calendar and requested a compact, pastel, multi-select filter experience.
- Product implementation is in progress on PR #2607 / branch feat/calendar-pastel-compact-cards-20261011: switched report date selection to the existing Jalali picker; converted filter sections to expandable roll boxes; added multi-select status and Tracking filters; added canonical Notebook title/description, kind and created/updated date filtering; added regression tests.
- GitHub Read/Write: read current branch sources and memory docs; wrote application/test changes on the feature branch and appended the decision to Decision Log, Project Knowledge and User Experience Log on docs/arvin-autonomous-memory-20261011. No merge to main.
- Validation status: not yet verified for this exact head. Run Analyze, focused and full tests, Debug/Release APK, then Android small-screen RTL visual checks. Device Smoke and owner acceptance remain required.
- Explicit boundaries: no separate Note-to-Task relation exists in the current canonical model; external phone-calendar-only events are not confirmed Report Center inputs. Do not claim either capability.


## LIVE CONTINUATION CHECKPOINT — 2026-10-11 18:06 UTC / PR #2607

- Re-read the current execution checkpoint before continuing. Audited PR #2607 exact head and workflow failures for Report Center filter tests.
- Current application PR: #2607 remains OPEN/DRAFT, head `9ae99714e3cc36fe73814b1c0af0c3611adff2d4`, based on current main `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- Exact failure evidence from previous run #38161588760: shard 2 failed because `report-filter-apply` was absent at test line 111 after prior interactions; shard 4 showed the category header's tap offset hit the modal barrier at test line 173, then `Bad state: No element` at line 180.
- Safe test-only correction committed to the PR branch: replace `ensureVisible` with `scrollUntilVisible` using the filter sheet ListView, and scroll the Apply button into view before tapping. Commit: https://github.com/mobinpda-lab/Arvin-clean/commit/9ae99714e3cc36fe73814b1c0af0c3611adff2d4.
- Exact-head Build workflow `38162419144` is QUEUED at checkpoint time: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144. No pass/fail result exists yet. Do not treat this as validated.
- Correction to prior note: Report Center `_pickTime` already uses `showUniversalArvinTimePicker`, and the test checks `universal-time-selected-value`. The earlier claim that the generic Flutter time picker remained in Report Center was stale and has been corrected in the existing PR comment.
- Completed this step: root failure evidence extracted; test-only correction committed; PR comment updated; memory checkpoint being recorded.
- In progress: exact-head CI result, especially shards 2 and 4; if still failing, inspect fresh logs and fix the actual UI/test root cause without weakening assertions.
- Blocked: merge/release acceptance until exact-head Analyze, all test shards, Debug/Release builds, Device Smoke, small-screen Android RTL visual validation, and owner acceptance are complete. No APK/device evidence has been produced by this step.
- GitHub Read/Write access verified. No write to `main`, no merge, no release, and no claim of successful validation.

### Next action
1. Poll workflow run #38162419144 and inspect all test shard conclusions.
2. If tests pass, review complete workflow result and confirm Device Smoke status; do not confuse skipped smoke with device acceptance.
3. If either test still fails, extract the new exact stack trace and diagnose before editing again.
4. Update the problem register and evidence map only with this commit and confirmed CI results; keep PR #2607 Draft until the complete acceptance gate passes.


## CONTINUATION — Report filter test fix follow-up — 2026-10-11

- Re-read the execution state and refreshed PR #2607 / exact-head CI before acting. GitHub Read/Write access verified.
- New exact-head result for prior test correction commit `9ae99714e3cc36fe73814b1c0af0c3611adff2d4`: [Build run #38162419144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38162419144) FAILED. Analyze, Debug APK, Release APK and test shards 0, 1, 3, 5 passed; test shards 2 and 4 failed; Device Smoke run #38162419065 was skipped.
- Extracted fresh logs for both failed shards. The failure was caused by the test helper argument, not the product widget: `scrollUntilVisible` requires a `Scrollable` finder but the previous test-only fix passed `find.byType(ListView)`, yielding `type 'ListView' is not a subtype of type 'Scrollable'` at test lines 104 and 178.
- Safe follow-up correction committed to the same PR branch: replace all five scrollable targets in `test/report_center_page_test.dart` with `find.byType(Scrollable).last`. Commit: [45caa5a3](https://github.com/mobinpda-lab/Arvin-clean/commit/45caa5a3d7c7b3b29264f0197d6affd2b1798df5). No production code or data contract changed.
- New exact-head Actions batch: [Arvin Build #38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995), [Device Smoke #38163195983](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195983), plus orchestrator/parallel automation. At checkpoint, Build and several automation runs were queued; Device Smoke was in progress. No validation result for commit `45caa5a...` yet.
- Completed: failure root cause precisely identified and corrected; new CI batch observed; no test assertions weakened.
- In progress: verify exact-head test shards and build results; inspect Device Smoke after it completes.
- Blocked: PR #2607 must remain Draft until exact-head Analyze, all test shards, Debug/Release builds, Device Smoke and owner/physical-device UX acceptance are all confirmed. No merge, release, APK handover or physical-device validation claim.

### Next action
Poll run #38163195995 and #38163195983. If tests still fail, inspect fresh logs before another edit. If all automated checks pass, review smoke artifacts/results and then request the owner to verify Persian RTL, compact filter layout, date/time and selected-filter retention on a real small-screen Android device.


## CI status refresh — 2026-10-11

- After the previous checkpoint, refreshed exact-head run states for commit `45caa5a3d7c7b3b29264f0197d6affd2b1798df5`.
- Build run [#38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995) remains IN_PROGRESS; all six test shards plus Analyze and Debug/Release APK jobs are still running at this refresh. No test/build conclusion is available yet.
- Device Smoke run [#38163195983](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195983) concluded SKIPPED, not passed. Physical-device visual acceptance remains unverified.
- The orchestration/parallel/production-loop/G1-lock-sync runs completed successfully; these do not substitute for Build tests or Device Smoke.
- Current state remains BLOCKED on exact-head Build and Device Smoke/owner validation. PR #2607 remains Draft. Next action: poll Build #38163195995, inspect shards 2 and 4 especially, and determine why Device Smoke is skipped before release decisions.


## CONTINUATION — Device Smoke skip root cause — 2026-10-11

- GitHub Read/Write access verified. Re-read the latest execution checkpoint before continuing.
- Exact-head Build run [#38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995), commit `45caa5a3d7c7b3b29264f0197d6affd2b1798df5`, is still IN_PROGRESS. Analyze has succeeded; all six test shards and Debug/Release APK jobs are still running. No final build/test result is available yet.
- Investigated Device Smoke skip instead of treating it as a pass. Workflow `.github/workflows/device-smoke.yml` defines job condition `github.event_name != 'pull_request' || github.event.pull_request.draft == false`. Because PR #2607 remains Draft, the PR-triggered Device Smoke job is intentionally skipped. This is workflow gating, not evidence that the smoke tests passed or failed.
- PR #2607 remains OPEN/DRAFT. Do not change Draft status automatically because that is a review/owner-facing product workflow decision. No merge or release.
- Completed: identified the exact reason Device Smoke was skipped; confirmed Analyze success and current unresolved test/build jobs.
- Blocked: full automated acceptance pending; Device Smoke evidence unavailable for this draft PR; physical-device/owner visual acceptance not completed.
- Next action: poll Build #38163195995 until terminal. If all jobs pass, obtain Device Smoke evidence through an authorized non-draft/manual run path without implying physical-device acceptance; if any job fails, inspect that exact job's logs before changing code. Keep PR Draft until acceptance criteria are met.


## CONTINUATION — Report filter regression follow-up — 2026-10-11

- GitHub Read/Write verified; continued from the last checkpoint and checked live PR #2607, exact-head Build jobs, recent workflow runs and the report-filter test source.
- Exact-head run [#38163195995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163195995) advanced: Analyze and test shards 0, 1, 2, 3 and 5 passed; test shard 4 failed. The failure is in `test/report_center_page_test.dart`, test “report filter sections collapse and expand without losing selections”: after scrolling to the selected category chip, the test taps the section header while it is outside the bottom-sheet viewport (hit test lands on the modal barrier). This is a test interaction/scroll-position issue; no evidence yet indicates a production filter logic defect.
- Applied a focused test-only correction in commit [`c2a1b2ff`](https://github.com/mobinpda-lab/Arvin-clean/commit/c2a1b2ff57465e0e0b393b1e6d28fa010dadc439): re-find the Category section header and call `tester.ensureVisible` before collapsing and reopening it. No production code, Task model, persistence, or data contract changed.
- Fresh exact-head Build run [#38163500776](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163500776) is PENDING for head `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439`; no pass/fail result yet. Device Smoke [#38163500919](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163500919) is SKIPPED because PR #2607 is Draft and the workflow condition excludes Draft PRs.
- Release closure run [#38163384915](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163384915) failed by design at its release gate: issue #2102 remains open, and PR #1901 remains open. This is a release-blocking condition, not a build failure; no issue/PR was closed automatically.
- Completed: diagnosed the latest shard-4 failure from the exact job log, applied a narrow test-only fix, and recorded why Device Smoke is skipped.
- In progress: validate the new exact-head Build run.
- Blocked: PR #2607 remains Draft; Device Smoke/physical-device and owner UX validation are outstanding; release gate #2102 and P0/P1 regression lane #1901 are still open.
- Next action: inspect run #38163500776 after completion. If any tests fail, read that job's fresh logs before changing anything. Do not merge or release based on orchestration success.


### Release containment verification — 2026-10-11

- Verified repository releases after Release Closure #38163384915 ran. Two Arvin prerelease records (`v0.1.0-arvin-dd95132` and `v0.1.0-arvin-33ed363`) are now Draft prereleases; their tags/assets were preserved. The workflow appended an explicit “UNAPPROVED — NOT A RELEASE CANDIDATE” notice while issue #2102 remains open. This is reversible containment, not a release approval.
- Exact-head Build #38163500776 remains IN_PROGRESS at latest poll; no terminal result is available. Device Smoke #38163500919 remains SKIPPED due to the PR Draft condition.
- Keep publication blocked until issue #2102 is closed after evidence and owner acceptance, and P0/P1 regression PR #1901 is resolved. Do not publish or close these gates automatically.


### Poll checkpoint — 2026-10-11 18:24 UTC

- Re-read this execution state and rechecked live PR #2607, exact-head Build #38163500776, Device Smoke #38163500919, release gate issue #2102, and regression PR #1901.
- Build #38163500776 is still IN_PROGRESS on commit `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439`. Analyze is SUCCESS; Debug/Release APK and test shards 0–5 remain IN_PROGRESS. A log request for running shard 4 returned NOT_FOUND, so no new test outcome can be inferred.
- Device Smoke #38163500919 is SKIPPED due to Draft PR gating. The available GitHub tool set has no workflow-dispatch action, so I did not claim to launch a manual smoke run. Do not mark this as passed.
- Issue #2102 and PR #1901 remain OPEN. Main is still `a6ced27660d34cd87dd8915aff68d3a7555fd57a`; no release/merge or owner-facing PR state change performed.
- Next action remains: poll the exact-head Build run for terminal results; inspect fresh failed-job logs once available. Device Smoke requires an authorized non-Draft/manual path; physical-device and owner acceptance remain outstanding.


### Exact-head test diagnosis and follow-up — 2026-10-11 18:26 UTC

- Build #38163500776 on `c2a1b2ff57465e0e0b393b1e6d28fa010dadc439` progressed far enough to expose a fresh shard-4 failure in `test/report_center_page_test.dart`, test `report filter sections collapse and expand without losing selections`. The log reports 181 tests passed and 1 failed.
- Root cause is now concrete: after collapsing the filter section, the test immediately called `tester.widget<FilterChip>(categoryChip)` at line 206. The collapsed `ExpansionTile` unmounts its child subtree, so the finder has no mounted element (`Bad state: No element`). This is a test assertion/lifecycle assumption, not evidence of a production report-filter failure.
- Applied a narrow test-only correction: remove the invalid assertion while collapsed and verify the selected chip after reopening, when it is mounted again. No production source, Task model, storage, or architecture changed.
- Commit: [`7526dc186a26d099368fb288fdc7891ed57222ce`](https://github.com/mobinpda-lab/Arvin-clean/commit/7526dc186a26d099368fb288fdc7891ed57222ce).
- Exact-head Build run #38163761104 is PENDING for the new commit. Device Smoke #38163760935 is SKIPPED because PR #2607 remains Draft. This correction is not validated until the new run reaches terminal success.
- PR #2607 remains OPEN/Draft. Release gate issue #2102 and regression PR #1901 remain open; no merge, release, or Draft-state change was made.
- Next action: inspect exact-head Build #38163761104 and its shard-4 result; if it fails, read the new log before making any further change. Device Smoke, physical-device checks, and owner acceptance remain required.


### Continuation poll — 2026-10-11 18:27 UTC

- Re-read execution state and polled exact-head Build #38163761104 for commit `7526dc186a26d099368fb288fdc7891ed57222ce`.
- Current state: Build IN_PROGRESS; `quality (analyze)` SUCCESS; test shards 0–5 and Debug/Release APK jobs still IN_PROGRESS. No terminal conclusion is available yet.
- PR #2607 is still OPEN/Draft at the expected head. Issue #2102 and regression PR #1901 remain OPEN. Main remains `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- No new code change made during this poll because there is no new failure evidence. Device Smoke remains skipped under Draft gating; physical-device validation and owner acceptance remain outstanding.
- Next action: continue polling this exact run and inspect logs only after a job reports failure.


### Continuation checkpoint — report-filter implementation rechecked (2026-10-11 18:28 UTC)

- Re-read this state and re-inspected PR #2607 branch source and tests to avoid repeating the prior diagnosis.
- Confirmed production file is `lib/report_center_page.dart` (not a nested `lib/features/reports/... ` path). The report time selector calls `showUniversalArvinTimePicker`; filter sections are implemented with `ExpansionTile`; tests assert the Jalali picker opens and Flutter's Gregorian `CalendarDatePicker` does not appear, and assert the shared Persian-digit time picker is used.
- Exact-head Build #38163761104 remains IN_PROGRESS in the available run response; Analyze is SUCCESS, other test shards and Debug/Release APK jobs are still marked IN_PROGRESS. Attempt to fetch running shard-4 logs returned NOT_FOUND, so no further conclusion can be drawn from that request.
- PR #2607 remains OPEN/Draft. Device Smoke is skipped due to Draft gate. Release issue #2102 and P0/P1 device-regression PR #1901 remain open.
- No additional code change was made without a fresh failing result. Next action: poll exact-head run #38163761104 again; once a job completes, inspect its result/log before any further change. Device/RTL small-screen validation and owner acceptance remain outstanding.


### Repository-wide audit checkpoint — 2026-10-11 18:35 UTC
- Current main SHA checked: a6ced27660d34cd87dd8915aff68d3a7555fd57a. GitHub Read/Write verified. This checkpoint records findings on the existing memory PR branch only; no app code or main changes.
- Inventory: 740 main-tree paths, 190 docs, 249 test/integration-test files, 21 workflows, 1,248 branches, 19 open PRs, 1,096 open Issues; 876 open AUTO-FIX search results, 16 priority:core, 4 factory:blocked and 3 release-labelled issues.
- Current main SHA Actions query reached 1,535 workflow runs, dominated by repeated Release Closure / Final Head Release Validation orchestration events. Recent release closures repeatedly fail/cancel; current run #38164393875 failed and Final Head Release Validation #38164416537 was skipped.
- PR #2607 exact head 7526dc186a26d099368fb288fdc7891ed57222ce Build #38163761104 is SUCCESS across Analyze, six test shards, Debug and Release APK. Device Smoke #38163760935 is SKIPPED because PR remains Draft. Do not claim device acceptance.
- Confirmed on main: lib/report_center_page.dart still uses showDatePicker and showTimePicker. Persian/Jalali date and shared Persian-digit time picker exist only on the unmerged #2607/#2591 work.
- Current release blockers: Issue #2102 open; PR #1901 open; owner acceptance ledger #1139 still has unchecked phone/tablet acceptance. Two prereleases remain Draft/unapproved.
- Main docs drift: ARVIN_STATUS references PR #135/v49.0 while the current operating package is v49.1; scorecards use August baselines; the v49.1 package references AMPOP v5 which is not on main (introduced by unmerged #2598). The owner Command v8 is now preserved in this branch as ARVIN_AUTONOMOUS_DELIVERY_EVOLUTION_COMMAND_V8.md.
- Documentation branches #2598/#2599/#2600/#2601 share old merge base 72a2f4cc24df7a38eff9856ce403461615db5280 and are behind current main; #2598 and #2599 both change docs/ARVIN_STATUS.md. PR #2600 contains 13 memory files after this audit (11 pre-audit files plus the exact Command v8 and repository-wide audit records); memory is not yet on main.
- Task Note: Issue #2593/PR #2594 accepts optional Task Note distinct from Description, but current PR #2595 source does not expose a root Task.note field or editor input even though its PR body claims it is implemented. Treat this as a contract/implementation mismatch and correct the PR description after verifying the final intended implementation.
- SQL migration: main TaskStore uses SQL/Drift and a one-time legacy SharedPreferences migration path. Issue #1324 remains open with September evidence; revalidate current main instead of relying on old issue text.
- Next: (1) reconcile existing release-loop fix PR #2531 against current main; (2) consolidate/rebase documentation PRs and memory; (3) coordinate #2591/#2607 and #2593/#2594/#2595/#2602; (4) refresh exact-main evidence and owner acceptance; (5) continue historical issue/branch/commit passes. This is an initial deep-audit checkpoint, not a claim that every old commit and all 1,096 issues were individually read.


## Deep audit continuation — live workflow-loop evidence (2026-10-11 18:43 UTC)
- Re-read this state first. Live main is still `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. GitHub Read/Write access confirmed.
- Rechecked current main workflow definitions and current exact-main runs. In a short interval around 18:38–18:42 UTC, main received repeated `Arvin Production Orchestrator`, `ARVIN Production Loop`, and `Factory REST Promotion Bridge` runs; several release-closure runs were cancelled/skipped/failing, and Final Head Release Validation was repeatedly skipped. This is active orchestration churn, not proof of product progress.
- Current main `.github/workflows/release-closure.yml` still has `cancel-in-progress: true` and triggers after every completed `Arvin Production Orchestrator`; its job runs on any successful orchestrator completion. Non-draft PR #2531 already proposes `cancel-in-progress: false` plus restricting the workflow_run source to a successful `workflow_dispatch` orchestrator run. The patch is narrowly scoped and matches the observed trigger-isolation problem, but must not be treated as integrated until its exact-head tests/build and review gates pass.
- Main `.github/workflows/production-orchestrator.yml` is triggered by Parallel Wave, Build, Device Smoke and a five-minute schedule; it also dispatches the production loop on failed gates and can dispatch itself after successful merge. Main `factory-rest-promotion-bridge.yml` also runs on schedule and on Parallel Wave/Build/Device Smoke completion. Keep these distinct from the release closure gate; audit cross-trigger causality before changing more than one workflow.
- Release gate remains BLOCKED: Issue #2102 OPEN, PR #1901 OPEN, owner acceptance ledger #1139 OPEN with unchecked installed-device acceptance. The two available prereleases remain Draft/unapproved. No release, merge, issue closure, or app-code change was made in this checkpoint.
- Product acceptance reminders: #1139 includes Home + → Quick Entry directly, sequential one-task persistence, same draft identity into Full Form, tablet text contrast, and more installed-device requirements; #845 remains a durable missed-requirements checklist. #866 remains open for premature Recovery Wave auto-close; its comments show repeated AI provider HTTP 429 cooldown/retry events, which are infrastructure pressure rather than product-failure evidence. #1324 remains open for lossless SQL migration acceptance.
- Next: inspect exact checks/jobs on PR #2531 and current trigger-chain run graph; then consolidate memory/docs branches and continue targeted historical PR/Issue/commit audit. Do not mass-close AUTO-FIX issues or delete branches.


## Existing release-loop PR rebased onto exact current main — 2026-10-11 18:46 UTC
- Continued from the live audit; did not create a duplicate PR. Existing PR #2531 was 18 commits behind main, so its existing branch was rebuilt from current main while retaining only its original two-file scope.
- New head: `4505c759a8338e91c596d9b031d16d29080a339c`; current base: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`; comparison is now ahead 1 / behind 0 with only `.github/workflows/release-closure.yml` and `test/release_closure_product_gate_test.dart`.
- Change is narrowly limited to release trigger isolation and a matching regression assertion. PR conversation records the rebase and warns that exact-head CI is pending.
- At latest poll, 21 checks exist: 6 completed, 9 in progress, 6 queued; Build #38165128162 and Device Smoke #38165128170 are queued. No failures observed yet. Do not merge until exact-head Build and Device Smoke complete successfully and the PR's required checks are satisfied.
- No main change or release occurred. Keep issue #2102 and PR #1901 open until actual product/device acceptance is complete.


## Live continuation update — Report Center validation (2026-10-11)

- Re-read this execution state from the existing memory branch before continuing; no new memory branch or duplicate issue was created.
- Reviewed PR #2607 current reported head `0ef03757ee869a49f7d36cfcad05f2d09751a31c` and its Build run [38160581498](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38160581498).
- Exact-head Build evidence: Analyze succeeded; Debug APK and Release APK builds succeeded and artifacts were uploaded; test shards 0, 1, 3, and 4 succeeded; test shards 2 and 5 failed. Therefore Build is NOT green and PR #2607 remains unaccepted. Device Smoke was skipped because the PR is Draft; no device acceptance is implied.
- Retrieved failure log for shard 2: `test/report_center_page_test.dart`, test “Report Center combines time and category filters and opens that exact report scope” failed at line 107 with `Bad state: No element` from `WidgetController.ensureVisible`. This is likely a test/widget target mismatch after filter UI restructuring; inspect the exact widget tree and intended user path before changing the test. Do not weaken the assertion or treat the test as flaky without evidence.
- PR #2607 adds the Report Filter & Memory Extension: Jalali date-range picker, expandable roll-box filter sections, multi-select Project/Category/Tag/Status/Tracking, and canonical Task-backed Notebook note/checklist/date filters. The decision file was read back from the PR head. These changes are on a PR branch, not accepted on main.
- Remaining Report Center gate: resolve shard failures on the current head; re-run Analyze, all test shards and APKs on the resulting exact head; run Android Device Smoke and small-screen RTL visual acceptance; reconcile shared time picker with existing Draft PR #2591 rather than adding a second picker. Current `_pickTime` still uses Flutter `showTimePicker`, so Persian/Jalali date selection alone does not satisfy the universal Persian 24-hour time-picker requirement.
- Data/architecture boundary remains: Report Center consumes canonical Task/Notebook records; no separate report store or invented Note-to-Task relation. External phone-calendar-only events are not proven report inputs.
- Release gate #2102 remains OPEN/BLOCKED. No merge, publication, or Release Ready claim was made.

**Completed this continuation:** revalidated memory, fetched exact-head CI jobs/artifacts, inspected the failing shard log, and recorded the new evidence here. **Next action:** inspect `test/report_center_page_test.dart` around line 107 and the current Report Center filter widget on PR #2607; correct the actual target/behavior mismatch, then rerun the affected shard before full exact-head validation.


## Superseding live correction — Report Center test follow-up (2026-10-11)

This entry supersedes the immediately preceding Report Center next-action note where later branch commits had already moved beyond the inspected SHA.

- PR #2607 evolved after Build run #38160581498. Its earlier shard-2 failure was in `report_center_page_test.dart` line 107: fixed-offset drag scrolled past a lazily built category section, making `ensureVisible` fail with `Bad state: No element`. Subsequent test-only commits corrected the scroll strategy.
- Latest observed run before this update: [Build #38163500776](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38163500776) on the then-current branch failed only quality test shard 4; Analyze and shards 0, 1, 2, 5 succeeded. Debug/Release APK jobs were cancelled when newer commits superseded that run. Device Smoke was not run because the PR is Draft.
- Shard-4 failure: test `report filter sections collapse and expand without losing selections`, line 206, `Bad state: No element`. Root cause in test interaction: after collapsing, the category section may be outside the lazy ListView's built range; calling `ensureVisible(categoryHeader)` cannot find it. Do not alter production behavior or weaken the persistence assertion to mask this.
- **Fix committed to the existing PR branch** `feat/calendar-pastel-compact-cards-20261011`: commit [8d3d60a1b321fa4ceb9f5da779a144d3705b9103](https://github.com/mobinpda-lab/Arvin-clean/commit/8d3d60a1b321fa4ceb9f5da779a144d3705b9103). The test now scrolls the category section back into the lazy ListView's viewport before reopening it, then retains the selection assertion. No production code, model, storage, or architecture was changed by this fix.
- Workflow lookup immediately after this commit returned no associated run/status yet; this is **missing validation**, not a pass. Re-check exact-head CI shortly. Required: Analyze, all test shards, Debug/Release APKs, Android Device Smoke, small-screen RTL visual review, and owner acceptance. Keep PR #2607 Draft and release blocked until these gates pass.
- **Correction to prior time-picker note:** the earlier claim that current PR #2607 still used generic Flutter `showTimePicker` was true for head `0ef03757ee869a49f7d36cfcad05f2d09751a31c` but became stale after later commits. PR comments confirm the current branch reuses `showUniversalArvinTimePicker` and includes a regression test. However, the shared picker source is also changed in PR #2607 and is byte-identical to the implementation in PR #2591; reconcile that overlapping path before merging so only one canonical implementation remains.

**Current status:** Report Center test-only fix committed; exact-head validation pending. **Next action:** query workflow runs for the new head; if no run appears, inspect the PR's current run state before considering any rerun. No merge, release, or acceptance claim.


## Exact-head validation restarted — Report Center (2026-10-11)

- After the test-only fix commit `8d3d60a1b321fa4ceb9f5da779a144d3705b9103`, the PR-triggered Build run [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) appeared for that exact commit.
- Live job snapshot: Analyze, all six test shards and Debug/Release APK jobs were in progress or queued at the time checked. No artifacts had been uploaded yet. This is **pending**, not a pass.
- Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) was skipped because PR #2607 remains Draft; that does not validate UI/device behavior.
- Continue monitoring this existing run; do not trigger duplicate CI. If the test shard 4 failure is resolved, wait for every remaining shard and both APK jobs to finish successfully on the same head. Then request/run Device Smoke and perform small-screen RTL/physical-device review. Shared time picker source overlap with PR #2591 still needs reconciliation before any merge.
- Release gate #2102 remains open; no merge, publish, or Release Ready claim.


## Exact-head validation result — Report Center (2026-10-11)

- Rechecked PR #2607 head commit `8d3d60a1b321fa4ceb9f5da779a144d3705b9103` and Build run [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767).
- **PASS on this exact head:** Analyze, all six quality test shards (0–5), Debug APK build, and Release APK build. Both APK artifacts were uploaded:
  - `arvin-debug-apk`, artifact ID `11712403085`, SHA-256 `78566ec458aed40fa36cc43d58c1cd3fd94bb8be18f501d0b8010942bdd8893b`.
  - `arvin-release-apk`, artifact ID `11712088044`, SHA-256 `ff8acc7c4a30e9178ca22d08eebc60b85b4789b4af9657740bd02069ca2de53c`.
- Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) remains `skipped` because PR #2607 is Draft. This is not a device acceptance pass; installed-device, small-screen Persian/RTL visual review, and owner acceptance remain outstanding.
- Current PR states rechecked: #2607 remains open/Draft; #2591 remains open/Draft. Release gate issue #2102 remains OPEN/BLOCKED.
- Compared shared file blob SHAs at exact PR heads. `lib/widgets/universal_arvin_time_picker.dart` is byte-identical on #2607 and #2591 (blob `caacc5539c5f2304a1a060f5e3610a25987a6619`). `lib/main.dart` and `lib/report_center_page.dart` differ because each PR carries additional integration changes. Reconcile these overlapping integration paths before merge; do not blindly merge either PR.
- No production-code change or merge was made in this continuation. The prior test-only fix remains validated by the passing exact-head CI above.
- **Next action:** use the successful APK artifacts for installed-device acceptance through an authorized device path; if device access is unavailable in this session, keep that gate explicitly blocked. Continue reviewing the overlapping #2607/#2591 patches and release gate #2102 without changing Draft state or claiming Release Ready.


## Release-closure workflow correction merged — 2026-10-11

- Reviewed and merged PR [#2531](https://github.com/mobinpda-lab/Arvin-clean/pull/2531) after exact-head checks passed. Merge commit: [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd).
- Scope was limited to `.github/workflows/release-closure.yml` and `test/release_closure_product_gate_test.dart`: stop cancelling an active release-closure run, and only allow workflow_run-triggered closure when the successful upstream Production Orchestrator was explicitly started via `workflow_dispatch`.
- Exact-head Build #38165128162 passed Analyze, all six test shards, Debug APK and Release APK. Device Smoke #38165128170 passed all six lanes (backup-restore, home, SQL migration, quick-capture, SQL persistence, people). This validates that PR head only; it does not replace current-main post-merge validation or full owner acceptance.
- PR #2531 is merged. Issue #2102 remains OPEN/BLOCKED. No release was published; the #2102 approval gate remains intact.
- Report Center PR #2607 remains OPEN/Draft with exact-head Build #38166678767 green; Device Smoke #38166678708 skipped because Draft. PR #2591 remains OPEN/Draft; shared picker source is identical, but `lib/main.dart` and `lib/report_center_page.dart` integrations differ and must be reconciled.
- **Next action:** verify post-merge workflow behavior on main, then continue P0 issue #2102 evidence recovery and Report Center device/RTL acceptance. Do not claim Release Ready until current-main P0/P1 evidence and owner approval are complete.


## Continuation checkpoint — post-merge release gate and main head (2026-10-11)

- Re-read this execution state and evidence map before acting. Latest repository commit found is [d8afc717eaf02d6d0bedf92e800c7f93209c97bd](https://github.com/mobinpda-lab/Arvin-clean/commit/d8afc717eaf02d6d0bedf92e800c7f93209c97bd), the merge commit for PR #2531; previous main head was `a6ced27660d34cd87dd8915aff68d3a7555fd57a`.
- Re-read `.github/workflows/release-closure.yml` on `main`: cancellation is disabled for the release-closure concurrency group, and workflow_run closure is guarded to require a successful upstream `workflow_dispatch` run. The matching contract test is present on main. This verifies merged file content, **not** a post-merge runtime execution.
- The current connector's commit-workflow lookup returns no runs for merge commit `d8afc717...` because it only exposes PR-triggered runs; do not interpret this as a pass. Combined status endpoint returned no status checks for the merge commit. Post-merge Build/Device Smoke evidence is therefore still missing.
- PR #2607 remains OPEN/Draft at `8d3d60a1...`, base SHA `a6ced276...`; exact-head Build [38166678767](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678767) passed Analyze, all six shards, and Debug/Release APKs. Device Smoke [38166678708](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38166678708) was skipped because Draft. The validation head predates merge commit d8afc717 and needs refreshed integration evidence before merge.
- PR #2591 remains OPEN/Draft at `eae0394163a958223b79fc3b7aa914f79b664b8a`; its base is stale relative to current main. The shared time-picker widget blob is identical across #2607/#2591, but `lib/main.dart` and `lib/report_center_page.dart` integration changes differ. Rebase/reconcile existing PRs; do not merge blindly or duplicate the shared picker.
- Issue [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) remains OPEN/BLOCKED. Existing evidence still requires real-device Android proof for Calendar same-event/no-duplicate sync, system file-provider backup/restore integrity, link retention, Home RTL/compact-screen review, full Golden Flow, and explicit product-owner acceptance.
- Version on main is `1.0.1+2`; no release publication or Release Ready claim is supported.
- **Next action:** obtain fresh current-main Build and Device Smoke evidence through an authorized workflow path; then refresh/reconcile the existing product PRs and collect physical-device acceptance. If workflow dispatch access is not exposed, record the limitation and keep release blocked. No app source change made in this checkpoint.


## P0 evidence recovery — Device Smoke and Calendar lane (2026-10-11)

- Rechecked the previously stale Device Smoke run [38037275973](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38037275973) rather than launching duplicate CI. The job API now reports all six lanes completed/success: Home (114175727462), Backup/Restore (114175727752), SQL migration (114175727913), Quick Capture (114175728065), People (114175728105), SQL persistence (114175752538).
- Artifacts available from that run: Home `11665410659`, People `11665011600`, Quick Capture `11664318029`. No Backup/Restore artifact is listed despite its successful job result. Automated lane success is recorded; backup evidence review/data-integrity acceptance is not.
- Calendar edit PR #2570 is already merged at `34a6cee9ae05ad1cf632960b96e98f2a5448e128`; do not duplicate the implementation.
- Added a factual checkpoint comment to release gate [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102) (comment ID `6112823569`) documenting lane results and missing Backup/Restore artifact.
- Post-merge status check lookup for current main merge commit `d8afc717eaf02d6d0bedf92e800c7f93209c97bd` returned no status entries; this connector response is insufficient to claim current-main CI passed. The merged workflow file and contract test are present on main, but current-main workflow execution is still unverified.
- Release gate #2102 remains OPEN/BLOCKED; PR #1901 remains OPEN. Physical-device/product-owner acceptance remains outstanding.
- **Next action:** review available Home/People/Quick Capture artifacts; recover or explicitly document missing Backup/Restore artifact; obtain exact-current-main validation and validate same-event Calendar edit plus restore link integrity. Keep the release gate closed until P0/P1 evidence and owner acceptance are complete.


## Exact current-main Build confirmed; Device Smoke queued — 2026-10-11

- Queried GitHub's actual `main` branch and Actions API. Current `main` is `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`.
- Exact-main Build [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381) completed successfully: Analyze, all six test shards, Debug APK, Release APK. Artifacts: Debug `11712873761`, SHA-256 `a6c6be99448d9160e2ddee09b8d6b03e198c9999fb8f48f6d31ec26a528806a5`; Release `11712389980`, SHA-256 `4c9b5deb4d84a8a097b42ca42594e1edf7b0e16657083fb91402ad8d5794f7a4`.
- Exact-main Device Smoke [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) has been created for the same SHA but is not complete: Home and Quick Capture passed; SQL migration and SQL persistence are in progress; Backup/Restore and People are queued. Artifacts currently available: Home `11712218995`, Quick Capture `11713050656`. Do not call the full smoke pass yet.
- Downloaded and visually inspected available smoke screenshots. Home screenshot is legible in RTL at the captured viewport; People screenshot shows an empty state and add-person action; Quick Capture screenshot shows truncated labels in the narrow three-column selection chips (P2 UX observation). These are automation/emulator artifacts; physical-device acceptance remains unproven.
- Release Closure [38167799987](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167799987) failed closed at the explicit product-release approval step on the prior SHA. This is not authorization to bypass the gate.
- PR #2585 (Backup/Restore) is already merged at `a6ced27660d34cd87dd8915aff68d3a7555fd57a`; Calendar sync #2570 and Calendar-link backup/restore #2569 are also already merged. Do not duplicate those implementations.
- PR #2607 remains Draft and its Build pass is on a head predating current main; PR #2591 remains Draft and its base is stale. Refresh/reconcile rather than merge blindly.
- **Next action:** monitor exact-main Device Smoke #38167835426 to completion, inspect Backup/Restore result/artifact and People screenshot; then refresh/reconcile PR #2607/#2591 integration. Release remains blocked on physical-device Calendar/Backup-Restore, recurrence, RTL, Golden Flow and explicit owner acceptance.


## Device Smoke progress correction — exact main SHA (2026-10-11)

- Rechecked run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) on `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`.
- SQL migration and SQL persistence have now completed successfully. Home and Quick Capture remain successful.
- Backup/Restore and People have moved from queued to in progress. Full run is still `in_progress`; neither lane is yet accepted and neither artifact is listed at this checkpoint.
- Continue waiting on this exact run; do not start duplicate Device Smoke. Release gate remains open/blocked.


## Exact-main Device Smoke completed — 2026-10-11

- Re-polled existing Device Smoke run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426) on exact main SHA `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`. Overall run completed with conclusion **success** at 2026-10-11T19:37:33Z.
- All six lanes passed: Backup/Restore (job 114553994598), Quick Capture (114553994694), Home (114553994728), People (114553994755), SQL Migration (114553994767), SQL Persistence (114553994778).
- Artifacts available: People screenshot bundle 11713400184 (12,418 bytes), Quick Capture 11713050656 (37,135 bytes), Home 11712218995 (31,109 bytes). **No Backup/Restore artifact is listed**; passing lane is not a substitute for reviewing a restore artifact or real-device/file-provider acceptance.
- Together with exact-main Build [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381), Analyze, six quality test shards, Debug APK and Release APK all pass on the same SHA. Debug SHA-256: `a6c6be99448d9160e2ddee09b8d6b03e198c9999fb8f48f6d31ec26a528806a5`; Release SHA-256: `4c9b5deb4d84a8a097b42ca42594e1edf7b0e16657083fb91402ad8d5794f7a4`.
- This closes the **current-main automated Build + Device Smoke evidence** step only. It does not close product release acceptance: physical-device same-event Calendar update/no-duplicate proof, real Android file-provider Backup/Restore and restored-link integrity, recurrence/Checklist/Golden Flow, compact-screen RTL visual acceptance, Quick Capture clipped-label UX follow-up, and explicit owner approval remain outstanding. Release Closure approval gate stays intact; no release authorized.
- **Completed:** exact-main Build and all six Device Smoke lanes validated. **In progress/blocked:** product/device acceptance and owner approval. **Next:** inspect the newly available People artifact; continue existing PR reconciliation without duplicate implementations.


# LIVE CONTINUATION ADDENDUM — 2026-10-11 (revalidated after checkpoint)

## CHECK — branch and evidence revalidation
- A GitHub compare of `d8afc717eaf02d6d0bedf92e800c7f93209c97bd` against `main` returned `identical`; current main is therefore confirmed at that exact SHA for this check.
- Exact-main Build run [38167835381](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835381): Analyze, test shards 0–5, Debug APK and Release APK all completed successfully.
- Exact-main Device Smoke run [38167835426](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38167835426): Backup/Restore, Quick Capture, Home, People, SQL Migration and SQL Persistence all completed successfully.
- Combined commit status API returned an empty status list; it is not used as a substitute for the explicit completed workflow-job results above.
- Current PR metadata rechecked: #2591, #2595, #2600, #2607 and #2608 remain OPEN / DRAFT. No merge occurred.

## Latest completed step
- Re-read this file before acting.
- Confirmed current main by comparing the recorded SHA with the symbolic `main` ref.
- Revalidated all Build and Device Smoke jobs on that exact main SHA.
- Rechecked live PR state and preserved the prior Task Note data-contract gate.
- Added a new live evidence checkpoint and PR-overlap audit in [ARVIN_LIVE_CHECKPOINT_2026-10-11.md](https://github.com/mobinpda-lab/Arvin-clean/blob/docs/arvin-autonomous-memory-20261011/docs/arvin-memory/ARVIN_LIVE_CHECKPOINT_2026-10-11.md), with verified read-back.

## Decisions / guardrails
- The green automated mainline runs are accepted as evidence only for the paths they exercised. They do not prove physical-device Calendar provider identity, real-file Backup/Restore integrity, full golden-flow acceptance, visual acceptance, or product-owner release approval.
- Do not merge #2591, #2595 or #2607 independently: their changed-file lists overlap in the shared time picker, main routing, report filter, Quick Capture and Task Editor paths. Reconcile one integrated head, then run full exact-head validation.
- Do not add or propagate root `Task.note` until the product owner explicitly decides whether it is distinct from `Task.description`; legacy serialization, SQL envelope, backup/restore and migration consequences must be specified and tested.
- Documentation PRs #2600 and #2608 overlap in memory/requirements scope. Reconcile against current main into one authority hierarchy; do not merge stale-base documentation blindly.
- No application code, main branch, schema, migration, APK publication, merge or release was changed in this execution.

## Current status
- **Completed:** current-main Build + six-lane Device Smoke revalidated; PR states rechecked; checkpoint recorded and read back.
- **In Progress:** safe consolidation plan for shared time-picker/report-filter/task-form changes; documentation hierarchy reconciliation; real-device/product acceptance.
- **Blocked:** Task Note data-contract change pending explicit owner decision; final release pending physical-device evidence and explicit owner acceptance.
- **Current bottleneck:** overlapping draft PRs plus missing physical-device/user-data acceptance. The mainline automated baseline is green, so do not rerun it without a new commit or evidence-driven reason.
- **Next action:** compare and reconcile the live PR diffs into one integration sequence without merging overlapping drafts independently; continue collecting non-destructive device acceptance evidence; update the release gate only from actual evidence. Keep #2102 open and fail-closed.


## LIVE CONTINUATION ADDENDUM — 2026-10-12 (CI routing validation)

### CHECK — exact current evidence
- Re-read this execution state before acting. Current main SHA at this checkpoint: `326afaa276b04650a86a811b18560eb4e20ed5cd`.
- CI-routing fix PR [#2639](https://github.com/mobinpda-lab/Arvin-clean/pull/2639) is open, unmerged, base `main`, head `433a741beb277572d2b4cdf6ef9838149e63a134`; one-line workflow diff removes the pull-request base-branch restriction while retaining main/master-only push triggers.
- Exact-head Build [38254855655](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855655): Analyze, test shards 0–5, Debug APK passed; Release APK was still in progress at latest poll. Overall result is not final.
- Exact-head Device Smoke [38254855466](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855466): Quick Capture and Home passed; SQL Persistence and SQL Migration were in progress; People and Backup/Restore were queued. Overall result is not final.
- Latest re-poll did not show completion; do not create duplicate runs or call the build/smoke green.
- Task-form PR [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595) remains open/draft on stacked base `feat/universal-arvin-time-picker-implementation-20261011`, head `a5d4581997084179f525de4f274ad00d5305ac1a`, mergeability false. The owner has not explicitly approved the previously proposed integration of #2591/#2595/#2602/#2607; no retarget, rebase, or merge is authorized.
- Release listing still contains only draft prereleases; release closure remains NO-GO. Automated mainline green runs do not replace physical-device Calendar same-event update/no-duplicate evidence, real file-provider Backup/Restore/link-integrity evidence, recurrence/checklist golden flow, compact RTL acceptance, and explicit owner approval.

### Completed in this continuation
- Revalidated project memory, current main, open PR inventory, release listing, and exact-head Build/Device Smoke jobs.
- Added an evidence checkpoint comment to PR #2639 (comment ID `6125186798`) with exact run IDs, status and guardrails.

### Current status
- **Completed:** CI routing fix is proposed; Analyze, all six test shards, Debug APK, Home and Quick Capture passed on its exact head.
- **In Progress:** Release APK and remaining Device Smoke lanes.
- **Blocked:** Final CI conclusion; Task-form stack integration awaiting explicit owner approval; release awaiting physical-device evidence and explicit owner acceptance.
- **Current bottleneck:** Exact-head validation has not finished; overlapping task-form changes must not be merged independently.
- **Next action:** Poll existing runs [38254855655](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855655) and [38254855466](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38254855466), fix only evidence-backed failures, and update this state with final job outcomes. Do not merge PRs or release APKs without required authorization and acceptance evidence.


---

# LIVE EXECUTION CHECKPOINT — 2026-10-12 (follow-up decision + CI acceleration)

This checkpoint supersedes earlier status statements where they conflict. Refresh GitHub before the next write.

- **Completed:** PR #2631 merged at `d136dfc5c3c64a4e1dc0dae20e1a928dd154e66e`. FollowUp Calendar projection now requires an explicitly configured `FollowUp.reminderDate`; it no longer projects follow-up history/date alone. Exact-head Build, Calendar Provider Acceptance and all six Device Smoke lanes passed on dependency head `e815a8f1daa312da7bf6bf1188cf94a3b541e380`.
- **Completed:** PR #2639 merged at `3550e754bdf5019b1a9192e4384d5ed4c947c680`. Stacked pull requests can now receive Build workflow validation; exact-head Build and Device Smoke passed before merge.
- **Owner decision:** `nextFollowUp` and `reminderDate` are independent. Never migrate/clear `nextFollowUp` to simplify UI. Keep separate next-action and reminder controls. Calendar may project an explicit reminder only, without mutating either field. Decision is documented in PR #2642 and the dedicated decision document on a review branch.
- **Correction in progress:** PR #2636 originally proposed a compatibility mapping that collapsed the two fields. Commented on PR #2636 and Issue #2635; updated PR description, FollowUp editor to preserve both values, regression tests and decision log. Current proposed head: `6d970acec8f2d26464f746525861f5b3f341ce67`.
- **Validation status for PR #2636:** exact-head Build and Device Smoke are queued; Calendar Provider Acceptance is in progress. Do not merge until all gates finish and the branch is reconciled with latest main. Earlier run `38238251976` failed multiple calendar widget tests due to a 1 px vertical overflow at `lib/calendar_page.dart:501`, plus a follow-up action expectation failure; those results are historical and not proof about the corrected head.
- **Current bottleneck:** verify PR #2636 on its exact current head and reconcile it with the merged PR #2631/main. The branch currently reports mergeable=false after main advanced; do not merge blindly.
- **Release:** NO-GO until physical-device same-event Calendar update/no-duplicate, real Android file-provider Backup/Restore and Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen visual acceptance, and explicit owner approval are evidenced.
- **Next action:** poll exact-head PR #2636 Build, Calendar Provider Acceptance and all six Device Smoke lanes; then reconcile branch/base conflicts and rerun on the final head. Continue only from this checkpoint; do not repeat already completed CI-routing/projection work.


## Owner execution command — Follow-up, Quick Entry and Checklist (2026-10-12)

- Canonical owner contract recorded in `docs/arvin-memory/ARVIN_FOLLOW_UP_AND_QUICK_ENTRY_DECISION.md` on documentation PR [#2643](https://github.com/mobinpda-lab/Arvin-clean/pull/2643); exact-head validation for the updated docs commit is running. Do not claim the document is merged until GitHub confirms it.
- Existing implementation lane [#2595](https://github.com/mobinpda-lab/Arvin-clean/pull/2595) already owns `lib/task_editor_dialog.dart`, `lib/quick_capture_dialog.dart` and their tests; avoid creating a parallel implementation PR. Added the new contract to that lane and Calendar PR #2636 for reconciliation.
- Required code changes remain **not yet verified complete**: remove auto-generated follow-up timestamp controls from Full Task Form while retaining «کار پیگیری‌دار»; preserve stored Task.followUpDate and FollowUp.nextFollowUp without copying/clearing; add compact Quick Entry «دارای پیگیری» and «دارای چک‌لیست» toggles that activate the canonical Roll Boxes; keep Checklist Task-owned; and make Calendar show explicit reminder first or nextFollowUp as an action item when no reminder exists, without scheduling a system notification from nextFollowUp alone.
- Existing #2595 is stacked and currently reports mergeable=false; do not merge or rebase blindly. Reconcile with its shared Universal Time Picker parent and existing overlapping Task-form drafts, then run exact-head Analyze, all test shards, Debug/Release APK, and relevant Calendar/Device Smoke.
- **Release remains NO-GO** until exact-head automated gates, physical-device Calendar update/no-duplicate behavior, real Backup/Restore and link-integrity evidence, RTL/compact-screen visual acceptance, and explicit owner approval are all recorded.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner clarified reminder initialization)

- **Live PR correction:** PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) is MERGED, not open. GitHub reports merge commit `8136c929237c321f2e879a80f067970c31cb0100`. Earlier text in this file describing #2650 as open is historical and superseded by this checkpoint.
- **New owner-confirmed product contract:** setting Next Follow-up does not automatically create a reminder. Create a reminder for it only if the user explicitly wants/chooses it. When chosen, prefill reminder title from the Task title and reminder date/time from Next Follow-up. The user can independently edit reminder title/date/time and may ask for additional reminders. This is initial-value convenience only, not a live binding.
- **Independence:** reminder is independent of previous/next follow-up and recorded Follow-up history. Later Next Follow-up edit/delete must not move/delete reminders; reminder edit/delete must not change Next Follow-up. Reminder can remain without Next Follow-up.
- **Collision/data-safety guard:** do not silently overwrite an existing reminder or create duplicates. Preserve existing data and require explicit user intent where an additional reminder is requested. Date-only/all-day intent is independently supported for Next Follow-up and reminders; never infer it from midnight alone.
- **Recorded to canonical memory:** follow-up concept decision, decision log, project knowledge, problem register and evidence map are being updated in this branch. This records the product contract only; it does not mean application code has been changed or validated.
- **Implementation gaps remain:** source audit found no first-set reminder creation bridge, no explicit Follow-up all-day metadata in the inspected model, and Follow-up Calendar projection does not set all-day explicitly. Need regression coverage across UI, model JSON, SQL envelope, backup/restore and Calendar event identity/no-duplicate behavior.
- **Validation:** no Flutter analyze/test/build/device run was performed as part of this documentation update. Release remains **NO-GO** until exact-head automation and required device/owner acceptance are proven.
- **Next action:** implement safely against canonical Task/FollowUp paths; test opt-in reminder creation and prefill, multiple reminders, independent edits/deletes, collision handling, date-only/all-day semantics, persistence/backup round-trip and same-event calendar updates. Recheck exact-head CI after the documentation PR is opened.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (multiple Follow-ups and reminders)

- **New owner-confirmed cardinality:** one Task may have multiple recorded Follow-up entries and multiple independent reminders. There is no one-per-Task limit.
- Each recorded Follow-up remains a distinct history entry. Each reminder remains a distinct, independently editable/deletable item with its own title and schedule. Editing/deleting one must not mutate other reminders, Follow-up history or Next Follow-up.
- Next Follow-up is still the separate next-action value. Setting it does not automatically create a reminder. If the user explicitly chooses to create a reminder for it, prefill Task title and Next Follow-up date/time as initial values only.
- **Implementation status:** this cardinality contract is now documented; the current implementation's support for multiple independently identified reminders and Follow-up entries has not been verified by this documentation update. Audit the canonical model/editor/storage/backup and Calendar identity paths; no parallel store.
- Required regression coverage: create/edit/delete one among several entries; preserve remaining entries and history; independently edit reminder title/date/time; reminder-only and multiple-reminder cases; JSON/SQL/backup-restore round-trip; Calendar same-event updates without duplicate creation; date-only/all-day semantics for each item.
- No app code or Flutter validation was performed in this documentation step. Release remains **NO-GO**.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (Calendar projection separation CI completed)

This checkpoint continues the current projection-separation PR; it does not restart prior audits. It supersedes older live status for PR #2665 where conflicting.

- **Repository:** `mobinpda-lab/Arvin-clean`.
- **PR #2665:** [fix(calendar): separate internal follow-up projection](https://github.com/mobinpda-lab/Arvin-clean/pull/2665), branch `fix/calendar-internal-followup-projection-20261013`, open/unmerged. Before this memory update, head was `1628048eacfd20ecd73e7938fddb79a8306c6b8c`; GitHub reported mergeable=true.
- **Completed — exact queried-head automation:** Build run [38364976764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38364976764) SUCCESS: Analyze, test shards 0–5, Debug APK and Release APK passed. Device Smoke run [38364976751](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38364976751) SUCCESS: Home, Quick Capture, People, SQL Migration, SQL Persistence and Backup/Restore all passed. These are automated/emulator results, not physical-device acceptance.
- **Implementation submitted:** separate read-only `FollowUpInternalCalendarProjection` reads canonical `FollowUp.nextFollowUp` and is combined with the existing calendar projection only at the internal calendar display boundary. Outbound sync remains wired to `FollowUpCalendarProjection`; the new follow-up-action entries are not passed into that outbound-sync call path. Regression tests cover internal-only visibility, separation when a Reminder exists, no canonical Task mutation, and independence of `nextFollowUp` from `reminderDate`.
- **Memory recorded:** decision details and the successful CI/emulator checkpoint are appended to `docs/arvin-memory/ARVIN_CALENDAR_PROJECTION_SEPARATION_DECISION.md` on this PR branch.
- **Still blocked:** PR review/merge; Calendar Provider Acceptance for CREATE → UPDATE same event/no duplicate; actual OS notification delivery/reschedule/cancel; physical-device installed-flow evidence; real file-provider Backup/Restore and Calendar-link integrity; multiple independent Task-level reminders (separate PR #2655); Persian RTL/compact-screen visual acceptance; explicit owner release approval.
- **Release:** **NO-GO**. Green CI does not establish physical-device or external-provider behavior and does not clear the separate multi-reminder gate.
- **Next action:** because this execution-state update itself creates another PR commit, query the resulting exact head and its Build + all six Device Smoke lanes. If green, review the diff and required provider/device gates; do not merge solely because GitHub says mergeable=true.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (projection test failure corrected; revalidation pending)

- Current reviewed implementation commit before this checkpoint: `683cf2a66f43282c1150d6d2f8674aeff86f8ba1`.
- Build run [38367352703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38367352703) surfaced one real regression-test failure in shard 4: `test/follow_up_internal_calendar_projection_test.dart`, test `changing nextFollowUp does not mutate existing reminderDate`, failed with `Bad state: No element`. Root cause: the newly added display-precedence rule correctly returns no internal Follow-up fallback when a Reminder exists, while the old test still expected a fallback item.
- **Correction committed:** `83d7ee4be40228ceeab7644219aa4ae82a56a974` updates that test to assert both contracts: an existing Reminder wins internal Calendar display, and `nextFollowUp` remains independently editable and visible when no Reminder exists. No production code changed in this correction.
- Earlier poll on head `683cf2a...`: Analyze PASS; test shards 0,1,2,3,5 PASS; shard 4 FAIL; Debug APK PASS; Release APK still running. Device Smoke: Home and Quick Capture PASS; SQL Migration and SQL Persistence running; People and Backup/Restore queued. These results are historical and must not be treated as validation of the corrected head.
- **Current state after correction:** new commit triggers fresh exact-head validation. Re-query the PR head and Build/Device Smoke workflows; require all test shards, both APK builds and all six smoke lanes to pass before considering merge.
- PR #2665 remains open/unmerged. No physical-device or external Calendar Provider Acceptance evidence exists. Multi-reminder PR #2655 remains open and non-mergeable.
- Release remains **NO-GO**.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (PR #2665 exact-head CI and device smoke completed)

This checkpoint supersedes earlier live status for PR #2665 where conflicting; preserve older entries as history.

- **Repository / lane:** `mobinpda-lab/Arvin-clean`; PR [#2665](https://github.com/mobinpda-lab/Arvin-clean/pull/2665), branch `fix/calendar-internal-followup-projection-20261013`, remains OPEN and UNMERGED. GitHub reported mergeable=true at this poll. Do not treat mergeability as approval or release readiness.
- **Exact validated code head before this memory-only update:** `2987f5530749b6de6292ff3c86933d8f50b56578`.
- **Build evidence:** [run 38368795309](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38368795309) completed SUCCESS on that exact head. Analyze, test shards 0–5, Debug APK and Release APK all passed.
- **Device Smoke evidence:** [run 38368795338](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38368795338) completed with all six lanes SUCCESS on that exact head: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore, and People.
- **Scope limitation:** these are GitHub automated/emulator gates. They do not establish physical-device acceptance, external Calendar provider CREATE→UPDATE/no-duplicate behavior, actual OS notification delivery/reschedule/cancel, or final owner approval.
- **Current implementation:** internal Calendar follow-up action projection remains separate from outbound Calendar sync. When a Task has an explicit Reminder, internal Calendar suppresses the fallback nextFollowUp action for that same Task; nextFollowUp and reminderDate remain independent canonical fields. PR #2665 is still unmerged.
- **Other open gate:** PR [#2655](https://github.com/mobinpda-lab/Arvin-clean/pull/2655) for multiple independent Task reminders remains non-mergeable at last known check; reconcile its base safely and validate exact head before integration. Issue [#2654](https://github.com/mobinpda-lab/Arvin-clean/issues/2654) remains the requirements tracker.
- **Release status:** **NO-GO** pending physical-device/product acceptance and explicit owner approval. Automated smoke is not a real-phone test.
- **Completed in this continuation:** re-polled the exact-head Build and all six Device Smoke jobs; all were successful. This new memory commit changes the PR head, so all exact-head gates must be queried again before merge.
- **Next action:** validate the resulting new PR head's Build and Device Smoke; review PR #2665 diff and provider/device gates. Then continue safe reconciliation of #2655 and the existing Calendar contract. Do not merge or publish a release solely because CI is green.


# AUTHORITATIVE CONTINUATION — 2026-10-13 (latest-head CI poll)

- Repository: `mobinpda-lab/Arvin-clean`; PR [#2665](https://github.com/mobinpda-lab/Arvin-clean/pull/2665), branch `fix/calendar-internal-followup-projection-20261013`, remains OPEN and UNMERGED; GitHub reports mergeable=true. Current checked head: `be52a7457b6300cb917b7ab312c2ec4e27c607fa`; base checkpoint `ee73adbc61c4baea82caeb9932969fd293922162`.
- **Completed — exact-head Build:** run [38370894374](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38370894374) SUCCESS on the checked head. Analyze, test shards 0–5, Debug APK and Release APK all completed successfully.
- **Completed — exact-head Device Smoke:** run [38370894181](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38370894181) SUCCESS on the checked head. All six lanes passed: Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore and People.
- Scope remains limited to CI/emulator validation. No physical-device acceptance or external Calendar Provider Acceptance is evidenced by these runs.
- **Safe next step:** inspect/reconcile PR #2655's 58-ahead/2-behind divergence against current main without blind merge/rebase. Its Task model, editor, Calendar inbound/outbound, backup and reminder scheduling changes overlap newer main and require path-by-path compatibility review.
- Release remains **NO-GO** pending multi-reminder integration, provider CREATE→UPDATE/no-duplicate evidence, real-device notification and backup/restore validation, Persian RTL/compact UX acceptance, and owner approval.
- This memory write creates a new PR head; re-query Build and all six Device Smoke lanes for that resulting exact head before any merge/readiness decision.



# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner-approved multiple-reminder migration command)

This checkpoint records the latest owner instruction. Keep older checkpoints as history; do not treat their “design unapproved” wording as current.

- Repository: `mobinpda-lab/Arvin-clean`.
- Latest main observed during this execution: `3f4b7299dca68afb31c9ad1c2c48b60dd8410a2d`.
- Owner explicitly approved the multiple independent Task reminder product model and requested a safe legacy migration from `Task.reminderDate` into a TaskReminder collection. The architecture decision is recorded in `docs/arvin-memory/ARVIN_MULTIPLE_REMINDER_ARCHITECTURE_DECISION.md` on branch `integration/task-multiple-reminders-safe-20261013`, commit `33ddb0f9467fd9a2d832c2e485eedf449da8eba3`.
- PR #2655 remains OPEN/unmerged; current feature branch `feat/task-multiple-reminders-editor-20261013` is diverged from main: 58 commits ahead, 3 behind, merge base `8136c929237c321f2e879a80f067970c31cb0100`; GitHub reports `mergeable=false`. It modifies model/JSON, editor, notification services, Calendar inbound/outbound/projections, persistence and backup tests.
- Safe integration branch created from current main: `integration/task-multiple-reminders-safe-20261013`. At this checkpoint it contains the approved architecture/migration decision document only; no application code has been ported, no schema migration has run, and no test/build/device run has been executed on this branch.
- Non-negotiable compatibility: `nextFollowUp` is not a reminder; legacy `FollowUp.reminderDate` stays independent; migration of `Task.reminderDate` must be idempotent and must not emit duplicate legacy/new Calendar events; explicit all-day state must distinguish date-only from intentional midnight; canonical Task JSON/SQL and existing backup/restore remain the only persistence path; internal Follow-up Action projection remains display-only and excluded from outbound sync/notification scheduling.
- Next implementation sequence: inspect latest main and feature sources side-by-side; port model/JSON with a deterministic, retry-safe legacy migration first; then persistence/backup, editor CRUD, notification identity, Calendar sync, and focused regression tests. Do not use a blind merge or overwrite mainline Calendar projection files.
- Validation gate: exact-final-head Analyze, test shards 0–5, Debug/Release APK, Calendar Provider Acceptance, all six Device Smoke lanes, followed by physical-device Calendar and Backup/Restore acceptance. Release remains NO-GO until evidence is recorded.


- **Draft integration PR created:** [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666), `feat(reminder): safely integrate multiple Task reminders`, base `main`, head branch `integration/task-multiple-reminders-safe-20261013`. It is intentionally DRAFT and must not be merged in the current documentation-only state. At creation, GitHub reported mergeable=false; this is not a code-validation result. The PR description explicitly lists the remaining implementation and acceptance gates.
- **Next executable step:** begin porting canonical `TaskReminder` model into the integration branch, but only together with backward-compatible JSON decoding/encoding, deterministic legacy migration semantics, and focused tests. Do not mark the branch implementation-ready until tests/builds run on its exact final head.
# AUTHORITATIVE CONTINUATION — 2026-10-13 (owner clarified current database is empty)

This checkpoint records the owner's explicit operational clarification. It supersedes any assumption that the owner has already entered personal records into Arvin; older technical compatibility requirements remain in force.

- **Owner statement:** the owner has entered no information into Arvin; the database is currently raw/empty.
- **Current-data risk framing:** do not claim that owner-entered records are currently at risk of loss when none have been entered. This does not prove every local/installed database, backup, fixture, or legacy payload is empty; inspect those boundaries before destructive operations.
- **Engineering implication:** the multiple-reminder migration/model gap remains a code-contract and backward-compatibility blocker, not evidence that current owner data has already been lost. Keep legacy JSON/backup decoding and idempotent migration tests because the product must safely handle prior versions and future real data.
- **No architecture relaxation:** preserve canonical Task as the single source of truth; keep nextFollowUp and per-FollowUp reminderDate independent; no parallel store/scheduler; prevent duplicate Calendar events/notifications.
- **Execution status:** this update is documentation-only. No application code, database, backup, or owner data was changed. The safe integration PR #2666 remains Draft; PR #2655 must not be blindly merged. Release remains NO-GO until implementation and exact-head validation are complete.
- **Next action:** proceed on the safe integration branch with source-level implementation only after reviewing canonical Task JSON/persistence, legacy reminder projection, backup/restore and relevant tests. Add explicit empty-database/fresh-install coverage where appropriate, while retaining legacy-payload compatibility tests. Then run exact-head CI; physical-device acceptance remains a separate gate.

---

## Latest poll correction — 2026-10-13 15:44 UTC

The integration branch advanced again during this audit. Latest observed parent PR #2666 head is `90c2addbd128776241d06d10f7f57207973d8907`. At this poll, Build and Device Smoke were pending; Calendar Provider Acceptance and several orchestration/lock workflows were queued. These are not pass results. Child PR #2681 remains Draft, unmerged, not mergeable, and has no associated workflow runs. This correction is documentation-only; it does not validate the source changes.


---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (latest execution checkpoint)

- **Parent PR #2666 live head:** `7c830e441a75656faebb4aa63bb146f92ebfab05`, open, unmerged, GitHub reports mergeable. The current CI set for this exact head is not green yet: Build is queued; Calendar Provider Acceptance is in progress; Device Smoke is queued; orchestration and production-loop workflows have completed successfully, but those do not substitute for Build/Calendar/Device acceptance.
- **Smoke-test correction included:** commit `69789128d36ad05249a2466b3a34125562cdef8b` replaced the obsolete `task-editor-followup-enabled` assertion with the canonical `task-editor-add-follow-up` control. Confirmed the updated assertion exists in the parent branch file. No passing test result is claimed until exact-head CI finishes.
- **Related PR #2679 failure inspected:** its Build run `38417142693` has Analyze and APK jobs green, but test shard 2 failed: 232 tests passed and `test/follow_up_office_page_test.dart` failed at line 263 because the expected waiting Task was not rendered. The implementation still derives waiting from `FollowUp.result` and latest-record-only semantics. This conflicts with the accepted structured per-Follow-up waiting/Person model in this branch; do not merge #2679 independently or patch around the test by weakening the assertion.
- **Child PR #2681:** remains Draft/unmerged and GitHub reports it not mergeable. Its branch remains materially diverged from the parent integration branch. Do not force-push or blindly merge; reconcile source and tests deliberately, retaining both parent reminder work and child structured Person/Follow-up work.
- **P1s remain open:** #2682 standalone Person directory backup/restore, #2683 Person-based reporting. Both require implementation plus regression evidence.
- **Next action:** wait for exact-head parent CI to finish; in parallel, reconcile the #2679 waiting semantics into the structured child implementation and plan the Person directory backup/restore extension on the same portable backup/restore path. Do not claim tests, build, device validation, or release readiness without actual green evidence.
- **Release:** **NO-GO**.

---

# PRODUCT COMPLETENESS AUDIT — 2026-10-13

- **Audit scope:** owner-requested user-facing audit across identity, Task core, Quick Entry, full editor, Follow-up, independent next-action/reminder behavior, multiple Task reminders, waiting response, Person directory, reports, Calendar, checklist, repeat, search, backup/restore and mobile UX.
- **Important branch distinction:** parent PR #2666 is open and unmerged; the Person-linked implementation in child PR #2681 is also open, Draft, and GitHub reports it not mergeable. Do not describe child-only features as already delivered to users.
- **Confirmed source evidence on parent integration branch:** canonical Task model, Task editor and Quick Capture exist; Task has a FollowUp record type and legacy followUpDate; multiple Task Reminder model and editor are implemented; repeat, checklist, RTL Home search and report filtering exist in code. This is not by itself end-to-end acceptance.
- **Confirmed structured Person/Waiting implementation on child branch:** FollowUp JSON includes waitingForResponse and personIds; SQL schema v6 includes structured Follow-up waiting/Person columns and people_directory; PersonDirectoryPage provides a lightweight add/edit/delete/search directory; Follow-up entry can load/select people. However, backup/restore coverage and Person-based report filtering remain explicit open P1 issues #2682 and #2683.
- **Report gap:** TaskReportFilter has date, project, category, tag, status, priority, repeat, Follow-up and checklist filters, but no Person filter and no per-Follow-up result rows that answer who is awaited and the next action.
- **Search gap:** observed Home search covers loaded Task/Home content and Persian/Follow-up text. No evidence was found in this audit that it searches a full indexed set of associated Person, Project, Category, Tag and Follow-up data end-to-end; mark this incomplete until a focused acceptance test proves it.
- **Backup/restore gap:** issue #2682 confirms standalone people_directory entries are not included in the current portable backup/restore payload; a person with no current association can be lost. Required: old-backup compatibility, reference validation before destructive restore, rollback/emergency backup inclusion, round-trip and injected-failure tests.
- **Current exact workflow evidence polled:** run 38425808151 has Analyze, Debug APK and Release APK successful, but test shards 2 and 3 failed; shards 4 and 5 were still in progress at the poll. Run 38425808310 Calendar Provider Acceptance succeeded. Run 38425808110 Quick Capture and Home smoke lanes succeeded; SQL migration and SQL persistence were still running, Backup/Restore and People lanes queued. Do not treat these partial results as a green overall gate.
- **Failure details from test logs:** follow_up_office_page_test.dart expected two matches but found one under the older latest-result waiting-list semantics; task_editor_dialog_test.dart has two checklist visibility/key failures; settings_page_test.dart cannot find all-day-reminder-time-setting; follow_up_reminder_model_test.dart expected legacy migrated title 'جلسه — یادآور ۱' but got 'یادآوری: جلسه'. These require root-cause fixes or a justified product-contract update, not test weakening.
- **Mobile UX:** RTL source widgets and RollBox usage exist, but no complete physical-device visual inspection/evidence is recorded for small-screen readability, density, icon sizing and real user flow.
- **Audit verdict:** the repository contains meaningful implementation, but the full product is not complete or release-ready. The strongest blockers are (1) failing exact-head test shards, (2) Person directory backup/restore integrity, (3) Person-based reports, (4) safe synchronization/merge of child PR #2681 with parent #2666, and (5) missing end-to-end/device evidence for search, calendar/reminder/follow-up behavior and mobile UX.
- **Next action:** fix the four evidenced test failures at root cause, finish remaining CI lanes, reconcile the stacked branch without overwriting parent changes, resolve #2682/#2683, then rerun all required gates on the exact final head. Release remains **NO-GO**.


---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (latest exact-head CI poll)

- **Parent PR #2666 current observed head:** `7c830e441a75656faebb4aa63bb146f92ebfab05` on `integration/task-multiple-reminders-safe-20261013`; open and unmerged against `main`. This is newer than earlier recorded heads. Do not assume prior workflow statuses are current.
- **Build run:** [38425808151](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38425808151) completed **failure**. Analyze and Debug/Release APK builds succeeded, but four test shards failed:
  - test-2: two checklist UI contract failures (missing/unexpected `task-editor-checklist-block`), missing `all-day-reminder-time-setting`, and legacy reminder migration title mismatch (`جلسه — یادآور ۱` expected, `یادآوری: جلسه` actual).
  - test-3: waiting-list test expected two `کار پاسخ‌گرفته` widgets but found one under the older latest-result semantics.
  - test-4: two reminder projection failures (multiple Task reminders expected but only one projected; migrated legacy title mismatch), plus Calendar inbound legacy reminder edit expected one match but found zero, and RTL right-swipe acceptance timed out.
  - test-5: Calendar inbound legacy reminder deletion expected one match but found zero; migrated reminder title mismatch; Notebook-to-Task editor conversion test failed; RTL left-swipe acceptance timed out.
  - These are distinct regressions/contract mismatches; do not bulk-change expected values or weaken tests without checking current product intent and root cause.
- **Calendar Provider Acceptance:** run [38425808310](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38425808310) succeeded for this head.
- **Device Smoke:** run [38425808110](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38425808110) remains in progress at latest poll. Quick Capture, SQL migration, SQL persistence, Backup/Restore, and Home lanes succeeded; People lane is still running. This is not yet an overall completed smoke gate.
- **Current blocker:** test failures span Task Editor/Settings, reminder projection and Calendar legacy identity, waiting-list contract, Notebook conversion, and RTL swipe acceptance. Prioritize the smallest reproducible root cause; rerun exact-head tests after each code fix. Child PR #2681 remains Draft/not mergeable and its Person backup/report gaps #2682/#2683 remain open.
- **Next action:** fetch full failing test context and current implementation for the exact PR head; fix one confirmed root cause without changing accepted contracts, then commit and rerun targeted CI. Keep release **NO-GO** until Build is green and Device Smoke reaches a successful terminal state plus child architecture gates pass.


---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (first CI-root-cause correction committed)

- **Parent PR #2666 head:** `4b7d5e3d454d0e1204ed6702e5643c78be83eac5`; open, unmerged, mergeable. Commit: [4b7d5e3](https://github.com/mobinPda-lab/Arvin-clean/commit/4b7d5e3d454d0e1204ed6702e5643c78be83eac5).
- **Correction scope:** test-only changes in `test/follow_up_reminder_model_test.dart` and `test/follow_up_reminder_projection_test.dart`.
  - The Task migration code explicitly documents that the migrated legacy reminder must preserve its legacy Calendar title/fingerprint (`یادآوری: <Task title>`). Two assertions expected a different title (`<Task title> — یادآور ۱`), contradicting that existing compatibility contract; expectations now match the preserved legacy title.
  - The multiple-reminder projection fixture had its second timed reminder at midnight while the test's `now` was 08:00. Since it is a timed (not all-day) reminder, it was correctly expired and filtered. The fixture now schedules it at 10:00 and expects 10:00, so the test verifies two genuinely active reminders instead of weakening expiry behavior.
- **Validation trigger:** exact-head Build run [38428476972](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476972) is in progress; Calendar Provider Acceptance [38428476999](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476999) and Device Smoke [38428476964](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476964) are also queued/in progress. No pass is claimed yet.
- **Not addressed by this commit:** checklist UI contract failures, all-day setting key, Calendar inbound legacy identity/delete tests, waiting-list semantic mismatch, Notebook conversion and RTL swipe timeouts; they require separate root-cause work.
- **Next action:** inspect this exact head's Build and smoke outcomes; if these two test corrections pass, take the next smallest source-level root cause. Keep PR unmerged and release **NO-GO** until all gates and Person backup/report work are validated.


---

# AUTHORITATIVE CONTINUATION — Person directory portable backup/restore implementation — 2026-10-13

- **Scope:** P1 issue [#2682](https://github.com/mobinpda-lab/Arvin-clean/issues/2682), standalone Person directory records missing from portable backup/restore and rollback.
- **Branch:** `integration/follow-up-person-model-20261013`; implementation is on stacked PR [#2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681), marked ready for review to collect CI evidence, based on parent integration PR #2666. Do not merge; GitHub currently reports the child PR not mergeable against its base.
- **Implementation authored:**
  - Existing portable backup v1 now accepts optional `people` entries; no second backup format and no version bump. Legacy files without `people` remain valid.
  - `ArvinBackupManager` serializes stable Person ID/display name, validates entries, rejects duplicate IDs, and exposes `people == null` for legacy backups versus an explicit list for newer backups.
  - Both Home's direct backup/restore flow and BackupPage flow include the Person directory in normal and emergency backups.
  - Restore merges incoming records by stable Person ID and retains local-only directory entries. Rollback restores the exact pre-restore directory through a transactional TaskStore operation, without cascading deletion of Tasks/Follow-ups.
  - Regression coverage added for portable document compatibility, manager round-trip, duplicate IDs, directory merge/replace, Home rollback, BackupPage runtime restore/late rollback, and file-backed round-trip.
- **Files changed:** `lib/backup_service.dart`, `lib/backup_manager.dart`, `lib/services/task_store.dart`, `lib/main.dart`, `lib/backup_page.dart`, `test/backup_service_test.dart`, `test/canonical_backup_manager_test.dart`, `test/person_directory_backup_restore_test.dart`, `test/home_restore_orchestration_test.dart`, `integration_test/android_backup_restore_sql_smoke_test.dart`.
- **Validation:** source and test edits are committed to the child branch; no workflow run/check result has yet been returned for its current head. Tests/build/device smoke are **NOT YET VERIFIED**. No claim of Done or release readiness.
- **Current status:** implementation authored; validation pending; issue #2682 remains open until exact-head tests, backup/restore/rollback evidence, and device smoke pass.
- **Next action:** obtain exact-head CI for the final child head, repair any concrete failures, safely synchronize with the latest parent branch without overwriting changes, then rerun required gates. Release remains **NO-GO**.


---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (post-command live recheck)
- Re-read this file first and continued from the Person-directory backup/restore P1 checkpoint; no architecture restart and no duplicate implementation.
- Live child PR #2681: open, ready-for-review (not Draft), unmerged, GitHub reports mergeable=false; head a50ef4549b66621287af3aec6f805f6876fed2fd, base PR #2666 integration branch at recorded base SHA c9d244d7ec45d18e5a8c89159a2eeac1c68ae9e1. No PR-associated workflow runs/checks were returned for this child head.
- Live parent PR #2666: open, ready-for-review, unmerged, mergeable; head 60af42f259c537fa9311dd0b195004d1dc400f2f.
- Branch compare confirms major divergence: child has 82 commits ahead and 134 commits behind parent integration branch; merge base 68724d6191590b81b2d611f59b7944a7fcbb06e0. This is not safe to resolve by force-update or blind merge. No local checkout/Flutter toolchain is available in this execution environment, and available GitHub operations do not provide automatic conflict-safe source reconciliation. Preserve both refs until deliberate merge/rebase and conflict review can be performed.
- Parent exact-head Build run [38454176741](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38454176741) for SHA 60af42f259c537fa9311dd0b195004d1dc400f2f: Analyze passed; Debug APK passed; Release APK passed; test shards 0–3 passed; shards 4 and 5 failed. Test-4 failures: Calendar page reminder action expected «انجام شد» but absent; migrated legacy provider edit found 0 instead of 1; RTL right-swipe acceptance timed out. Test-5 failures: Calendar page ownership/delete controls absent, canonical repeat occurrence action absent, migrated legacy provider delete found 0 instead of 1, legacy reminder projection title mismatch (expected «تماس — یادآور ۱», actual «یادآوری: تماس»), Calendar long-press «حذف کار» absent, Notebook-to-Task same-identity conversion failed, and RTL left-swipe acceptance timed out. Do not weaken assertions without root-cause review.
- Parent Calendar Provider Acceptance run [38454176500](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38454176500) succeeded on the parent SHA. Parent Device Smoke run [38454176507](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38454176507) succeeded on that SHA. These do not override failed Build quality and do not validate child-only Person backup code.
- P1 #2682 remains OPEN: backup/restore source and regression tests are authored on child branch but exact-head tests, rollback evidence and device validation remain unverified. P1 #2683 Person-specific Report Center filtering/results remains incomplete.
- Next action: safe branch synchronization/conflict reconciliation is the immediate blocker; then obtain child exact-head Build/Calendar/Device runs, fix concrete failures at root cause, complete #2683, and rerun all gates on one final SHA. Release remains NO-GO; no APK is declared release-ready.


---

# AUTHORITATIVE CONTINUATION — 2026-10-13 (fresh source compatibility audit)
- Fresh live audit after the previous checkpoint: PR #2681 remains open/unmerged and its current head is 4ccaa65af60079538527909ee7ed4724a05171ef; base is integration/task-multiple-reminders-safe-20261013 at base SHA c9d244d7ec45d18e5a8c89159a2eeac1c68ae9e1. No PR-triggered workflow runs/checks are associated with this child head.
- Parent PR #2666 remains open/unmerged at 60af42f259c537fa9311dd0b195004d1dc400f2f, targeting main. Its latest Build remains failed (run 38454176741); Calendar Provider Acceptance (38454176500) and Device Smoke (38454176507) passed, but do not satisfy the full release gate.
- New compatibility-audit finding: parent already has PersonReference and Task-scoped task_people storage, but it does **not** have the standalone people_directory table/schema, directory APIs in TaskStore, or Person directory UI. Child #2681 adds those pieces as part of the larger structured Follow-up/Person feature. Its backup fix therefore cannot be safely transplanted as a few isolated backup-file replacements; it depends on the directory/schema/TaskStore work.
- Parent-child compare still reports 82 commits ahead / 134 behind, merge base 68724d6191590b81b2d611f59b7944a7fcbb06e0. No local checkout or Flutter toolchain is available for conflict resolution and validation here. No branch ref was force-updated, no PR merged, and no issue closed.
- #2682 stays OPEN. Next safe action requires a reconciled branch with the directory/schema and backup changes integrated together, then exact-head CI. Release remains NO-GO.
