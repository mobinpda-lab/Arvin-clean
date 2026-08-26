# Canonical Home Boundary — 2026-08-26

Issue #225. Refs #195.

## Goal

Remove the transitional `ArvinTask` Home projection and keep the existing Persian Home experience directly on the canonical `Task` model and `arvin.tasks` persistence path.

## Implemented vertical slice

- Home state is now `List<Task>` loaded by the existing `TaskMigrationReader`.
- `ArvinTask`, `_legacyViewOf`, `_canonicalSnapshotOf`, and the duplicated `canonicalTasks` list are removed.
- Search, Calendar, Backup and Home rendering all consume the same canonical Task list.
- Home saves the full canonical Task objects through the existing `TaskMigrationWriter` instead of rebuilding a lossy legacy snapshot.
- Editing mutates only the Home-owned editable fields on the existing Task object, preserving additive canonical fields such as FollowUps, recurrence, reminder, checklist, category and timestamps.
- Archive, trash, restore, completion and selection now act directly on canonical Tasks.
- No new model, repository, database or storage key was introduced.

## Validation

`test/canonical_home_boundary_test.dart` prevents the legacy projection from returning and locks the full-Task save boundary. Existing Home/Search/Backup tests plus exact-head Parallel Wave and full Build/APKs remain mandatory before merge, followed by post-merge main Build.
