# Quick Capture UI — 2026-08-26

## Scope
Advance roadmap feature #11 from the already-merged canonical parser into a real Persian RTL Home capture flow without creating a second Task model, repository, database or storage key.

## Reused foundation
- `QuickCaptureService` remains the only parser.
- `QuickCaptureDialog` returns the existing canonical `Task` model.
- Persistence uses the existing Home `TaskMigrationWriter` / `arvin.tasks` path.
- Existing tasks are written through the lossless migration boundary, preserving canonical FollowUp/history fields.

## User flow
- Home AppBar exposes `ثبت سریع`.
- The compact Persian dialog accepts one short line with optional standalone `#tag` tokens.
- `ثبت` returns the canonical parsed Task.
- Empty input stays in the dialog and shows visible Persian feedback.
- The captured canonical Task is appended to the current canonical Home projection and persisted through `TaskMigrationWriter`.
- Home reloads from storage after persistence and shows visible success feedback.

## Regression coverage
- Dialog tests cover Persian title/tag parsing and empty-input feedback.
- Home integration test verifies the captured task is persisted with tags and `createdAt`.
- The same integration test verifies existing FollowUp history remains intact after Quick Capture persistence.

## Guardrails
- No Home redesign.
- No new storage key/database/repository.
- No second parser or Task model.
- No direct SharedPreferences write from the UI.

## Delivery gate
Keep PR #178 Draft until the completed Home-wired head passes exact-head `Arvin Build` and `Arvin Parallel Wave`. After merge, require post-merge main Build before promoting Quick Capture in the official scorecard.

Refs #174, #92, #153.
