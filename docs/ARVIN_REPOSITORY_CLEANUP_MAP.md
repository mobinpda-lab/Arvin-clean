# Arvin Repository Cleanup Map

Date: 2026-09-12

## Purpose

This document is a current-state cleanup map for Arvin. It exists to prevent historical implementation slices, old migration boundaries, factory automation and product work from being treated as one active implementation path.

## Authority

- GitHub `main` is the executable source of truth.
- `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 is the active governance reference.
- `docs/ARVIN_PROJECT_STATE.md` is the current-state index.
- Historical and dated documents are evidence only unless explicitly promoted.

## Verified canonical product storage

`lib/services/task_store.dart` is the current canonical Task persistence path used by `lib/main.dart`.

- Storage key: `arvin.tasks`
- Home owns `List<Task>` state.
- Home saves through `TaskStore.save(...)`.
- Mutating feature services can use `TaskStore.mutate(...)`.
- No second Task model or second persistence key should be introduced.

## Verified transitional / historical migration layer

The following remain in the repository but are not the current Home write/read path:

- `lib/services/task_migration_reader.dart`
- `lib/services/task_migration_writer.dart`
- `lib/services/task_migration_adapter.dart`

They are still referenced by migration-oriented tests, integration seeding and historical documentation. They must not be described as the active Home persistence authority.

## Confirmed documentation drift

Several dated documents still describe `TaskMigrationReader`/`TaskMigrationWriter` as the active Home boundary even though current `main.dart` uses `TaskStore`. This is documentation drift, not proof that two runtime stores are active.

The repository should preserve these documents as historical evidence rather than deleting them blindly. New work must link to the current canonical state instead.

## Product conflict identified

PR #885 creates the Wave 2 coordinator:

- `lib/services/wave2_product_fast_track.dart`
- existing `HomeTaskEditorContextService`
- existing `TaskProjectAssignmentService`

The coordinator is not yet wired into the real Home `_add()` / `_edit()` path on `main`. Therefore the repository currently contains a prepared Wave 2 path alongside the older direct editor calls.

This is the immediate product integration boundary. It must be completed before adding another Task-entry abstraction.

## Quick Capture rule

`QuickCaptureDialog` and `QuickCaptureService` may remain because they reuse the canonical `Task` model and `TaskStore` persistence. They are not a separate storage system. They must not evolve into a second Task-entry persistence architecture.

## Factory rule

`.github/workflows/*factory*`, autonomous queue infrastructure and factory-only PRs are supporting mechanisms. They are not the product completion target. Factory changes must not outrank a product release blocker.

## Cleanup policy

1. Do not delete historical evidence solely because it is old.
2. Do not maintain two active architectural authorities.
3. Do not create another Task model, Task store or persistence key.
4. Prefer small reversible cleanup PRs.
5. Resolve documentation contradictions when touching the affected area.
6. Product work proceeds independently of factory perfection.
7. The next product-critical integration is Wave 2 Home Add/Edit wiring, followed by exact-head Analyze/Test/Build/Device Smoke.
