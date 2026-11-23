# Home latest follow-up display — 2026-08-26

Issue: #13

## Change
Home's compatibility projection now prefers the latest canonical `Task.followUps` entry when follow-up history exists.

## Compatibility
- Legacy tasks with only `followUpDate` keep the same displayed date.
- No storage, repository, or model layer was added.
- The canonical `followUps` history remains the source of truth.

## Validation
`test/models/task_home_migration_test.dart` pins both the legacy fallback and latest-history behavior.

Merge only after repository Build and Parallel Wave automation pass on the exact PR head.
