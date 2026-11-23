# Canonical calendar launcher — 2026-08-26

## What changed

Added `CanonicalCalendarLauncher`, a small UI boundary that accepts canonical `Task` objects and passes projected follow-up reminders to `IranianOfficialCalendarPage`.

## Architecture

`Task.followUps` → `FollowUpCalendarProjection` → `CalendarReminder` → `IranianOfficialCalendarPage`

The launcher owns no storage, does not mutate tasks, and does not introduce another reminder model.

## Why this slice exists

A previous direct Home wiring attempt produced an unsafe large diff in `main.dart` and was closed without merge. This slice isolates the integration first so the remaining Home change can be minimal: import the launcher and use it at the existing calendar navigation boundary.

## Validation

A widget regression test was added to prove the launcher accepts canonical follow-ups through the existing model boundary. GitHub Actions remains the merge gate; no green result is claimed until the exact PR head completes CI.

## Next action

Wire the existing Home calendar navigation to `CanonicalCalendarLauncher(tasks: canonicalTasks)` with a minimal diff, then require green CI before merge.
