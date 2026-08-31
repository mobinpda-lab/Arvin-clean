# Android Calendar Provider discovery — 2026-08-31

## Goal

Extend Arvin's existing `arvin/system_calendar` bridge with a read-only Android Calendar Provider discovery boundary. This reuses the current system-calendar integration instead of introducing Google- or Samsung-specific SDKs.

## Implemented slice

- Declares `READ_CALENDAR`; no `WRITE_CALENDAR` permission is added.
- Exposes permission status and permission request through the existing MethodChannel.
- Enumerates `CalendarContract.Calendars` only after permission is granted.
- Returns stable calendar/provider metadata: id, display name, account name/type, owner account, access level, visibility, sync-events, and primary flag.
- Extends `SystemCalendarBridge` with typed provider discovery while preserving the existing user-approved insert intent.
- Permission denial and missing plugin/provider paths fail safely without affecting Arvin core data or settings.
- Contract tests lock the read-only Android boundary and typed Dart parsing.

## Safety boundaries

This slice does not read events, write events directly, delete events, synchronize recurrence, or invoke vendor-specific Google/Samsung APIs. Provider account metadata is only the discovery foundation for the existing Calendar Settings model.

## Delivery

Issue: #595
Parent work: #348 / #516
Settings UI lane: #592

Draft → exact-head Fast → reconcile with latest `main` after the Settings lane → Build/APK + Device → Production Orchestrator.
