# Waiting for Response — user-facing flow — 2026-08-26

## Scope
This slice advances the merged Waiting for Response contract from core stage to a real user-facing Follow-up Office flow.

## What changed
- FollowUpEntryPage exposes a Persian «منتظر پاسخ دیگران» switch.
- Saving the switch persists the existing canonical `waiting_for_response` token through FollowUpRepository.
- Existing waiting entries reopen in waiting mode and can be resolved by disabling the switch and entering a normal result.
- FollowUpOfficePage adds a «فقط منتظر پاسخ» filter based on each task's latest follow-up.
- Waiting rows display a user-friendly Persian chip instead of the internal token.

## Persistence boundary
No new model, storage, database, or repository was introduced. FollowUps remain the source of truth.

## Validation
Widget regression coverage is part of this delivery and CI must be green on the exact PR head before merge.

## Progress impact
After merge and post-merge validation, roadmap feature #10 can be promoted according to the official progress scorecard.
