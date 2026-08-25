# Home → Follow-up calendar wiring — 2026-08-25

## What changed

Home now projects its canonical task source through `FollowUpCalendarProjection` when the user opens the calendar. The resulting reminders are passed into `IranianOfficialCalendarPage`, which already merges caller reminders with official calendar reminders.

## Boundary

- No new storage was introduced.
- `FollowUpCalendarProjection` remains read-only.
- Official reminder loading remains owned by `OfficialCalendarPage`.
- Home supplies only canonical follow-up reminders.

## Regression coverage

`test/home_calendar_navigation_test.dart` now verifies that canonical follow-up history loaded through the migration reader reaches `IranianOfficialCalendarPage` as a `CalendarReminder` with the stable projection id, title, and date.

## Next safe slice

After CI is green, the next calendar slice can focus on keeping canonical Home state synchronized after mutations so newly edited follow-up history is reflected without introducing a second source of truth.
