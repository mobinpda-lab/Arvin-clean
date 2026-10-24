# Arvin Owner Decision Register: Reminder Is the Only Current Scheduling Concept

**Decision locked:** 2026-10-24  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Acceptance owner:** Issue [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139)  
**Normative contract:** [ARVIN_REMINDER_CONTRACT.md](ARVIN_REMINDER_CONTRACT.md)

## The settled decision

The owner already removed the product concepts “پیگیری بعدی” (Next Follow-up) and “پیگیری مستقل” (independent Follow-up), replacing them with **هشدار / یادآور (Reminder)**.

This decision is settled. It is not an open design question. Do not re-propose the removed concepts, ask the owner to decide again, or treat old PR text/tests/docs as the current product contract.

Current product scheduling model:
- One canonical Task.
- A separate Task due date.
- Zero or more stable-ID Reminders belonging to that Task.
- Independent delivery channels for Arvin alarm notifications and phone Calendar synchronization.

## What legacy code means

Names such as `FollowUp`, `nextFollowUp`, `followUpEnabled`, `followUpDate`, `followUps`, and nested legacy `reminderDate` are present in older implementation/data. Their presence does not mean the removed concepts are still supported product behavior.

They may remain temporarily only where needed to read, migrate or preserve existing user data. They must not create new UI flows, active scheduling semantics, separate Calendar cards, notification behavior, report/filter dimensions or product requirements. Preserve old records until a complete consumer audit and safe migration is proven; do not perform a blind delete/rename.

## Required rule for every future wave

Before modifying Reminder, Calendar, alarms, Task scheduling, migration or backup/restore:
1. Read this register and the normative Reminder contract.
2. Read Issue #1139 and inspect all open/relevant PRs and their exact heads.
3. Search the whole repository for the legacy terms above, including tests, docs, fixtures, workflows and migration code.
4. Classify each occurrence as current Reminder implementation, compatibility/migration, historical record, or prohibited active legacy behavior.
5. Reuse the canonical Task/Reminder/store/projection. Do not create parallel models or engines.
6. Keep assertions that represent this contract. Diagnose a failing test at the correct data/projection/UI boundary; never make it pass by weakening the contract.
7. Do not claim acceptance until exact-SHA Analyze, relevant tests, builds, Device Smoke and the separate owner/device gates have evidence.

## Known audit findings to track, not to normalize as product requirements

The baseline source search found legacy fields in `lib/models/task.dart`; a legacy external Calendar projection in `lib/services/follow_up_calendar_projection.dart`; an internal Calendar projection in `lib/services/follow_up_internal_calendar_projection.dart` that emits planned-action rows from `nextFollowUp`; and legacy alarm planning in `lib/services/follow_up_reminder_alarm_planner.dart`. These require a caller/data-flow audit and safe migration. This register does not claim those code paths have already been removed.

The Android Calendar interaction test on main, `integration_test/calendar_card_interaction_test.dart`, still seeds a legacy `FollowUp`, expects a key beginning `reminder-card-followup:`, and opens a “ویرایش پیگیری” editor. This is not a valid end-state acceptance scenario for the current Reminder-only contract. Replace/rework it to exercise a canonical Task Reminder and the current Reminder UX only after inspecting the actual calendar-card route and canonical model. Keep a regression test for the retired flow being absent where appropriate.

## Anti-regression / acceptance gate

Do not close this decision as complete merely because this document exists. Completion requires:
- the full legacy-reference audit with dispositions,
- removal/retirement of active legacy behavior,
- safe and idempotent legacy-data handling,
- Reminder-focused regression coverage across JSON/SQLite/backup-restore/Calendar/alarms,
- exact-head CI and relevant Device Smoke,
- owner acceptance on the intended installed build.

Until those gates pass, release remains `BLOCKED — RELEASE: NO-GO`.

**If a later PR or conversation conflicts with this register, stop and reconcile it against the owner decision before coding or merging.**
