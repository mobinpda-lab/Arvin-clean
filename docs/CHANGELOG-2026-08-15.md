# Arvin — Change Log 2026-08-15

## FollowUp date-only UI

Commit: `2b04471e1f104739372d383f8017812638ff4f70`

- Extended the existing FollowUp Office UI to consume the additive `allDay` contract from the FollowUp model.
- Date-only FollowUps now display `تمام‌روز` instead of exposing the persisted time or a fake `00:00` value.
- Future filtering treats an all-day FollowUp as active through the end of its calendar day.
- Existing time-aware FollowUps keep their date/time presentation.
- No new storage, database, Reminder model, or Calendar foundation was introduced.

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

- The date-only UI change is isolated on `feat/followup-all-day-ui`, based directly on the reviewed FollowUp contract commit.
- GitHub Actions must be checked on the resulting PR before the change is considered validated or merged.

## Continuity rule

The next change must re-audit `main`, current FollowUp/Calendar contracts, existing tests, open PRs, CI, and project documentation before touching another implementation area. Do not rebuild existing foundations.
