# Follow-up → Calendar projection

Date: 2026-08-25

## Scope

This slice adds a read-only projection from canonical `Task.followUps` into the existing `CalendarReminder` presentation model.

## Boundary

- Source of truth remains the canonical `Task` model.
- No new persistence or parallel reminder database is introduced.
- Trashed tasks are excluded.
- Follow-ups are emitted in chronological order.
- Reminder IDs are namespaced with both task and follow-up IDs to avoid collisions with official calendar providers.
- Completion presentation follows the parent task completion state.

## Integration status

The projection and regression tests are implemented in this slice. Wiring the projection into the Home → `IranianOfficialCalendarPage(reminders: ...)` navigation is intentionally kept as the next small integration step so CI can validate the new boundary independently before UI wiring.
