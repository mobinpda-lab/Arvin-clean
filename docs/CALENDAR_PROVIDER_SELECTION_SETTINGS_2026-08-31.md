# Calendar Provider selection in Settings — 2026-08-31

## Goal

Connect the already-merged Android Calendar Provider discovery boundary to the already-merged `تقویم و همگام‌سازی` Settings page without creating a second calendar engine, settings store, or vendor-specific Google/Samsung SDK.

## User flow

`تنظیمات → تقویم و همگام‌سازی → تقویم‌های دستگاه`

- Opening the page checks read-only calendar permission without changing settings.
- If permission is absent, the user can explicitly request `READ_CALENDAR` access.
- After approval, Arvin lists calendars returned by the existing `arvin/system_calendar` bridge.
- Google, Samsung and other Android calendars are identified from provider/account metadata.
- The user can choose one target calendar and one or more calendars whose external events may later be shown in Arvin.
- Selections persist through the existing `CalendarIntegrationSettings` / `AppSettingsService` fields.

## Safety boundary

This slice still performs no direct event read, create, update, delete, recurrence sync or background sync. It only discovers calendars and stores user selections. `WRITE_CALENDAR` is not added. Loading or granting provider access performs zero settings writes until the user explicitly selects a calendar.

## Validation

Focused widget tests prove:
- pre-existing IDs remain visible before provider access;
- Google/Samsung provider metadata renders through one common Android path;
- target/visible selections persist through the canonical settings service;
- permission request alone does not mutate settings.

Refs: #597 #595 #348 #516.