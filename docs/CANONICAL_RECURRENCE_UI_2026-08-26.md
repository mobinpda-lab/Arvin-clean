# Canonical Recurrence UI — 2026-08-26

Issue: #208

## Implemented Vertical Slice

- Reuses the existing `Task.recurrence` / `RecurrenceRule` model.
- Reuses canonical `TaskStore` and the existing `arvin.tasks` persistence key.
- Adds `TaskRecurrenceRepository` only as a write boundary over `TaskStore`; it owns no storage.
- UI supports enable/disable, frequency and interval configuration.
- Frequencies remain the existing contract only: daily, weekly, monthly, yearly and once-per-day.
- `Resume From Today` reuses the existing pure recurrence calculation and advances only `Task.reminderDate`.
- FollowUp history is never rewritten by recurrence actions.
- Recurrence UI is reachable from the existing Task Timeline action and opens with that same canonical Task selected.

## Validation

- Repository tests cover set/clear persistence through `TaskStore.key` only.
- Resume tests prove reminder advancement while FollowUp history remains unchanged.
- Error cases cover missing task, recurrence and reminder schedule.
- Widget tests cover enabling recurrence, canonical persistence, Resume From Today and Timeline → same-Task entry.

## Architecture guardrails

- No second recurrence model.
- No recurrence-specific storage key/database.
- No history migration/rewrite.
- No new frequency semantics.
- Exact-head Fast Lane + full APK validation remain mandatory before merge, followed by post-merge main Build.

Refs #208 #195 #92 #153.


## Wave 7.18-R2 — Next Follow-up / independent Follow-up Reminder contract (2026-10-23)

Owner decision:
- A Task's Next Follow-up date/time is Home-facing scheduling data. It must not create a phone Calendar card by itself.
- A Follow-up may have its own independent reminder. If configured and active, that reminder is eligible for Calendar synchronization; the Calendar event time comes from the independent reminder, not from Next Follow-up.
- Changing Next Follow-up must not change the independent reminder. Changing/deleting a reminder must not delete the Follow-up record, result, or history.
- Task due date, Task-level reminders, Follow-up next-action date, and Follow-up reminder are distinct concepts.
- A notification alone is not a Calendar event. Calendar Provider denial/failure must not be reported as successful synchronization.
- Current model cardinality: each Follow-up has one optional `reminderDate` field; a Task can hold multiple Follow-up records and separately has a `taskReminders` collection. Multiple reminders per single Follow-up are not established and remain an owner decision.

Calendar eligibility:
- Next Follow-up / legacy `followUpDate`: never project solely because the date exists.
- `FollowUp.reminderDate`: project as the Follow-up's independently configured reminder with stable source identity.
- `Task.dueDate`, Task-level reminders, and recurrence occurrences: retain their existing permitted projection behavior.
- Reprocessing must update/reconcile the same linked event and must not create duplicates.

Acceptance must prove: Next Follow-up without a reminder remains visible in Home but absent from Calendar; an independent Follow-up reminder appears at its own time even when different from Next Follow-up; editing either time does not mutate the other; deleting the reminder preserves Follow-up history; SQLite reload/Restart preserves both values; cancellation is a no-op; Provider permission/failure is not PASS; permitted event tap opens the exact source Task.

This contract does not authorize a parallel model/store, data deletion, schema migration, or support for multiple reminders per one Follow-up.
