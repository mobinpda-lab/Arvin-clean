# Calendar Follow-up reminder acceptance contract

Date: 2026-10-21
Related diagnostic PR: https://github.com/mobinpda-lab/Arvin-clean/pull/2895
Binding product contract: https://github.com/mobinpda-lab/Arvin-clean/issues/529
Related Follow-up Calendar UX contract: https://github.com/mobinpda-lab/Arvin-clean/issues/350

## Binding behavior

- Home presents the canonical Task and its Follow-up history according to Home rules.
- Calendar projects actual reminders, dated Tasks, and supported calendar/shared items.
- A Follow-up history record by itself is not a calendar event.
- A Follow-up with an explicit `reminderDate` projects one reminder card. The card is a reminder presentation linked to its canonical Follow-up, not a second standalone Follow-up entity.
- `nextFollowUp` and legacy `followUpDate` do not independently create a Calendar card without an explicit reminder.
- A dated Task remains eligible for its own due-date card. Equivalent timestamps must not produce duplicate cards; distinct due/reminder times remain independently visible.

## Existing implementation and regression evidence

- `lib/services/follow_up_calendar_projection.dart` projects a Follow-up only inside `if (followUp.reminderDate != null)`, with stable presentation ID `followup:<taskId>:<followUpId>`. `resolveTarget` also requires a non-null reminderDate.
- `test/follow_up_calendar_projection_test.dart` already covers:
  - a Follow-up with a reminder produces a reminder card with the expected ID, title, parent context, and reminder timestamp;
  - a Follow-up without an independent reminder produces no card;
  - `nextFollowUp` remains internal;
  - a dated Task projects independently;
  - duplicate timestamps are deduplicated while distinct Task due-date and Follow-up reminder times remain visible.
- Historical implementation evidence includes [commit 0601950e8f56a7563533393844c835b6de49aade](https://github.com/mobinpda-lab/Arvin-clean/commit/0601950e8f56a7563533393844c835b6de49aade), which established the Calendar interaction smoke and tap/long-press contract, and [Issue #529](https://github.com/mobinpda-lab/Arvin-clean/issues/529), which explicitly says to preserve the canonical projection and avoid rebuilding it without a proven gap.

## Interpretation of the current Android smoke

The smoke seed has `FollowUp.reminderDate = now + 10 minutes`. Therefore its expected key,
`reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up`, is the UI key formed by `CalendarPage` from the reminder projection ID. It is valid for this reminder-present scenario; it does not assert that a no-reminder Follow-up should appear independently.

A failure to find this card after the SQL round-trip passed points to the downstream load/projection/visible-date/rendering path, or to test navigation/timing. It does not by itself prove that the product contract is wrong. Do not remove or weaken this assertion unless new evidence proves the seed or UI contract is invalid.

## Scenario coverage boundary

| Scenario | Existing evidence | Acceptance state for this Android smoke |
|---|---|---|
| A. Follow-up without reminder | Projection unit test asserts no Calendar card; Home behavior is a separate surface | Unit contract present; this Android smoke does not cover it |
| B. Follow-up with reminder | Projection unit tests assert ID/title/time and target resolution; Android smoke seeds reminder and tests card interaction | Android end-to-end result remains NOT VERIFIED until the exact-head emulator run completes |
| C. Task with due date/time | Projection unit tests assert due-date card and independent Task/Follow-up times | Projection contract present; not a substitute for Android integration proof |
| D. Other Calendar items | Separate existing Calendar/provider tests and workflows apply | Not proven by the Follow-up-only smoke |

## Decision rule

Do not change production Calendar logic or the reminder-present expectation based only on the previous missing-card assertion. First obtain the latest projection diagnostic from the existing Device Smoke run and distinguish:
1. canonical Task absent from app-loaded Task list;
2. Task loaded but reminder projection absent;
3. projected reminder present but excluded by visible-date range/selected-day filtering;
4. card generated but not found due to UI/navigation/timing.

Then make only the smallest evidence-supported test or product change. Keep Calendar acceptance NOT VERIFIED until the corrected exact-SHA Device Smoke passes. This document does not claim a new test run passed.
