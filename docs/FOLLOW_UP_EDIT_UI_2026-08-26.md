# Follow-up Office edit flow — 2026-08-26

## Scope
This slice advances Issue #13 by wiring the existing Follow-up Office UI to the repository edit contract merged through PR #161.

## What changed
- `FollowUpEntryPage` can open with an existing `FollowUp`.
- Existing note, result, date/time, and next-follow-up values are prefilled.
- Saving an edit preserves the stable follow-up `id` instead of creating a new record.
- `FollowUpOfficePage` exposes an edit action for each history row and reloads the office after a successful update.
- The UI reports success or retry feedback for the edit path.

## Validation
A widget regression test verifies that editing an existing follow-up keeps exactly one history entry, preserves its id, and persists the changed note/result.

## Dependency status
PR #161 is merged into `main`. PR #162 is now based on `main` and must pass `Arvin Build` and `Arvin Parallel Wave` on its exact head before merge.

## Scope guard
- No new storage key.
- No parallel repository/model layer.
- No Home rewrite.
