# Arvin — Change Log 2026-08-15

## Calendar official-reminder service hardening

Commit: `4dc35af634e4ce162fa38adeaa2befd7aa0f2a6c`

- Kept the existing `OfficialCalendarReminder` / `CalendarReminder` foundation unchanged.
- Hardened `OfficialCalendarReminderService` so a requested Gregorian year is enforced at the service boundary.
- Duplicate reminder IDs are collapsed deterministically, preserving the first authoritative source occurrence.
- Returned reminders are sorted chronologically before mapping to the existing `CalendarReminder` model.
- Added regression coverage for year filtering, duplicate IDs, first-source precedence, and chronological ordering.
- No production holiday/prayer data was fabricated or hard-coded; real Providers remain a separate gap requiring authoritative, auditable source data.

## Verification state

- The commit was written directly to `main` through the GitHub connector.
- The current GitHub connector's commit-workflow lookup returned no PR-triggered runs for this commit yet, and the combined status endpoint currently reports no checks. Therefore CI is **not** being claimed green for this commit until GitHub exposes a concrete run/check result.

## Continuity rule

The next change must re-audit `main`, current Calendar contracts, existing tests, open PRs, and official-source research before touching Provider implementation. Do not rebuild the Calendar foundation.
