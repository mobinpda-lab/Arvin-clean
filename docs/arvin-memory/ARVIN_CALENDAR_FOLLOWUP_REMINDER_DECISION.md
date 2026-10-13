# ARVIN Calendar, Follow-up & Reminder Decision

Date: 2026-10-13
Status: **OWNER-SUPPLIED FINAL PRODUCT / ARCHITECTURE DECISION**
Repository: `mobinpda-lab/Arvin-clean`

This document records the owner's explicit Calendar Follow-up & Reminder Integration Command v1.0. It resolves the prior ambiguity about the scope of the in-app Calendar versus external/device Calendar. Implementation and validation evidence are tracked separately; recording this decision does not itself establish that the feature is implemented or tested.

## 1. Canonical ownership

- The existing `Task` remains the single source of truth.
- Follow-up, Reminder, notifications, internal Calendar, external Calendar, reports, and search are Task-owned behavior or projections—not parallel task systems, stores, databases, or schedulers.
- `nextFollowUp` and `reminderDate` are distinct fields/concepts. Neither substitutes for the other.
- Preserve Task identity, follow-up history, legacy serialized fields, backup/restore compatibility, and stable external-event identity.

## 2. Definitions

### Follow-up / action plan
- Meaning: when to revisit a subject or take the next action.
- Field: `nextFollowUp`.
- May exist without any Reminder.
- Must not automatically create an OS notification or an event in an external/device Calendar.

### Reminder / notification
- Meaning: what Arvin should notify the user about and when.
- Legacy field: `reminderDate`; the approved multi-reminder design allows multiple independently identified reminders for a Task.
- May exist without a Follow-up.
- Is the source for reminder notifications and, when synchronization is enabled and authorized, external Calendar projection.

## 3. Internal Arvin Calendar

The in-app Calendar recognizes both concepts and must label their nature clearly.

1. If one or more Reminders exist for a Task, display the Reminder item(s), with each item identifiable as a Reminder and linked to the parent Task.
2. If no Reminder exists and `nextFollowUp` exists, display a **Follow-up Action** in the in-app Calendar.
3. Showing `nextFollowUp` internally is presentation only: it does not create a Reminder, schedule a notification, or create an external event.
4. Preserve stable identity and update-existing behavior; refresh/update an existing projected item rather than creating duplicates.

## 4. External / device Calendar

Google Calendar and device Calendar may receive only:
- Reminders explicitly created by the user (subject to enabled/authorized sync); and
- Events the user or an authorized system flow explicitly designates for synchronization.

Forbidden:
- Creating an external event solely because `nextFollowUp` is set.
- Scheduling an OS notification solely because `nextFollowUp` is set.
- Treating an internal Follow-up Action as permission to sync externally.

Every synchronized Reminder must link back to its parent Task. Use stable Task/reminder identity and CREATE → UPDATE EXISTING semantics; do not identify events by title/date alone or create duplicates.

## 5. Independence on change

- Changing `nextFollowUp` must not move, edit, or delete any Reminder.
- Changing a Reminder schedule/title must not mutate `nextFollowUp`, Follow-up history, or another Reminder.
- If the user asks to change associated Reminders together with a Follow-up, obtain an explicit, clearly scoped choice first.
- Enabling Follow-up or setting `nextFollowUp` must not invent a Reminder or timestamp.

## 6. Independence on deletion

- Deleting a Reminder must not delete Follow-up, clear `nextFollowUp`, alter Follow-up history, or delete another Reminder.
- Removing a Follow-up must not delete independent Reminders without an explicit user decision.
- Preserve history and legacy data according to the established compatibility contract.

## 7. Full Task form

- Keep the **«کار پیگیری‌دار»** control.
- Remove **«زمان پیگیری: تاریخ و ساعت خودکار سیستم»** where it represents an automatically generated follow-up timestamp.
- Do not generate a timestamp merely because Follow-up is enabled.
- Keep Follow-up and Reminder as separate concepts and controls.
- The Task form must support the approved multiple-reminder model without creating a parallel store.

## 8. Follow-up creation flow

Expected path: **Task → افزودن پیگیری → ثبت پیگیری**.

The entry can include:
- Optional Follow-up title;
- Result/notes;
- `nextFollowUp`;
- Optional explicit **«افزودن یادآور»** action.

Creating a Reminder is opt-in. Any initial title/time copied from the Task or Follow-up is an editable initial value, not a permanent binding.

## 9. Quick Entry

- Keep compact, separate **«پیگیری‌دار»** and **«چک‌لیست‌دار»** controls near existing icons.
- Enabling Follow-up reveals its roll box.
- Enabling Checklist reveals its roll box.
- Keep progressive disclosure and avoid unnecessary space.
- Neither toggle may generate duplicate Tasks, implicit Reminders, or automatic Follow-up timestamps.

## 10. Reports and search

Where supported, reporting and search must independently identify/filter:
- Follow-up and Follow-up history;
- `nextFollowUp`;
- Reminder existence/items;
- `reminderDate` / Reminder schedule.

Do not combine the concepts into one status/count or infer one from the other. Reports remain projections of canonical Task data.

## 11. Data safety and migration

Before changing persistence, schema, serialization, or migration:
1. Audit every read/write and dependent projection of `nextFollowUp` and `reminderDate`.
2. Verify backup availability and preserve legacy values/payloads.
3. Document migration and rollback plans.
4. Add compatibility tests before changing serialization.
5. Validate JSON round-trip, SQL save/reload, backup/restore, independent edit/delete, notification reschedule/cancel, all-day versus intentional midnight, and Calendar identity/no-duplicate behavior.
6. Do not ship a migration when rollback or preservation of existing user data is unproven.

No parallel store or scheduler is permitted.

## 12. Acceptance checklist

- [ ] `nextFollowUp` remains preserved and independent of `reminderDate`.
- [ ] Follow-up alone creates neither OS notification nor external Calendar event.
- [ ] Internal Calendar shows Reminder item(s) when present; otherwise it can show a clearly labeled Follow-up Action.
- [ ] Internal Follow-up display does not trigger notification or external sync.
- [ ] External Calendar receives only authorized Reminders/Events.
- [ ] Every external Reminder can navigate back to its parent Task.
- [ ] Calendar uses stable identity and updates existing events without duplicates.
- [ ] Reminder edits/deletes do not change Follow-up or other Reminders.
- [ ] Follow-up edits/deletes do not silently change/delete Reminders or history.
- [ ] Full Task form retains Follow-up toggle and has no obsolete auto-generated Follow-up time.
- [ ] Quick Entry Follow-up and Checklist toggles are compact and reveal their respective roll boxes.
- [ ] Reports/search distinguish Follow-up, `nextFollowUp`, Reminder, and `reminderDate`.
- [ ] Legacy JSON, SQL, backup/restore, and migration/rollback behavior are validated.
- [ ] Exact-head Analyze, all test shards, Debug/Release APK, Calendar Provider Acceptance, six Device Smoke lanes, and required physical-device checks are evidenced.

## 13. Related records and current evidence boundary

- General owner decision: `docs/arvin-memory/ARVIN_FOLLOW_UP_REMINDER_ARCHITECTURE_DECISION.md`.
- Multi-reminder design and implementation tracking: Issue #2654 and PR #2655.
- Documentation decision PR: #2662.
- This file records the final Calendar scope decision and supersedes the earlier unresolved in-app-versus-phone Calendar clarification gate.
- No application code, database schema, migration, or user data is changed by this decision record alone.
- Release remains **NO-GO** until implementation and exact-head/device acceptance evidence is complete.
