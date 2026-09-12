# Arvin Repository Cleanup Map

Date: 2026-09-12

## Purpose

This is the current-state map for repository cleanup. It separates executable product code, transitional migration code, historical documentation and factory automation.

## Active authority

- GitHub `main` is the executable source of truth.
- `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 is the active production/governance reference.
- `docs/ARVIN_PROJECT_STATE.md` is the current-state index.
- Dated/historical documents are evidence, not competing active authorities.

## Current canonical Task storage

`lib/services/task_store.dart` is the current Task persistence path used by `lib/main.dart`.

- key: `arvin.tasks`
- Home state: `List<Task>`
- normal save: `TaskStore.save(...)`
- atomic mutation: `TaskStore.mutate(...)`
- no second Task model/store/key is permitted.

## Transitional migration layer

These files still exist and are referenced by migration tests/integration seeding and historical material:

- `lib/services/task_migration_reader.dart`
- `lib/services/task_migration_writer.dart`
- `lib/services/task_migration_adapter.dart`

They are not the current Home persistence authority. They must not be used to introduce a second runtime storage path.

## Confirmed documentation drift

Several dated documents still describe `TaskMigrationReader`/`TaskMigrationWriter` as the active Home boundary, while the current Home code uses `TaskStore`. This is documentation drift, not proof of two active runtime stores.

Historical documents should be preserved unless a safe replacement is available. When a touched area is updated, its documentation must point to the current implementation.

## Product integration conflict

PR #885 contains the Wave 2 coordinator and reuses existing services:

- `Wave2ProductFastTrack`
- `HomeTaskEditorContextService`
- `TaskProjectAssignmentService`

The current Home `_add()` / `_edit()` path is still directly opening `ArvinTaskEditorDialog`. Therefore the prepared Wave 2 path has not yet become the real product path.

Next product-critical sequence:

`Home +/Edit -> canonical Task Editor -> project/category context -> TaskStore save -> project assignment -> focused tests -> Analyze/Test -> APK Build -> Device Smoke`

No new Task-entry architecture should be created for this.

## Quick Capture

`QuickCaptureDialog` and `QuickCaptureService` may remain because they reuse the canonical `Task` model and `TaskStore` persistence. They are a fast entry surface, not a second persistence system.

## Factory

Factory workflows and autonomous queues are supporting mechanisms. Factory completion is not the product goal. Factory work must not outrank a product release blocker.

## Cleanup rules

1. Keep one active Task model and one active Task storage path.
2. Keep historical evidence, but never treat it as current implementation.
3. Reuse existing product services before creating new abstractions.
4. Make cleanup changes small, reversible and PR-based.
5. Validate product changes at the exact commit before integration.
6. Product completion has priority over factory completion.
