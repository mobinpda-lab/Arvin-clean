# Calendar Provider selection in Settings — 2026-08-31

## Goal

Connect the already-merged Android Calendar Provider discovery boundary to the already-merged `تقویم و همگام‌سازی` Settings page without creating a second calendar engine, settings store, or vendor-specific Google/Samsung SDK.

## User flow

`تنظیمات → تقویم و همگام‌سازی → تقویم‌های دستگاه`

- Opening the page performs no platform permission call and does not change settings.
- The user explicitly presses the provider-access action before Arvin requests/uses read-only `READ_CALENDAR` access.
- After approval, Arvin lists calendars returned by the existing `arvin/system_calendar` bridge.
- Google, Samsung and other Android calendars are identified from provider/account metadata.
- The user can choose one target calendar and one or more calendars whose external events may later be shown in Arvin.
- Selections persist through the existing `CalendarIntegrationSettings` / `AppSettingsService` fields.

## Safety boundary

This slice still performs no direct event read, create, update, delete, recurrence sync or background sync. It only discovers calendars and stores user selections. `WRITE_CALENDAR` is not added. Loading or granting provider access performs zero settings writes until the user explicitly selects a calendar.

## Validation

Focused widget tests prove:
- page load is non-mutating and does not require a live platform plugin;
- pre-existing IDs remain visible before provider access;
- Google/Samsung provider metadata renders through one common Android path;
- target/visible selections persist through the canonical settings service;
- permission request alone does not mutate settings.

## Current-main replay

This version is replayed from production `main` after Worker reliability #601 merged. Historical #602 Fast validation remains evidence for the bounded behavior, but this current-main branch requires its own fresh exact-head gates before promotion.

Refs: #597 #595 #348 #516.
