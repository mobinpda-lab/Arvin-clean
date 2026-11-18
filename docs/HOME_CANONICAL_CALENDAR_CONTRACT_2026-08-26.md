# Home canonical calendar contract — 2026-08-26

Issue: #157

## Verified boundary

Home currently opens `IranianOfficialCalendarPage` directly. The merged `CanonicalCalendarLauncher` already owns the projection from canonical `Task.followUps` into calendar reminders.

## Required integration

The Home drawer calendar action must route through `CanonicalCalendarLauncher(tasks: _searchSource)` while preserving drawer close behavior and RTL presentation.

## Regression contract

`test/home_canonical_calendar_contract_test.dart` pins the integration boundary and verifies that opening the calendar does not mutate `arvin.tasks` storage.

This branch intentionally establishes the test/documentation side of the parallel wave before the production wiring is merged. The production change remains a minimal `main.dart` patch and must pass the repository Build and Parallel Wave automation before merge.
