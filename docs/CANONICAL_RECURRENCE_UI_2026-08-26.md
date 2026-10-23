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


## Wave 7.16 — Follow-up / Calendar separation contract (2026-10-23)

- Follow-up records, Follow-up dates, history, and a Follow-up's own reminder date remain in canonical Task data and are not projected as Arvin Calendar cards merely because a date exists.
- Calendar projection may include canonical Task due dates, independent Task reminders, recurrence occurrences, prayer content, and permitted external-calendar events. A separately configured Task Reminder remains visible even when the same Task has Follow-up history.
- A normal tap on a permitted Task calendar event opens that exact Task's detail page; long-press actions remain separate.
- Regression acceptance must prove: Follow-up is absent from Calendar; its source fields survive SQLite reload and Calendar interaction; independent Reminder and due-date events remain visible; exact Task detail opens with one tap.
- This is a product contract change only for Calendar projection/navigation. It must not delete, rewrite, or migrate Follow-up records or couple Follow-up to Reminder.
