# Calendar Provider read-only event access — 2026-08-31

## Goal

Add the next bounded Android Calendar Provider slice for Arvin: read external event instances from user-selected calendars without introducing write/delete permissions, a vendor-specific Google/Samsung integration, or a second calendar engine.

## Boundary

The existing `arvin/system_calendar` MethodChannel is extended with `listDeviceCalendarEvents`.

The call requires:
- one or more selected calendar IDs;
- a positive bounded time range;
- existing `READ_CALENDAR` permission.

Queries are limited to at most 20 calendars and 93 days per call. Android `CalendarContract.Instances` is used so recurring events are returned as concrete instances inside the requested range.

## Provider-neutral event model

Dart receives only the data needed for a later read-only projection:
- instance/event/calendar IDs;
- calendar display name;
- title and optional description;
- start/end/all-day;
- event timezone;
- recurrence rule when available.

Malformed rows are ignored safely. Permission denial or a missing platform plugin returns an empty external-event result and does not affect canonical Arvin Task/FollowUp data.

## Safety

- no `WRITE_CALENDAR` permission is added;
- no event create/update/delete is performed by this slice;
- no Task conversion/import happens automatically;
- no real calendar content is written to CI logs;
- empty calendar selection performs no platform call;
- oversized calendar sets and unbounded date windows fail before provider access.

## Next integration

After provider selection #604 is merged, a separate current-main lane can project these external-owned events into the existing Calendar/Work Agenda aggregator while preserving source labels and keeping external events out of canonical Task reports/backups by default.

Refs: #348 #516 #597.