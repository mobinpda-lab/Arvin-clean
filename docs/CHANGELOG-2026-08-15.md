# Arvin — Change Log 2026-08-15

## Calendar official-reminder service hardening

Commit: `4dc35af634e4ce162fa38adeaa2befd7aa0f2a6c`

- Kept the existing `OfficialCalendarReminder` / `CalendarReminder` foundation unchanged.
- Hardened `OfficialCalendarReminderService` so a requested Gregorian year is enforced at the service boundary.
- Duplicate reminder IDs are collapsed deterministically, preserving the first authoritative source occurrence.
- Returned reminders are sorted chronologically before mapping to the existing `CalendarReminder` model.
- Added regression coverage for year filtering, duplicate IDs, first-source precedence, and chronological ordering.
- No production holiday/prayer data was fabricated or hard-coded; real Providers remain a separate gap requiring authoritative, auditable source data.

## FollowUp chain hardening

Commits: `c6b5f97adc4a60fbb86bbdb3c0207559f0817198` + `552e793b0a4bf5595bfe2ae46f97eade1719255a`

- Kept the existing Unified Item + `FollowUps[]` storage path; no parallel Task/Note storage was introduced.
- `TaskStore.addFollowUp()` now explicitly enables `followUpEnabled` when a FollowUp is added, matching the product contract that an Item becomes follow-up-enabled through the same Item.
- The Item `updatedAt` is refreshed when a FollowUp is recorded.
- Existing FollowUp history and legacy migration remain intact.
- Added regression assertions that the stored Item becomes follow-up-enabled and receives an update timestamp.

## Verification state

- The changes were written directly to `main` through the GitHub connector.
- GitHub Actions are expected to trigger from the commits; CI is only reported green after a concrete run/check is observed.

## Continuity rule

The next change must re-audit `main`, current FollowUp/Calendar contracts, existing tests, open PRs, CI, and project documentation before touching another implementation area. Do not rebuild existing foundations.
