# Follow-up Office edit flow — 2026-08-26

## Scope
This stacked slice advances Issue #13 by wiring the existing Follow-up Office UI to the repository edit contract prepared in PR #161.

## What changed
- `FollowUpEntryPage` can open with an existing `FollowUp`.
- Existing note, result, date/time, and next-follow-up values are prefilled.
- Saving an edit preserves the stable follow-up `id` instead of creating a new record.
- `FollowUpOfficePage` exposes an edit action for each history row and reloads the office after a successful update.
- The UI reports success or retry feedback for the edit path.

## Validation
A widget regression test verifies that editing an existing follow-up keeps exactly one history entry, preserves its id, and persists the changed note/result.

## Dependency
This branch is stacked on the repository update contract from PR #161. After #161 merges, this PR can be retargeted to `main` and validated on its exact head before merge.

## Scope guard
- No new storage key.
- No parallel repository/model layer.
- No Home rewrite.
