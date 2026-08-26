# System Calendar Export — 2026-08-26

Issue #223. Refs #195.

## Goal

Close the Gate G system-calendar gap without creating a second calendar source of truth.

## Architecture

`Task / FollowUps[] -> FollowUpCalendarProjection -> CalendarReminder -> SystemCalendarBridge -> Android ACTION_INSERT`

Arvin remains the source of truth. Android's calendar app is only a user-approved external destination.

## Implemented Vertical Slice

- `SystemCalendarBridge` accepts only active canonical `followup:` reminders.
- The existing `CanonicalCalendarLauncher` exposes a Persian RTL user action to select and export an eligible FollowUp.
- Official prayer times and Iranian holidays remain read-only and are not silently copied.
- `MainActivity` opens Android's calendar insert UI through `CalendarContract.Events.CONTENT_URI` and `Intent.ACTION_INSERT`.
- Arvin requests no direct calendar write permission and maintains no second event database.
- Missing compatible calendar apps and platform errors return visible user feedback rather than creating a parallel fallback.

## Validation

Focused Dart tests cover eligibility and MethodChannel payload. Android contract coverage verifies ACTION_INSERT/CalendarContract and absence of WRITE_CALENDAR permission. Exact-head Parallel Wave + full Build/release+debug APK remain required before merge, followed by post-merge main Build.
