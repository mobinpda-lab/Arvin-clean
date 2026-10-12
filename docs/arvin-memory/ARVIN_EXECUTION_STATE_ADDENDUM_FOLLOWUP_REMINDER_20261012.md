# Execution Addendum — Follow-up / Reminder Lifecycle

Date: 2026-10-12
Repository: `mobinpda-lab/Arvin-clean`
Branch: `docs/decision-follow-up-vs-reminder-20261012`
PR: https://github.com/mobinpda-lab/Arvin-clean/pull/2650 (OPEN, unmerged)
Verified PR base SHA: `18117aea2fa07b5a9a02e6021f41ff4faae120cc`

## Completed in this run
- Updated `ARVIN_DECISION_LOG.md`, `ARVIN_PROJECT_KNOWLEDGE.md`, and `ARVIN_FOLLOW_UP_CONCEPT_DECISION.md` on this docs branch with the owner clarification.
- Corrected PR #2650 body to replace the obsolete absolute rule “follow-up never creates reminder” with the one-time initial reminder rule.
- Read-only source audit: `FollowUp` currently stores `reminderDate` and `nextFollowUp` as separate nullable `DateTime` fields; the editor currently saves both independently. `_pickNext()` uses the recorded Follow-up's hour/minute and has no visible date-only choice or clear-next action in the inspected UI section.
- Existing `FollowUpCalendarProjection` projects an explicit `reminderDate`, but the inspected branch sets `isAllDay` only for Task due-date reminders, not FollowUp reminder entries. The project has an existing date-only heuristic based on a zero time for due dates, but using that for FollowUp reminders would make midnight timed reminders ambiguous.

## Binding product contract
- Next Follow-up begins empty and is explicitly activated by the user.
- First setting creates one initial reminder at the same date/time; date-only means all-day.
- Later Next Follow-up edits do not change the reminder. Deleting Next Follow-up does not delete the reminder.
- A reminder can exist without Next Follow-up; editing/deleting either leaves the other unchanged.
- Recorded Follow-up `dateTime` is not Next Follow-up.

## Blockers / decisions required
- Owner must decide behavior when a reminder already exists at the first activation of Next Follow-up. Until then, never overwrite or duplicate the existing reminder by assumption.
- All-day semantics need a backward-compatible decision: zero-time inference reuses existing convention but cannot distinguish an intentional midnight reminder; explicit all-day metadata would affect model/persistence/backup and needs a migration/compatibility plan.

## Validation status
- No app source was changed in this run.
- No Flutter analyze/tests/build/device validation was run in this run.
- PR #2650 workflow runs on its then-current head were still in progress/queued when inspected; re-check exact-head results after the last docs commit.
- Release remains NO-GO. Physical-device Calendar same-event update/no-duplicate, Android Backup/Restore + Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen acceptance, and owner release approval remain required.

## Next action
Inspect the existing calendar provider and SQL/JSON/backup tests, then obtain the two owner decisions above before implementation. Do not mark the feature complete or merge this docs PR without exact-head validation.