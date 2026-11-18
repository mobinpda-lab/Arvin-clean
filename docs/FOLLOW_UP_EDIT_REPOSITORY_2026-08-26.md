# Follow-up edit repository contract — 2026-08-26

## Scope
This slice advances Issue #13 by adding the persistence contract required for editing an existing follow-up.

## What changed
- `FollowUpRepository.update(taskId, followUp)` replaces one existing follow-up by its stable `id`.
- The surrounding `arvin.tasks` task envelope is preserved.
- Sibling follow-up entries are preserved.
- A missing task or follow-up id fails explicitly instead of silently appending or overwriting unrelated data.

## Compatibility
- Existing `add` and `loadForTask` behavior remains unchanged.
- Legacy `followUpDate` compatibility remains available through the existing decode path.
- No new storage key, database, model, or repository layer was introduced.

## Validation
Regression tests cover editing one entry while preserving sibling history and task metadata, plus the missing-id failure case.

## Next slice
Wire the existing Follow-up Office UI to this repository update boundary so a user can open and edit a history entry without duplicating it.
