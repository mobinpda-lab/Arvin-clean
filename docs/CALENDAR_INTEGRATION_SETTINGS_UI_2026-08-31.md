# Calendar integration Settings UI — 2026-08-31

## Scope

This slice exposes the already-existing `CalendarIntegrationSettings` through the canonical Arvin Settings flow. It does not create a second settings store, calendar engine, scheduler, Task store, or provider-specific Google/Samsung API.

## User path

`تنظیمات → تقویم و همگام‌سازی`

The page lets the user configure the existing safe preferences for:
- master device-calendar integration;
- showing external calendar events;
- Arvin-to-device sync intent;
- due dates, task reminders, follow-ups, follow-up reminders and recurrence;
- auto sync preference;
- conservative linked-event deletion policy.

The destructive `delete linked event with Task` preference remains OFF by default and is shown with an explicit warning.

## Provider boundary

Calendar selection remains provider-dependent. Until Android Calendar Provider discovery/permission work in #348 is available, the page only shows persisted target/visible-calendar IDs when they already exist and explains that selection becomes available after provider discovery. No fake Google/Samsung integration is introduced.

Google Calendar, Samsung Calendar and other Android calendars must continue through one Android Calendar Provider adapter.

## Safety

- loading the page performs zero settings writes;
- core Arvin behavior remains available when integration is disabled or provider access is unavailable;
- portable restore keeps device-specific calendar preferences local via the existing `AppSettingsService` contract;
- focused widget tests cover visibility, persistence and default-off destructive behavior.

## Current-main reconciliation

This version is rebuilt from `main` after Backup restore confirmation #582 merged. The previous #586 validation is historical only; this current-main branch requires fresh exact-head gates.

Refs: #584 #516 #348.
