# ARVIN FOLLOW-UP CONCEPT DECISION

**Date:** 2026-10-12  
**Status:** APPROVED PRODUCT CONTRACT — authoritative  
**Scope:** FollowUp data semantics, editor UI, Calendar projection, reports and filters  
**Applies to:** All future implementation and refactoring; especially experimental Calendar integration PR #2640

## Decision

`nextFollowUp` and `reminderDate` are two independent concepts. They MUST NOT be merged, treated as aliases, or replace one another.

## 1. `nextFollowUp` — next action / review time

The time when a topic should next be acted on or reviewed. It belongs to work and follow-up management.

Example: for the Task «خرید فرش اتاق», `nextFollowUp = 25 Mehr` means the topic should be followed up again on 25 Mehr.

## 2. `reminderDate` — notification time

The time when Arvin should notify the user. It belongs to the Reminder/Notification function.

Example: `reminderDate = 25 Mehr, 09:00` means Arvin should remind the user at 09:00 to follow up on buying the carpet.

The two values may be related, but their meanings are not interchangeable.

## 3. Relationship

- Task → Follow-up → `nextFollowUp`
- Follow-up → Reminder/Notification → `reminderDate`

## 4. Mandatory data-contract rules

- Never delete or clear `nextFollowUp` merely to simplify the UI.
- Never copy `nextFollowUp` into `reminderDate` as an implicit normalization or migration.
- Never use `reminderDate` as a substitute for the next-action/follow-up schedule.
- Preserve both fields independently when editing, serializing/deserializing, storing in SQL, syncing, backing up, and restoring.
- Any actual schema/data migration or change to these semantics requires a separate explicit owner decision.

## 5. UI

UI simplification must preserve the model. If needed, the FollowUp editor may expose a separate control labelled «یادآور پیگیری بعدی» for the reminder. That control represents `reminderDate`; it does not replace `nextFollowUp`.

## 6. Calendar projection

For a FollowUp calendar projection:
1. If an explicit `reminderDate` exists, use it as the Calendar reminder time.
2. Otherwise, if `nextFollowUp` exists, use `nextFollowUp` as the fallback projection time.
3. Do not mutate either stored field while choosing the projection time.
4. Keep stable Task/FollowUp and external Calendar identity rules; update an existing linked event rather than creating duplicates.

This rule governs Calendar display/projection only. It does not make the two fields semantically equivalent.

## 7. Reports and filters

Reports and filters must be able to distinguish:
- upcoming follow-ups based on `nextFollowUp`; and
- scheduled notifications/reminders based on `reminderDate`.

A view may combine them for convenience only if the event type remains distinguishable and neither underlying field is lost.

## 8. Required regression coverage

Tests should prove that:
- editing a FollowUp preserves `nextFollowUp` independently of `reminderDate`;
- a reminder-only FollowUp does not invent a follow-up schedule;
- a follow-up-only FollowUp does not persist an implicit reminder;
- JSON/SQL and backup/restore round-trips preserve both values independently;
- Calendar projection prefers explicit `reminderDate`, falls back to `nextFollowUp` only when no reminder exists, and never mutates stored data;
- Calendar synchronization updates the same external event by stable identity and does not create duplicates.

## 9. Current execution consequence

The former mapping in the Calendar decision log—read `nextFollowUp` as `reminderDate` and clear `nextFollowUp` on save—is superseded by this decision and must not be implemented.

For experimental PR #2640, preserve the existing independent fields and validate the current corrected editor behavior. Do not merge to `main` or release automatically; all existing physical-device, RTL/compact-screen, and owner acceptance gates still apply.

## Evidence and references

- Experimental integration PR: https://github.com/mobinpda-lab/Arvin-clean/pull/2640
- Release/acceptance gate issue: https://github.com/mobinpda-lab/Arvin-clean/issues/2102
- Core fields and consumers include `lib/models/task.dart`, `lib/follow_up_entry_page.dart`, `lib/follow_up_repository.dart`, `lib/services/task_next_action_service.dart`, `lib/services/work_agenda_projection.dart`, `lib/task_detail_page.dart`, SQL persistence, and backup/restore paths.
