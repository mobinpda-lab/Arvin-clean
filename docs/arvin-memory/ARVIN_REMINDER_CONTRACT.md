# ARVIN Reminder Contract
**Status:** Current owner-directed product contract  
**Decision date:** 2026-10-24  
**Scope:** Task reminders, Task due dates, recorded Follow-up history, Calendar projection, alarms, recurrence, reporting and backup/restore  
**Authority:** Explicit owner instruction in Wave 7.31. This contract supersedes conflicting earlier follow-up decision notes for current behavior.

## 1. Canonical concepts
- **Task:** The canonical work item owned by Arvin.
- **Due Date:** The Task's original due date. It is independent of all reminders.
- **Reminder:** Zero or more independently identifiable notification/calendar intents belonging to a Task. Each has a stable ID, date and either a meaningful time or explicit all-day intent.
- **Follow-up record:** An immutable/history-preserving record of an action, result, note, waiting-for-response state and parent Task relationship. It is not a reminder.
- **Next Follow-up:** The legacy/current UI concept for a future action date. It is not a parallel current scheduling source. Current user-facing behavior must be redesigned around Reminder where that is the explicitly specified behavior; historical values remain readable until consumers and migration are audited.

## 2. Reminder data and isolation
Each reminder must have a stable identity and independent lifecycle. Editing, rescheduling, disabling, or deleting one reminder must not mutate the Task Due Date, another reminder, or a Follow-up history record.

Reminder settings are independent:
- date and either an actual time or explicit all-day mode;
- Calendar synchronization enabled/disabled;
- Arvin alarm enabled/disabled;
- stable reminder ID;
- external Calendar event ID only when Arvin created/owns a corresponding event;
- scheduled notification ID only when an Arvin alarm is enabled;
- synchronization state/error when supported by the architecture.

Do not introduce duplicate fields or a parallel Task store before auditing existing canonical models and consumers. If a required setting has no safe representation, document the gap and propose the smallest compatible model migration before implementation.

## 3. Date and all-day semantics
- An all-day reminder is explicitly represented as all-day; display-time midnight (00:00) alone never implies all-day.
- All-day reminders must not schedule an unintended midnight alarm.
- A timed reminder uses its real stored time, not a UI placeholder such as 00:00.
- Preserve legacy date/time values during decoding and migration. Do not silently infer user intent from incomplete data.

## 4. Calendar and Arvin alarms are separate channels
The Calendar-sync setting controls whether Arvin creates or updates an event it owns in the phone calendar. The Arvin-alarm setting controls whether Arvin schedules its own notification. All four combinations are valid and must be tested independently:
1. Calendar ON, Arvin alarm ON: Calendar event plus Arvin notification.
2. Calendar ON, Arvin alarm OFF: Calendar event, no Arvin notification.
3. Calendar OFF, Arvin alarm ON: Arvin notification, no new Arvin-owned Calendar event.
4. Calendar OFF, Arvin alarm OFF: retain the Reminder internally, with neither new Calendar event nor Arvin notification.

Turning off Arvin alarms must not delete the Reminder. Turning off Calendar sync may delete/update only an event proven to be owned by Arvin; never delete unrelated phone-calendar events. Permission denial and provider errors must be surfaced as failures or blocked outcomes, not false success. Repeated startup, rescheduling, or restore must not duplicate events or notifications.

Completing a Task stops its future Arvin alarms and future owned Calendar reminders while retaining the Reminder and Follow-up history according to the data-retention rules.

## 5. Follow-up history and legacy migration
- Follow-up records remain separate historical entries and retain their parent Task relationship, action timestamp, result, note and waiting-for-response state.
- Do not treat Next Follow-up as the whole Follow-up history or as a Reminder.
- Do not continuously link reminder fields to Next Follow-up.
- Do not automatically create a reminder merely because a legacy Next Follow-up value exists, unless a specifically approved one-time migration is separately documented. The current owner contract in Wave 7.31 replaces the older conflicting decision; implementation must not preserve an automatic or bidirectional link by inertia.
- Historical fields and records are retained until a full consumer audit proves a safe migration/removal path. Any migration must be bounded, idempotent, documented, reversible where feasible, and tested against existing JSON, SQLite, Backup/Restore and report consumers.

## 6. Recurrence, Home and Calendar projections
- Each recurrence occurrence has independent completion state.
- A new occurrence's checklist is initialized from the valid recurrence template, not by mutating completed historical occurrences.
- Resume, restart and restore must not create duplicate occurrences.
- Calendar shows at most the next five future occurrences per recurring Task.
- Home places all-day tasks above timed tasks and summarizes the nearest reminder per Task for each day. This summary must not hide additional reminders from Task details or Calendar.
- Reminder edits/deletes and recurrence generation must be identity-based and idempotent.

## 7. Reports and filters
Reports must preserve action history and show completed and remaining recurrence counts plus action dates where the underlying data supports them. A filter may be enabled only when implemented and backed by actual data. Combined people, project, category, tag, date range, title, description, status, recurrence, follow-up and checklist filters must not silently pretend to filter dimensions that are unsupported.

## 8. Required verification
Before accepting implementation:
- exact-SHA source audit of all legacy Next Follow-up/reminder references;
- JSON round-trip, SQLite file-backed close/reopen, CRUD isolation, migration idempotence and Backup/Restore identity/relationship preservation;
- all four Calendar/Arvin-alarm combinations through create/edit/reschedule/delete;
- permission/provider error handling, restart/restore idempotence, and ownership-safe event deletion;
- all-day/no-midnight-alarm and timed 00:00 display-vs-value tests;
- recurrence occurrence/checklist/history tests and Home/Calendar projection limits;
- exact-head Analyze, relevant test shards, Build and CI review;
- separate installed-device owner acceptance.

A passing unit test, PR existence, or successful build alone does not mean product acceptance. Release remains `BLOCKED — RELEASE: NO-GO` until all mandatory gates pass.

## 9. Superseded decision history and Product Reference v1.3
The former document [ARVIN_FOLLOW_UP_CONCEPT_DECISION.md](ARVIN_FOLLOW_UP_CONCEPT_DECISION.md) is retained as history and marked superseded for current behavior. Its older statement that Next Follow-up must remain a parallel current concept is not normative for new behavior.

Product Reference v1.3 was searched for in the inspected repository, but no matching artifact was found in the available search results. This contract does not fabricate, reconstruct, or claim approval by a missing v1.3 document. If the official artifact is supplied or located, reconcile its version and authority explicitly without silently weakening this owner-directed contract.
