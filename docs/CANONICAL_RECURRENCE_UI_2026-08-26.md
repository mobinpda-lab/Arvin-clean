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


## Wave 7.14 — Home occurrence integration contract (2026-10-23)

### Approved display behavior
- Home consumes the existing read-only `RecurringTripleWindowProjection` over canonical `Task.recurrence` and `Task.reminderDate`.
- Uncompleted past occurrences appear under `معوق`; today's occurrences appear under `کارهای امروز`; the nearest future occurrence per recurring Task appears under `پیش‌نمایش آینده` (so a daily task previews tomorrow).
- Occurrence completion is recorded only under the matching `Task.occurrenceHistory` ISO timestamp through `TaskRecurrenceRepository.completeOccurrence`. It does not toggle `Task.completed` and does not create a new Task.
- `پرش به روز جاری` / `Resume from Today` is a **data-changing recurrence action**, not a view-only filter. It calls the existing `TaskRecurrenceRepository.resumeFromToday` for each canonical recurring Task that has overdue uncompleted occurrences, advancing only `Task.reminderDate` according to the existing recurrence rule and the injected Iran-time clock.
- Resume must not create Task/occurrence records or rewrite `occurrenceHistory`, `checklistOccurrences`, recurrence rules, FollowUp history, category, tags, or other Task fields. The Task remains the same canonical record; the existing recurrence rule determines today's and future occurrences from the advanced reminder anchor.
- After successful resume, overdue occurrences for resumed Tasks no longer block Home. The control is disabled if no overdue occurrences exist or while the successful action remains active in the current Home session. Navigating away may reset button state, but it must never roll back the persisted reminder anchor or restore old overdue occurrences. Re-entry/restart preserves the advanced anchor.
- Existing recurring Tasks are shown in the recurrence panel instead of also being duplicated as ordinary Home task rows while the panel's all-time/all-task scope is active. Other Home filters retain their existing Task list path.
- Recurrence projection uses `IranClock.now()` for Home's date boundary, reusing the existing Iran-time clock. The projection remains read-only and creates no occurrence records.

### Wave 7.14 validation status
- Added a projection test for hiding past items without changing Task reminder/history.
- Added a repository test proving completing one occurrence does not change neighboring occurrence statuses.
- The Home widget interaction, timezone/device boundary, checklist/follow-up/taxonomy regressions, Analyze, Quality shards, Debug/Release builds and Device Smoke must be confirmed by exact-head CI before this feature can be accepted. No CI result should be inferred from source changes alone.
