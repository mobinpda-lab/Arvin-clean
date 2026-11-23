# Arvin Core Foundation Audit — Issue #106

## Scope

This document records the first low-risk Core Foundation audit for `#106 - Core Foundation Stabilization` before any structural migration.

## Current repository structure

The current branch remains a Flutter application with a largely flat `lib/` structure. The expected target folders `lib/core/`, `lib/shared/`, and `lib/features/` are not yet established.

The current root contains architectural/runtime files such as `main.dart`, `backup_manager.dart`, model files, service files, and feature/page files.

## Findings

1. `lib/main.dart` currently contains `ArvinApp`, the `ArvinTask` model, and `TaskRepository` in the same file.
2. `TaskRepository` currently persists `ArvinTask` data through `SharedPreferences` using the `arvin.tasks` key.
3. `main.dart` also reads through `TaskMigrationReader`, while the save path still uses `TaskRepository`; this is an important migration boundary that should not be changed in the first audit commit.
4. `pubspec.yaml` currently uses `shared_preferences`, `saf`, `android_alarm_manager_plus`, and `flutter_local_notifications`.
5. Existing CI should remain unchanged. The existing `build.yml` already performs analyze, test, release APK build, and debug APK build.

## First low-risk action

Do not perform a broad architecture rewrite or move existing files yet.

The first implementation slice after this audit should isolate one small Core responsibility behind an explicit boundary, with tests and documentation updated in the same PR. Storage migration must remain incremental and backward compatible.

## Validation requirements

- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- Existing CI workflow remains unchanged.

## Governance

- Issue #106 is the tracking item.
- Work stays on `feature/core-foundation-stabilization`.
- No direct changes to `main`.
- No duplicate workflow is created.
- Structural migration is incremental; no full rewrite.
