# Arvin V1 — Clean Code Audit

Date: 2026-08-16
Branch: main

## Purpose

Record the first clean-code audit before production refactoring. This document intentionally does not change runtime behavior or UI.

## Confirmed findings

### 1. Legacy Home model remains in `lib/main.dart`

`ArvinTask` duplicates part of the canonical `Task` model. It contains id/title/description/follow-up/tags/archive/trash/completed, while the canonical `Task` also owns reminder, follow-ups, recurrence, checklist and timestamps.

Decision: do not delete `ArvinTask` yet. It is still part of the legacy compatibility boundary and must remain until Save Migration is proven.

### 2. Legacy repository remains in `lib/main.dart`

`TaskRepository` directly reads/writes the existing `arvin.tasks` SharedPreferences key. This is a second data-access path beside the migration boundary.

Decision: do not create another repository or storage key. The eventual Save Migration must move Home persistence to the canonical store through one controlled path.

### 3. Load migration boundary exists

`TaskMigrationReader` reads `arvin.tasks` and converts the data through `TaskMigrationAdapter` into canonical `Task` objects. The reader is intentionally read-only.

Decision: preserve this boundary and use it as the basis for Save Migration tests.

### 4. Home still converts canonical `Task` back into `ArvinTask`

This currently happens through `_legacyViewOf`. It is useful as a compatibility bridge but prevents Home from being fully unified.

Decision: replace this only as part of the planned Home Save Migration, not as an isolated refactor.

### 5. Backup/Restore still serializes the legacy Home representation

Home backup and restore currently operate on `ArvinTask` values. This must be audited before changing the Save boundary so user data remains preservable and recoverable.

## Refactoring order

1. Add/verify Save Boundary characterization tests.
2. Add Data Preservation tests.
3. Add Idempotency tests.
4. Audit Backup/Restore compatibility.
5. Introduce the smallest canonical Save path.
6. Switch Home writes to the canonical path.
7. Verify read-back.
8. Only after successful migration evidence, remove legacy Home model/repository.

## Explicit constraints

- No new Task model.
- No parallel repository.
- No parallel storage key.
- No dual-write.
- Do not change UI during this refactor.
- Preserve `arvin.tasks` until migration is proven.
- Run `flutter analyze`, `flutter test`, and the real GitHub Actions workflows after production changes.

## Next action

Proceed with Save Boundary audit and tests before production-code cleanup. DeepSeek cross-review is recommended before changing the persistence architecture.
