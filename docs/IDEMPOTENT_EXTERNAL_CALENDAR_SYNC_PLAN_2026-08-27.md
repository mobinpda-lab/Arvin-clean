# Idempotent External Calendar Sync Plan — 2026-08-27

Issue #343. Refs #5 #223 #195.

## Goal
Define the provider-neutral core required for real Google/system-calendar synchronization without turning an external calendar into Arvin's source of truth.

## Canonical flow

`Task/FollowUp -> CalendarReminder -> CalendarSyncRevision -> ExternalCalendarEventLink -> CalendarSyncPlan`

Only active canonical `followup:` reminders are eligible. Official Iranian holidays and prayer-time rows remain read-only Arvin content and cannot enter external sync through this contract.

## Stable revision

`CalendarSyncRevisionService` derives SHA-256 evidence from the exact external-event payload Arvin intends to synchronize:

- canonical reminder id;
- trimmed title;
- begin time;
- end time;
- all-day flag.

Timed events reuse the existing 30-minute System Calendar convention. All-day events end at the next local day.

## External link metadata

`ExternalCalendarEventLink` represents only the mapping needed for idempotency:

- canonical Arvin reminder id;
- selected external calendar id;
- external event id;
- fingerprint last successfully synchronized.

It is metadata, not a second Calendar/Task model. Persistence and provider/account lifetime rules are intentionally deferred to the provider-adapter lane.

## Deterministic plan

- local revision + no link -> `create`
- no local revision + existing link -> `delete`
- matching fingerprint -> `noOp`
- changed fingerprint -> `update`

Revision ids and link ids must be unique. Repeated sync with an unchanged reminder therefore plans `noOp` instead of a duplicate create.

## Explicitly not implemented in this slice

- Android Calendar Provider writes;
- Google-account/calendar selection;
- READ/WRITE_CALENDAR permissions;
- OAuth or token handling;
- link persistence;
- background synchronization;
- provider error recovery.

The next vertical slice can implement an Android Calendar Provider adapter against this plan while preserving Arvin as the canonical source of truth.

## Current-main reconciliation — 2026-08-28

This contract was rebuilt on current main instead of reusing stale PR #346 evidence. The behavior remains intentionally unchanged; only the validation baseline was refreshed so promotion requires current exact-head CI.
