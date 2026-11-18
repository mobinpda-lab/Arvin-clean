# Latest Follow-up Ordering Contract — 2026-08-26

Issue: #13

## Verified problem
`Task.lastFollowUp` previously depended on list position (`followUps.last`). Imported, migrated, or externally assembled history can be out of chronological order, which could make Home display a non-latest follow-up.

## Change
- `Task.lastFollowUp` now selects the entry with the greatest `dateTime` without mutating the stored history order.
- `lastFollowUpDate` and the Home compatibility projection inherit this chronological behavior.
- Legacy `followUpDate` fallback remains unchanged when no history exists.

## Regression guard
`test/models/task_home_migration_test.dart` includes an unordered history case and requires the newest timestamp to win.

## Scope
No storage rewrite, no new model layer, and no Home rewrite.
