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

## Latest live verification — 2026-10-12
- PR #2650 remains OPEN and unmerged; current head is `a7cc6719d17ca7d90b0fef42c1176000f72dff60`, base is `18117aea2fa07b5a9a02e6021f41ff4faae120cc`, and GitHub currently reports `mergeable=true`. This does not mean checks passed or that the PR should merge.
- Exact-head workflows when checked: `ARVIN Orchestrator` SUCCESS; `G1 lock sync` SUCCESS; `ARVIN Orchestrator PR Wakeup` SUCCESS; `ARVIN Production Loop` SUCCESS; `Arvin Build` IN_PROGRESS; `Arvin Device Smoke` QUEUED; `Arvin Parallel Wave` SKIPPED. No exact-head Build/Device Smoke success is claimed.
- Existing source tests include `test/follow_up_calendar_projection_test.dart`, with coverage for a date-only Task due date. Search did not establish equivalent tests for date-only FollowUp reminders or the one-time creation bridge.
- The projection sends `CalendarReminder.isAllDay` for date-only Task due dates, while FollowUp reminder projection currently passes only `date: reminderDate` and omits `isAllDay`. `SystemCalendarBridge` already supports all-day events, so the gap is in source semantics/projection and safe persisted representation, not proof that the platform has no all-day capability.
- The default-branch execution state has newer live status than the PR base; this PR is based on `18117aea...` and should not be assumed to include later main changes. Rebase/cherry-pick only after checking changed files and exact branch ancestry; do not casually update its base while checks run.
- No code change was made and no application test/build was run by this assistant. Next permitted action is inspect existing model/persistence/backup/provider tests and prepare a compatibility-safe design; implementation of the unresolved pre-existing-reminder behavior remains blocked on owner decision.

# AUTHORITATIVE CONTINUATION — 2026-10-13 (follow-up/reminder compatibility audit)

- Repository: `mobinpda-lab/Arvin-clean`; default branch `main`; live main SHA observed: `18117aea2fa07b5a9a02e6021f41ff4faae120cc`. PR [#2650](https://github.com/mobinpda-lab/Arvin-clean/pull/2650) is OPEN, unmerged, base SHA matches this main checkpoint, head `aa3dabf145b7ee7c8042978e58901de769da6634`; exact-head Build was IN_PROGRESS and Device Smoke QUEUED at this poll. A documentation update creates a new head, so check runs again on the resulting exact SHA.
- **Completed read-only compatibility audit:** `FollowUp` stores nullable `reminderDate` and `nextFollowUp` separately, but has no explicit all-day metadata for either. `Task.allDay` applies to Task due-date only. `FollowUp.toJson/fromJson` serializes these fields as ISO strings and does not encode date-only intent separately.
- **Canonical persistence and backup path:** the SQL Task store writes the full canonical Task envelope as JSON; canonical backup serializes via `Task.toJson()`, and restore reconstructs through `Task.fromJson()`. The existing `FollowUp` fields therefore travel through the canonical Task payload, but a new all-day flag must be represented in the model/JSON and covered by SQL envelope + backup/restore round-trip tests. Existing date-only values already serialized at midnight cannot be reliably distinguished from intentional midnight times retroactively.
- **Calendar path:** `FollowUpCalendarProjection` currently omits `isAllDay` for FollowUp reminder projections (default false). The date-only heuristic is applied to Task due dates only. `CalendarReminder`, sync revision and `SystemCalendarBridge` already carry all-day state; the missing semantics originate earlier in the FollowUp model/editor/projection.
- **Editor path:** `FollowUpEntryPage._pickNext()` inherits hour/minute from the recorded Follow-up `dateTime`; it does not offer a date-only choice or clear-next action in the inspected code. Saving `nextFollowUp` currently does not create an initial `reminderDate`. Existing tests cover JSON round-trip, independent reminder edit/clear, and date-only Task due dates, but no verified regression coverage for first-set creation, clear-next independence, or date-only FollowUp reminder projection.
- **Data safety:** do not infer all-day from midnight, overwrite a pre-existing reminder, or silently normalize legacy `nextFollowUp` into `reminderDate`. The existing-reminder first-activation behavior is still an owner decision. A separate persisted all-day marker for Next Follow-up and Reminder is the safer candidate because each can independently be date-only or timed, but this is a model/backup compatibility change and must be specified before implementation.
- **This run:** source/docs audit only; no app code changed and no Flutter analyze/test/build/device validation was executed. Release remains **NO-GO**.
- **Next action:** owner decision on first activation when a reminder already exists; then agree on backward-compatible all-day representation. Safe work may continue after recording these gates; do not merge this PR without exact-head validation.


# AUTHORITATIVE STATUS CORRECTION — 2026-10-13 (PR #2650 merged)

- PR #2650 is **MERGED**, not open: squash commit `8136c929237c321f2e879a80f067970c31cb0100`; source head `e6b0dbbd70c5779e2e21f731ce6f2cf29604c99b`.
- Exact source-head Build [38305396957](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305396957) and six-lane Device Smoke [38305396917](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38305396917) both succeeded. These are automated CI/emulator results, not physical-device acceptance.
- This merge only records documentation; it does not fix app code. The first-set reminder creation, FollowUp all-day representation/projection, date-only editor and clear-next behavior remain unimplemented/unvalidated.
- Product owner still needs to decide behavior when an existing reminder is present at first Next Follow-up activation. No data-changing implementation should assume overwrite, duplicate creation, or normalization.
- Current main after merge: `8136c929237c321f2e879a80f067970c31cb0100`. Keep Release NO-GO until product gates, code/tests, exact-head validation and physical-device evidence are complete.
