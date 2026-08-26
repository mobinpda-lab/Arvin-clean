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
