# ARVIN Reminder Contract

**Status:** Current, owner-directed and normative  
**Decision date:** 2026-10-24  
**Scope:** Task scheduling, reminders, Calendar projection/sync, alarms, recurrence, persistence, migration, backup/restore and regression prevention  
**Authority:** Explicit product-owner clarification. This decision supersedes older documents and PR descriptions that treated “Next Follow-up” or “independent Follow-up” as current product concepts.

## 1. Non-negotiable product vocabulary

The current scheduling model is:
- **Task**
- **Task due date**, independent from reminders
- **Reminder**, zero or more independently identifiable scheduled reminders attached to a Task

The settled owner decision removed the scheduling concepts **“پیگیری بعدی” (Next Follow-up)** and **“پیگیری مستقل” (independent Follow-up Reminder)** and replaced them with canonical Task Reminders. Do not reintroduce those retired scheduling concepts in UI, active schedule behavior, Calendar cards, filters, reports, notifications, acceptance criteria or new product documentation. Do not reopen this decision.

**Important distinction:** a dated FollowUp/history record may still represent a real past interaction (for example, a call, result, note, completion state or linked person) where that history is part of the accepted product. Do not delete or rename that historical record merely because the old scheduling fields are retired. What must not remain active is the old nextFollowUp future-action schedule or a separate reminder schedule nested under a FollowUp record. The current scheduled notification/calendar intent belongs to a canonical Task Reminder.

Arvin's own alarm and phone-calendar synchronization are separate delivery channels for a Reminder, not separate product concepts.
## 2. Legacy names and stored data

The repository contains historical FollowUp records as well as legacy scheduling fields. The record type/history and the retired scheduling concepts must not be conflated:
- FollowUp records and the followUps collection may hold historical interaction data and must be preserved where used by accepted history, people or report flows.
- nextFollowUp, legacy enable/date fields, and a nested FollowUp.reminderDate are old scheduling concepts to audit and retire or migrate; they do not define current Reminder behavior.
- Their existence in source, database schemas, JSON or old PRs is not authority to revive the removed Next Follow-up or independent Follow-up Reminder workflows.
- Compatibility with old serialized fields is not a product requirement. Fields may be retired from the active code model where safe, but the absence of a compatibility requirement is not permission to erase real owner data.

Rules:
- Do not create new user-facing scheduling behavior based on legacy Next Follow-up or nested legacy reminder fields.
- Do not render legacy-only planned-action or nested FollowUp reminder records as current Task Reminder cards. Only an explicit, documented, stable-ID and duplicate-safe conversion of a real reminder timestamp into the canonical TaskReminder collection is permitted.
- Do not create a Reminder by inference from a legacy next-action date.
- Preserve FollowUp history records as historical records. Do not delete or rewrite a real owner database, installed-app database or owner Backup without explicit approval for that exact operation. Development tests must use a provably separate temporary database and must never seed the owner's raw database.

## 3. Reminder behavior

Each Reminder has a stable identity, date, explicit timed/all-day semantics, and independent lifecycle. It has separate `alarmEnabled` and `calendarSyncEnabled` settings. Editing, moving, disabling or deleting one Reminder must not mutate the Task due date or another Reminder.

Calendar synchronization and Arvin alarm delivery are independent settings:
1. Calendar ON, alarm ON: owned Calendar event plus Arvin notification.
2. Calendar ON, alarm OFF: owned Calendar event only.
3. Calendar OFF, alarm ON: Arvin notification only.
4. Calendar OFF, alarm OFF: Reminder remains stored; neither channel is scheduled.

Turning off Calendar sync may remove/update only a provider event proven to be owned by Arvin. Never delete unrelated phone-calendar events. Permission/provider failures must not be reported as success. Repeated startup, rescheduling and restore must not duplicate events or notifications.

All-day is explicit. Midnight alone does not prove all-day intent. All-day reminders must not produce unintended midnight alarms. Timed reminders preserve their actual time. Completing a Task must stop future delivery according to the approved lifecycle without silently deleting reminder records or unrelated Calendar events.

## 4. Canonical storage and migration

A local alarm toggle controls only notification delivery; a device-calendar sync toggle controls only Arvin-owned provider events. Neither toggle deletes the Reminder record. The four combinations must be tested independently.

- Keep one canonical Task source of truth and the existing canonical storage path. Do not introduce a parallel Task store, Reminder engine or Calendar projection.
- Reminder IDs and relationships must survive JSON round-trip, file-backed SQLite close/reopen, CRUD, migration and backup/restore.
- Deleting or editing one Reminder must leave sibling Reminders and the Task due date unchanged.
- Migration must be bounded, idempotent, versioned, and tested on legacy data. A stale legacy field must not resurrect a deleted Reminder.
- Preserve recurrence occurrence identity/history and per-occurrence checklist state.

## 5. Required code and PR audit

Before marking this decision implemented, audit the **entire repository and every open/relevant PR**, not only the files changed by the latest wave:
- Search source, tests, docs, fixtures, CI workflows and PR descriptions for `FollowUp`, `followUp`, `nextFollowUp`, `followUpEnabled`, `followUpDate`, and legacy `reminderDate`.
- Classify each match as: (a) current Reminder behavior, (b) data compatibility/migration, (c) historical documentation, or (d) prohibited active legacy behavior.
- Check editors/forms, Home, Calendar and its internal/external projections, alarm planners, notifications, repositories/stores, SQLite writers/migrations, JSON, backup/restore, reports/filters, recurrence, navigation and all tests.
- Reconcile conflicting open PRs before accepting any of them. A passing test that encodes the retired product concept is not valid acceptance evidence.
- Never weaken or delete a failing assertion merely to get CI green. First determine whether the assertion, fixture, projection, persisted data or UI route is wrong against this contract.

## 6. Mandatory regression gates

- Static repository-wide search with reviewed disposition for every relevant legacy match.
- Reminder create/edit/reschedule/delete and sibling-isolation tests.
- JSON round-trip, file-backed SQLite close/reopen, migration idempotence and backup/restore identity/relationship tests.
- All four Calendar/alarm combinations, including permission/provider failure and ownership-safe cleanup.
- All-day/no-midnight-alarm and timed reminder semantics.
- Restart/restore idempotence, recurrence and Home/Calendar projection tests.
- Analyze, relevant test shards, Debug/Release builds and Device Smoke on the exact candidate SHA.
- Installed-device and owner acceptance remain separate gates.

A documentation PR, an open PR, a passing unit test, or a successful build alone does not prove the product refactor complete. Keep release `BLOCKED — RELEASE: NO-GO` until all mandatory gates pass on the accepted revision.

## 7. Decision precedence and anti-forget rule

This file is the current normative product contract. Older decision documents, comments, PR titles/descriptions, tests and model names are historical evidence only where they conflict with this decision. Preserve history, but do not treat it as current requirements.

Every new task or conversation must read this contract and Issue #1139 before changing Reminder, Calendar, notification, migration or related behavior. Do not ask the owner to re-explain or re-approve the already settled removal of the old Follow-up concepts.
